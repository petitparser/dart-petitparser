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

  static _define(Environment env, args) {
    if (args.head is Name) {
      return env.define(args.head, evalList(env, args.tail));
    } else if (args.head.head is Name) {
      return env.define(args.head.head, _lambda(env, new Cons(args.head.tail, args.tail)));
    } else {
      throw new ArgumentError('Invalid define: $args');
    }
  }

  static _lambda(Environment lambda_env, lambda_args) {
    return (Environment env, args) {
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

  static _quote(Environment env, args) {
    return args;
  }

  static _eval(Environment env, args) {
    return eval(env.create(), eval(env, args.head));
  }

  static _apply(Environment env, args) {
    return eval(env, args.head)(env.create(), args.tail);
  }

  static _let(Environment env, args) {
    var inner = env.create();
    var binding = args.head;
    while (binding != null) {
      inner.define(binding.head.head, eval(env, binding.head.tail.head));
      binding = binding.tail;
    }
    return evalList(inner, args.tail);
  }

  static _set(Environment env, args) {
    return env[args.head] = eval(env, args.tail.head);
  }

  static _print(Environment env, args) {
    var buffer = new StringBuffer();
    while (args != null) {
      buffer.write(eval(env, args.head));
      args = args.tail;
    }
    print(buffer);
    return null;
  }

  static _if(Environment env, args) {
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

  static _while(Environment env, args) {
    var result = null;
    while (eval(env, args.head)) {
      result = evalList(env, args.tail);
    }
    return result;
  }

  static _and(Environment env, args) {
    while (args != null) {
      if (!eval(env, args.head)) {
        return false;
      }
      args = args.tail;
    }
    return true;
  }

  static _or(Environment env, args) {
    while (args != null) {
      if (eval(env, args.head)) {
        return true;
      }
      args = args.tail;
    }
    return false;
  }

  static _not(Environment env, args) {
    return !eval(env, args.head);
  }

  static _plus(Environment env, args) {
    var value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value += eval(env, args.head);
    }
    return value;
  }

  static _minus(Environment env, args) {
    var value = eval(env, args.head);
    if (args.tail == null) {
      return -value;
    }
    for (args = args.tail; args != null; args = args.tail) {
      value -= eval(env, args.head);
    }
    return value;
  }

  static _multiply(Environment env, args) {
    var value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value *= eval(env, args.head);
    }
    return value;
  }

  static _divide(Environment env, args) {
    var value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value /= eval(env, args.head);
    }
    return value;
  }

  static _modulo(Environment env, args) {
    var value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value %= eval(env, args.head);
    }
    return value;
  }

  static _smaller(Environment env, args) {
    return eval(env, args.head) < eval(env, args.tail.head);
  }

  static _smallerOrEqual(Environment env, args) {
    return eval(env, args.head) <= eval(env, args.tail.head);
  }

  static _equal(Environment env, args) {
    return eval(env, args.head) == eval(env, args.tail.head);
  }

  static _notEqual(Environment env, args) {
    return eval(env, args.head) != eval(env, args.tail.head);
  }

  static _larger(Environment env, args) {
    return eval(env, args.head) > eval(env, args.tail.head);
  }

  static _largerOrEqual(Environment env, args) {
    return eval(env, args.head) >= eval(env, args.tail.head);
  }


  static _cons(Environment env, args) {
    return new Cons(eval(env, args.head), eval(env, args.tail.head));
  }

  static _car(Environment env, args) {
    var cons = eval(env, args.head);
    return cons is Cons ? cons.head : null;
  }

  static _carSet(Environment env, args) {
    var cons = eval(env, args.head);
    if (cons is Cons) {
      cons.head = eval(env, args.tail.head);
    }
    return cons;
  }

  static _cdr(Environment env, args) {
    var cons = eval(env, args.head);
    return cons is Cons ? cons.tail : null;
  }

  static _cdrSet(Environment env, args) {
    var cons = eval(env, args.head);
    if (cons is Cons) {
      cons.tail = eval(env, args.tail.head);
    }
    return cons;
  }

}
