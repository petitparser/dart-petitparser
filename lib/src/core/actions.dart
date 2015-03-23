part of petitparser;

/**
 * A parser that performs a transformation with a given function on the
 * successful parse result of the delegate.
 */
class ActionParser extends DelegateParser {
  final Function _function;

  ActionParser(parser, this._function) : super(parser);

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
  bool hasEqualProperties(Parser other) {
    return other is ActionParser
        && super.hasEqualProperties(other)
        && _function == other._function;
  }
}

/**
 * A parser that silently consumes input of another parser around
 * its delegate.
 */
class TrimmingParser extends DelegateParser {
  Parser _left;
  Parser _right;

  TrimmingParser(parser, this._left, this._right) : super(parser);

  @override
  Result parseOn(Context context) {
    var current = context;
    do {
      current = _left.parseOn(current);
    } while (current.isSuccess);
    var result = _delegate.parseOn(current);
    if (result.isFailure) {
      return result;
    }
    current = result;
    do {
      current = _right.parseOn(current);
    } while (current.isSuccess);
    return current.success(result.value);
  }

  @override
  Parser copy() => new TrimmingParser(_delegate, _left, _right);

  @override
  List<Parser> get children => [_delegate, _left, _right];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (_left == source) {
      _left = target;
    }
    if (_right == source) {
      _right = target;
    }
  }
}

/**
 * A parser that answers a substring or sub-list of the range its delegate
 * parses.
 */
class FlattenParser extends DelegateParser {
  FlattenParser(parser) : super(parser);

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
  TokenParser(parser) : super(parser);

  @override
  Result parseOn(Context context) {
    var result = _delegate.parseOn(context);
    if (result.isSuccess) {
      var token = new Token(
          result.value, context.buffer, context.position, result.position);
      return result.success(token);
    } else {
      return result;
    }
  }

  @override
  Parser copy() => new TokenParser(_delegate);
}
