import '../../context/context.dart';
import '../../core/parser.dart';

/// A parser that uses a [Pattern] matcher for parsing.
///
/// This parser wraps [Pattern.matchAsPrefix] in a [Parser]. This works for
/// any implementation of [Pattern], but can lead to very inefficient parsers
/// when not used carefully.
class PatternParser extends Parser<Match> {
  PatternParser(this.pattern, this.message);

  /// The [Pattern] matcher this parser uses.
  final Pattern pattern;

  /// Error message to annotate parse failures with.
  final String message;

  @override
  void parseOn(Context context) {
    final result = pattern.matchAsPrefix(context.buffer, context.position);
    if (result != null) {
      context.isSuccess = true;
      context.value = result;
      context.position = result.end;
    } else {
      context.isSuccess = false;
      context.message = message;
    }
  }

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  PatternParser copy() => PatternParser(pattern, message);

  @override
  bool hasEqualProperties(PatternParser other) =>
      super.hasEqualProperties(other) &&
      pattern == other.pattern &&
      message == other.message;
}
