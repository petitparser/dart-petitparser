import '../../context/context.dart';
import '../../context/failure.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../action/cast.dart';
import '../action/pick.dart';
import '../combinator/sequence.dart';
import '../predicate/any.dart';
import 'delegate.dart';

extension NotParserExtension<T> on Parser<T> {
  /// Returns a parser (logical not-predicate) that succeeds with the [Failure]
  /// whenever the receiver fails, but never consumes input.
  ///
  /// For example, the parser `char('_').not().seq(identifier)` accepts
  /// identifiers that do not start with an underscore character. If the parser
  /// `char('_')` accepts the input, the negation and subsequently the
  /// complete parser fails. Otherwise the parser `identifier` is given the
  /// ability to process the complete identifier.
  Parser<Failure<T>> not([String message = 'success not expected']) =>
      NotParser(this, message);

  /// Returns a parser that consumes any input token (character), but the
  /// receiver.
  ///
  /// For example, the parser `letter().neg()` accepts any input but a letter.
  /// The parser fails for inputs like `'a'` or `'Z'`, but succeeds for
  /// input like `'1'`, `'_'` or `'$'`.
  Parser<String> neg([String message = 'input not expected']) =>
      [not(message), any()].toSequenceParser().pick(1).cast<String>();
}

/// The not-predicate, a parser that succeeds whenever its delegate does not,
/// but consumes no input [Parr 1994, 1995].
class NotParser<T> extends DelegateParser<Failure<T>> {
  final String message;

  NotParser(Parser delegate, this.message) : super(delegate);

  @override
  Result<Failure<T>> parseOn(Context context) {
    final result = delegate.parseOn(context);
    if (result.isFailure) {
      return context.success(result as Failure<T>);
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
  NotParser<T> copy() => NotParser<T>(delegate, message);

  @override
  bool hasEqualProperties(NotParser<T> other) =>
      super.hasEqualProperties(other) && message == other.message;
}
