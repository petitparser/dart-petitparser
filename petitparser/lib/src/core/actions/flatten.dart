library petitparser.core.actions.flatten;

import '../combinators/delegate.dart';
import '../contexts/context.dart';
import '../contexts/result.dart';
import '../parser.dart';

/// A parser that answers a substring of the range its delegate
/// parses.
class FlattenParser extends DelegateParser<String> {
  FlattenParser(Parser delegate, [this.message]) : super(delegate);

  final String message;

  @override
  Result<String> parseOn(Context context) {
    if (message == null) {
      final result = delegate.parseOn(context);
      if (result.isSuccess) {
        final output =
            context.buffer.substring(context.position, result.position);
        return result.success(output);
      }
      return result.failure(result.message);
    } else {
      // If we have a message we can switch to fast mode.
      final position = delegate.fastParseOn(context.buffer, context.position);
      if (position < 0) {
        return context.failure(message);
      }
      final output = context.buffer.substring(context.position, position);
      return context.success(output, position);
    }
  }

  @override
  int fastParseOn(String buffer, int position) {
    return delegate.fastParseOn(buffer, position);
  }

  @override
  bool hasEqualProperties(FlattenParser other) =>
      super.hasEqualProperties(other) && message == other.message;

  @override
  FlattenParser copy() => FlattenParser(delegate, message);
}
