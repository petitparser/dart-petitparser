import 'package:meta/meta.dart';

import '../core/parser.dart';
import '../parser/action/map.dart';
import '../parser/combinator/choice.dart';
import '../parser/combinator/sequence.dart';
import '../parser/repeater/possessive.dart';
import '../parser/repeater/separated_by.dart';
import 'result.dart';

/// Models a group of operators of the same precedence.
class ExpressionGroup<T> {
  @internal
  ExpressionGroup(this.loopback);

  @internal
  final Parser<T> loopback;

  /// Defines a new primitive or literal [parser].
  void primitive(Parser<T> parser) => primitives.add(parser);

  @internal
  Parser<T> buildPrimitive(Parser<T> inner) => buildChoice(primitives, inner);

  @internal
  final List<Parser<T>> primitives = [];

  /// Defines a new wrapper using [left] and [right] parsers, that are typically
  /// used for parenthesis. Evaluates the [callback] with the parsed `left`
  /// delimiter, the `value` and `right` delimiter.
  void wrapper<O>(Parser<O> left, Parser<O> right,
          T Function(O left, T value, O right) callback) =>
      wrappers.add([left, loopback, right].toSequenceParser().map(
          (value) => callback(value[0] as O, value[1] as T, value[2] as O)));

  @internal
  Parser<T> buildWrapper(Parser<T> inner) => buildChoice([...wrappers, inner]);

  @internal
  final List<Parser<T>> wrappers = [];

  /// Adds a prefix operator [parser]. Evaluates the [callback] with the parsed
  /// `operator` and `value`.
  void prefix<O>(Parser<O> parser, T Function(O operator, T value) callback) =>
      prefixes.add(parser
          .map((operator) => ExpressionResultPrefix<T, O>(operator, callback)));

  @internal
  Parser<T> buildPrefix(Parser<T> inner) {
    if (prefixes.isEmpty) {
      return inner;
    } else {
      return [buildChoice(prefixes).star(), inner].toSequenceParser().map(
          (tuple) => (tuple.first as List).reversed.fold(tuple.last as T,
              (value, result) => (result as ExpressionResultPrefix)(value)));
    }
  }

  @internal
  final List<Parser<ExpressionResultPrefix>> prefixes = [];

  /// Adds a postfix operator [parser]. Evaluates the [callback] with the parsed
  /// `value` and `operator`.
  void postfix<O>(Parser<O> parser, T Function(T value, O operator) callback) =>
      postfixes.add(parser.map(
          (operator) => ExpressionResultPostfix<T, O>(operator, callback)));

  @internal
  Parser<T> buildPostfix(Parser<T> inner) {
    if (postfixes.isEmpty) {
      return inner;
    } else {
      return [inner, buildChoice(postfixes).star()].toSequenceParser().map(
          (tuple) => (tuple.last as List).fold(tuple.first as T,
              (value, result) => (result as ExpressionResultPostfix)(value)));
    }
  }

  @internal
  final List<Parser<ExpressionResultPostfix>> postfixes = [];

  /// Adds a right-associative operator [parser]. Evaluates the [callback] with
  /// the parsed `left` term, `operator`, and `right` term.
  void right<O>(
          Parser<O> parser, T Function(T left, O operator, T right) callback) =>
      rights.add(parser
          .map((operator) => ExpressionResultInfix<T, O>(operator, callback)));

  @internal
  Parser<T> buildRight(Parser<T> inner) {
    if (rights.isEmpty) {
      return inner;
    } else {
      return inner.separatedBy(buildChoice(rights)).map((sequence) {
        var result = sequence.last;
        for (var i = sequence.length - 2; i > 0; i -= 2) {
          result =
              (sequence[i] as ExpressionResultInfix)(sequence[i - 1], result);
        }
        return result;
      });
    }
  }

  @internal
  final List<Parser<ExpressionResultInfix>> rights = [];

  /// Adds a left-associative operator [parser]. Evaluates the [callback] with
  /// the parsed `left` term, `operator`, and `right` term.
  void left<O>(
          Parser<O> parser, T Function(T left, O operator, T right) callback) =>
      lefts.add(parser
          .map((operator) => ExpressionResultInfix<T, O>(operator, callback)));

  @internal
  Parser<T> buildLeft(Parser<T> inner) {
    if (lefts.isEmpty) {
      return inner;
    } else {
      return inner.separatedBy(buildChoice(lefts)).map((sequence) {
        var result = sequence.first;
        for (var i = 1; i < sequence.length; i += 2) {
          result =
              (sequence[i] as ExpressionResultInfix)(result, sequence[i + 1]);
        }
        return result;
      });
    }
  }

  @internal
  final List<Parser<ExpressionResultInfix>> lefts = [];

  // Internal helper to build the group of parsers.
  @internal
  Parser<T> build(Parser<T> inner) => buildLeft(buildRight(
      buildPostfix(buildPrefix(buildWrapper(buildPrimitive(inner))))));
}

// Internal helper to build an optimal choice parser.
Parser<T> buildChoice<T>(List<Parser<T>> parsers, [Parser<T>? otherwise]) {
  if (parsers.isEmpty) {
    return otherwise!;
  } else if (parsers.length == 1) {
    return parsers.first;
  } else {
    return parsers.toChoiceParser();
  }
}
