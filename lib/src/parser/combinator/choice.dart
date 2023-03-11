import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import 'list.dart';

/// Selects the strategy to report errors of a [ChoiceParser].
enum ChoiceStrategy {
  /// Reports the first parse failure observed.
  firstFailure,

  /// Reports the last parse failure observed (default).
  lastFailure,

  /// Reports the parser failure closest down in the input string, preferring
  /// earlier failures over later ones.
  closestFailure,

  /// Reports the parser failure farthest down in the input string, preferring
  /// later failures over earlier ones.
  farthestFailure,
}

extension ChoiceParserExtension on Parser {
  /// Returns a parser that accepts the receiver or [other]. The resulting
  /// parser returns the parse result of the receiver, if the receiver fails
  /// it returns the parse result of [other] (exclusive ordered choice).
  ///
  /// An optional [strategy] can be specified that determines what error the
  /// choice reports. By default the last failure is returned
  /// [ChoiceStrategy.lastFailure], but [ChoiceStrategy.farthestFailure] is
  /// another common choice that usually gives better default error messages.
  ///
  /// For example, the parser `letter().or(digit())` accepts a letter or a
  /// digit. An example where the order matters is the following choice between
  /// overlapping parsers: `letter().or(char('a'))`. In the example the parser
  /// `char('a')` will never be activated, because the input is always consumed
  /// `letter()`. This can be problematic if the author intended to attach a
  /// production action to `char('a')`.
  ///
  /// Due to https://github.com/dart-lang/language/issues/1557 the resulting
  /// parser cannot be properly typed. Please use [ChoiceIterableExtension]
  /// as a workaround: `[first, second].toChoiceParser()`.
  @useResult
  ChoiceParser or(Parser other, {ChoiceStrategy? strategy}) {
    final self = this;
    return self is ChoiceParser
        ? [...self.children, other]
            .toChoiceParser(strategy: strategy ?? self.strategy)
        : [this, other].toChoiceParser(strategy: strategy);
  }

  /// Convenience operator returning a parser that accepts the receiver or
  /// [other]. See [or] for details.
  @useResult
  ChoiceParser operator |(Parser other) => or(other);
}

extension ChoiceIterableExtension<R> on Iterable<Parser<R>> {
  /// Converts the parser in this iterable to a choice of parsers.
  @useResult
  ChoiceParser<R> toChoiceParser({ChoiceStrategy? strategy}) {
    switch (strategy) {
      case ChoiceStrategy.firstFailure:
        return _FirstFailureChoiceParser<R>(this);
      case null:
      case ChoiceStrategy.lastFailure:
        return _LastFailureChoiceParser<R>(this);
      case ChoiceStrategy.closestFailure:
        return _ClosestFailureChoiceParser<R>(this);
      case ChoiceStrategy.farthestFailure:
        return _FarthestFailureChoiceParser<R>(this);
    }
  }
}

/// A parser that uses the first parser that succeeds.
abstract class ChoiceParser<R> extends ListParser<R, R> {
  ChoiceParser(super.children)
      : assert(children.isNotEmpty, 'Choice parser cannot be empty');

  ChoiceStrategy get strategy;

  @override
  bool hasEqualProperties(ChoiceParser<R> other) =>
      super.hasEqualProperties(other) && strategy == other.strategy;

  @override
  ChoiceParser<R> copy() => children.toChoiceParser(strategy: strategy);
}

class _FirstFailureChoiceParser<R> extends ChoiceParser<R> {
  _FirstFailureChoiceParser(super.children);

  @override
  ChoiceStrategy get strategy => ChoiceStrategy.firstFailure;

  @override
  void parseOn(Context context) {
    final isCut = context.isCut;
    final position = context.position;
    var errorPosition = 0, errorMessage = '';
    for (var i = 0; i < children.length; i++) {
      context.isCut = false;
      context.position = position;
      children[i].parseOn(context);
      if (context.isSuccess || context.isCut) {
        context.isCut |= isCut;
        return;
      } else if (i == 0) {
        errorPosition = context.position;
        errorMessage = context.message;
      }
    }
    context.position = errorPosition;
    context.message = errorMessage;
    context.isCut |= isCut;
  }
}

class _LastFailureChoiceParser<R> extends ChoiceParser<R> {
  _LastFailureChoiceParser(super.children);

  @override
  ChoiceStrategy get strategy => ChoiceStrategy.lastFailure;

  @override
  void parseOn(Context context) {
    final isCut = context.isCut;
    final position = context.position;
    for (var i = 0; i < children.length; i++) {
      context.isCut = false;
      context.position = position;
      children[i].parseOn(context);
      if (context.isSuccess || context.isCut) {
        context.isCut |= isCut;
        return;
      }
    }
    context.isCut |= isCut;
  }
}

class _FarthestFailureChoiceParser<R> extends ChoiceParser<R> {
  _FarthestFailureChoiceParser(super.children);

  @override
  ChoiceStrategy get strategy => ChoiceStrategy.farthestFailure;

  @override
  void parseOn(Context context) {
    final isCut = context.isCut;
    final position = context.position;
    var errorPosition = position, errorMessage = '';
    for (var i = 0; i < children.length; i++) {
      context.isCut = false;
      context.position = position;
      children[i].parseOn(context);
      if (context.isSuccess || context.isCut) {
        context.isCut |= isCut;
        return;
      } else if (errorPosition <= context.position) {
        errorPosition = context.position;
        errorMessage = context.message;
      }
    }
    context.position = errorPosition;
    context.message = errorMessage;
    context.isCut |= isCut;
  }
}

class _ClosestFailureChoiceParser<R> extends ChoiceParser<R> {
  _ClosestFailureChoiceParser(super.children);

  @override
  ChoiceStrategy get strategy => ChoiceStrategy.closestFailure;

  @override
  void parseOn(Context context) {
    final isCut = context.isCut;
    final position = context.position;
    var errorPosition = position, errorMessage = '';
    for (var i = 0; i < children.length; i++) {
      context.isCut = false;
      context.position = position;
      children[i].parseOn(context);
      if (context.isSuccess || context.isCut) {
        context.isCut |= isCut;
        return;
      } else if (i == 0 || context.position <= errorPosition) {
        errorPosition = context.position;
        errorMessage = context.message;
      }
    }
    context.position = errorPosition;
    context.message = errorMessage;
    context.isCut |= isCut;
  }
}
