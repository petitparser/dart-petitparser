// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Parser class for individual character classes.
 */
class _CharacterParser extends Parser {

  final _CharMatcher _matcher;

  final String _message;

  _CharacterParser(this._matcher, this._message);

  Result _parse(Context context) {
    var buffer = context.buffer;
    var position = context.position;
    if (position < buffer.length && _matcher.match(buffer.codeUnitAt(position))) {
      return context.success(buffer[position], position + 1);
    }
    return context.failure(_message);
  }

  Parser copy() => new _CharacterParser(_matcher, _message);

}

/** Internal method to convert an element to a character code. */
int _toCharCode(dynamic element) {
  if (element is int) {
    return element;
  }
  var value = element.toString();
  if (value.length != 1) {
    throw new ArgumentError('$value is not a character');
  }
  return value.codeUnitAt(0);
}

/** Internal abstract character matcher class. */
abstract class _CharMatcher {
  const _CharMatcher();
  bool match(int value);
}

/** Internal character matcher that negates the result. */
class _NotCharMatcher extends _CharMatcher {
  final _CharMatcher _matcher;
  const _NotCharMatcher(this._matcher);
  bool match(int value) => !_matcher.match(value);
}

/** Internal character matcher for alternatives. */
class _AltCharMatcher extends _CharMatcher {
  final List<_CharMatcher> _matchers;
  const _AltCharMatcher(this._matchers);
  bool match(int value) {
    for (var matcher in _matchers) {
      if (matcher.match(value)) {
        return true;
      }
    }
    return false;
  }
}

/** Internal character matcher that does a binary search. */
class _BinarySearchCharMatcher extends _CharMatcher {
  final List<int> _codes;
  const _BinarySearchCharMatcher(this._codes);
  bool match(int value) {
    var lo = 0;
    var hi = _codes.length - 1;
    while (lo <= hi) {
      var index = (lo + hi) ~/ 2;
      if (value < _codes[index]) {
        hi = index - 1;
      } else if (value > _codes[index]) {
        lo = index + 1;
      } else {
        return true;
      }
    }
    return false;
  }
}

/** Returns a parser that accepts a specific character only. */
Parser char(dynamic element, {String message}) {
  return new _CharacterParser(
      new _SingleCharMatcher(_toCharCode(element)),
      message != null ? message : '$element expected');
}

class _SingleCharMatcher extends _CharMatcher {
  final int _value;
  const _SingleCharMatcher(this._value);
  bool match(int value) => identical(_value, value);
}

/** Returns a parser that accepts any digit character. */
Parser digit({String message}) {
  return new _CharacterParser(
      _digitCharMatcher,
      message != null ? message : 'digit expected');
}

class _DigitCharMatcher extends _CharMatcher {
  const _DigitCharMatcher();
  bool match(int value) => 48 <= value && value <= 57;
}

final _DigitCharMatcher _digitCharMatcher = const _DigitCharMatcher();

/** Returns a parser that accepts any letter character. */
Parser letter({String message}) {
  return new _CharacterParser(
      _letterCharMatcher,
      message != null ? message : 'letter expected');
}

class _LetterCharMatcher extends _CharMatcher {
  const _LetterCharMatcher();
  bool match(int value) => (65 <= value && value <= 90) || (97 <= value && value <= 122);
}

final _LetterCharMatcher _letterCharMatcher = const _LetterCharMatcher();

/** Returns a parser that accepts any lowercase character. */
Parser lowercase({String message}) {
  return new _CharacterParser(
      _lowercaseCharMatcher,
      message != null ? message : 'lowercase letter expected');
}

class _LowercaseCharMatcher extends _CharMatcher {
  const _LowercaseCharMatcher();
  bool match(int value) => 97 <= value && value <= 122;
}

_LowercaseCharMatcher _lowercaseCharMatcher = const _LowercaseCharMatcher();

/** Returns a parser that accepts the given character class pattern. */
Parser pattern(String element, {String message}) {
  if (_pattern == null) {
    var single = any().map((each) {
      return new _SingleCharMatcher(_toCharCode(each));
    });
    var multiple = any().seq(char('-')).seq(any()).map((each) {
      return new _RangeCharMatcher(_toCharCode(each[0]), _toCharCode(each[2]));
    });
    var positive = multiple.or(single).plus().map((each) {
      return each.length == 1 ? each[0] : new _AltCharMatcher(each);
    });
    _pattern = char('^').optional().seq(positive).map((each) {
      return each[0] == null ? each[1] : new _NotCharMatcher(each[1]);
    });
  }
  return new _CharacterParser(
      _pattern.parse(element).result,
      message != null ? message : '[$element] expected');
}

Parser _pattern;

/** Returns a parser that accepts any character in the range between [start] and [stop]. */
Parser range(dynamic start, dynamic stop, {String message}) {
  return new _CharacterParser(
      new _RangeCharMatcher(_toCharCode(start), _toCharCode(stop)),
      message != null ? message : '$start..$stop expected');
}

class _RangeCharMatcher extends _CharMatcher {
  final int _start;
  final int _stop;
  const _RangeCharMatcher(this._start, this._stop);
  bool match(int value) => _start <= value && value <= _stop;
}

/** Returns a parser that accepts any uppercase character. */
Parser uppercase({String message}) {
  return new _CharacterParser(
      _uppercaseCharMatcher,
      message != null ? message : 'uppercase letter expected');
}

class _UppercaseCharMatcher extends _CharMatcher {
  const _UppercaseCharMatcher();
  bool match(int value) => 65 <= value && value <= 90;
}

final _UppercaseCharMatcher _uppercaseCharMatcher = const _UppercaseCharMatcher();

/** Returns a parser that accepts any whitespace character. */
Parser whitespace({String message}) {
  return new _CharacterParser(
      _whitespaceCharMatcher,
      message != null ? message : 'whitespace expected');
}

class _WhitespaceCharMatcher extends _CharMatcher {
  const _WhitespaceCharMatcher();
  bool match(int value) => (9 <= value && value <= 13) || (value == 32) || (value == 160)
      || (value == 5760) || (value == 6158) || (8192 <= value && value <= 8202) || (value == 8232)
      || (value == 8233) || (value == 8239) || (value == 8287) || (value == 12288);
}

final _WhitespaceCharMatcher _whitespaceCharMatcher = const _WhitespaceCharMatcher();

/** Returns a parser that accepts any word character. */
Parser word({String message}) {
  return new _CharacterParser(
      _wordCharMatcher,
      message != null ? message : 'letter or digit expected');
}

class _WordCharMatcher extends _CharMatcher {
  const _WordCharMatcher();
  bool match(int value) => (65 <= value && value <= 90) || (97 <= value && value <= 122)
      || (48 <= value && value <= 57) || (value == 95);
}

final _WordCharMatcher _wordCharMatcher = const _WordCharMatcher();