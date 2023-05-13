import 'package:meta/meta.dart';

import '../core/parser.dart';
import '../parser/action/map.dart';
import '../parser/combinator/optional.dart';
import '../parser/combinator/sequence.dart';
import '../parser/repeater/possessive.dart';
import '../parser/repeater/separated.dart';
import 'result.dart';
import 'utils.dart';

/// Models a group of operators of the same precedence.
class ExpressionGroup<T> {
  @internal
  ExpressionGroup(this._loopback);

  /// Loopback parser used to establish the recursive expressions.
  final Parser<T> _loopback;

  /// Defines a new primitive or literal [parser].
  @Deprecated('Define primitive parsers directly on the builder using '
      '`ExpressionBuilder.primitive`')
  void primitive(Parser<T> parser) => primitives.add(parser);

  @internal
  final List<Parser<T>> primitives = [];

  /// Defines a new wrapper using [left] and [right] parsers, that are typically
  /// used for parenthesis. Evaluates the [callback] with the parsed `left`
  /// delimiter, the `value` and `right` delimiter.
  void wrapper<L, R>(Parser<L> left, Parser<R> right,
          T Function(L left, T value, R right) callback) =>
      _wrapper.add((left, _loopback, right).toSequenceParser().map3(callback));

  Parser<T> _buildWrapper(Parser<T> inner) => buildChoice([..._wrapper, inner]);

  final List<Parser<T>> _wrapper = [];

  /// Adds a prefix operator [parser]. Evaluates the [callback] with the parsed
  /// `operator` and `value`.
  void prefix<O>(Parser<O> parser, T Function(O operator, T value) callback) =>
      _prefix.add(parser
          .map((operator) => ExpressionResultPrefix<T, O>(operator, callback)));

  Parser<T> _buildPrefix(Parser<T> inner) => _prefix.isEmpty
      ? inner
      : (buildChoice(_prefix).star(), inner).toSequenceParser().map2(
          (prefix, value) =>
              prefix.reversed.fold(value, (each, result) => result.call(each)));

  final List<Parser<ExpressionResultPrefix<T, void>>> _prefix = [];

  /// Adds a postfix operator [parser]. Evaluates the [callback] with the parsed
  /// `value` and `operator`.
  void postfix<O>(Parser<O> parser, T Function(T value, O operator) callback) =>
      _postfix.add(parser.map(
          (operator) => ExpressionResultPostfix<T, O>(operator, callback)));

  Parser<T> _buildPostfix(Parser<T> inner) => _postfix.isEmpty
      ? inner
      : (inner, buildChoice(_postfix).star()).toSequenceParser().map2(
          (value, postfix) =>
              postfix.fold(value, (each, result) => result.call(each)));

  final List<Parser<ExpressionResultPostfix<T, void>>> _postfix = [];

  /// Adds a right-associative operator [parser]. Evaluates the [callback] with
  /// the parsed `left` term, `operator`, and `right` term.
  void right<O>(
          Parser<O> parser, T Function(T left, O operator, T right) callback) =>
      _right.add(parser
          .map((operator) => ExpressionResultInfix<T, O>(operator, callback)));

  Parser<T> _buildRight(Parser<T> inner) => _right.isEmpty
      ? inner
      : inner.plusSeparated(buildChoice(_right)).map((sequence) => sequence
          .foldRight((left, result, right) => result.call(left, right)));

  final List<Parser<ExpressionResultInfix<T, void>>> _right = [];

  /// Adds a left-associative operator [parser]. Evaluates the [callback] with
  /// the parsed `left` term, `operator`, and `right` term.
  void left<O>(
          Parser<O> parser, T Function(T left, O operator, T right) callback) =>
      _left.add(parser
          .map((operator) => ExpressionResultInfix<T, O>(operator, callback)));

  Parser<T> _buildLeft(Parser<T> inner) => _left.isEmpty
      ? inner
      : inner.plusSeparated(buildChoice(_left)).map((sequence) =>
          sequence.foldLeft((left, result, right) => result.call(left, right)));

  final List<Parser<ExpressionResultInfix<T, void>>> _left = [];

  /// Makes the group optional and instead return the provided [value].
  void optional(T value) {
    assert(!_optional, 'At most one optional value expected');
    _optionalValue = value;
    _optional = true;
  }

  Parser<T> _buildOptional(Parser<T> inner) =>
      _optional ? inner.optionalWith(_optionalValue) : inner;

  late T _optionalValue;
  bool _optional = false;

  // Internal helper to build the group of parsers.
  @internal
  Parser<T> build(Parser<T> inner) => _buildOptional(_buildLeft(
      _buildRight(_buildPostfix(_buildPrefix(_buildWrapper(inner))))));
}
