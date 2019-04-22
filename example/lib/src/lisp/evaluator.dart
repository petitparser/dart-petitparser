library petitparser.example.lisp.evaluator;

import 'package:example/src/lisp/cons.dart';
import 'package:example/src/lisp/environment.dart';
import 'package:example/src/lisp/name.dart';
import 'package:petitparser/petitparser.dart';

/// The evaluation function.
Object eval(Environment env, Object expr) {
  if (expr is Cons) {
    final Function function = eval(env, expr.head);
    return function(env, expr.tail);
  } else if (expr is Name) {
    return env[expr];
  } else {
    return expr;
  }
}

/// Evaluate a cons of instructions.
Object evalList(Environment env, Cons expr) {
  Object result;
  while (expr is Cons) {
    result = eval(env, expr.head);
    expr = expr.tail;
  }
  return result;
}

/// The arguments evaluation function.
Object evalArguments(Environment env, Cons args) {
  if (args is Cons) {
    return Cons(eval(env, args.head), evalArguments(env, args.tail));
  } else {
    return null;
  }
}

/// Reads and evaluates a [script].
Object evalString(Parser parser, Environment env, String script) {
  Object result;
  for (final cell in parser.parse(script).value) {
    result = eval(env, cell);
  }
  return result;
}
