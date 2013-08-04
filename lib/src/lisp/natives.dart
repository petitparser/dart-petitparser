// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of lisp;

/**
 * The native functions.
 */
class Natives {

  /** Imports the native functions into the [environment]. */
  static Environment import(Environment environment) {

    // basic functions
    environment.define(new Name('define'), _define);
    environment.define(new Name('lambda'), _lambda);
    environment.define(new Name('quote'), _quote);
    environment.define(new Name('eval'), _eval);
    environment.define(new Name('apply'), _apply);
    environment.define(new Name('let'), _let);
    environment.define(new Name('set!'), _set);
    environment.define(new Name('print'), _print);

    // control structures
    environment.define(new Name('if'), _if);
    environment.define(new Name('while'), _while);
    environment.define(new Name('and'), _and);
    environment.define(new Name('or'), _or);
    environment.define(new Name('not'), _not);

    // arithmetic operators
    environment.define(new Name('+'), _plus);
    environment.define(new Name('-'), _minus);
    environment.define(new Name('*'), _multiply);
    environment.define(new Name('/'), _divide);
    environment.define(new Name('%'), _modulo);

    // arithmetic comparators
    environment.define(new Name('<'), _smaller);
    environment.define(new Name('<='), _smallerOrEqual);
    environment.define(new Name('='), _equal);
    environment.define(new Name('!='), _notEqual);
    environment.define(new Name('>'), _larger);
    environment.define(new Name('>='), _largerOrEqual);

    // list operators
    environment.define(new Name('cons'), _cons);
    environment.define(new Name('car'), _car);
    environment.define(new Name('car!'), _carSet);
    environment.define(new Name('cdr'), _cdr);
    environment.define(new Name('cdr!'), _cdrSet);

    return environment;
  }

  static dynamic _define(Environment env, dynamic args) {
    if (args.head is Name) {
      return env.define(args.head, evalList(env, args.tail));
    } else if (args.head.head is Name) {
      return env.define(args.head.head, _lambda(env,
          new Cons(args.head.tail, args.tail)));
    } else {
      throw new ArgumentError('Invalid define: $args');
    }
  }

  static dynamic _lambda(Environment lambda_env, dynamic lambda_args) {
    return (Environment env, dynamic args) {
      var inner = lambda_env.create();
      var names = lambda_args.head;
      var values = evalArguments(env, args);
      while (names != null && values != null) {
        inner.define(names.head, values.head);
        names = names.tail;
        values = values.tail;
      }
      return evalList(inner, lambda_args.tail);
    };
  }

  static dynamic _quote(Environment env, dynamic args) {
    return args;
  }

  static dynamic _eval(Environment env, dynamic args) {
    return eval(env.create(), eval(env, args.head));
  }

  static dynamic _apply(Environment env, dynamic args) {
    return eval(env, args.head)(env.create(), args.tail);
  }

  static dynamic _let(Environment env, dynamic args) {
    var inner = env.create();
    var binding = args.head;
    while (binding != null) {
      inner.define(binding.head.head, eval(env, binding.head.tail.head));
      binding = binding.tail;
    }
    return evalList(inner, args.tail);
  }

  static dynamic _set(Environment env, dynamic args) {
    return env[args.head] = eval(env, args.tail.head);
  }

  static dynamic _print(Environment env, dynamic args) {
    var buffer = new StringBuffer();
    while (args != null) {
      buffer.write(eval(env, args.head));
      args = args.tail;
    }
    print(buffer);
    return null;
  }

  static dynamic _if(Environment env, dynamic args) {
    var condition = eval(env, args.head);
    if (condition) {
      if (args.tail != null) {
        return eval(env, args.tail.head);
      }
    } else {
      if (args.tail != null && args.tail.tail != null) {
        return eval(env, args.tail.tail.head);
      }
    }
    return null;
  }

  static dynamic _while(Environment env, dynamic args) {
    var result = null;
    while (eval(env, args.head)) {
      result = evalList(env, args.tail);
    }
    return result;
  }

  static dynamic _and(Environment env, dynamic args) {
    while (args != null) {
      if (!eval(env, args.head)) {
        return false;
      }
      args = args.tail;
    }
    return true;
  }

  static dynamic _or(Environment env, dynamic args) {
      while (args != null) {
        if (eval(env, args.head)) {
          return true;
        }
        args = args.tail;
      }
      return false;
    }

  static dynamic _not(Environment env, dynamic args) {
    return !eval(env, args.head);
  }

  static dynamic _plus(Environment env, dynamic args) {
    var value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value += eval(env, args.head);
    }
    return value;
  }

  static dynamic _minus(Environment env, dynamic args) {
    var value = eval(env, args.head);
    if (args.tail == null) {
      return -value;
    }
    for (args = args.tail; args != null; args = args.tail) {
      value -= eval(env, args.head);
    }
    return value;
  }

  static dynamic _multiply(Environment env, dynamic args) {
    var value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value *= eval(env, args.head);
    }
    return value;
  }

  static dynamic _divide(Environment env, dynamic args) {
    var value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value /= eval(env, args.head);
    }
    return value;
  }

  static dynamic _modulo(Environment env, dynamic args) {
    var value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value %= eval(env, args.head);
    }
    return value;
  }

  static dynamic _smaller(Environment env, dynamic args) {
    return eval(env, args.head) < eval(env, args.tail.head);
  }

  static dynamic _smallerOrEqual(Environment env, dynamic args) {
    return eval(env, args.head) <= eval(env, args.tail.head);
  }

  static dynamic _equal(Environment env, dynamic args) {
    return eval(env, args.head) == eval(env, args.tail.head);
  }

  static dynamic _notEqual(Environment env, dynamic args) {
    return eval(env, args.head) != eval(env, args.tail.head);
  }

  static dynamic _larger(Environment env, dynamic args) {
    return eval(env, args.head) > eval(env, args.tail.head);
  }

  static dynamic _largerOrEqual(Environment env, dynamic args) {
    return eval(env, args.head) >= eval(env, args.tail.head);
  }


  static dynamic _cons(Environment env, dynamic args) {
    return new Cons(eval(env, args.head), eval(env, args.tail.head));
  }

  static dynamic _car(Environment env, dynamic args) {
    var cons = eval(env, args.head);
    return cons is Cons ? cons.head : null;
  }

  static dynamic _carSet(Environment env, dynamic args) {
    var cons = eval(env, args.head);
    if (cons is Cons) {
      cons.head = eval(env, args.tail.head);
    }
    return cons;
  }

  static dynamic _cdr(Environment env, dynamic args) {
    var cons = eval(env, args.head);
    return cons is Cons ? cons.tail : null;
  }

  static dynamic _cdrSet(Environment env, dynamic args) {
    var cons = eval(env, args.head);
    if (cons is Cons) {
      cons.tail = eval(env, args.tail.head);
    }
    return cons;
  }

}