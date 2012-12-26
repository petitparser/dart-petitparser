// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Abstract base class for all parsers.
 */
abstract class Parser {

  /**
   * Private abstract method doing the actual parsing.
   *
   * The methods takes a parse [context] and returns the resulting context,
   * which is either a [Success] or [Failure] context.
   */
  Result _parse(Context context);

  /**
   * Returns the parse result of the [input].
   *
   * The implementation creates a default parse context on the input and calls
   * the internal parsing logic of the receiving parser.
   *
   * For example, [:letter().plus().parse('abc'):] results in an instance of
   * [Success], where [Result#position] is [:3:] and [Success.result] is
   * [:[a, b, c]:].
   *
   * Similarly, [:letter().plus().parse('123'):] results in an instance of
   * [Failure], where [Result#position] is [:0:] and [Failure.message] is
   * ['letter expected'].
   */
  Result parse(dynamic input) {
    return _parse(new Context(input, 0));
  }

  /**
   * Tests if the [input] can be successfully parsed.
   *
   * For example, [:letter().plus().accept('abc'):] returns [:true:], and
   * [:letter().plus().accept('123'):] returns [:false:].
   */
  bool accept(dynamic input) {
    return parse(input).isSuccess();
  }

  /**
   * Returns a list of all successful overlapping parses of the [input].
   *
   * For example, [:letter().plus().matches('abc de'):] results in the list
   * [:[[a, b, c], [b, c], [c], [d, e], [e]]:]. See [Parser#matchesSkipping]
   * to retrieve non-overlapping parse results.
   */
  Iterable matches(dynamic input) {
    var list = new List();
    and().map((each) => list.add(each)).seq(any()).or(any()).star().parse(input);
    return list;
  }

  /**
   * Returns a list of all successful non-overlapping parses of the input.
   *
   * For example, [:letter().plus().matchesSkipping('abc de'):] results in the
   * list [:[[a, b, c], [d, e]]:]. See [Parser#matches] to retrieve overlapping
   * parse results.
   */
  Iterable matchesSkipping(dynamic input) {
    var list = new List();
    map((each) => list.add(each)).or(any()).star().parse(input);
    return list;
  }

  /**
   * Returns new parser that accepts the receiver, if possible. The resulting
   * parser returns the result of the receiver, or [:null:] if not applicable.
   * The returned value can be provided as an optional argument [otherwise].
   *
   * For example, the parser [:letter().optional():] accepts a letter as input
   * and returns that letter. When given something else the parser succeeds as
   * well, does not consume anything and returns [:null:].
   */
  Parser optional([dynamic otherwise]) => new OptionalParser(this, otherwise);

  /**
   * Returns a parser that accepts the receiver zero or more times. The
   * resulting parser returns a list of the parse results of the receiver.
   */
  Parser star() => repeat(0, 65536);

  /**
   * Returns a parser that accepts the receiver one or more times. The
   * resulting parser returns a list of the parse results of the receiver.
   */
  Parser plus() => repeat(1, 65536);

  /**
   * Returns a parser that accepts the receiver exactly [count] times. The
   * resulting parser returns a list of the parse results of the receiver.
   */
  Parser times(int count) => repeat(count, count);

  /**
   * Returns a parser that accepts the receiver between [min] and [max] times.
   * The resulting parser returns a list of the parse results of the receiver.
   */
  Parser repeat(int min, int max) => new RepeatingParser(this, min, max);

  /**
   * Returns a parser that accepts the receiver followed by [other]. The
   * resulting parser returns a list of the parse result of the receiver
   * followed by the parse result of [other]. Calling [SequenceParser#seq]
   * causes the sequences to be concatenated instead of nested.
   */
  Parser seq(Parser other) => new SequenceParser([this, other]);

  /**
   * Returns a parser that accepts the receiver or [other]. The resulting
   * parser returns the parse result of the receiver, if the receiver fails
   * it returns the parse result of [other] (exclusive ordered choice).
   */
  Parser or(Parser other) => new ChoiceParser([this, other]);

  /**
   * Returns a parser (logical and-predicate) that succeeds whenever the
   * receiver does, but never consumes input.
   */
  Parser and() => new AndParser(this);

  /**
   * Returns a parser (logical not-predicate) that succeeds whenever the
   * receiver fails, but never consumes input.
   */
  Parser not([String message]) => new NotParser(this, message);

  /**
   * Returns a parser that consumes any input token (character), but the
   * receiver.
   */
  Parser neg([String message]) => not(message).seq(any()).pick(1);

  Parser wrapper() => new WrapperParser(this);
  Parser flatten() => new FlattenParser(this);
  Parser token() => new TokenParser(this);
  Parser trim([Parser trimmer]) => new TrimmingParser(this, trimmer == null ? whitespace() : trimmer);
  Parser end([String message]) => new EndOfInputParser(this, message == null ? 'end of input expected' : message);

  /**
   * Returns a parser that evaluates [function] as action handler on success
   * of the receiver.
   */
  Parser map(Function function) => new ActionParser(this, function);

  /**
   * Returns a parser that transform a successful parse result by returning
   * the element at [index] of a list.
   */
  Parser pick(int index) => this.map((List list) => list[index]);

  /**
   * Returns a parser that transforms a successful parse result by returning
   * the permutated elements at [indexes] of a list.
   */
  Parser perm(List<int> indexes) {
    return this.map((List list) => indexes.map((index) => list[index]));
  }

  Parser separatedBy(Parser separator) {
    return new SequenceParser([this, new SequenceParser([separator, this]).star()]).map((List list) {
      var result = new List();
      result.add(list[0]);
      list[1].forEach((each) => result.addAll(each));
      return result;
    });
  }
  Parser withoutSeparators() {
    return map((List list) {
      var result = new List();
      for (var i = 0; i < list.length; i += 2) {
        result.add(list[i]);
      }
      return result;
    });
  }

  /**
   * Returns a list of directly referenced parsers.
   *
   * For example, [:letter().children:] returns the empty collection [:[]:],
   * because the letter parser is a primitive or leaf parser that does not
   * depend or call any other parser.
   *
   * In contrast, [:letter().or(digit()).children:] returns a collection
   * containing both the [:letter():] and [:digit():] parser.
   */
  List<Parser> get children => [];

  /**
   * Changes the receiver by replacing [source] with [target]. Does nothing
   * if [source] does not exist in [Parser#children].
   *
   * The following example creates a letter parser and then defines a parser
   * called [:example:] that accepts one or more letters. Eventually the parser
   * [:example:] is modified by replacing the [:letter:] parser with a new
   * parser that accepts a digit. The resulting [:example:] parser accepts one
   * or more digits.
   *
   *     var letter = letter();
   *     var example = letter.plus();
   *     example.replace(letter, digit());
   */
  void replace(Parser source, Parser target) {
    // no children, nothing to do
  }

}