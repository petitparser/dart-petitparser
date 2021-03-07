import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import 'choice.dart';

/// Factory method to create a [FailureStrategy] from a choice-[parser]
/// and an initial parse [context].
typedef FailureStrategyFactory<T> = FailureStrategy<T> Function(
    ChoiceParser<T> parser, Context context);

/// Abstract failure strategy for choice parsers.
abstract class FailureStrategy<T> {
  /// Adds a generated parse [failure] from the provided [parser].
  void add(Parser<T> parser, Result<T> failure);

  /// Returns the resulting [Result] of the [ChoiceParser].
  ///
  /// This method is only called when the choice didn't succeed for any of its
  /// parsers, thus it is guaranteed that [add] has been called at least once.
  Result<T> get failure;
}

/// Reports the _first_ failure within an ordered choice.
FailureStrategyFactory<T> firstFailure<T>() =>
    (parser, context) => _FirstFailureStrategy<T>();

class _FirstFailureStrategy<T> extends FailureStrategy<T> {
  Result<T>? previous;

  @override
  void add(Parser<T> parser, Result<T> failure) => previous ??= failure;

  @override
  Result<T> get failure => previous!;
}

/// Reports the _last_ failure within an ordered choice.
FailureStrategyFactory<T> lastFailure<T>() =>
    (parser, context) => _LastFailureStrategy<T>();

class _LastFailureStrategy<T> extends FailureStrategy<T> {
  Result<T>? previous;

  @override
  void add(Parser<T> parser, Result<T> failure) => previous = failure;

  @override
  Result<T> get failure => previous!;
}

/// Reports the _nearest_ failure position within an ordered choice.
FailureStrategyFactory<T> nearestFailure<T>() =>
    (parser, context) => _NearestFailureStrategy<T>();

class _NearestFailureStrategy<T> extends FailureStrategy<T> {
  Result<T>? previous;

  @override
  void add(Parser<T> parser, Result<T> failure) {
    if (previous == null || failure.position < previous!.position) {
      previous = failure;
    }
  }

  @override
  Result<T> get failure => previous!;
}

/// Reports the _farthest_ failure position within an ordered choice.
FailureStrategyFactory<T> farthestFailure<T>() =>
    (parser, context) => _FarthestFailureStrategy<T>();

class _FarthestFailureStrategy<T> extends FailureStrategy<T> {
  Result<T>? previous;

  @override
  void add(Parser<T> parser, Result<T> failure) {
    if (previous == null || previous!.position < failure.position) {
      previous = failure;
    }
  }

  @override
  Result<T> get failure => previous!;
}
