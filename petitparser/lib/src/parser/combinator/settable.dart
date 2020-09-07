import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import '../combinator/delegate.dart';
import '../misc/failure.dart';

extension SettableParserExtension<T> on Parser<T> {
  /// Returns a parser that points to the receiver, but can be changed to point
  /// to something else at a later point in time.
  ///
  /// For example, the parser `letter().settable()` behaves exactly the same
  /// as `letter()`, but it can be replaced with another parser using
  /// [SettableParser.set].
  SettableParser<T> settable() => SettableParser<T>(this);
}

/// Returns a parser that is not defined, but that can be set at a later
/// point in time.
///
/// For example, the following code sets up a parser that points to itself
/// and that accepts a sequence of a's ended with the letter b.
///
///     final p = undefined();
///     p.set(char('a').seq(p).or(char('b')));
SettableParser<T> undefined<T>([String message = 'undefined parser']) =>
    failure<T>(message).settable();

/// A parser that is not defined, but that can be set at a later
/// point in time.
class SettableParser<T> extends DelegateParser<T> {
  SettableParser(Parser delegate) : super(delegate);

  /// Sets the receiver to delegate to [parser].
  void set(Parser<T> parser) => replace(children[0], parser);

  @override
  Result<T> parseOn(Context context) => delegate.parseOn(context) as Result<T>;

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  SettableParser<T> copy() => SettableParser<T>(delegate);
}
