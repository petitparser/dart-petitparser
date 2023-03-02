import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';

/// Returns a parser that accepts any input element.
///
/// For example, `any()` succeeds and consumes any given letter. It only
/// fails for an empty input.
@useResult
Parser<String> any([String message = 'input expected']) => AnyParser(message);

/// A parser that accepts any input element.
class AnyParser extends Parser<String> {
  AnyParser(this.message);

  /// Error message to annotate parse failures with.
  final String message;

  @override
  void parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    if (position < buffer.length) {
      context.isSuccess = true;
      context.position++;
      context.value = buffer[position];
    } else {
      context.isSuccess = false;
      context.message = message;
    }
  }

  @override
  void fastParseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    if (position < buffer.length) {
      context.isSuccess = true;
      context.position++;
    } else {
      context.isSuccess = false;
      context.message = message;
    }
  }

  @override
  AnyParser copy() => AnyParser(message);

  @override
  bool hasEqualProperties(AnyParser other) =>
      super.hasEqualProperties(other) && message == other.message;
}
