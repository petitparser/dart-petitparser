import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../predicate/any.dart';
import 'delegate.dart';
import 'skip.dart';

extension NotParserExtension<R> on Parser<R> {
  /// Returns a parser (logical not-predicate) that succeeds with the [Failure]
  /// whenever the receiver fails, but never consumes input.
  ///
  /// For example, the parser `char('_').not().seq(identifier)` accepts
  /// identifiers that do not start with an underscore character. If the parser
  /// `char('_')` accepts the input, the negation and subsequently the
  /// complete parser fails. Otherwise the parser `identifier` is given the
  /// ability to process the complete identifier.
  @useResult
  Parser<Failure> not([String message = 'success not expected']) =>
      NotParser(this, message);

  /// Returns a parser that consumes any input token (character), but the
  /// receiver.
  ///
  /// For example, the parser `letter().neg()` accepts any input but a letter.
  /// The parser fails for inputs like `'a'` or `'Z'`, but succeeds for
  /// input like `'1'`, `'_'` or `'$'`.
  @useResult
  Parser<String> neg([String message = 'input not expected']) =>
      any().skip(before: not(message));
}

/// The not-predicate, a parser that succeeds whenever its delegate does not,
/// but consumes no input.
class NotParser<R> extends DelegateParser<R, Failure> {
  NotParser(super.delegate, this.message);

  /// Error message to annotate parse failures with.
  final String message;

  @override
  Result<Failure> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result is Failure) {
      return context.success(result);
    } else {
      return context.failure(message);
    }
  }

  @override
  int fastParseOn(String buffer, int position) {
    final result = delegate.fastParseOn(buffer, position);
    return result < 0 ? position : -1;
  }

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  NotParser<R> copy() => NotParser<R>(delegate, message);

  @override
  bool hasEqualProperties(NotParser<R> other) =>
      super.hasEqualProperties(other) && message == other.message;
}
