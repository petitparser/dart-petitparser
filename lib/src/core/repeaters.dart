part of petitparser;

/**
 * An [int] used to mark an unbounded maximum repetition.
 */
const int unbounded = -1;

/**
 * An abstract parser that repeatedly parses between 'min' and 'max' instances of
 * its delegate.
 */
abstract class RepeatingParser extends DelegateParser {

  final int _min;
  final int _max;

  RepeatingParser(Parser parser, this._min, this._max)
      : super(parser) {
    assert(0 <= _min);
    assert(_max == unbounded || _min <= _max);
  }

  @override
  String toString() {
    var max = _max == unbounded ? '*' : _max;
    return '${super.toString()}[$_min..$max]';
  }

  @override
  bool equalProperties(RepeatingParser other) {
    return super.equalProperties(other) && _min == other._min && _max == other._max;
  }

}

/**
 * A greedy parser that repeatedly parses between 'min' and 'max' instances of
 * its delegate.
 */
class PossessiveRepeatingParser extends RepeatingParser {

  PossessiveRepeatingParser(Parser parser, int min, int max)
      : super(parser, min, max);

  @override
  Result parseOn(Context context) {
    var current = context;
    var elements = new List();
    while (elements.length < _min) {
      var result = _delegate.parseOn(current);
      if (result.isFailure) {
        return result;
      }
      elements.add(result.value);
      current = result;
    }
    while (_max == unbounded || elements.length < _max) {
      var result = _delegate.parseOn(current);
      if (result.isFailure) {
        return current.success(elements);
      }
      elements.add(result.value);
      current = result;
    }
    return current.success(elements);
  }

  @override
  Parser copy() => new PossessiveRepeatingParser(_delegate, _min, _max);

}

/**
 * An abstract parser that repeatedly parses between 'min' and 'max' instances of
 * its delegate and that requires the input to be completed with a specified parser
 * 'limit'. Subclasses provide repeating behavior as typically seen in regular
 * expression implementations (non-blind).
 */
abstract class LimitedRepeatingParser extends RepeatingParser {

  Parser _limit;

  LimitedRepeatingParser(Parser parser, this._limit, int min, int max)
      : super(parser, min, max);

  @override
  List<Parser> get children => [_delegate, _limit];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (_limit == source) {
      _limit = target;
    }
  }

}

/**
 * A greedy repeating parser, commonly seen in regular expression implementations. It
 * aggressively consumes as much input as possible and then backtracks to meet the
 * 'limit' condition.
 */
class GreedyRepeatingParser extends LimitedRepeatingParser {

  GreedyRepeatingParser(Parser parser, Parser limit, int min, int max)
      : super(parser, limit, min, max);

  @override
  Result parseOn(Context context) {
    var current = context;
    var elements = new List();
    while (elements.length < _min) {
      var result = _delegate.parseOn(current);
      if (result.isFailure) {
        return result;
      }
      elements.add(result.value);
      current = result;
    }
    var contexts = new List.from([current]);
    while (_max == unbounded || elements.length < _max) {
      var result = _delegate.parseOn(current);
      if (result.isFailure) {
        break;
      }
      elements.add(result.value);
      contexts.add(current = result);
    }
    while (true) {
      var limit = _limit.parseOn(contexts.last);
      if (limit.isSuccess) {
        return contexts.last.success(elements);
      }
      if (elements.isEmpty) {
        return limit;
      }
      contexts.removeLast();
      elements.removeLast();
      if (contexts.isEmpty) {
        return limit;
      }
    }
  }

  @override
  Parser copy() => new GreedyRepeatingParser(_delegate, _limit, _min, _max);

}

/**
 * A lazy repeating parser, commonly seen in regular expression implementations. It
 * limits its consumption to meet the 'limit' condition as early as possible.
 */
class LazyRepeatingParser extends LimitedRepeatingParser {

  LazyRepeatingParser(Parser parser, Parser limit, int min, int max)
      : super(parser, limit, min, max);

  @override
  Result parseOn(Context context) {
    var current = context;
    var elements = new List();
    while (elements.length < _min) {
      var result = _delegate.parseOn(current);
      if (result.isFailure) {
        return result;
      }
      elements.add(result.value);
      current = result;
    }
    while (true) {
      var limit = _limit.parseOn(current);
      if (limit.isSuccess) {
        return current.success(elements);
      } else {
        if (_max != unbounded && elements.length >= _max) {
          return limit;
        }
        var result = _delegate.parseOn(current);
        if (result.isFailure) {
          return limit;
        }
        elements.add(result.value);
        current = result;
      }
    }
  }

  @override
  Parser copy() => new LazyRepeatingParser(_delegate, _limit, _min, _max);

}
