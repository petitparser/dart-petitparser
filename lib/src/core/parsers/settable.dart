library petitparser.core.parsers.settable;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/parser.dart';
import 'package:petitparser/src/core/parsers/failure.dart';

/// Returns a parser that is not defined, but that can be set at a later
/// point in time.
///
/// For example, the following code sets up a parser that points to itself
/// and that accepts a sequence of a's ended with the letter b.
///
///     var p = undefined();
///     p.set(char('a').seq(p).or(char('b')));
SettableParser undefined([String message = 'undefined parser']) {
  return failure(message).settable();
}

/// A parser that is not defined, but that can be set at a later
/// point in time.
class SettableParser extends DelegateParser {
  SettableParser(Parser delegate) : super(delegate);

  /// Sets the receiver to delegate to [parser].
  void set(Parser parser) => replace(children[0], parser);

  @override
  Parser copy() => new SettableParser(delegate);
}
