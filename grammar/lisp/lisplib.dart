// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('lisplib');

#import('../../lib/petitparser.dart');

#source('cells.dart');
#source('environment.dart');
#source('grammar.dart');
#source('natives.dart');
#source('parser.dart');

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
Dynamic evalArgs(Environment env, Dynamic args) {
  if (args is Cons) {
    return new Cons(eval(env, args.head), evalArgs(env, args.tail));
  } else {
    return args;
  }
}