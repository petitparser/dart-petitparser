// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('lisplib');

#import('dart:builtin');
#import('dart:io');

#import('../../lib/petitparser.dart');

#source('cons.dart');
#source('environment.dart');
#source('grammar.dart');
#source('natives.dart');
#source('parser.dart');
#source('symbol.dart');

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
  for (var cell in parser.parse(script).getResult()) {
    result = eval(env, cell);
  }
  return result;
}

/** Read, evaluate, print loop. */
void evalInteractive(Parser parser, Environment env, InputStream input, OutputStream output) {
  var stream = new StringInputStream(input);
  stream.onLine = () {
    output.writeString('${evalString(parser, env, stream.readLine())}\n');
  };
}