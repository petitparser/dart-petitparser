import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import 'choice_strategies.dart';
import 'list.dart';

extension ChoiceParserExtension on Parser {
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
  Parser or(Parser other) => this is ChoiceParser
      ? ChoiceParser([...children, other])
      : ChoiceParser([this, other]);

  /// Convenience operator returning a parser that accepts the receiver or
  /// [other]. See [or] for details.
  Parser operator |(Parser other) => or(other);
}

extension ChoiceIterableExtension<T> on Iterable<Parser<T>> {
  /// Converts the parser in this iterable to a choice of parsers.
  Parser<T> toChoiceParser(
          {FailureStrategyFactory<T>? failureStrategyFactory}) =>
      ChoiceParser<T>(this, failureStrategyFactory: failureStrategyFactory);
}

/// A parser that uses the first parser that succeeds.
class ChoiceParser<T> extends ListParser<T> {
  ChoiceParser(Iterable<Parser<T>> children,
      {FailureStrategyFactory<T>? failureStrategyFactory})
      : _failureStrategyFactory = failureStrategyFactory ?? lastFailure(),
        super(children) {
    if (children.isEmpty) {
      throw ArgumentError('Choice parser cannot be empty.');
    }
  }

  /// Factory that creates a failure resolution strategy.
  final FailureStrategyFactory<T> _failureStrategyFactory;

  @override
  Result<T> parseOn(Context context) {
    final failureStrategy = _failureStrategyFactory(this, context);
    for (var i = 0; i < children.length; i++) {
      final parser = children[i] as Parser<T>;
      final result = parser.parseOn(context);
      if (result.isSuccess) {
        return result;
      }
      failureStrategy.add(parser, result);
    }
    return failureStrategy.failure;
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
  ChoiceParser<T> copy() => ChoiceParser<T>(children as List<Parser<T>>,
      failureStrategyFactory: _failureStrategyFactory);
}
