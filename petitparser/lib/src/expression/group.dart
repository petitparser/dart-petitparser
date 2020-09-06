import '../core/parser.dart';
import '../parser/action/map.dart';
import '../parser/combinator/choice.dart';
import '../parser/combinator/sequence.dart';
import '../parser/repeater/possessive.dart';
import '../parser/repeater/separated_by.dart';
import 'result.dart';

/// Models a group of operators of the same precedence.
class ExpressionGroup {
  final Parser _loopback;

  ExpressionGroup(this._loopback);

  /// Defines a new primitive or literal [parser]. Evaluates the optional
  /// [action].
  void primitive<V>(Parser<V> parser, [dynamic Function(V value)? action]) {
    _primitives.add(action != null ? parser.map(action) : parser);
  }

  Parser _buildPrimitive(Parser inner) {
    return _buildChoice(_primitives, inner);
  }

  final List<Parser> _primitives = [];

  /// Defines a new wrapper using [left] and [right] parsers, that are typically
  /// used for parenthesis. Evaluates the optional [action] with the parsed
  /// `left` delimiter, the `value` and `right` delimiter.
  void wrapper<O, V>(Parser<O> left, Parser<O> right,
      [dynamic Function(O left, V value, O right)? action]) {
    final callback = action ?? (left, value, right) => [left, value, right];
    _wrappers.add([left, _loopback, right]
        .toSequenceParser()
        .map((value) => callback(value[0], value[1], value[2])));
  }

  Parser _buildWrapper(Parser inner) {
    return _buildChoice([..._wrappers, inner], inner);
  }

  final List<Parser> _wrappers = [];

  /// Adds a prefix operator [parser]. Evaluates the optional [action] with the
  /// parsed `operator` and `value`.
  void prefix<O, V>(Parser<O> parser,
      [dynamic Function(O operator, V value)? action]) {
    final callback = action ?? (operator, value) => [operator, value];
    _prefix.add(parser.map((operator) => ExpressionResult(operator, callback)));
  }

  Parser _buildPrefix(Parser inner) {
    if (_prefix.isEmpty) {
      return inner;
    } else {
      return [_buildChoice(_prefix).star(), inner]
          .toSequenceParser()
          .map((tuple) {
        return tuple.first.reversed.fold(tuple.last, (value, result) {
          final ExpressionResult expressionResult = result;
          return expressionResult.callback(expressionResult.operator, value);
        });
      });
    }
  }

  final List<Parser> _prefix = [];

  /// Adds a postfix operator [parser]. Evaluates the optional [action] with the
  /// parsed `value` and `operator`.
  void postfix<O, V>(Parser<O> parser,
      [dynamic Function(V value, O operator)? action]) {
    final callback = action ?? (value, operator) => [value, operator];
    _postfix
        .add(parser.map((operator) => ExpressionResult(operator, callback)));
  }

  Parser _buildPostfix(Parser inner) {
    if (_postfix.isEmpty) {
      return inner;
    } else {
      return [inner, _buildChoice(_postfix).star()]
          .toSequenceParser()
          .map((tuple) {
        return tuple.last.fold(tuple.first, (value, result) {
          final ExpressionResult expressionResult = result;
          return expressionResult.callback(value, expressionResult.operator);
        });
      });
    }
  }

  final List<Parser> _postfix = [];

  /// Adds a right-associative operator [parser]. Evaluates the optional
  /// [action] with the parsed `left` term, `operator`, and `right` term.
  void right<O, V>(Parser<O> parser,
      [dynamic Function(V left, O operator, V right)? action]) {
    final callback =
        action ?? (left, operator, right) => [left, operator, right];
    _right.add(parser.map((operator) => ExpressionResult(operator, callback)));
  }

  Parser _buildRight(Parser inner) {
    if (_right.isEmpty) {
      return inner;
    } else {
      return inner.separatedBy(_buildChoice(_right)).map((sequence) {
        var result = sequence.last;
        for (var i = sequence.length - 2; i > 0; i -= 2) {
          final ExpressionResult expressionResult = sequence[i];
          result = expressionResult.callback(
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
      [dynamic Function(V left, O operator, V right)? action]) {
    final callback =
        action ?? (left, operator, right) => [left, operator, right];
    _left.add(parser.map((operator) => ExpressionResult(operator, callback)));
  }

  Parser _buildLeft(Parser inner) {
    if (_left.isEmpty) {
      return inner;
    } else {
      return inner.separatedBy(_buildChoice(_left)).map((sequence) {
        var result = sequence.first;
        for (var i = 1; i < sequence.length; i += 2) {
          final ExpressionResult expressionResult = sequence[i];
          result = expressionResult.callback(
              result, expressionResult.operator, sequence[i + 1]);
        }
        return result;
      });
    }
  }

  final List<Parser> _left = [];

  // helper to build an optimal choice parser
  Parser _buildChoice(List<Parser> parsers, [Parser? otherwise]) {
    if (parsers.isEmpty) {
      return otherwise!;
    } else if (parsers.length == 1) {
      return parsers.first;
    } else {
      return parsers.toChoiceParser();
    }
  }

  // helper to build the group of parsers
  Parser build(Parser inner) => _buildLeft(_buildRight(
      _buildPostfix(_buildPrefix(_buildWrapper(_buildPrimitive(inner))))));
}
