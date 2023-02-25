import 'package:meta/meta.dart';

import '../../context/context.dart';
import '../../core/parser.dart';
import '../utils/separated_list.dart';
import '../utils/sequential.dart';
import 'repeating.dart';
import 'unbounded.dart';

extension SeparatedRepeatingParserExtension<R> on Parser<R> {
  /// Returns a parser that consumes the receiver zero or more times separated
  /// by the [separator] parser. The resulting parser returns a [SeparatedList]
  /// containing collections of both the elements of type [R] as well as the
  /// separators of type [S].
  ///
  /// For example, the parser `digit().starSeparated(anyOf(',;'))` returns a
  /// parser that consumes input like `'1,2;3'` and that returns a
  /// [SeparatedList] with elements `['1', '2', '3']` as well as the separators
  /// [`,`, `;`].
  @useResult
  Parser<SeparatedList<R, S>> starSeparated<S>(Parser<S> separator) =>
      repeatSeparated<S>(separator, 0, unbounded);

  /// Returns a parser that consumes the receiver one or more times separated
  /// by the [separator] parser. The resulting parser returns a [SeparatedList]
  /// containing collections of both the elements of type [R] as well as the
  /// separators of type [S].
  @useResult
  Parser<SeparatedList<R, S>> plusSeparated<S>(Parser<S> separator) =>
      repeatSeparated<S>(separator, 1, unbounded);

  /// Returns a parser that consumes the receiver [count] times separated
  /// by the [separator] parser. The resulting parser returns a [SeparatedList]
  /// containing collections of both the elements of type [R] as well as the
  /// separators of type [S].
  @useResult
  Parser<SeparatedList<R, S>> timesSeparated<S>(
          Parser<S> separator, int count) =>
      repeatSeparated<S>(separator, count, count);

  /// Returns a parser that consumes the receiver between [min] and [max] times
  /// separated by the [separator] parser. The resulting parser returns a
  /// [SeparatedList] containing collections of both the elements of type [R] as
  /// well as the separators of type [S].
  @useResult
  Parser<SeparatedList<R, S>> repeatSeparated<S>(
          Parser<S> separator, int min, int max) =>
      SeparatedRepeatingParser<R, S>(this, separator, min, max);
}

/// A parser that consumes the [delegate] between [min] and [max] times
/// separated by the [separator] parser.
class SeparatedRepeatingParser<R, S>
    extends RepeatingParser<R, SeparatedList<R, S>>
    implements SequentialParser {
  SeparatedRepeatingParser(
      super.delegate, this.separator, super.min, super.max);

  /// Parser consuming input between the repeated elements.
  Parser<S> separator;

  @override
  void parseValueOn(Context context) {
    final elements = <R>[];
    final separators = <S>[];
    while (elements.length < min) {
      if (elements.isNotEmpty) {
        separator.parseOn(context);
        if (!context.isSuccess) return;
        separators.add(context.value);
      }
      delegate.parseOn(context);
      if (!context.isSuccess) return;
      elements.add(context.value);
    }
    while (elements.length < max) {
      final position = context.position;
      if (elements.isNotEmpty) {
        separator.parseOn(context);
        if (!context.isSuccess) {
          context.isSuccess = true;
          context.position = position;
          context.value = SeparatedList(elements, separators);
          return;
        }
        separators.add(context.value);
      }
      delegate.parseOn(context);
      if (!context.isSuccess) {
        if (elements.isNotEmpty) separators.removeLast();
        context.isSuccess = true;
        context.position = position;
        context.value = SeparatedList(elements, separators);
        return;
      }
      elements.add(context.value);
    }
    context.value = SeparatedList(elements, separators);
  }

  @override
  void parseSkipOn(Context context) {
    var count = 0;
    while (count < min) {
      if (count > 0) {
        separator.parseOn(context);
        if (!context.isSuccess) return;
      }
      delegate.parseOn(context);
      if (!context.isSuccess) return;
      count++;
    }
    while (count < max) {
      final position = context.position;
      if (count > 0) {
        separator.parseOn(context);
        if (!context.isSuccess) {
          context.isSuccess = true;
          context.position = position;
          return;
        }
      }
      delegate.parseOn(context);
      if (!context.isSuccess) {
        context.isSuccess = true;
        context.position = position;
        return;
      }
      count++;
    }
  }

  @override
  List<Parser> get children => [delegate, separator];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (separator == source) {
      separator = target as Parser<S>;
    }
  }

  @override
  SeparatedRepeatingParser<R, S> copy() =>
      SeparatedRepeatingParser<R, S>(delegate, separator, min, max);
}
