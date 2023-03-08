import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../context/failure.dart';
import '../../core/parser.dart';
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
  Parser<Failure<R>> not([String message = 'success not expected']) =>
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
/// but consumes no input [Parr 1994, 1995].
class NotParser<R> extends DelegateParser<R, Failure<R>> {
  NotParser(super.delegate, this.message);

  /// Error message to annotate parse failures with.
  final String message;

  @override
  void parseOn(Context context) {
    final position = context.position;
    final isSkip = context.isSkip;
    context.isSkip = true;
    delegate.parseOn(context);
    context.isSkip = isSkip;
    if (context.isSuccess) {
      context.isSuccess = false;
      context.message = message;
    } else {
      context.isSuccess = true;
      if (!isSkip) {
        context.value =
            Failure<R>(context.buffer, context.position, context.message);
      }
    }
    context.position = position;
  }

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  NotParser<R> copy() => NotParser<R>(delegate, message);

  @override
  bool hasEqualProperties(NotParser<R> other) =>
      super.hasEqualProperties(other) && message == other.message;
}
