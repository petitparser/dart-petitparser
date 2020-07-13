library petitparser.definition.grammar;

import 'package:meta/meta.dart';

import '../core/parser.dart';
import 'reference.dart';

/// Helper to conveniently define and build complex, recursive grammars using
/// plain Dart code.
///
/// To create a new grammar definition subclass [GrammarDefinition]. For every
/// production create a new method returning the primitive parser defining it.
/// The method called [start] is supposed to return the start production of the
/// grammar. To refer to a production defined in the same definition use [ref]
/// with the function reference as the first argument.
///
/// Consider the following example to parse a list of numbers:
///
///     class ListGrammarDefinition extends GrammarDefinition {
///       start()   => ref(list).end();
///       list()    => ref(element) & char(',') & ref(list)
///                  | ref(element);
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
/// arguments to [ref].
///
/// Consider extending the above grammar with a parametrized token production:
///
///     class TokenizedListGrammarDefinition extends GrammarDefinition {
///       start()   => ref(list).end();
///       list()    => ref(element) & ref(token, char(',')) & ref(list)
///                  | ref(element);
///       element() => ref(token, digit().plus());
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
abstract class GrammarDefinition {
  const GrammarDefinition();

  /// The starting production of this definition.
  Parser start();

  /// Returns a parser reference to a production defined by a [function].
  ///
  /// The optional arguments parametrize the called production.
  Parser ref(Function function,
      [Object arg1,
      Object arg2,
      Object arg3,
      Object arg4,
      Object arg5,
      Object arg6]) {
    final arguments = [arg1, arg2, arg3, arg4, arg5, arg6]
        .takeWhile((each) => each != null)
        .toList(growable: false);
    return Reference(function, arguments);
  }

  /// Builds a composite parser from this definition.
  ///
  /// The optional [start] reference specifies a different starting production
  /// into the grammar. The optional [arguments] list parametrizes the called
  /// production.
  Parser<T> build<T>({Function start, List arguments = const []}) {
    return _resolve(Reference(start ?? this.start, arguments));
  }

  /// Internal helper to resolve a complete parser graph.
  Parser _resolve(Reference reference) {
    final mapping = <Reference, Parser>{};

    Parser _dereference(Reference reference) {
      var parser = mapping[reference];
      if (parser == null) {
        final references = {reference};
        parser = reference.resolve();
        while (parser is Reference) {
          final Reference otherReference = parser;
          if (references.contains(otherReference)) {
            throw StateError('Recursive references detected: $references');
          }
          references.add(otherReference);
          parser = otherReference.resolve();
        }
        for (final otherReference in references) {
          mapping[otherReference] = parser;
        }
      }
      return parser;
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

    return mapping[reference];
  }
}
