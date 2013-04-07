// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Returns a parser that accepts any input element.
 *
 * For example, [:any():] succeeds and consumes any given letter. It only
 * fails for an empty input.
 */
Parser any({String message}) {
  return new _PredicateParser(1,
    (each) => true,
    message != null ? message : 'input expected');
}

/**
 * Returns a parser that accepts any of the [elements].
 *
 * For example, [:anyIn('ab'):] succeeds and consumes either the letter
 * [:'a':] or the letter [:'b':]. For any other input the parser fails.
 */
Parser anyIn(dynamic elements, {String message}) {
  return new _PredicateParser(1,
    (each) => elements.indexOf(each) >= 0,
    message != null ? message : 'any of $elements expected');
}

/**
 * Returns a parser that accepts the string [element].
 *
 * For example, [:string('foo'):] succeeds and consumes the input string
 * [:'foo':]. Fails for any other input.
 */
Parser string(String element, {String message}) {
  return new _PredicateParser(element.length,
    (String each) => element == each,
    message != null ? message : '$element expected');
}

/**
 * Returns a parser that accepts the string [element] ignoring the case.
 *
 * For example, [:stringIgnoreCase('foo'):] succeeds and consumes the input
 * string [:'Foo':] or [:'FOO':]. Fails for any other input.
 */
Parser stringIgnoreCase(String element, {String message}) {
  final lowerElement = element.toLowerCase();
  return new _PredicateParser(element.length,
    (String each) => lowerElement == each.toLowerCase(),
    message != null ? message : '$element expected');
}

/**
 * A parser for a single literal satisfying a predicate.
 */
class _PredicateParser extends Parser {

  final int _length;
  final Function _predicate;
  final String _message;

  _PredicateParser(this._length, this._predicate, this._message);

  Result _parse(Context context) {
    final start = context.position;
    final stop = start + _length;
    if (stop <= context.buffer.length) {
      var result = context.buffer is String
          ? context.buffer.substring(start, stop)
          : context.buffer.sublist(start, stop);
      if (_predicate(result)) {
        return context.success(result, stop);
      }
    }
    return context.failure(_message);
  }

}
