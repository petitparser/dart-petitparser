import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
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
  /// `[',', ';']`.
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
  Result<SeparatedList<R, S>> parseOn(Context context) {
    var current = context;
    final elements = <R>[];
    final separators = <S>[];
    while (elements.length < min) {
      if (elements.isNotEmpty) {
        final separation = separator.parseOn(current);
        if (separation is Failure) return separation;
        current = separation;
        separators.add(separation.value);
      }
      final result = delegate.parseOn(current);
      if (result is Failure) return result;
      current = result;
      elements.add(result.value);
    }
    while (elements.length < max) {
      final previous = current;
      if (elements.isNotEmpty) {
        final separation = separator.parseOn(current);
        if (separation is Failure) break;
        current = separation;
        separators.add(separation.value);
      }
      final result = delegate.parseOn(current);
      if (result is Failure) {
        if (elements.isNotEmpty) separators.removeLast();
        return previous.success(SeparatedList(elements, separators));
      }
      current = result;
      elements.add(result.value);
    }
    return current.success(SeparatedList(elements, separators));
  }

  @override
  int fastParseOn(String buffer, int position) {
    var count = 0;
    var current = position;
    while (count < min) {
      if (count > 0) {
        final separation = separator.fastParseOn(buffer, current);
        if (separation < 0) return -1;
        current = separation;
      }
      final result = delegate.fastParseOn(buffer, current);
      if (result < 0) return -1;
      count++;
      current = result;
    }
    while (count < max) {
      final previous = current;
      if (count > 0) {
        final separation = separator.fastParseOn(buffer, current);
        if (separation < 0) break;
        current = separation;
      }
      final result = delegate.fastParseOn(buffer, current);
      if (result < 0) return previous;
      count++;
      current = result;
    }
    return current;
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
