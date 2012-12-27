// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Returns a parser that accepts any input element.
 */
Parser any([String message]) {
  return new _AnyPredicateParser(message != null ? message : 'input expected');
}

class _AnyPredicateParser extends Parser {
  final String _message;
  _AnyPredicateParser(this._message);
  Result _parse(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    if (position < buffer.length) {
      return context.success(buffer[position], position + 1);
    } else {
      return context.failure(_message);
    }
  }
}

/**
 * Returns a parser that accepts any of the [elements].
 */
Parser anyIn(dynamic elements, [String message]) {
  return new PredicateParser(1,
    (each) => elements.indexOf(each) >= 0,
    message != null ? message : 'any of $elements expected');
}

/**
 * Returns a parser that accepts the string [element].
 */
Parser string(String element, [String message]) {
  return new PredicateParser(element.length,
    (String each) => element == each,
    message != null ? message : '$element expected');
}

/**
 * Returns a parser that accepts the string [element] ignoring the case.
 */
Parser stringIgnoreCase(String element, [String message]) {
  final lowerElement = element.toLowerCase();
  return new PredicateParser(element.length,
    (String each) => lowerElement == each.toLowerCase(),
    message != null ? message : '$element expected');
}

/**
 * A parser for a single literal satisfying a predicate.
 */
class PredicateParser extends Parser {

  final int _length;
  final Function _predicate;
  final String _message;

  PredicateParser(this._length, this._predicate, this._message);

  Result _parse(Context context) {
    final start = context.position;
    final stop = start + _length;
    if (stop <= context.buffer.length) {
      var result = context.buffer.substring(start, stop);
      if (_predicate(result)) {
        return context.success(result, stop);
      }
    }
    return context.failure(_message);
  }

}