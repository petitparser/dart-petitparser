library petitparser.core.parsers.settable;

import '../combinators/delegate.dart';
import '../parser.dart';
import 'failure.dart';

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
  SettableParser(Parser<T> delegate) : super(delegate);

  /// Sets the receiver to delegate to [parser].
  void set(Parser<T> parser) => replace(children[0], parser);

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  SettableParser<T> copy() => SettableParser<T>(delegate);
}
