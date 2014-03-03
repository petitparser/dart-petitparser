part of petitparser;

/**
 * A parser that performs a transformation with a given function on the
 * successful parse result of the delegate.
 */
class ActionParser extends DelegateParser {

  final Function _function;

  ActionParser(parser, this._function): super(parser);

  @override
  Result parseOn(Context context) {
    var result = _delegate.parseOn(context);
    if (result.isSuccess) {
      return result.success(_function(result.value));
    } else {
      return result;
    }
  }

  @override
  Parser copy() => new ActionParser(_delegate, _function);

  @override
  bool equalProperties(ActionParser other) {
    return super.equalProperties(other) && _function == other._function;
  }

}

/**
 * A parser that silently consumes input of another parser around
 * its delegate.
 */
class TrimmingParser extends DelegateParser {

  Parser _trimmer;

  TrimmingParser(parser, this._trimmer): super(parser);

  @override
  Result parseOn(Context context) {
    var current = context;
    do {
      current = _trimmer.parseOn(current);
    } while (current.isSuccess);
    var result = _delegate.parseOn(current);
    if (result.isFailure) {
      return result;
    }
    current = result;
    do {
      current = _trimmer.parseOn(current);
    } while (current.isSuccess);
    return current.success(result.value);
  }

  @override
  Parser copy() => new TrimmingParser(_delegate, _trimmer);

  @override
  List<Parser> get children => [_delegate, _trimmer];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (_trimmer == source) {
      _trimmer = target;
    }
  }

}

/**
 * A parser that answers a substring or sublist of the range its delegate
 * parses.
 */
class FlattenParser extends DelegateParser {

  FlattenParser(parser): super(parser);

  @override
  Result parseOn(Context context) {
    var result = _delegate.parseOn(context);
    if (result.isSuccess) {
      var output = context.buffer is String
          ? context.buffer.substring(context.position, result.position)
          : context.buffer.sublist(context.position, result.position);
      return result.success(output);
    } else {
      return result;
    }
  }

  @override
  Parser copy() => new FlattenParser(_delegate);

}

/**
 * A parser that answers a token of the result its delegate parses.
 */
class TokenParser extends DelegateParser {

  TokenParser(parser): super(parser);

  @override
  Result parseOn(Context context) {
    var result = _delegate.parseOn(context);
    if (result.isSuccess) {
      var token = new Token(result.value, context.buffer, context.position, result.position);
      return result.success(token);
    } else {
      return result;
    }
  }

  @override
  Parser copy() => new TokenParser(_delegate);

}
