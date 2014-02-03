// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of petitparser;

/**
 * Builss a parser to conveniently define an expression grammar with
 * prefix, postfix, and left- and right-associative infix operators.
 *
 * The following code initializes a parser for arithmetic expressions.
 * First we instantiate an expression parser, a simple parser for
 * expressions in parenthesis and a simple parser for integer numbers.
 *
 *    var builder = new ExpressionBuilder();
 *
 *    expression := PPExpressionParser new.
 *    parens := $( asParser token trim , expression , $) asParser token trim
 *        ==> [ :nodes | nodes second ].
 *    integer := #digit asParser plus token trim
 *        ==> [ :token | token value asInteger ].
 *
 * Then we define on what term the expression grammar is built on:
 *
 *    expression term: parens / integer.
 *
 * Finally we define the operator-groups in descending precedence. Note, that
 * the action blocks receive both, the terms and the parsed operator in the
 * order they appear in the parsed input.
 *
 * expression
    group: [ :g |
      g prefix: $- asParser token trim do: [ :op :a | a negated ] ];
    group: [ :g |
      g postfix: '++' asParser token trim do: [ :a :op | a + 1 ].
      g postfix: '--' asParser token trim do: [ :a :op | a - 1 ] ];
    group: [ :g |
      g right: $^ asParser token trim do: [ :a :op :b | a raisedTo: b ] ];
    group: [ :g |
      g left: $* asParser token trim do: [ :a :op :b | a * b ].
      g left: $/ asParser token trim do: [ :a :op :b | a / b ] ];
    group: [ :g |
      g left: $+ asParser token trim do: [ :a :op :b | a + b ].
      g left: $- asParser token trim do: [ :a :op :b | a - b ] ].

After evaluating the above code the 'expression' is an efficient parser that evaluates examples like:

  expression parse: '-8++'.
  expression parse: '1+2*3'.
  expression parse: '1*2+3'.
  expression parse: '(1+2)*3'.
  expression parse: '8/4/2'.
  expression parse: '8/(4/2)'.
  expression parse: '2^2^3'.
  expression parse: '(2^2)^3'.

Instance Variables:
  operators <Dictionary>  The operators defined in the current group.
 */
class ExpressionBuilder {

  final List<ExpressionGroup> _groups = new List();

  /**
   * Creates a new group of operators that share the same prority.
   */
  ExpressionGroup group() {
    var group = new ExpressionGroup();
    _groups.add(group);
    return group;
  }

  /**
   * Builds an optimized version of the expression parser.
   */
  Parser build() => _groups.fold(epsilon(), (a, b) => b._build(a));

}

class ExpressionGroup {

  /**
   * Defines a new primitive or literal [parser].
   */
  void primitive(Parser parser) {
    _primitives.add(parser);
  }

  Parser _build_primitive(Parser inner) {
    return _build_choice(_primitives, inner);
  }

  final List<Parser> _primitives = new List();

  /**
   * Adds a prefix operator [parser]. Evaluates the optional [action] with the
   * parsed `operator` and `value`.
   */
  void prefix(Parser parser, [action(operator, value)]) {
    if (action == null) action = (operator, value) => [operator, value];
    _prefix.add(parser.map((operator) => new _ExpressionResult(operator, action)));
  }

  Parser _build_prefix(Parser inner) {
    if (_prefix.isEmpty) {
      return inner;
    } else {
      return new _SequenceParser([_build_choice(_prefix).star(), inner]).map((tuple) {
        return tuple.first.reversed.fold(tuple.last, (value, result) {
          return result.action(result.operator, value);
        });
      });
    }
  }

  final List<Parser> _prefix = new List();

  /**
   * Adds a postfix operator [parser]. Evaluates the optional [action] with the
   * parsed `value` and `operator`.
   */
  void postfix(Parser parser, [action(value, operator)]) {
    if (action == null) action = (value, operator) => [value, operator];
    _postfix.add(parser.map((operator) => new _ExpressionResult(operator, action)));
  }

  Parser _build_postfix(Parser inner) {
    if (_postfix.isEmpty) {
      return inner;
    } else {
      return new _SequenceParser([inner, _build_choice(_postfix).star()]).map((tuple) {
        return tuple.last.fold(tuple.first, (value, result) {
          return result.action(value, result.operator);
        });
      });
    }
  }

  final List<Parser> _postfix = new List();

  /**
   * Adds a right-associative operator [parser]. Evaluates the optional [action] with
   * the parsed `left` term, `operator`, and `right` term.
   */
  void right(Parser parser, [action(left, operator, right)]) {
    if (action == null) action = (left, operator, right) => [left, operator, right];
    _right.add(parser.map((operator) => new _ExpressionResult(operator, action)));
  }

  Parser _build_right(Parser inner) {
    if (_right.isEmpty) {
      return inner;
    } else {
      return inner.separatedBy(_build_choice(_right)).map((sequence) {
        var result = sequence.last;
        for (var i = sequence.length - 2; i > 0; i -= 2) {
          result = sequence[i].action(sequence[i - 1], sequence[i].operator, result);
        }
        return result;
      });
    }
  }

  final List<Parser> _right = new List();

  /**
   * Adds a left-associative operator [parser]. Evaluates the optional [action] with
   * the parsed `left` term, `operator`, and `right` term.
   */
  void left(Parser parser, [action(left, operator, right)]) {
    if (action == null) action = (left, operator, right) => [left, operator, right];
    _left.add(parser.map((operator) => new _ExpressionResult(operator, action)));
  }

  Parser _build_left(Parser inner) {
    if (_left.isEmpty) {
      return inner;
    } else {
      return inner.separatedBy(_build_choice(_left)).map((sequence) {
        var result = sequence.first;
        for (var i = 1; i < sequence.length; i += 2) {
          result = sequence[i].action(result, sequence[i].operator, sequence[i + 1]);
        }
        return result;
      });
    }
  }

  final List<Parser> _left = new List();

  // helper to build an optimized choice parser
  Parser _build_choice(List<Parser> parsers, [Parser otherwise]) {
    if (parsers.isEmpty) {
      return otherwise;
    } else if (parsers.length == 1) {
      return parsers.first;
    } else {
      return new _ChoiceParser(parsers);
    }
  }

  // helper to build the group of parsers
  Parser _build(Parser inner) {
    return _build_left(_build_right(
      _build_postfix(_build_prefix(
      _build_primitive(inner)))));
  }

}

// helper class to associate operators and actions
class _ExpressionResult {
  final dynamic operator;
  final Function action;
  _ExpressionResult(this.operator, this.action);
}