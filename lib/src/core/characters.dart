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

  /**
   * Tests if the character predicate is satisfied.
   */
  bool test(int value);

}

class _NotCharacterPredicate implements CharacterPredicate {

  final CharacterPredicate predicate;

  _NotCharacterPredicate(this.predicate);

  @override
  bool test(int value) => !predicate.test(value);

}

class _AltCharacterPredicate implements CharacterPredicate {

  final List<CharacterPredicate> predicates;

  const _AltCharacterPredicate(this.predicates);

  @override
  bool test(int value) {
    for (var predicate in predicates) {
      if (predicate.test(value)) {
        return true;
      }
    }
    return false;
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
  sortedRanges.sort((first, second) => first.start - second.start);

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
      predicates.add(new _RangeCharPredicate(range.start, range.stop));
    } else {
      for (var value = range.start; value <= range.stop; value++) {
        predicates.add(new _SingleCharPredicate(value));
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
  var ranges = string.codeUnits.map((value) => new _CharacterRange(value));
  return new CharacterParser(
      new _NotCharacterPredicate(_optimize(ranges)),
      message != null ? message : 'none of "$string" expected');
}

/**
 * Returns a parser that accepts a specific character only.
 */
Parser char(element, [String message]) {
  return new CharacterParser(
      new _SingleCharPredicate(_toCharCode(element)),
      message != null ? message : '"$element" expected');
}

class _SingleCharPredicate implements CharacterPredicate {

  final int _value;

  const _SingleCharPredicate(this._value);

  @override
  bool test(int value) => identical(_value, value);

}

/**
 * Returns a parser that accepts any digit character.
 */
Parser digit([String message]) {
  return new CharacterParser(
      _digitCharPredicate,
      message != null ? message : 'digit expected');
}

class _DigitCharPredicate implements CharacterPredicate {

  const _DigitCharPredicate();

  @override
  bool test(int value) => 48 <= value && value <= 57;

}

const _digitCharPredicate = const _DigitCharPredicate();

/**
 * Returns a parser that accepts any letter character.
 */
Parser letter([String message]) {
  return new CharacterParser(
      _letterCharPredicate,
      message != null ? message : 'letter expected');
}

class _LetterCharPredicate implements CharacterPredicate {

  const _LetterCharPredicate();

  @override
  bool test(int value) => (65 <= value && value <= 90) || (97 <= value && value <= 122);

}

const _letterCharPredicate = const _LetterCharPredicate();

/**
 * Returns a parser that accepts any lowercase character.
 */
Parser lowercase([String message]) {
  return new CharacterParser(
      _lowercaseCharPredicate,
      message != null ? message : 'lowercase letter expected');
}

class _LowercaseCharPredicate implements CharacterPredicate {

  const _LowercaseCharPredicate();

  @override
  bool test(int value) => 97 <= value && value <= 122;

}

const _lowercaseCharPredicate = const _LowercaseCharPredicate();

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
      .map((each) => each[0] == null ? each[1] : new _NotCharacterPredicate(each[1]));
}

final _patternParser = _createPatternParser();

/**
 * Returns a parser that accepts any character in the range
 * between [start] and [stop].
 */
Parser range(start, stop, [String message]) {
  return new CharacterParser(
      new _RangeCharPredicate(_toCharCode(start), _toCharCode(stop)),
      message != null ? message : '$start..$stop expected');
}

class _RangeCharPredicate implements CharacterPredicate {

  final int start;
  final int stop;

  const _RangeCharPredicate(this.start, this.stop);

  @override
  bool test(int value) => start <= value && value <= stop;

}

/**
 * Returns a parser that accepts any uppercase character.
 */
Parser uppercase([String message]) {
  return new CharacterParser(
      _uppercaseCharPredicate,
      message != null ? message : 'uppercase letter expected');
}

class _UppercaseCharPredicate implements CharacterPredicate {

  const _UppercaseCharPredicate();

  @override
  bool test(int value) => 65 <= value && value <= 90;

}

const _uppercaseCharPredicate = const _UppercaseCharPredicate();

/**
 * Returns a parser that accepts any whitespace character.
 */
Parser whitespace([String message]) {
  return new CharacterParser(
      _whitespaceCharPredicate,
      message != null ? message : 'whitespace expected');
}

class _WhitespaceCharPredicate implements CharacterPredicate {

  const _WhitespaceCharPredicate();

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

const _whitespaceCharPredicate = const _WhitespaceCharPredicate();

/**
 * Returns a parser that accepts any word character.
 */
Parser word([String message]) {
  return new CharacterParser(
      _wordCharPredicate,
      message != null ? message : 'letter or digit expected');
}

class _WordCharPredicate implements CharacterPredicate {

  const _WordCharPredicate();

  @override
  bool test(int value) => (65 <= value && value <= 90) || (97 <= value && value <= 122)
      || (48 <= value && value <= 57) || (value == 95);

}

const _wordCharPredicate = const _WordCharPredicate();
