// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Abstract base class for all parsers.
 */
class Parser {

  /**
   * Private abstract method doing the actual parsing.
   *
   * The methods takes a parse [context] and returns the resulting context,
   * which is either a [Success] or [Failure] context.
   */
  abstract Result _parse(Context context);

  /**
   * Returns the parse result of the [input].
   *
   * The implementation creates a default parse context on the input and calls
   * the internal parsing logic of the receiving parser.
   *
   * For example, [:letter().plus().parse('abc'):] results in an instance of
   * [Success], where [Success#position] is [:3:] and [Success.result] is
   * [:[a, b, c]:].
   *
   * Similarly, [:letter().plus().parse('123'):] results in an instance of
   * [Failure], where [Success#position] is [:0:] and [Success.message] is
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
   * Returns new parser that parses the receiver, if possible. The resulting
   * parser returns the result of the receiver, or [:null:] if not applicable.
   */
  Parser optional() => new OptionalParser(this);

  /**
   * Returns a parser that parses the receiver zero or more times. The
   * resulting parser returns a list of the parse results of the receiver.
   */
  Parser star() => repeat(0, 65536);

  /**
   * Returns a parser that parses the receiver one or more times. The
   * resulting parser returns a list of the parse results of the receiver.
   */
  Parser plus() => repeat(1, 65536);

  /**
   * Returns a parser that parses the receiver exactly [count] times. The
   * resulting parser returns a list of the parse results of the receiver.
   */
  Parser times(int count) => repeat(count, count);

  /**
   * Returns a parser that parses the receiver between [min] and [max] times.
   * The resulting parser returns a list of the parse results of the receiver.
   */
  Parser repeat(int min, int max) => new RepeatingParser(this, min, max);

  Parser seq(Parser other) => new SequenceParser([this, other]);
  Parser or(Parser other) => new ChoiceParser([this, other]);

  Parser and() => new AndParser(this);
  Parser not([String message]) => new NotParser(this, message);
  Parser neg([String message]) => not(message).seq(any()).map((each) => each[1]);

  Parser wrapper() => new WrapperParser(this);
  Parser flatten() => new FlattenParser(this);
  Parser token() => new TokenParser(this);
  Parser trim([Parser trimmer]) => new TrimmingParser(this, trimmer == null ? whitespace() : trimmer);
  Parser map(Function function) => new ActionParser(this, function);
  Parser end([String message]) => new EndOfInputParser(this, message == null ? 'end of input expected' : message);

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

  // reflection functions
  // // // // // // // // // // // // // // // // // // // // // // // //

  /** Returns a list of directly referring parsers. */
  List<Parser> get children => [];

  /** Replaces [source] with [target], if [source] exists. */
  void replace(Parser source, Parser target) {
    // no children, nothing to do
  }

}

/** Returns a parser that consumes nothing and succeeds. */
Parser epsilon() => new _EpsilonParser();

class _EpsilonParser extends Parser {
  Result _parse(Context context) => context.success(null);
}

/** Returns a parser that consumes nothing and fails. */
Parser failure(String message) => new _FailureParser(message);

class _FailureParser extends Parser {
  final String _message;
  _FailureParser(this._message);
  Result _parse(Context context) => context.failure(_message);
}

/**
 * A parser that delegates to another one.
 */
class DelegateParser extends Parser {

  Parser _delegate;

  DelegateParser(this._delegate);

  Result _parse(Context context) {
    return _delegate._parse(context);
  }

  List<Parser> get children => [_delegate];

  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (identical(_delegate, source)) {
      _delegate = target;
    }
  }

}

/**
 * A parser that succeeds only at the end of the input.
 */
class EndOfInputParser extends DelegateParser {

  final String _message;

  EndOfInputParser(parser, this._message)
    : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
    if (result.isFailure() || result.position == result.buffer.length) {
      return result;
    }
    return result.failure(_message, result.position);
  }

}