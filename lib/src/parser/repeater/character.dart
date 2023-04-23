import 'package:meta/meta.dart';

import '../../../parser.dart';
import '../../context/context.dart';
import '../../context/result.dart';
import '../character/constant.dart';

extension RepeatingCharacterParserExtension on Parser<String> {
  /// Returns a parser that accepts the receiver zero or more times. The
  /// resulting parser returns the consumed input string.
  ///
  /// This implementation is equivalent to [PossessiveRepeatingParserExtension.star],
  /// but particularly performant when used on character parsers. Instead of a
  /// [List] it returns the parsed sub-[String].
  ///
  /// For example, the parser `letter().starString()` accepts the empty string
  /// or any sequence of letters and returns a possibly empty string of the
  /// parsed letters.
  @useResult
  Parser<String> starString() => repeatString(0, unbounded);

  /// Returns a parser that accepts the receiver one or more times. The
  /// resulting parser returns the consumed input string.
  ///
  /// This implementation is equivalent to [PossessiveRepeatingParserExtension.plus],
  /// but particularly performant when used on character parsers. Instead of a
  /// [List] it returns the parsed sub-[String].
  ///
  /// For example, the parser `letter().plusString()` accepts any sequence of
  /// letters and returns the string of the parsed letters.
  @useResult
  Parser<String> plusString() => repeatString(1, unbounded);

  /// Returns a parser that accepts the receiver exactly [count] times. The
  /// resulting parser returns the consumed input string.
  ///
  /// This implementation is equivalent to [PossessiveRepeatingParserExtension.times],
  /// but particularly performant when used on character parsers. Instead of a
  /// [List] it returns the parsed sub-[String].
  ///
  /// For example, the parser `letter().timesString(2)` accepts two letters and
  /// returns a string of the two parsed letters.
  @useResult
  Parser<String> timesString(int count) => repeatString(count, count);

  /// Returns a parser that accepts the receiver between [min] and [max] times.
  /// The resulting parser returns the consumed input string.
  ///
  /// This implementation is equivalent to [PossessiveRepeatingParserExtension.repeat],
  /// but particularly performant when used on character parsers. Instead of a
  /// [List] it returns the parsed sub-[String].
  ///
  /// For example, the parser `letter().repeatString(2, 4)` accepts a sequence of
  /// two, three, or four letters and returns the accepted letters as a string.
  @useResult
  Parser<String> repeatString(int min, [int? max]) {
    final self = this;
    if (self is SingleCharacterParser) {
      return RepeatingCharacterParser(
          self.predicate, self.message, min, max ?? min);
    } else if (self is AnyCharacterParser) {
      return RepeatingCharacterParser(
          const ConstantCharPredicate(true), self.message, min, max ?? min);
    } else {
      return self.repeat(min, max).flatten();
    }
  }
}

/// An abstract parser that repeatedly parses between 'min' and 'max' instances
/// of its delegate.
class RepeatingCharacterParser extends Parser<String> {
  RepeatingCharacterParser(this.predicate, this.message, this.min, this.max)
      : assert(0 <= min, 'min must be at least 0, but got $min'),
        assert(min <= max, 'max must be at least $min, but got $max');

  /// Predicate indicating whether a character can be consumed.
  final CharacterPredicate predicate;

  /// Error message to annotate parse failures with.
  final String message;

  /// The minimum amount of repetitions.
  final int min;

  /// The maximum amount of repetitions, or [unbounded].
  final int max;

  @override
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final start = context.position;
    final end = buffer.length;
    var position = start;
    var count = 0;
    while (count < min) {
      if (position >= end || !predicate.test(buffer.codeUnitAt(position))) {
        return context.failure(message, position);
      }
      position++;
      count++;
    }
    while (position < end && count < max) {
      if (!predicate.test(buffer.codeUnitAt(position))) {
        break;
      }
      position++;
      count++;
    }
    return context.success(buffer.substring(start, position), position);
  }

  @override
  int fastParseOn(String buffer, int position) {
    final end = buffer.length;
    var count = 0;
    while (count < min) {
      if (position >= end || !predicate.test(buffer.codeUnitAt(position))) {
        return -1;
      }
      position++;
      count++;
    }
    while (position < end && count < max) {
      if (!predicate.test(buffer.codeUnitAt(position))) {
        break;
      }
      position++;
      count++;
    }
    return position;
  }

  @override
  RepeatingCharacterParser copy() =>
      RepeatingCharacterParser(predicate, message, min, max);

  @override
  String toString() =>
      '${super.toString()}[$min..${max == unbounded ? '*' : max}]';

  @override
  bool hasEqualProperties(RepeatingCharacterParser other) =>
      super.hasEqualProperties(other) &&
      min == other.min &&
      max == other.max &&
      predicate.isEqualTo(other.predicate) &&
      message == other.message;
}
