import 'package:meta/meta.dart';

import '../core/parser.dart';
import '../parser/action/map.dart';
import '../parser/combinator/sequence.dart';
import '../parser/repeater/possessive.dart';
import '../parser/repeater/separated.dart';
import '../parser/repeater/unbounded.dart';
import 'result.dart';
import 'utils.dart';

/// Models a group of operators of the same precedence.
class ExpressionGroup<T> {
  @internal
  ExpressionGroup(this._loopback);

  /// Loopback parser used to establish the recursive expressions.
  final Parser<T> _loopback;

  /// Defines a new wrapper using [left] and [right] parsers, that are typically
  /// used for parenthesis. Evaluates the [callback] with the parsed `left`
  /// delimiter, the `value` and `right` delimiter.
  void wrapper<L, R>(Parser<L> left, Parser<R> right,
          T Function(L left, T value, R right) callback) =>
      _wrapper.add(seq3(left, _loopback, right).map3(callback));

  Parser<T> _buildWrapper(Parser<T> inner) => buildChoice([..._wrapper, inner]);

  final List<Parser<T>> _wrapper = [];

  /// Adds a prefix operator [parser]. Evaluates the [callback] with the parsed
  /// `operator` and `value`.
  void prefix<O>(Parser<O> parser, T Function(O operator, T value) callback) =>
      _prefix.add(parser
          .map((operator) => ExpressionResultPrefix<T, O>(operator, callback)));

  Parser<T> _buildPrefix(Parser<T> inner) => _prefix.isEmpty
      ? inner
      : seq2(buildChoice(_prefix).star(), inner).map2((prefix, value) =>
          prefix.reversed.fold(value, (each, result) => result.call(each)));

  final List<Parser<ExpressionResultPrefix<T, void>>> _prefix = [];

  /// Adds a postfix operator [parser]. Evaluates the [callback] with the parsed
  /// `value` and `operator`.
  void postfix<O>(Parser<O> parser, T Function(T value, O operator) callback) =>
      _postfix.add(parser.map(
          (operator) => ExpressionResultPostfix<T, O>(operator, callback)));

  Parser<T> _buildPostfix(Parser<T> inner) => _postfix.isEmpty
      ? inner
      : seq2(inner, buildChoice(_postfix).star()).map2((value, postfix) =>
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

  /// Adds a sequence of repeated and non-separated terms. Evaluates the
  /// [callback] with the list of parsed terms.
  void list(T Function(List<T> list) callback,
      {int min = 1, int max = unbounded}) {
    assert(_listCallback == null, 'At most one list callback can be specified');
    _listCallback = callback;
    _listMin = min;
    _listMax = max;
  }

  Parser<T> _buildList(Parser<T> inner) => _listCallback == null
      ? inner
      : inner.repeat(_listMin, _listMax).map(_listCallback!);

  T Function(List<T> list)? _listCallback;
  int _listMin = 1;
  int _listMax = unbounded;

  // Internal helper to build the group of parsers.
  @internal
  Parser<T> build(Parser<T> inner) => _buildList(_buildLeft(
      _buildRight(_buildPostfix(_buildPrefix(_buildWrapper(inner))))));
}
