import 'package:meta/meta.dart';

import '../core/parser.dart';
import 'reference.dart';

/// Helper to conveniently define and build complex, recursive grammars using
/// plain Dart code.
///
/// To create a new grammar definition subclass [GrammarDefinition]. For every
/// production create a new method returning the primitive parser defining it.
/// The method called [start] is supposed to return the start production of the
/// grammar. To refer to a production defined in the same definition use [ref0]
/// with the function reference as the argument.
///
/// Consider the following example to parse a list of numbers:
///
///     class ListGrammarDefinition extends GrammarDefinition {
///       start()   => ref0(list).end();
///       list()    => ref0(element) & char(',') & ref0(list)
///                  | ref0(element);
///       element() => digit().plus().flatten();
///     }
///
/// Since this is plain Dart code, common refactorings such as renaming a
/// production updates all references correctly. Also code navigation and code
/// completion works as expected.
///
/// To attach custom production actions you might want to further subclass your
/// grammar definition and override overriding the necessary productions defined
/// in the superclass:
///
///     class ListParserDefinition extends ListGrammarDefinition {
///       element() => super.element().map((value) => int.parse(value));
///     }
///
/// Note that productions can be parametrized. Define such productions with
/// positional arguments and reference to multiple instances by passing the
/// arguments to [ref1], [ref2], [ref3], [ref4], or [ref5] instead.
///
/// Consider extending the above grammar with a parametrized token production:
///
///     class TokenizedListGrammarDefinition extends GrammarDefinition {
///       start()   => ref0(list).end();
///       list()    => ref0(element) & ref1(token, char(',')) & ref0(list)
///                  | ref0(element);
///       element() => ref1(token, digit().plus());
///       token(p)  => p.token().trim();
///     }
///
/// To get a runnable parser call the [build] method on the definition. It
/// resolves recursive references and returns an efficient parser that can be
/// further composed. The optional `start` reference specifies a different
/// starting production into the grammar. The optional `arguments` parametrize
/// the start production.
///
///     final parser = new ListParserDefinition().build();
///
///     parser.parse('1');          // [1]
///     parser.parse('1,2,3');      // [1, 2, 3]
///
@optionalTypeArgs
abstract class GrammarDefinition {
  const GrammarDefinition();

  /// The starting production of this definition.
  Parser start();

  /// Reference to a production [callback] optionally parametrized with
  /// [arg1], [arg2], [arg3], [arg4], and [arg5].
  ///
  /// This function is deprecated because it doesn't work well in strong mode.
  /// Use [ref0], [ref1], [ref2], [ref3], [ref4], or [ref5] instead.
  @Deprecated('Use [ref0], [ref1], [ref2], ... instead.')
  Parser<T> ref<T>(Function callback,
      [dynamic arg1 = _undefined,
      dynamic arg2 = _undefined,
      dynamic arg3 = _undefined,
      dynamic arg4 = _undefined,
      dynamic arg5 = _undefined]) {
    final arguments = [arg1, arg2, arg3, arg4, arg5]
        .takeWhile((each) => each != _undefined)
        .toList(growable: false);
    return Reference<T>(callback, arguments);
  }

  /// Reference to a production [callback] without any parameters.
  Parser<T> ref0<T>(Parser<T> Function() callback) =>
      Reference<T>(callback, const []);

  /// Reference to a production [callback] parametrized with a single argument
  /// [arg1].
  Parser<T> ref1<T, A1>(Parser<T> Function(A1) callback, A1 arg1) =>
      Reference<T>(callback, [arg1]);

  /// Reference to a production [callback] parametrized with two arguments
  /// [arg1] and [arg2].
  Parser<T> ref2<T, A1, A2>(
          Parser<T> Function(A1, A2) callback, A1 arg1, A2 arg2) =>
      Reference<T>(callback, [arg1, arg2]);

  /// Reference to a production [callback] parametrized with tree arguments
  /// [arg1], [arg2], and [arg3].
  Parser<T> ref3<T, A1, A2, A3>(
          Parser<T> Function(A1, A2, A3) callback, A1 arg1, A2 arg2, A3 arg3) =>
      Reference<T>(callback, [arg1, arg2, arg3]);

  /// Reference to a production [callback] parametrized with four arguments
  /// [arg1], [arg2], [arg3], and [arg4].
  Parser<T> ref4<T, A1, A2, A3, A4>(Parser<T> Function(A1, A2, A3, A4) callback,
          A1 arg1, A2 arg2, A3 arg3, A4 arg4) =>
      Reference<T>(callback, [arg1, arg2, arg3, arg4]);

  /// Reference to a production [callback] parametrized with five arguments
  /// [arg1], [arg2], [arg3], [arg4], and [arg5].
  Parser<T> ref5<T, A1, A2, A3, A4, A5>(
          Parser<T> Function(A1, A2, A3, A4, A5) callback,
          A1 arg1,
          A2 arg2,
          A3 arg3,
          A4 arg4,
          A5 arg5) =>
      Reference<T>(callback, [arg1, arg2, arg3, arg4, arg5]);

  /// Builds a composite parser from this definition.
  ///
  /// The optional [start] reference specifies a different starting production
  /// into the grammar. The optional [arguments] list parametrizes the called
  /// production.
  Parser<T> build<T>({Function? start, List<Object> arguments = const []}) =>
      _resolve(Reference(start ?? this.start, arguments)) as Parser<T>;

  /// Internal helper to resolve a complete parser graph.
  Parser _resolve(Reference reference) {
    final mapping = <Reference, Parser>{};

    Parser _dereference(Reference reference) {
      var parser = mapping[reference];
      if (parser == null) {
        final references = {reference};
        parser = reference.resolve();
        while (parser is Reference) {
          if (references.contains(parser)) {
            throw StateError('Recursive references detected: $references');
          }
          references.add(parser);
          parser = parser.resolve();
        }
        for (final otherReference in references) {
          mapping[otherReference] = parser!;
        }
      }
      return parser!;
    }

    final todo = [_dereference(reference)];
    final seen = {...todo};

    while (todo.isNotEmpty) {
      final parent = todo.removeLast();
      for (var child in parent.children) {
        if (child is Reference) {
          final referenced = _dereference(child);
          parent.replace(child, referenced);
          child = referenced;
        }
        if (seen.add(child)) {
          todo.add(child);
        }
      }
    }

    return mapping[reference]!;
  }
}

class _Undefined {
  const _Undefined();
}

const _undefined = _Undefined();
