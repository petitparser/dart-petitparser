library petitparser.parsers.combinators.not;

import '../../core/contexts/context.dart';
import '../../core/contexts/result.dart';
import '../../core/parser.dart';
import '../actions/pick.dart';
import '../combinators/sequence.dart';
import '../predicates/any.dart';
import 'delegate.dart';

extension NotParserExtension<T> on Parser<T> {
  /// Returns a parser (logical not-predicate) that succeeds whenever the
  /// receiver fails, but never consumes input.
  ///
  /// For example, the parser `char('_').not().seq(identifier)` accepts
  /// identifiers that do not start with an underscore character. If the parser
  /// `char('_')` accepts the input, the negation and subsequently the
  /// complete parser fails. Otherwise the parser `identifier` is given the
  /// ability to process the complete identifier.
  Parser<void> not([String message = 'success not expected']) =>
      NotParser(this, message);

  /// Returns a parser that consumes any input token (character), but the
  /// receiver.
  ///
  /// For example, the parser `letter().neg()` accepts any input but a letter.
  /// The parser fails for inputs like `'a'` or `'Z'`, but succeeds for
  /// input like `'1'`, `'_'` or `'$'`.
  Parser<String> neg([String message = 'input not expected']) =>
      not(message).seq(any()).pick(1);
}

/// The not-predicate, a parser that succeeds whenever its delegate does not,
/// but consumes no input [Parr 1994, 1995].
class NotParser extends DelegateParser<void> {
  final String message;

  NotParser(Parser delegate, this.message)
      : assert(message != null, 'message must not be null'),
        super(delegate);

  @override
  Result<void> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isFailure) {
      return context.success(null);
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
  NotParser copy() => NotParser(delegate, message);

  @override
  bool hasEqualProperties(NotParser other) =>
      super.hasEqualProperties(other) && message == other.message;
}
