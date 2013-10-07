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
   * Defines a priority group during the evaluation of the [scope]."
   */
  void group(void scope(ExpressionGroup group)) {
    var group = new ExpressionGroup(this);
    _groups.add(group);
    scope(group);
  }

  /**
   * Returns the outermost parser of the grammar.
   */
  Parser get root => _groups.first.root;

}

class ExpressionGroup {

  static final int _PRIMITIVE = 0;
  static final int _PREFIX = 1;
  static final int _POSTFIX = 2;
  static final int _RIGHT = 3;
  static final int _LEFT = 4;

  /**
   * Returns the builder that this group is part of.
   */
  final ExpressionBuilder builder;

  /**
   * Returns the outermost parser of the group.
   */
  final SetableParser root = undefined();

  /**
   * Defined operators in the group.
   */
  final Map<int, List<_ExpressionOperator>> _operators = new Map();

  ExpressionGroup(this.builder);

  /**
   * Adds a custom parser to this group, for example to parse numbers
   * or to recurse into another group.
   */
  void primitive(Parser parser, [void action(value)]) {
    // TODO(renggli): kill all the unnecessary indirection
    _operators.putIfAbsent(_PRIMITIVE, () => new List())
        .add(new _ExpressionOperator(parser, action, (parsers, next) {
          return parsers.map((result) => result.action(result.value));
        }));
  }

  /**
   * Defines a prefix [operator]. Evaluates the [action] with the
   * parsed `operator` and `value`.
   */
  void prefix(Parser operator, [void action(operator, value)]) {
    _operators.putIfAbsent(_PREFIX, () => new List())
        .add(new _ExpressionOperator(operator, action, (operators, next) {
          return new _SequenceParser([operators, next]).map((results) {
            return results.first.action(results.first.value, results.last);
          });
        }));
  }

  /**
   * Defines a postfix [operator]. Evaluates the [action] with the
   * parsed `value` and `operator`.
   */
  void postfix(Parser operator, [void action(value, operator)]) {
    _operators.putIfAbsent(_POSTFIX, () => new List())
        .add(new _ExpressionOperator(operator, action, (operators, next) {
          return new _SequenceParser([next, operators]).map((results) {
            return results.last.action(results.first, results.last.value);
          });
        }));
  }

  /**
   * Defines an [operator] that is right-associative. Evaluates the
   * [action] with the parsed `left` term, `operator`, and `right`
   * term.
   */
  void right(Parser operator, [void action(left, operator, right)]) {
    _operators.putIfAbsent(_RIGHT, () => new List())
        .add(new _ExpressionOperator(operator, action, (operators, next) {
          return next.separatedBy(operators);
        }));
  }

  /**
   * Defines an [operator] that is left-associative. Evaluates the
   * [action] with the parsed `left` term, `operator`, and `right`
   * term.
   */
  void left(Parser operator, [void action(left, operator, right)]) {
    _operators.putIfAbsent(_LEFT, () => new List())
        .add(new _ExpressionOperator(operator, action, (operators, next) {
          return next.separatedBy(operators);
        }));
  }

  Parser _build(Parser parser) {
    var priorities = new List.from(_operators.keys)
        ..sort()
        ..map((priority) => _operators[priority]);
    return priorities.fold(parser, (parser, operators) {
      if (operators.isEmpty) {
        return parser;
      } else {
        var choice = operators
            .map((operator) => operator.parser.map((result) {
              return new _ExpressionOperatorResult(result, operator.action);
            }))
            .reduce((a, b) => a.or(b));
        return operators.combinator(choice, parser);
      }
    });
  }

}

class _ExpressionOperator {
  final Parser parser;
  final Function action;
  final Function combinator;
  _ExpressionOperator(this.parser, this.action, this.combinator);
}

class _ExpressionOperatorResult {
  final dynamic value;
  final Function action;
  _ExpressionOperatorResult(this.value, this.action);
}