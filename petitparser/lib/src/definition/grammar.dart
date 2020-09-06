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
/// with the function reference as the first argument.
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
/// arguments to [ref1], [ref2], or [ref3].
///
/// Consider extending the above grammar with a parametrized token production:
///
///     class TokenizedListGrammarDefinition extends GrammarDefinition {
///       start()   => ref0(list).end();
///       list()    => ref0(element) & ref0(token, char(',')) & ref0(list)
///                  | ref0(element);
///       element() => ref0(token, digit().plus());
///       token(p)  => p.token().trim();
///     }
///
/// To get a runnable parser call the [build] method on the definition. It
/// resolves recursive references and returns an efficient parser that can be
/// further composed. The optional `start` reference specifies a different
/// starting production into the grammar. The optional `arguments` parametrize
/// the start production.
///
///     let parser = new ListParserDefinition().build();
///
///     parser.parse('1');          // [1]
///     parser.parse('1,2,3');      // [1, 2, 3]
///
@optionalTypeArgs
abstract class GrammarDefinition<T> {
  const GrammarDefinition();

  /// The starting production of this definition.
  Parser<T> start();

  /// Returns a parser reference to a production defined by a [function].
  @Deprecated('Use properly typed ref0, ref1, ref2, and ref3 instead.')
  Parser<R> ref<R>(Function function,
      [dynamic arg1, dynamic arg2, dynamic arg3]) {
    final arguments = [arg1, arg2, arg3]
        .takeWhile((each) => each != null)
        .toList(growable: false);
    return Reference<R>(function, arguments);
  }

  /// Returns a parser reference to a production defined by a [function]
  /// (without arguments).
  Parser<R> ref0<R>(
    Parser<R> Function() function,
  ) =>
      Reference<R>(function, const []);

  /// Returns a parser reference to a production defined by a [function]
  /// (with 1 argument).
  Parser<R> ref1<R, A1>(
    Parser<R> Function(A1 arg1) function,
    A1 arg1,
  ) =>
      Reference<R>(function, [arg1]);

  /// Returns a parser reference to a production defined by a [function]
  /// (with 2 arguments).
  Parser<R> ref2<R, A1, A2>(
    Parser<R> Function(A1 arg1, A2 arg2) function,
    A1 arg1,
    A2 arg2,
  ) =>
      Reference<R>(function, [arg1, arg2]);

  /// Returns a parser reference to a production defined by a [function]
  /// (with 3 arguments).
  Parser<R> ref3<R, A1, A2, A3>(
    Parser<R> Function(A1 arg1, A2 arg2, A3 arg3) function,
    A1 arg1,
    A2 arg2,
    A3 arg3,
  ) =>
      Reference<R>(function, [arg1, arg2, arg3]);

  /// Builds a composite parser from this definition.
  ///
  /// The optional [start] reference specifies a different starting production
  /// into the grammar. The optional [arguments] list parametrizes the called
  /// production.
  Parser<R> build<R>({Function? start, List arguments = const []}) =>
      _resolve<R>(Reference<R>(start ?? this.start, arguments));

  /// Internal helper to resolve a complete parser graph.
  Parser<R> _resolve<R>(Reference<R> reference) {
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
        if (!seen.contains(child)) {
          seen.add(child);
          todo.add(child);
        }
      }
    }

    return mapping[reference] as Parser<R>;
  }
}
