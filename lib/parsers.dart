// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * Abstract base class for all parsers.
 */
abstract class Parser {

  // parsing related functions
  // // // // // // // // // // // // // // // // // // // // // // // //

  /** Internal abstract method doing the actual parsing. */
  abstract Result _parse(Context context);

  /** Returns the parse result of the input. */
  Result parse(Dynamic input) {
    return _parse(new Context(input, 0));
  }

  /** Tests if the input can be successfully parsed. */
  bool accept(Dynamic input) {
    return parse(input).isSuccess();
  }

  /** Returns a list of all successful overlapping parses of the input. */
  List<Dynamic> matches(Dynamic input) {
    var list = new List();
    and().map((each) => list.add(each)).seq(any()).or(any()).star().parse(input);
    return list;
  }

  /** Returns a list of all successful non-overlapping parses of the input. */
  List<Dynamic> matchesSkipping(Dynamic input) {
    var list = new List();
    map((each) => list.add(each)).or(any()).star().parse(input);
    return list;
  }

  // parser combinator functions
  // // // // // // // // // // // // // // // // // // // // // // // //

  Parser optional() => new OptionalParser(this);
  Parser star() => new RepeatingParser(this, 0, 65536);
  Parser plus() => new RepeatingParser(this, 1, 65536);
  Parser times(int count) => new RepeatingParser(this, count, count);
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
  List<Parser> get children() => [];

  /** Replaces [source] with [target], if [source] exists. */
  void replace(Parser source, Parser target) {
    // no children, nothing to do
  }

}

/**
 * A parser that consumes nothing and always succeeds.
 */
class EpsilonParser extends Parser {

  Result _parse(Context context) {
    return context.success(null);
  }

}

/**
 * A parser that consumes nothing and always fails.
 */
class FailureParser extends Parser {

  final String _message;

  FailureParser(this._message);

  Result _parse(Context context) {
    return context.failure(_message);
  }

}

/**
 * A parser that delegates to another one.
 */
abstract class DelegateParser extends Parser {

  Parser _delegate;

  DelegateParser(this._delegate);

  Result _parse(Context context) {
    return _delegate._parse(context);
  }

  List<Parser> get children() => [_delegate];

  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (_delegate === source) {
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