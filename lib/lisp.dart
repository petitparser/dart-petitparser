// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

library lisp;

import 'dart:math';
import 'package:petitparser/petitparser.dart';

part 'src/lisp/cons.dart';
part 'src/lisp/environment.dart';
part 'src/lisp/grammar.dart';
part 'src/lisp/natives.dart';
part 'src/lisp/parser.dart';
part 'src/lisp/symbol.dart';

/** The evaluation function. */
Dynamic eval(Environment env, Dynamic expr) {
  if (expr is Cons) {
    return eval(env, expr.head)(env, expr.tail);
  } else if (expr is Symbol) {
    return env[expr];
  } else {
    return expr;
  }
}

/** The arguments evaluatation function. */
Dynamic evalArguments(Environment env, Dynamic args) {
  if (args != null) {
    return new Cons(eval(env, args.head), evalArguments(env, args.tail));
  } else {
    return args;
  }
}

/** Reads and evaluates a script [contents]. */
Dynamic evalString(Parser parser, Environment env, String script) {
  var result = null;
  for (var cell in parser.parse(script).result) {
    result = eval(env, cell);
  }
  return result;
}