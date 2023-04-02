import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import 'repeating.dart';
import 'unbounded.dart';

extension PossessiveRepeatingParserExtension<R> on Parser<R> {
  /// Returns a parser that accepts the receiver zero or more times. The
  /// resulting parser returns a list of the parse results of the receiver.
  ///
  /// This is a greedy and blind implementation that tries to consume as much
  /// input as possible and that does not consider what comes afterwards.
  ///
  /// For example, the parser `letter().star()` accepts the empty string or
  /// any sequence of letters and returns a possibly empty list of the parsed
  /// letters.
  @useResult
  Parser<List<R>> star() => repeat(0, unbounded);

  /// Returns a parser that accepts the receiver one or more times. The
  /// resulting parser returns a list of the parse results of the receiver.
  ///
  /// This is a greedy and blind implementation that tries to consume as much
  /// input as possible and that does not consider what comes afterwards.
  ///
  /// For example, the parser `letter().plus()` accepts any sequence of
  /// letters and returns a list of the parsed letters.
  @useResult
  Parser<List<R>> plus() => repeat(1, unbounded);

  /// Returns a parser that accepts the receiver exactly [count] times. The
  /// resulting parser returns a list of the parse results of the receiver.
  ///
  /// This is a greedy and blind implementation that tries to consume as much
  /// input as possible and that does not consider what comes afterwards.
  ///
  /// For example, the parser `letter().times(2)` accepts two letters and
  /// returns a list of the two parsed letters.
  @useResult
  Parser<List<R>> times(int count) => repeat(count, count);

  /// Returns a parser that accepts the receiver between [min] and [max] times.
  /// The resulting parser returns a list of the parse results of the receiver.
  ///
  /// This is a greedy and blind implementation that tries to consume as much
  /// input as possible and that does not consider what comes afterwards.
  ///
  /// For example, the parser `letter().repeat(2, 4)` accepts a sequence of
  /// two, three, or four letters and returns the accepted letters as a list.
  @useResult
  Parser<List<R>> repeat(int min, [int? max]) =>
      PossessiveRepeatingParser<R>(this, min, max ?? min);
}

/// A greedy parser that repeatedly parses between 'min' and 'max' instances of
/// its delegate.
class PossessiveRepeatingParser<R> extends RepeatingParser<R, List<R>> {
  PossessiveRepeatingParser(super.parser, super.min, super.max);

  @override
  void fullParseOn(Context context) {
    final elements = <R>[];
    while (elements.length < min) {
      delegate.parseOn(context);
      if (!context.isSuccess) return;
      elements.add(context.value as R);
    }
    final isCut = context.isCut;
    while (elements.length < max) {
      final position = context.position;
      context.isCut = false;
      delegate.parseOn(context);
      if (context.isSuccess) {
        elements.add(context.value as R);
      } else if (context.isCut) {
        return;
      } else {
        context.isSuccess = true;
        context.position = position;
        context.value = elements;
        context.isCut |= isCut;
        return;
      }
    }
    context.value = elements;
    context.isCut |= isCut;
  }

  @override
  void skipParseOn(Context context) {
    var count = 0;
    while (count < min) {
      delegate.parseOn(context);
      if (!context.isSuccess) return;
      count++;
    }
    final isCut = context.isCut;
    while (count < max) {
      final position = context.position;
      context.isCut = false;
      delegate.parseOn(context);
      if (context.isSuccess) {
        count++;
      } else if (context.isCut) {
        return;
      } else {
        context.isSuccess = true;
        context.position = position;
        context.isCut |= isCut;
        return;
      }
    }
    context.isCut |= isCut;
  }

  @override
  PossessiveRepeatingParser<R> copy() =>
      PossessiveRepeatingParser<R>(delegate, min, max);
}
