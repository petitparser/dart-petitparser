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

  static Object _define(Environment env, Cons args) {
    if (args.head is Name) {
      return env.define(args.head, evalList(env, args.tail));
    } else if (args.head is Cons) {
      final Cons head = args.head;
      if (head.head is Name) {
        return env.define(head.head, _lambda(env, Cons(head.tail, args.tail)));
      }
    }
    throw ArgumentError('Invalid define: $args');
  }

  static Function(Environment, Cons) _lambda(
      Environment lambdaEnv, Cons lambdaArgs) {
    return (evalEnv, evalArgs) {
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

  static Object _quote(Environment env, Cons args) {
    return args;
  }

  static Object _eval(Environment env, Cons args) {
    return eval(env.create(), eval(env, args.head));
  }

  static Object _apply(Environment env, Cons args) {
    final Function function = eval(env, args.head);
    return function(env.create(), args.tail);
  }

  static Object _let(Environment env, Cons args) {
    final inner = env.create();
    Cons binding = args.head;
    while (binding is Cons) {
      final Cons definition = binding.head;
      inner.define(definition.head, eval(env, definition.tail.head));
      binding = binding.tail;
    }
    return evalList(inner, args.tail);
  }

  static Object _set(Environment env, Cons args) {
    return env[args.head] = eval(env, args.tail.head);
  }

  static Object _print(Environment env, Cons args) {
    final buffer = StringBuffer();
    while (args != null) {
      buffer.write(eval(env, args.head));
      args = args.tail;
    }
    printer(buffer.toString());
    return null;
  }

  static Object _if(Environment env, Cons args) {
    final condition = eval(env, args.head);
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

  static Object _while(Environment env, Cons args) {
    Object result;
    while (eval(env, args.head)) {
      result = evalList(env, args.tail);
    }
    return result;
  }

  static Object _and(Environment env, Cons args) {
    while (args != null) {
      if (!eval(env, args.head)) {
        return false;
      }
      args = args.tail;
    }
    return true;
  }

  static Object _or(Environment env, Cons args) {
    while (args != null) {
      if (eval(env, args.head)) {
        return true;
      }
      args = args.tail;
    }
    return false;
  }

  static Object _not(Environment env, Cons args) {
    return !eval(env, args.head);
  }

  static Object _plus(Environment env, Cons args) {
    num value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value += eval(env, args.head);
    }
    return value;
  }

  static Object _minus(Environment env, Cons args) {
    num value = eval(env, args.head);
    if (args.tail == null) {
      return -value;
    }
    for (args = args.tail; args != null; args = args.tail) {
      value -= eval(env, args.head);
    }
    return value;
  }

  static Object _multiply(Environment env, Cons args) {
    num value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value *= eval(env, args.head);
    }
    return value;
  }

  static Object _divide(Environment env, Cons args) {
    num value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value /= eval(env, args.head);
    }
    return value;
  }

  static Object _modulo(Environment env, Cons args) {
    num value = eval(env, args.head);
    for (args = args.tail; args != null; args = args.tail) {
      value %= eval(env, args.head);
    }
    return value;
  }

  static Object _smaller(Environment env, Cons args) {
    final Comparable a = eval(env, args.head);
    final Comparable b = eval(env, args.tail.head);
    return a.compareTo(b) < 0;
  }

  static Object _smallerOrEqual(Environment env, Cons args) {
    final Comparable a = eval(env, args.head);
    final Comparable b = eval(env, args.tail.head);
    return a.compareTo(b) <= 0;
  }

  static Object _equal(Environment env, Cons args) {
    final a = eval(env, args.head);
    final b = eval(env, args.tail.head);
    return a == b;
  }

  static Object _notEqual(Environment env, Cons args) {
    final a = eval(env, args.head);
    final b = eval(env, args.tail.head);
    return a != b;
  }

  static Object _larger(Environment env, Cons args) {
    final Comparable a = eval(env, args.head);
    final Comparable b = eval(env, args.tail.head);
    return a.compareTo(b) > 0;
  }

  static Object _largerOrEqual(Environment env, Cons args) {
    final Comparable a = eval(env, args.head);
    final Comparable b = eval(env, args.tail.head);
    return a.compareTo(b) >= 0;
  }

  static Object _cons(Environment env, Cons args) {
    final head = eval(env, args.head);
    final tail = eval(env, args.tail.head);
    return Cons(head, tail);
  }

  static Object _car(Environment env, Cons args) {
    final cons = eval(env, args.head);
    return cons is Cons ? cons.head : null;
  }

  static Object _carSet(Environment env, Cons args) {
    final cons = eval(env, args.head);
    if (cons is Cons) {
      cons.car = eval(env, args.tail.head);
    }
    return cons;
  }

  static Object _cdr(Environment env, Cons args) {
    final cons = eval(env, args.head);
    return cons is Cons ? cons.cdr : null;
  }

  static Object _cdrSet(Environment env, Cons args) {
    final cons = eval(env, args.head);
    if (cons is Cons) {
      cons.cdr = eval(env, args.tail.head);
    }
    return cons;
  }
}

/// Type of printer function to output text on the console.
typedef Printer = void Function(Object object);

/// Default printer to output text on the console.
Printer printer = print;
