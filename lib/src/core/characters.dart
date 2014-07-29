part of petitparser;

/**
 * Parser class for individual character classes.
 */
class CharacterParser extends Parser {

  final _CharMatcher _matcher;

  final String _message;

  CharacterParser(this._matcher, this._message);

  @override
  Result parseOn(Context context) {
    var buffer = context.buffer;
    var position = context.position;
    if (position < buffer.length && _matcher.match(buffer.codeUnitAt(position))) {
      return context.success(buffer[position], position + 1);
    }
    return context.failure(_message);
  }

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  Parser copy() => new CharacterParser(_matcher, _message);

  @override
  bool equalProperties(CharacterParser other) {
    return super.equalProperties(other)
        && _matcher == other._matcher
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
 * Internal abstract character matcher class.
 */
abstract class _CharMatcher {
  bool match(int value);
}

/**
 * Internal character matcher that negates the result.
 */
class _NotCharMatcher implements _CharMatcher {

  final _CharMatcher _matcher;

  const _NotCharMatcher(this._matcher);

  @override
  bool match(int value) => !_matcher.match(value);

}

/**
 * Internal character matcher for alternatives.
 */
class _AltCharMatcher implements _CharMatcher {

  final List<_CharMatcher> _matchers;

  const _AltCharMatcher(this._matchers);

  @override
  bool match(int value) {
    for (var matcher in _matchers) {
      if (matcher.match(value)) {
        return true;
      }
    }
    return false;
  }

}

/**
 * Returns a parser that accepts a specific character only.
 */
Parser char(element, [String message]) {
  return new CharacterParser(
      new _SingleCharMatcher(_toCharCode(element)),
      message != null ? message : '$element expected');
}

class _SingleCharMatcher implements _CharMatcher {

  final int _value;

  const _SingleCharMatcher(this._value);

  @override
  bool match(int value) => identical(_value, value);

}

/**
 * Returns a parser that accepts any digit character.
 */
Parser digit([String message]) {
  return new CharacterParser(
      _digitCharMatcher,
      message != null ? message : 'digit expected');
}

class _DigitCharMatcher implements _CharMatcher {

  const _DigitCharMatcher();

  @override
  bool match(int value) => 48 <= value && value <= 57;

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

class _LetterCharMatcher implements _CharMatcher {

  const _LetterCharMatcher();

  @override
  bool match(int value) => (65 <= value && value <= 90) || (97 <= value && value <= 122);

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

class _LowercaseCharMatcher implements _CharMatcher {

  const _LowercaseCharMatcher();

  @override
  bool match(int value) => 97 <= value && value <= 122;

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
  var single = any().map((each) {
    return new _SingleCharMatcher(_toCharCode(each));
  });
  var multiple = any().seq(char('-')).seq(any()).map((each) {
    return new _RangeCharMatcher(_toCharCode(each[0]), _toCharCode(each[2]));
  });
  var positive = multiple.or(single).plus().map((each) {
    return each.length == 1 ? each[0] : new _AltCharMatcher(each);
  });
  return char('^').optional().seq(positive).map((each) {
    return each[0] == null ? each[1] : new _NotCharMatcher(each[1]);
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

class _RangeCharMatcher implements _CharMatcher {

  final int _start;

  final int _stop;

  const _RangeCharMatcher(this._start, this._stop);

  @override
  bool match(int value) => _start <= value && value <= _stop;

}

/**
 * Returns a parser that accepts any uppercase character.
 */
Parser uppercase([String message]) {
  return new CharacterParser(
      _uppercaseCharMatcher,
      message != null ? message : 'uppercase letter expected');
}

class _UppercaseCharMatcher implements _CharMatcher {

  const _UppercaseCharMatcher();

  @override
  bool match(int value) => 65 <= value && value <= 90;

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

class _WhitespaceCharMatcher implements _CharMatcher {

  const _WhitespaceCharMatcher();

  @override
  bool match(int value) {
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

class _WordCharMatcher implements _CharMatcher {

  const _WordCharMatcher();

  @override
  bool match(int value) => (65 <= value && value <= 90) || (97 <= value && value <= 122)
      || (48 <= value && value <= 57) || (value == 95);

}

const _wordCharMatcher = const _WordCharMatcher();
