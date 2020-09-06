import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import 'list.dart';

extension ChoiceParserExtension<T> on Parser<T> {
  /// Returns a parser that accepts the receiver or [other]. The resulting
  /// parser returns the parse result of the receiver, if the receiver fails
  /// it returns the parse result of [other] (exclusive ordered choice).
  ///
  /// For example, the parser `letter().or(digit())` accepts a letter or a
  /// digit. An example where the order matters is the following choice between
  /// overlapping parsers: `letter().or(char('a'))`. In the example the parser
  /// `char('a')` will never be activated, because the input is always consumed
  /// `letter()`. This can be problematic if the author intended to attach a
  /// production action to `char('a')`.
  Parser<dynamic> or(Parser<dynamic> other) => this is ChoiceParser
      ? ChoiceParser<dynamic>([...children, other])
      : ChoiceParser<dynamic>([this, other]);

  /// Convenience operator returning a parser that accepts the receiver or
  /// [other]. See [or] for details.
  Parser operator |(Parser other) => or(other);
}

extension ChoiceIterableExtension<T> on Iterable<Parser<T>> {
  /// Converts the parser in this iterable to a choice of parsers.
  Parser toChoiceParser() => ChoiceParser<T>(this);
}

/// A parser that uses the first parser that succeeds.
class ChoiceParser<T> extends ListParser<T, T> {
  ChoiceParser(Iterable<Parser<T>> children) : super(children) {
    if (children.isEmpty) {
      throw ArgumentError('Choice parser cannot be empty.');
    }
  }

  @override
  Result<T> parseOn(Context context) {
    Result<T>? result;
    for (var i = 0; i < children.length; i++) {
      result = children[i].parseOn(context);
      if (result.isSuccess) {
        return result;
      }
    }
    return result!;
  }

  @override
  int fastParseOn(String buffer, int position) {
    var result = -1;
    for (var i = 0; i < children.length; i++) {
      result = children[i].fastParseOn(buffer, position);
      if (result >= 0) {
        return result;
      }
    }
    return result;
  }

  @override
  ChoiceParser<T> copy() => ChoiceParser<T>(children);
}
