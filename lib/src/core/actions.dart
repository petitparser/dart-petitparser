// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/** Function interface for parse actions. */
typedef dynamic _ActionFunction(dynamic argument);

/**
 * A parser that performs a transformation with a given function on the
 * successful parse result of the delegate.
 */
class _ActionParser extends _DelegateParser {

  final _ActionFunction _function;

  _ActionParser(parser, this._function) : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
    if (result.isSuccess) {
      return result.success(_function(result.result));
    } else {
      return result;
    }
  }

}

/**
 * A parser that silently consumes input of a parser around its delegate.
 */
class _TrimmingParser extends _DelegateParser {

  Parser _trimmer;

  _TrimmingParser(parser, this._trimmer) : super(parser);

  Result _parse(Context context) {
    var current = context;
    do {
      current = _trimmer._parse(current);
    } while (current.isSuccess);
    var result = super._parse(current);
    if (result.isFailure) {
      return result;
    }
    current = result;
    do {
      current = _trimmer._parse(current);
    } while (current.isSuccess);
    return current.success(result.result);
  }

  List<Parser> get children => [_delegate, _trimmer];

  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (identical(_trimmer, source)) {
      _trimmer = target;
    }
  }

}

/**
 * A parser that answers a substring of the range its delegate parses.
 */
class _FlattenParser extends _DelegateParser {

  _FlattenParser(parser) : super(parser);

  Result _parse(Context context) {
    var result = super._parse(context);
    if (result.isSuccess) {
      return result.success(_flatten(context.buffer, context.position,
                                     result.position));
    } else {
      return result;
    }
  }

  dynamic _flatten(dynamic buffer, int start, int stop) {
    return buffer.substring(start, stop);
  }

}
