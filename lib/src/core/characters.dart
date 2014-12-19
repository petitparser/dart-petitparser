part of petitparser;

/**
 * Parser class for individual character classes.
 */
class CharacterParser extends Parser {

  final CharacterPredicate _predicate;

  final String _message;

  CharacterParser(this._predicate, this._message);

  @override
  Result parseOn(Context context) {
    var buffer = context.buffer;
    var position = context.position;
    if (position < buffer.length && _predicate.test(buffer.codeUnitAt(position))) {
      return context.success(buffer[position], position + 1);
    }
    return context.failure(_message);
  }

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  Parser copy() => new CharacterParser(_predicate, _message);

  @override
  bool hasEqualProperties(CharacterParser other) {
    return super.hasEqualProperties(other)
        && _predicate == other._predicate
        && _message == other._message;
  }

}

/**
 * Abstract character predicate class.
 */
abstract class CharacterPredicate {

  const CharacterPredicate();

  /**
   * Tests if the character predicate is satisfied.
   */
  bool test(int value);

  /**
   * Negates this character predicate.
   */
  CharacterPredicate not() => new _NotCharacterPredicate(this);

  /**
   * Matches this character predicate or other.
   */
  CharacterPredicate or(CharacterPredicate other) => new _AltCharacterPredicate([this, other]);

}

class _NotCharacterPredicate extends CharacterPredicate {

  final CharacterPredicate _predicate;

  const _NotCharacterPredicate(this._predicate);

  @override
  bool test(int value) => !_predicate.test(value);

  @override
  CharacterPredicate not() => _predicate;

}

class _AltCharacterPredicate extends CharacterPredicate {

  final List<CharacterPredicate> _predicates;

  const _AltCharacterPredicate(this._predicates);

  @override
  bool test(int value) {
    for (var predicate in _predicates) {
      if (predicate.test(value)) {
        return true;
      }
    }
    return false;
  }

  @override
  CharacterPredicate or(CharacterPredicate other) {
    return new _AltCharacterPredicate(new List()..addAll(_predicates)..add(other));
  }

}

int _toCharCode(element) {
  if (element is num) {
    return element.round();
  }
  var value = element.toString();
  if (value.length != 1) {
    throw new ArgumentError('$value is not a character');
  }
  return value.codeUnitAt(0);
}

class _CharacterRange {

  final int start;
  final int stop;

  _CharacterRange._(this.start, this.stop);

  factory _CharacterRange(start, [stop]) {
    if (stop == null) stop = start;
    return new _CharacterRange._(_toCharCode(start), _toCharCode(stop));
  }

}

CharacterPredicate _optimize(Iterable<_CharacterRange> ranges) {

  // 1. sort the ranges
  var sortedRanges = new List.from(ranges);
  sortedRanges.sort((first, second) {
    return first.start < second.start ? -1
      : first.start > second.start ? 1
      : first.stop < second.stop ? -1
      : first.stop > second.stop ? 1
      : 0;
  });

  // 2. merge adjacent or overlapping ranges
  var mergedRanges = new List();
  for (var currentRange in sortedRanges) {
    if (mergedRanges.isEmpty) {
      mergedRanges.add(currentRange);
    } else {
      var lastRange = mergedRanges.last;
      if (lastRange.stop + 1 >= currentRange.start) {
        mergedRanges[mergedRanges.length - 1] = new _CharacterRange(
            lastRange.start < currentRange.start ? lastRange.start : currentRange.start,
            lastRange.stop > currentRange.stop ? lastRange.stop : currentRange.stop);
      } else {
        mergedRanges.add(currentRange);
      }
    }
  }

  // 3. build the corresponding predicates
  var predicates = new List();
  for (var range in mergedRanges) {
    if (range.stop - range.start > 1) {
      predicates.add(new _RangeCharMatcher(range.start, range.stop));
    } else {
      for (var value = range.start; value <= range.stop; value++) {
        predicates.add(new _SingleCharMatcher(value));
      }
    }
  }

  // 4. when necessary build a composite predicate
  return predicates.length == 1 ? predicates.first : new _AltCharacterPredicate(predicates);

}

/**
 * Returns a parser that accepts any of the specified characters.
 */
Parser anyOf(String string, [String message]) {
  return new CharacterParser(
      _optimize(string.codeUnits.map((value) => new _CharacterRange(value))),
      message != null ? message : 'any of "$string" expected');
}

/**
 * Returns a parser that accepts none of the specified characters.
 */
Parser noneOf(String string, [String message]) {
  return new CharacterParser(
      _optimize(string.codeUnits.map((value) => new _CharacterRange(value))).not(),
      message != null ? message : 'none of "$string" expected');
}

/**
 * Returns a parser that accepts a specific character only.
 */
Parser char(element, [String message]) {
  return new CharacterParser(
      new _SingleCharMatcher(_toCharCode(element)),
      message != null ? message : '"$element" expected');
}

class _SingleCharMatcher extends CharacterPredicate {

  final int _value;

  const _SingleCharMatcher(this._value);

  @override
  bool test(int value) => identical(_value, value);

}

/**
 * Returns a parser that accepts any digit character.
 */
Parser digit([String message]) {
  return new CharacterParser(
      _digitCharMatcher,
      message != null ? message : 'digit expected');
}

class _DigitCharMatcher extends CharacterPredicate {

  const _DigitCharMatcher();

  @override
  bool test(int value) => 48 <= value && value <= 57;

}

const _digitCharMatcher = const _DigitCharMatcher();

/**
 * Returns a parser that accepts any letter character.
 */
Parser letter([String message]) {
  return new CharacterParser(
      _letterCharMatcher,
      message != null ? message : 'letter expected');
}

class _LetterCharMatcher extends CharacterPredicate {

  const _LetterCharMatcher();

  @override
  bool test(int value) => (65 <= value && value <= 90) || (97 <= value && value <= 122);

}

const _letterCharMatcher = const _LetterCharMatcher();

/**
 * Returns a parser that accepts any lowercase character.
 */
Parser lowercase([String message]) {
  return new CharacterParser(
      _lowercaseCharMatcher,
      message != null ? message : 'lowercase letter expected');
}

class _LowercaseCharMatcher extends CharacterPredicate {

  const _LowercaseCharMatcher();

  @override
  bool test(int value) => 97 <= value && value <= 122;

}

const _lowercaseCharMatcher = const _LowercaseCharMatcher();

/**
 * Returns a parser that accepts the given character class pattern.
 */
Parser pattern(String element, [String message]) {
  return new CharacterParser(
      _patternParser.parse(element).value,
      message != null ? message : '[$element] expected');
}

Parser _createPatternParser() {
  var single = any()
      .map((each) => new _CharacterRange(each));
  var multiple = any()
      .seq(char('-'))
      .seq(any())
      .map((each) => new _CharacterRange(each[0], each[2]));
  var positive = multiple.or(single).plus()
      .map((each) => _optimize(each));
  return char('^').optional().seq(positive)
      .map((each) => each[0] == null ? each[1] : each[1].not());
}

final _patternParser = _createPatternParser();

/**
 * Returns a parser that accepts any character in the range
 * between [start] and [stop].
 */
Parser range(start, stop, [String message]) {
  return new CharacterParser(
      new _RangeCharMatcher(_toCharCode(start), _toCharCode(stop)),
      message != null ? message : '$start..$stop expected');
}

class _RangeCharMatcher extends CharacterPredicate {

  final int _start;

  final int _stop;

  const _RangeCharMatcher(this._start, this._stop);

  @override
  bool test(int value) => _start <= value && value <= _stop;

}

/**
 * Returns a parser that accepts any uppercase character.
 */
Parser uppercase([String message]) {
  return new CharacterParser(
      _uppercaseCharMatcher,
      message != null ? message : 'uppercase letter expected');
}

class _UppercaseCharMatcher extends CharacterPredicate {

  const _UppercaseCharMatcher();

  @override
  bool test(int value) => 65 <= value && value <= 90;

}

const _uppercaseCharMatcher = const _UppercaseCharMatcher();

/**
 * Returns a parser that accepts any whitespace character.
 */
Parser whitespace([String message]) {
  return new CharacterParser(
      _whitespaceCharMatcher,
      message != null ? message : 'whitespace expected');
}

class _WhitespaceCharMatcher extends CharacterPredicate {

  const _WhitespaceCharMatcher();

  @override
  bool test(int value) {
    if (value < 256) {
      return value == 0x09 || value == 0x0A || value == 0x0B || value == 0x0C
          || value == 0x0D || value == 0x20 || value == 0x85 || value == 0xA0;
    } else {
      return value == 0x1680 || value == 0x180E || value == 0x2000 || value == 0x2001
          || value == 0x2002 || value == 0x2003 || value == 0x2004 || value == 0x2005
          || value == 0x2006 || value == 0x2007 || value == 0x2008 || value == 0x2009
          || value == 0x200A || value == 0x2028 || value == 0x2029 || value == 0x202F
          || value == 0x205F || value == 0x3000 || value == 0xFEFF;
    }
  }

}

const _whitespaceCharMatcher = const _WhitespaceCharMatcher();

/**
 * Returns a parser that accepts any word character.
 */
Parser word([String message]) {
  return new CharacterParser(
      _wordCharMatcher,
      message != null ? message : 'letter or digit expected');
}

class _WordCharMatcher extends CharacterPredicate {

  const _WordCharMatcher();

  @override
  bool test(int value) => (65 <= value && value <= 90) || (97 <= value && value <= 122)
      || (48 <= value && value <= 57) || (value == 95);

}

const _wordCharMatcher = const _WordCharMatcher();
