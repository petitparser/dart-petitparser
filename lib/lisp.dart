/**
 * This package contains a simple grammar and evaluator for LISP.
 *
 * The code is reasonably complete to run and evaluate reasonably complex
 * programs from the console and from the web browser.
 */
library lisp;

import 'dart:collection';
import 'package:petitparser/petitparser.dart';

part 'src/lisp/cons.dart';
part 'src/lisp/environment.dart';
part 'src/lisp/grammar.dart';
part 'src/lisp/name.dart';
part 'src/lisp/natives.dart';
part 'src/lisp/parser.dart';
part 'src/lisp/standard.dart';

/** The evaluation function. */
eval(Environment env, expr) {
  if (expr is Cons) {
    return eval(env, expr.head)(env, expr.tail);
  } else if (expr is Name) {
    return env[expr];
  } else {
    return expr;
  }
}

/** Evaluate a cons of instructions. */
evalList(Environment env, expr) {
  var result = null;
  while (expr is Cons) {
    result = eval(env, expr.head);
    expr = expr.tail;
  }
  return result;
}

/** The arguments evaluatation function. */
evalArguments(Environment env, args) {
  if (args is Cons) {
    return new Cons(eval(env, args.head), evalArguments(env, args.tail));
  } else {
    return null;
  }
}

/** Reads and evaluates a [script]. */
evalString(LispParser parser, Environment env, String script) {
  var result = null;
  for (var cell in parser.parse(script).value) {
    result = eval(env, cell);
  }
  return result;
}
