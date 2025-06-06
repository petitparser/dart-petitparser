import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../../shared/pragma.dart';
import '../../shared/types.dart';

/// Returns a parser that reads input of the specified [length], accepts
/// it if the [predicate] matches, or fails with the given [message].
@useResult
Parser<String> predicate(
  int length,
  Predicate<String> predicate,
  String message,
) => PredicateParser(length, predicate, message);

/// A parser for a literal satisfying a predicate.
class PredicateParser extends Parser<String> {
  PredicateParser(this.length, this.predicate, this.message)
    : assert(length > 0, 'length must be positive');

  /// The length of the input to read.
  final int length;

  /// The predicate function testing the input.
  final Predicate<String> predicate;

  /// Error message to annotate parse failures with.
  final String message;

  @override
  @noBoundsChecks
  Result<String> parseOn(Context context) {
    final start = context.position;
    final stop = start + length;
    if (stop <= context.buffer.length) {
      final result = context.buffer.substring(start, stop);
      if (predicate(result)) return context.success(result, stop);
    }
    return context.failure(message);
  }

  @override
  @noBoundsChecks
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
