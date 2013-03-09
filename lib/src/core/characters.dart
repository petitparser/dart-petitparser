// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

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

/** Internal abstract parser class for character classes. */
abstract class _CharacterParser extends Parser {
  String _message;
  _CharacterParser(this._message);
  Result _parse(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    if (position < buffer.length) {
      if (_match(buffer.codeUnitAt(position))) {
        return context.success(buffer[position], position + 1);
      }
    }
    return context.failure(_message);
  }
  bool _match(int value);
  Parser or(Parser other) => other is _CharacterParser ? new _AlternativeCharacterParser([this, other]) : super.or(other);
  Parser neg([String message]) => new _NegatedCharacterParser(message != null ? message : 'no $_message', this);
}

/** Internal parser class for negated character classes. */
class _NegatedCharacterParser extends _CharacterParser {
  final _CharacterParser _parser;
  _NegatedCharacterParser(String message, this._parser) : super(message);
  bool _match(int value) => !_parser._match(value);
  Parser neg([String message]) => _parser;
}

/** Internal parser class for alternative character classes. */
class _AlternativeCharacterParser extends _CharacterParser {
  final List<_CharacterParser> _parsers;
  _AlternativeCharacterParser(parsers)
      : super(parsers[0]._message),
        _parsers = parsers;
  bool _match(int value) {
    for (final parser in _parsers) {
      if (parser._match(value)) {
        return true;
      }
    }
    return false;
  }
  Parser or(Parser other) {
    if (other is _CharacterParser) {
      var list = new List.from(_parsers);
      list.add(other);
      return new _AlternativeCharacterParser(list);
    } else {
      return super.or(other);
    }
  }
}

/** Internal parser class that does a binary search. */
class _BinarySearchCharacterParser extends _CharacterParser {
  final List<int> _codes;
  _BinarySearchCharacterParser(String message, this._codes) : super(message);
  bool _match(int value) {
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
  return new _CharParser(message != null ? message : '$element expected', _toCharCode(element));
}

class _CharParser extends _CharacterParser {
  final int _char;
  _CharParser(String message, this._char) : super(message);
  bool _match(int value) => identical(_char, value);
}

/** Returns a parser that accepts any digit character. */
Parser digit({String message}) {
  return new _DigitParser(message != null ? message : 'digit expected');
}

class _DigitParser extends _CharacterParser {
  _DigitParser(String message) : super(message);
  bool _match(int value) => 48 <= value && value <= 57;
}

/** Returns a parser that accepts any letter character. */
Parser letter({String message}) {
  return new _LetterParser(message != null ? message : 'letter expected');
}

class _LetterParser extends _CharacterParser {
  _LetterParser(String message) : super(message);
  bool _match(int value) => (65 <= value && value <= 90) || (97 <= value && value <= 122);
}

/** Returns a parser that accepts any lowercase character. */
Parser lowercase({String message}) {
  return new _LowercaseParser(message != null ? message : 'lowercase letter expected');
}

class _LowercaseParser extends _CharacterParser {
  _LowercaseParser(String message) : super(message);
  bool _match(int value) => 97 <= value && value <= 122;
}

/** Returns a parser that accepts the given character class pattern. */
Parser pattern(String element, {String message}) {
  if (_pattern == null) {
    final single = any().map((each) {
      return char(each);
    });
    final multiple = any().seq(char('-')).seq(any()).map((each) {
      return range(each[0], each[2]);
    });
    final positive = multiple.or(single).plus().map((each) {
      return each.length == 1 ? each[0] : new _AlternativeCharacterParser(each);
    });
    _pattern = char('^').optional().seq(positive).map((each) {
      return each[0] == null ? each[1] : each[1].neg();
    });
  }
  var parser = _pattern.parse(element).result;
  parser._message = message != null ? message : '[$element] expected';
  return parser;
}

Parser _pattern;

/** Returns a parser that accepts any character in the range between [start] and [stop]. */
Parser range(dynamic start, dynamic stop, {String message}) {
  return new _RangeParser( message != null ? message : '$start..$stop expected', _toCharCode(start), _toCharCode(stop));
}

class _RangeParser extends _CharacterParser {
  final int _start;
  final int _stop;
  _RangeParser(String message, this._start, this._stop) : super(message);
  bool _match(int value) => _start <= value && value <= _stop;
}

/** Returns a parser that accepts any uppercase character. */
Parser uppercase({String message}) {
  return new _UppercaseParser(message != null ? message : 'uppercase letter expected');
}

class _UppercaseParser extends _CharacterParser {
  _UppercaseParser(String message) : super(message);
  bool _match(int value) => 65 <= value && value <= 90;
}

/** Returns a parser that accepts any whitespace character. */
Parser whitespace({String message}) {
  return new _WhitespaceParser(message != null ? message : 'whitespace expected');
}

class _WhitespaceParser extends _CharacterParser {
  _WhitespaceParser(String message) : super(message);
  bool _match(int value) => (9 <= value && value <= 13) || (value == 32) || (value == 160)
      || (value == 5760) || (value == 6158) || (8192 <= value && value <= 8202) || (value == 8232)
      || (value == 8233) || (value == 8239) || (value == 8287) || (value == 12288);
}

/** Returns a parser that accepts any word character. */
Parser word({String message}) {
  return new _WordParser(message != null ? message : 'letter or digit expected');
}

class _WordParser extends _CharacterParser {
  _WordParser(String message) : super(message);
  bool _match(int value) => (65 <= value && value <= 90) || (97 <= value && value <= 122)
      || (48 <= value && value <= 57) || (value == 95);
}
