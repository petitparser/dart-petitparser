library petitparser.core.predicates.predicate;

import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// A generic predicate function returning `true` or `false` for a given
/// [input] argument.
typedef bool Predicate(input);

/// Returns a parser that reads input of the specified [length], accepts
/// it if the [predicate] matches, or fails with the given [message].
Parser predicate(int length, Predicate predicate, String message) {
  return PredicateParser(length, predicate, message);
}

/// A parser for a literal satisfying a predicate.
class PredicateParser extends Parser {
  final int _length;
  final Predicate _predicate;
  final String _message;

  PredicateParser(this._length, this._predicate, this._message);

  @override
  Result parseOn(Context context) {
    final start = context.position;
    final stop = start + _length;
    if (stop <= context.buffer.length) {
      var result = context.buffer.substring(start, stop);
      if (_predicate(result)) {
        return context.success(result, stop);
      }
    }
    return context.failure(_message);
  }

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  Parser copy() => PredicateParser(_length, _predicate, _message);

  @override
  bool hasEqualProperties(Parser other) {
    return other is PredicateParser &&
        super.hasEqualProperties(other) &&
        _length == other._length &&
        _predicate == other._predicate &&
        _message == other._message;
  }
}
