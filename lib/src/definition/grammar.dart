import 'package:meta/meta.dart';

import '../core/parser.dart';
import 'reference.dart';
import 'resolve.dart';

/// Helper to conveniently define and build complex, recursive grammars using
/// plain Dart code.
///
/// To create a new grammar definition extend [GrammarDefinition] with the return
/// type of the [start] production. For every production define a method returning
/// a strongly typed [Parser]. The method [start] defines the entry production of
/// the grammar. To refer to another production use [ref0] with the function
/// reference as the argument.
///
/// Consider the following example to parse a comma-separated list of numbers
/// directly into a list of integers:
///
/// ```dart
/// class ListGrammarDefinition extends GrammarDefinition<List<int>> {
///   @override
///   // Refers to another production:
///   Parser<List<int>> start() => ref0(list).end();
///
///   Parser<List<int>> list() => [
///     // Recursively refers to element and list:
///     seq3(ref0(element), char(','), ref0(list))
///         .map3((first, _, rest) => [first, ...rest]),
///     ref0(element).map((value) => [value]),
///   ].toChoiceParser();
///
///   Parser<int> element() => digit().plus().flatten().map(int.parse);
/// }
/// ```
///
/// Since this is plain Dart code, common refactorings such as renaming a
/// production update all references correctly. Also code navigation and code
/// completion work as expected.
///
/// Productions can be parametrized. Define such productions with positional
/// arguments, and refer to them using [ref1], [ref2], ... where the number
/// corresponds to the argument count.
///
/// For example, to add a parametrized token production that trims whitespace,
/// update the productions in `ListGrammarDefinition`:
///
/// ```dart
///   Parser<List<int>> list() => [
///     // Refers to a parametrized production:
///     seq3(ref0(element), ref1(token, char(',')), ref0(list))
///         .map3((first, _, rest) => [first, ...rest]),
///     ref0(element).map((value) => [value]),
///   ].toChoiceParser();
///
///   // Refers to a parametrized production:
///   Parser<int> element() =>
///       ref1(token, digit().plus().flatten()).map(int.parse);
///
///   // Defines a parametrized production:
///   Parser<String> token(Parser<String> parser) => parser.trim();
/// ```
///
/// To get a runnable parser call [build] on the definition. It resolves
/// recursive references and returns an efficient parser that can be further
/// composed:
///
/// ```dart
/// final parser = ListGrammarDefinition().build();
///
/// parser.parse('1').value; // [1]
/// parser.parse('1,2,3').value; // [1, 2, 3]
/// ```
///
/// You can also build a parser starting from any specific production rule in
/// the grammar using [buildFrom]:
///
/// ```dart
/// final definition = ListGrammarDefinition();
/// final elementParser = definition.buildFrom(ref0(definition.element));
///
/// elementParser.parse('42').value; // 42
/// ```
@optionalTypeArgs
abstract class GrammarDefinition<R> {
  const new();

  /// Returns the starting production of this definition.
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
