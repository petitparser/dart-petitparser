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

  final List<_ExpressionGroup> _groups = new List();

  /**
   * Defines a priority group during the evaluation of the [scope]."
   */
  void group(void scope(_ExpressionGroup group)) {
    var group = new _ExpressionGroup();
    _groups.add(group);
    scope(group);
  }

}

class _ExpressionGroup {

  final List<Function> _prefix = new List();
  final List<Function> _postfix = new List();
  final List<Function> _right = new List();
  final List<Function> _left = new List();

  /**
   * Defines a prefix [operator]. Evaluates the [action] with the
   * parsed `operator` and `value`.
   */
  void prefix(Parser operator, [void action(operator, value)]) {
    _prefix.add((parser) {
      var result = new _SequenceParser([operator.star(), parser]);
      if (action != null) {
        result = result.map((input) {
          var value = input.last;
          for (var i = input.first.length - 1; i >= 0; i--) {
            value = action(input.first[i], value);
          }
          return value;
        });
      }
      return result;
    });
  }

  /**
   * Defines a postfix [operator]. Evaluates the [action] with the
   * parsed `value` and `operator`.
   */
  void postfix(Parser operator, [void action(value, operator)]) {
    _postfix.add((parser) {
      var result = new _SequenceParser([parser, operator.star()]);
      if (action != null) {
        result = result.map((input) {
          var value = input.first;
          for (var i = 0; i < input.second.length; i++) {
            value = action(value, input.second[i]);
          }
          return value;
        });
      }
      return result;
    });
  }

  /**
   * Defines an [operator] that is right-associative. Evaluates the
   * [action] with the parsed `left` term, `operator`, and `right`
   * term.
   */
  void right(Parser operator, [void action(left, operator, right)]) {
    _right.add((parser) {
      var result = parser.separatedBy(operator);
      if (action != null) {
        result = result.map((input) {
          var value = input.last;
          for (var i = input.length - 3; i >= 0; i -= 2) {
            value = action(input[i], input[i + 1], value);
          }
          return value;
        });
      }
      return result;
    });
  }

  /**
   * Defines an [operator] that is left-associative. Evaluates the
   * [action] with the parsed `left` term, `operator`, and `right`
   * term.
   */
  void left(Parser operator, [void action(left, operator, right)]) {
    _left.add((parser) {
      var result = parser.separatedBy(operator);
      if (action != null) {
        result = result.map((input) {
          var value = input.first;
          for (var i = 1; i < input.length; i += 2) {
            value = action(value, input[i], input[i + 1]);
          }
          return value;
        });
      }
      return result;
    });
  }

  Parser _build(Parser parser) {
    return [_prefix, _postfix, _right, _left].fold(parser, (parser, list) {
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
