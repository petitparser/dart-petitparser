import 'package:petitparser/petitparser.dart';

import 'cons.dart';
import 'environment.dart';
import 'name.dart';
import 'quote.dart';

/// The evaluation function.
dynamic eval(Environment env, dynamic expr) {
  if (expr is Quote) {
    return expr.datum;
  } else if (expr is Cons) {
    final Function function = eval(env, expr.head);
    return function(env, expr.tail);
  } else if (expr is Name) {
    return env[expr];
  } else {
    return expr;
  }
}

/// Evaluate a cons of instructions.
dynamic evalList(Environment env, dynamic expr) {
  dynamic result;
  while (expr is Cons) {
    result = eval(env, expr.head);
    expr = expr.tail;
  }
  return result;
}

/// The arguments evaluation function.
dynamic evalArguments(Environment env, dynamic args) {
  if (args is Cons) {
    return Cons(eval(env, args.head), evalArguments(env, args.tail));
  } else {
    return null;
  }
}

/// Reads and evaluates a [script].
dynamic evalString(Parser parser, Environment env, String script) {
  dynamic result;
  for (final cell in parser.parse(script).value) {
    result = eval(env, cell);
  }
  return result;
}
