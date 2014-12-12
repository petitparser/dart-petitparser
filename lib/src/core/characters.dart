part of petitparser;

/**
 * Parser class for individual character classes.
 */
class CharacterParser extends Parser {

  final _CharacterPredicate _predicate;

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

/**
 * Internal abstract character predicate class.
 */
abstract class _CharacterPredicate {
  bool test(int value);
}

/**
 * Internal character predicate that negates the result.
 */
class _NotCharacterPredicate implements _CharacterPredicate {

  final _CharacterPredicate _predicate;

  const _NotCharacterPredicate(this._predicate);

  @override
  bool test(int value) => !_predicate.test(value);

}

/**
 * Internal character predicate for alternatives.
 */
class _AltCharacterPredicate implements _CharacterPredicate {

  final List<_CharacterPredicate> _predicates;

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

}

/**
 * Returns a parser that accepts any of the specified characters.
 */
Parser anyOf(String string, [String message]) {
  return new CharacterParser(
      _optimized(string),
      message != null ? message : 'any of "$string" expected');
}

_CharacterPredicate _optimized(String characters) {
  var codeUnits = characters.codeUnits.toSet().toList()..sort();
  var groupedRanges = new Map();
  for (var i = 0; i < codeUnits.length; i++) {
    var key = i - codeUnits[i];
    var range = groupedRanges.putIfAbsent(key, () => new List());
    while (range.length > 1) {
      range.removeLast();
    }
    range.add(codeUnits[i]);
  }
  var predicates = new List();
  for (var range in groupedRanges.values) {
    var start = range.first, stop = range.last;
    if (stop - start > 2) {
      predicates.add(new _RangeCharMatcher(start, stop));
    } else {
      for (var value = start; value <= stop; value++) {
        predicates.add(new _SingleCharMatcher(value));
      }
    }
  }
  return predicates.length == 1 ? predicates.single : new _AltCharacterPredicate(predicates);
}

/**
 * Returns a parser that accepts none of the specified characters.
 */
Parser noneOf(String string, [String message]) {
  return new CharacterParser(
      new _NotCharacterPredicate(_optimized(string)),
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

class _SingleCharMatcher implements _CharacterPredicate {

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

class _DigitCharMatcher implements _CharacterPredicate {

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

class _LetterCharMatcher implements _CharacterPredicate {

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

class _LowercaseCharMatcher implements _CharacterPredicate {

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
  var single = any();
  var multiple = any().seq(char('-')).seq(any()).map((each) {
    var buffer = new StringBuffer();
    var start = _toCharCode(each[0]), stop = _toCharCode(each[2]);
    for (var value = start; value <= stop; value++) {
      buffer.writeCharCode(value);
    }
    return buffer.toString();
  });
  var positive = multiple.or(single).plus().map((each) {
    return _optimized(each.join());
  });
  return char('^').optional().seq(positive).map((each) {
    return each[0] == null ? each[1] : new _NotCharacterPredicate(each[1]);
  });
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

class _RangeCharMatcher implements _CharacterPredicate {

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

class _UppercaseCharMatcher implements _CharacterPredicate {

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

class _WhitespaceCharMatcher implements _CharacterPredicate {

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

class _WordCharMatcher implements _CharacterPredicate {

  const _WordCharMatcher();

  @override
  bool test(int value) => (65 <= value && value <= 90) || (97 <= value && value <= 122)
      || (48 <= value && value <= 57) || (value == 95);

}

const _wordCharMatcher = const _WordCharMatcher();
