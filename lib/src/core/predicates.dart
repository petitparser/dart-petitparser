part of petitparser;

/**
 * Returns a parser that accepts any input element.
 *
 * For example, `any()` succeeds and consumes any given letter. It only
 * fails for an empty input.
 */
Parser any([String message = 'input expected']) {
  return new AnyParser(message);
}

class AnyParser extends Parser {

  final String _message;

  AnyParser(this._message);

  @override
  Result parseOn(Context context) {
    var position = context.position;
    var buffer = context.buffer;
    return position < buffer.length
        ? context.success(buffer[position], position + 1)
        : context.failure(_message);
  }

  @override
  Parser copy() => new AnyParser(_message);

  @override
  bool equalProperties(AnyParser other) {
    return super.equalProperties(other)
        && _message == other._message;
  }

}

/**
 * Returns a parser that accepts any of the [elements].
 *
 * For example, `anyIn('ab')` succeeds and consumes either the letter
 * `'a'` or the letter `'b'`. For any other input the parser fails.
 */
Parser anyIn(elements, [String message]) {
  return predicate(1,
      (each) => elements.indexOf(each) >= 0,
      message != null ? message : 'any of $elements expected');
}

/**
 * Returns a parser that accepts the string [element].
 *
 * For example, `string('foo')` succeeds and consumes the input string
 * `'foo'`. Fails for any other input.
 */
Parser string(String element, [String message]) {
  return predicate(element.length,
      (String each) => element == each,
      message != null ? message : '$element expected');
}

/**
 * Returns a parser that accepts the string [element] ignoring the case.
 *
 * For example, `stringIgnoreCase('foo')` succeeds and consumes the input
 * string `'Foo'` or `'FOO'`. Fails for any other input.
 */
Parser stringIgnoreCase(String element, [String message]) {
  final lowerElement = element.toLowerCase();
  return predicate(element.length,
      (String each) => lowerElement == each.toLowerCase(),
      message != null ? message : '$element expected');
}

/**
 * A generic predicate function returning [true] or [false] for a given
 * [input] argument.
 */
typedef bool Predicate(input);

/**
 * Returns a parser that reads input of the specified [length], accepts
 * it if the [predicate] matches, or fails with the given [message].
 */
Parser predicate(int length, Predicate predicate, String message) {
  return new PredicateParser(length, predicate, message);
}

/**
 * A parser for a literal satisfying a predicate.
 */
class PredicateParser extends Parser {

  final int _length;
  final Predicate _predicate;
  final String _message;

  PredicateParser(this._length, this._predicate, this._message);

  @override
  Result parseOn(Context context) {
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

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  Parser copy() => new PredicateParser(_length, _predicate, _message);

  @override
  bool equalProperties(PredicateParser other) {
    return super.equalProperties(other)
        && _length == other._length
        && _predicate == other._predicate
        && _message == other._message;
  }

}
