import 'package:meta/meta.dart';

import '../core/parser.dart';
import 'reference.dart';
import 'resolve.dart';

/// Helper to conveniently define and build complex, recursive grammars using
/// plain Dart code.
///
/// To create a new grammar definition subclass [GrammarDefinition]. For every
/// production create a new method returning the primitive parser defining it.
/// The method called [start] is supposed to return the start production of the
/// grammar (that can be customized when building the parsers). To refer to
/// another production use [ref0] with the function reference as the argument.
///
/// Consider the following example to parse a list of numbers:
///
/// ```dart
/// class ListGrammarDefinition extends GrammarDefinition {
///   Parser start()   => ref0(list).end();
///   Parser list()    => ref0(element) & char(',') & ref0(list)
///                     | ref0(element);
///   Parser element() => digit().plus().flatten();
/// }
/// ```
///
/// Since this is plain Dart code, common refactorings such as renaming a
/// production updates all references correctly. Also code navigation and code
/// completion works as expected.
///
/// To attach custom production actions you might want to further subclass your
/// grammar definition and override overriding the necessary productions defined
/// in the superclass:
///
/// ```dart
/// class ListParserDefinition extends ListGrammarDefinition {
///   Parser element() => super.element().map((value) => int.parse(value));
/// }
/// ```
///
/// Note that productions can be parametrized. Define such productions with
/// positional arguments, and refer to them using [ref1], [ref2], ... where
/// the number corresponds to the argument count.
///
/// Consider extending the above grammar with a parametrized token production:
///
/// ```dart
/// class TokenizedListGrammarDefinition extends GrammarDefinition {
///   Parser start() => ref0(list).end();
///   Parser list() => ref0(element) & ref1(token, char(',')) & ref0(list)
///                  | ref0(element);
///   Parser element() => ref1(token, digit().plus());
///   Parser token(Parser parser)  => parser.token().trim();
/// }
/// ```
///
/// To get a runnable parser call the [build] method on the definition. It
/// resolves recursive references and returns an efficient parser that can be
/// further composed. The optional `start` reference specifies a different
/// starting production within the grammar. The optional `arguments`
/// parametrize the start production.
///
/// ```dart
/// final parser = new ListParserDefinition().build();
///
/// parser.parse('1');          // [1]
/// parser.parse('1,2,3');      // [1, 2, 3]
/// ```
@optionalTypeArgs
abstract class GrammarDefinition<R> {
  const GrammarDefinition();

  /// The starting production of this definition.
  Parser<R> start();

  /// Builds the default composite parser starting at [start].
  ///
  /// To start the building at a different production use [buildFrom].
  @useResult
  Parser<R> build() => buildFrom<R>(ref0(start));

  /// Builds a composite parser starting with the specified [parser].
  ///
  /// As argument either pass a reference to a production in this definition, or
  /// any other parser using productions in this definition.
  @useResult
  Parser<T> buildFrom<T>(Parser<T> parser) => resolve<T>(parser);
}
