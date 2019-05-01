library petitparser.core.expression.group;

import 'package:petitparser/src/core/combinators/choice.dart';
import 'package:petitparser/src/core/combinators/sequence.dart';
import 'package:petitparser/src/core/expression/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// Models a group of operators of the same precedence.
class ExpressionGroup {
  /// Defines a new primitive or literal [parser]. Evaluates the optional
  /// [action].
  void primitive<V>(Parser<V> parser, [Object Function(V value) action]) {
    _primitives.add(action != null ? parser.map(action) : parser);
  }

  Parser _buildPrimitive(Parser inner) {
    return _buildChoice(_primitives, inner);
  }

  final List<Parser> _primitives = [];

  /// Adds a prefix operator [parser]. Evaluates the optional [action] with the
  /// parsed `operator` and `value`.
  void prefix<O, V>(Parser<O> parser,
      [Object Function(O operator, V value) action]) {
    action ??= (operator, value) => [operator, value];
    _prefix.add(parser.map((operator) => ExpressionResult(operator, action)));
  }

  Parser _buildPrefix(Parser inner) {
    if (_prefix.isEmpty) {
      return inner;
    } else {
      return SequenceParser([_buildChoice(_prefix).star(), inner]).map((tuple) {
        return tuple.first.reversed.fold(tuple.last, (value, result) {
          final ExpressionResult expressionResult = result;
          return expressionResult.action(expressionResult.operator, value);
        });
      });
    }
  }

  final List<Parser> _prefix = [];

  /// Adds a postfix operator [parser]. Evaluates the optional [action] with the
  /// parsed `value` and `operator`.
  void postfix<O, V>(Parser<O> parser,
      [Object Function(V value, O operator) action]) {
    action ??= (value, operator) => [value, operator];
    _postfix.add(parser.map((operator) => ExpressionResult(operator, action)));
  }

  Parser _buildPostfix(Parser inner) {
    if (_postfix.isEmpty) {
      return inner;
    } else {
      return SequenceParser([inner, _buildChoice(_postfix).star()])
          .map((tuple) {
        return tuple.last.fold(tuple.first, (value, result) {
          final ExpressionResult expressionResult = result;
          return expressionResult.action(value, expressionResult.operator);
        });
      });
    }
  }

  final List<Parser> _postfix = [];

  /// Adds a right-associative operator [parser]. Evaluates the optional
  /// [action] with the parsed `left` term, `operator`, and `right` term.
  void right<O, V>(Parser<O> parser,
      [Object Function(V left, O operator, V right) action]) {
    action ??= (left, operator, right) => [left, operator, right];
    _right.add(parser.map((operator) => ExpressionResult(operator, action)));
  }

  Parser _buildRight(Parser inner) {
    if (_right.isEmpty) {
      return inner;
    } else {
      return inner.separatedBy(_buildChoice(_right)).map((sequence) {
        var result = sequence.last;
        for (var i = sequence.length - 2; i > 0; i -= 2) {
          final ExpressionResult expressionResult = sequence[i];
          result = expressionResult.action(
              sequence[i - 1], expressionResult.operator, result);
        }
        return result;
      });
    }
  }

  final List<Parser> _right = [];

  /// Adds a left-associative operator [parser]. Evaluates the optional [action]
  /// with the parsed `left` term, `operator`, and `right` term.
  void left<O, V>(Parser<O> parser,
      [Object Function(V left, O operator, V right) action]) {
    action ??= (left, operator, right) => [left, operator, right];
    _left.add(parser.map((operator) => ExpressionResult(operator, action)));
  }

  Parser _buildLeft(Parser inner) {
    if (_left.isEmpty) {
      return inner;
    } else {
      return inner.separatedBy(_buildChoice(_left)).map((sequence) {
        var result = sequence.first;
        for (var i = 1; i < sequence.length; i += 2) {
          final ExpressionResult expressionResult = sequence[i];
          result = expressionResult.action(
              result, expressionResult.operator, sequence[i + 1]);
        }
        return result;
      });
    }
  }

  final List<Parser> _left = [];

  // helper to build an optimal choice parser
  Parser _buildChoice(List<Parser> parsers, [Parser otherwise]) {
    if (parsers.isEmpty) {
      return otherwise;
    } else if (parsers.length == 1) {
      return parsers.first;
    } else {
      return ChoiceParser(parsers);
    }
  }

  // helper to build the group of parsers
  Parser build(Parser inner) {
    return _buildLeft(
        _buildRight(_buildPostfix(_buildPrefix(_buildPrimitive(inner)))));
  }
}
