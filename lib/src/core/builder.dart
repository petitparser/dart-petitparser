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
  final List<_ExpressionOperator> _primitive = new List();
  final List<_ExpressionOperator> _prefix = new List();
  final List<_ExpressionOperator> _postfix = new List();
  final List<_ExpressionOperator> _right = new List();
  final List<_ExpressionOperator> _left = new List();

  ExpressionGroup(this.builder);

  /**
   * Adds a custom parser to this group, for example to parse numbers
   * or to recurse into another group.
   */
  void primitive(Parser parser, [void action(value)]) {
    _primitive.add(new _PrimitiveOperator(parser, action));
  }

  /**
   * Defines a prefix [operator]. Evaluates the [action] with the
   * parsed `operator` and `value`.
   */
  void prefix(Parser operator, [void action(operator, value)]) {
    _prefix.add(new _PrefixOperator(operator, action));
  }

  /**
   * Defines a postfix [operator]. Evaluates the [action] with the
   * parsed `value` and `operator`.
   */
  void postfix(Parser operator, [void action(value, operator)]) {
    _postfix.add(new _PostfixOperator(operator, action));
  }

  /**
   * Defines an [operator] that is right-associative. Evaluates the
   * [action] with the parsed `left` term, `operator`, and `right`
   * term.
   */
  void right(Parser operator, [void action(left, operator, right)]) {
    _right.add(new _RightOperator(operator, action));
  }

  /**
   * Defines an [operator] that is left-associative. Evaluates the
   * [action] with the parsed `left` term, `operator`, and `right`
   * term.
   */
  void left(Parser operator, [void action(left, operator, right)]) {
    _left.add(new _LeftOperator(operator, action));
  }

  Parser _build(Parser parser) {
    return [_primitive, _prefix, _postfix, _right, _left].fold(parser, (parser, list) {
      if (list.isEmpty) {
        return parser;
      } else if (list.size == 1) {
        return list.first(parser);
      } else {
        return list.fold(new _ChoiceParser([]), (choice, function) {
          return choice.or(function(parser));
        });
      }
    });
  }

}

class _ExpressionOperator {
  final Parser operator;
  final Function action;
  _ExpressionOperator(this.operator, this.action);
}

class _PrimitiveOperator implements _ExpressionOperator {
  _PrimitiveOperator(operator, action) : super(operator, action);
}
