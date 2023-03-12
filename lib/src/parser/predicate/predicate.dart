import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../../shared/types.dart';

/// Returns a parser that reads input of the specified [length], accepts
/// it if the [predicate] matches, or fails with the given [message].
@useResult
Parser<String> predicate(
        int length, Predicate<String> predicate, String message) =>
    PredicateParser(length, predicate, message);

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
  void parseOn(Context context) {
    final start = context.position;
    final stop = start + length;
    if (stop <= context.end) {
      final result = context.buffer.substring(start, stop);
      if (predicate(result)) {
        context.isSuccess = true;
        context.value = result;
        context.position = stop;
        return;
      }
    }
    context.isSuccess = false;
    context.message = message;
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
