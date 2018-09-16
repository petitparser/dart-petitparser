library petitparser.example.lisp.native;

import 'cons.dart';
import 'environment.dart';
import 'evaluator.dart';
import 'name.dart';

class NativeEnvironment extends Environment {
  NativeEnvironment([Environment owner]) : super(owner) {
    // basic functions
    define(Name('define'), _define);
    define(Name('lambda'), _lambda);
    define(Name('quote'), _quote);
    define(Name('eval'), _eval);
    define(Name('apply'), _apply);
    define(Name('let'), _let);
    define(Name('set!'), _set);
    define(Name('print'), _print);

    // control structures
    define(Name('if'), _if);
    define(Name('while'), _while);
    define(Name('and'), _and);
    define(Name('or'), _or);
    define(Name('not'), _not);

    // arithmetic operators
    define(Name('+'), _plus);
    define(Name('-'), _minus);
    define(Name('*'), _multiply);
    define(Name('/'), _divide);
    define(Name('%'), _modulo);

    // arithmetic comparators
    define(Name('<'), _smaller);
    define(Name('<='), _smallerOrEqual);
    define(Name('='), _equal);
    define(Name('!='), _notEqual);
    define(Name('>'), _larger);
    define(Name('>='), _largerOrEqual);

    // list operators
    define(Name('cons'), _cons);
    define(Name('car'), _car);
    define(Name('car!'), _carSet);
    define(Name('cdr'), _cdr);
    define(Name('cdr!'), _cdrSet);
  }

  static _define(Environment env, Cons args) {
    if (args.head is Name) {
      return env.define(args.head, evalList(env, args.tail));
    } else if (args.head is Cons) {
      Cons head = args.head;
      if (head.head is Name) {
        return env.define(head.head, _lambda(env, Cons(head.tail, args.tail)));
      }
    } else {
      throw ArgumentError('Invalid define: $args');
    }
  }

  static _lambda(Environment lambdaEnv, Cons lambdaArgs) {
    return (Environment evalEnv, Cons evalArgs) {
      final inner = lambdaEnv.create();
      Cons names = lambdaArgs.head;
      Cons values = evalArguments(evalEnv, evalArgs);
      while (names != null && values != null) {
        inner.define(names.head, values.head);
        names = names.tail;
        values = values.tail;
      }
      return evalList(inner, lambdaArgs.tail);
    };
  }

  static _quote(Environment env, Cons args) {
    return args;
  }

  static _eval(Environment env, Cons args) {
    return eval(env.create(), eval(env, args.head));
  }

  static _apply(Environment env, Cons args) {
    Function fun = eval(env, args.head);
    return fun(env.create(), args.tail);
  }

  static _let(Environment env, Cons args) {
    final inner = env.create();
    Cons binding = args.head;
    while (binding is Cons) {
      Cons definition = binding.head;
      inner.define(definition.head, eval(env, definition.tail.head));
      binding = binding.tail;
    }
    return evalList(inner, args.tail);
  }

  static _set(Environment env, Cons args) {
    return env[args.head] = eval(env, args.tail.head);
  }

  static _print(Environment env, Cons args) {
    var buffer = StringBuffer();
    while (args != null) {
      buffer.write(eval(env, args.head));
      args = args.tail;
    }
    printer(buffer.toString());
    return null;
  }

  static _if(Environment env, Cons args) {
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

  static _while(Environment env, Cons args) {
    var result;
    while (eval(env, args.head)) {
      result = evalList(env, args.tail);
    }
    return result;
  }

  static _and(Environment env, Cons args) {
    while (args != null) {
      if (!eval(env, args.head)) {
        return false;
      }
      args = args.tail;
    }
    return true;
  }

  static _or(Environment env, Cons args) {
    while (args != null) {
      if (eval(env, args.head)) {
        return true;
      }
      args = args.tail;
    }
    return false;
  }

  static _not(Environment env, Cons args) {
    return !eval(env, args.head);
  }

  static _plus(Environment env, Cons args) {
    num value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value += eval(env, args.head);
    }
    return value;
  }

  static _minus(Environment env, Cons args) {
    num value = eval(env, args.head);
    if (args.tail == null) {
      return -value;
    }
    for (args = args.tail; args != null; args = args.tail) {
      value -= eval(env, args.head);
    }
    return value;
  }

  static _multiply(Environment env, Cons args) {
    num value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value *= eval(env, args.head);
    }
    return value;
  }

  static _divide(Environment env, Cons args) {
    num value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value /= eval(env, args.head);
    }
    return value;
  }

  static _modulo(Environment env, Cons args) {
    num value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value %= eval(env, args.head);
    }
    return value;
  }

  static _smaller(Environment env, Cons args) {
    Comparable a = eval(env, args.head);
    Comparable b = eval(env, args.tail.head);
    return a.compareTo(b) < 0;
  }

  static _smallerOrEqual(Environment env, Cons args) {
    Comparable a = eval(env, args.head);
    Comparable b = eval(env, args.tail.head);
    return a.compareTo(b) <= 0;
  }

  static _equal(Environment env, Cons args) {
    var a = eval(env, args.head);
    var b = eval(env, args.tail.head);
    return a == b;
  }

  static _notEqual(Environment env, Cons args) {
    var a = eval(env, args.head);
    var b = eval(env, args.tail.head);
    return a != b;
  }

  static _larger(Environment env, Cons args) {
    Comparable a = eval(env, args.head);
    Comparable b = eval(env, args.tail.head);
    return a.compareTo(b) > 0;
  }

  static _largerOrEqual(Environment env, Cons args) {
    Comparable a = eval(env, args.head);
    Comparable b = eval(env, args.tail.head);
    return a.compareTo(b) >= 0;
  }

  static _cons(Environment env, Cons args) {
    return Cons(eval(env, args.head), eval(env, args.tail.head));
  }

  static _car(Environment env, Cons args) {
    var cons = eval(env, args.head);
    return cons is Cons ? cons.head : null;
  }

  static _carSet(Environment env, Cons args) {
    var cons = eval(env, args.head);
    if (cons is Cons) {
      cons.car = eval(env, args.tail.head);
    }
    return cons;
  }

  static _cdr(Environment env, Cons args) {
    var cons = eval(env, args.head);
    return cons is Cons ? cons.cdr : null;
  }

  static _cdrSet(Environment env, Cons args) {
    var cons = eval(env, args.head);
    if (cons is Cons) {
      cons.cdr = eval(env, args.tail.head);
    }
    return cons;
  }
}

/// Type of printer function to output text on the console.
typedef void Printer(Object);

/// Default printer to output text on the console.
Printer printer = print;
