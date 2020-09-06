import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';

/// A generic predicate function returning `true` or `false` for a given
/// [input] argument.
typedef Predicate = bool Function(String input);

/// Returns a parser that reads input of the specified [length], accepts
/// it if the [predicate] matches, or fails with the given [message].
Parser<String> predicate(int length, Predicate predicate, String message) {
  return PredicateParser(length, predicate, message);
}

/// A parser for a literal satisfying a predicate.
class PredicateParser extends Parser<String> {
  /// The length of the input to read.
  final int length;

  /// The predicate function testing the input.
  final Predicate predicate;

  /// The failure message in case of a miss-match.
  final String message;

  PredicateParser(this.length, this.predicate, this.message)
      : assert(length > 0, 'length must be positive');

  @override
  Result<String> parseOn(Context context) {
    final start = context.position;
    final stop = start + length;
    if (stop <= context.buffer.length) {
      final result = context.buffer.substring(start, stop);
      if (predicate(result)) {
        return context.success(result, stop);
      }
    }
    return context.failure(message);
  }

  @override
  int fastParseOn(String buffer, int position) {
    final stop = position + length;
    return stop <= buffer.length && predicate(buffer.substring(position, stop))
        ? stop
        : -1;
  }

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  PredicateParser copy() => PredicateParser(length, predicate, message);

  @override
  bool hasEqualProperties(PredicateParser other) =>
      super.hasEqualProperties(other) &&
      length == other.length &&
      predicate == other.predicate &&
      message == other.message;
}
