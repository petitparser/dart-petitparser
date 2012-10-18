// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of lisplib;

/** Collection of native functions. */
class Natives {

  static Map<String, Dynamic> _natives;

  /** Looks a native function up. */
  static Dynamic find(String name) {
    _initialize();
    return _natives[name];
  }

  /** Imports all the native functions into the [environment]. */
  static Environment importAllInto(Environment env) {
    _initialize();
    _natives.forEach((key, value) {
      env[new Symbol(key)] = value;
    });
    return env;
  }

  static void _initialize() {
    if (_natives == null) {
      _natives = new Map();
      _basicFunctions();
      _controlStructures();
      _arithmeticMethods();
      _arithmeticComparators();
      _listOperators();
    }
  }

  static void _basicFunctions() {
    _natives['define'] = (Environment env, Dynamic args) {
      var definition = args.head;
      if (definition is Symbol) {

      }
    };
    _natives['lambda'] = (Environment lambda_env, Dynamic lambda_args) {
      return (Environment env, Dynamic args) {
        var inner = lambda_env.create();
        var names = lambda_args.head;
        var values = evalArguments(env, args);
        while (names != null && values != null) {
          inner[names.head] = values.head;
          names = names.tail;
          values = values.tail;
        }
        var result = null;
        var stmt = lambda_args.tail;
        while (stmt != null) {
          result = eval(inner, stmt.head);
          stmt = stmt.tail;
        }
        return result;
      };
    };
    _natives['quote'] = (Environment env, Dynamic args) {
      return args;
    };
    _natives['eval'] = (Environment env, Dynamic args) {
      return eval(env.create(), eval(env, args.head));
    };
    _natives['apply'] = (Environment env, Dynamic args) {
      return eval(env, args.head)(env.create(), args.tail);
    };
    _natives['let'] = (Environment env, Dynamic args) {
      var inner = env.create();
      var binding = args.head;
      while (binding != null) {
        inner[binding.head.head] = eval(env, binding.head.tail.head);
        binding = binding.tail;
      }
      var result = null;
      var stmt = args.tail;
      while (stmt != null) {
        result = eval(inner, stmt.head);
        stmt = stmt.tail;
      }
      return result;
    };
    _natives['set!'] = (Environment env, Dynamic args) {
      return env[args.head] = eval(env, args.tail.head);
    };
    _natives['print'] = (Environment env, Dynamic args) {
      while (args != null) {
        print(eval(env, args.head));
        args = args.tail;
      }
      return null;
    };
  }

  static void _controlStructures() {
    _natives['if'] = (Environment env, Dynamic args) {
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
    };
    _natives['while'] = (Environment env, Dynamic args) {
      var result = null;
      while (eval(env, args.head)) {
        result = eval(env, args.tail.head);
      }
      return result;
    };
    _natives['true'] = true;
    _natives['false'] = false;
    _natives['and'] = (Environment env, Dynamic args) {
      while (args != null) {
        if (!eval(env, args.head)) {
          return false;
        }
        args = args.tail;
      }
      return true;
    };
    _natives['or'] = (Environment env, Dynamic args) {
      while (args != null) {
        if (eval(env, args.head)) {
          return true;
        }
        args = args.tail;
      }
      return false;
    };
    _natives['not'] = (Environment env, Dynamic args) {
      return !eval(env, args.head);
    };
  }

  static void _arithmeticMethods() {
    _natives['+'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value += eval(env, args.head);
      }
      return value;
    };
    _natives['-'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      if (args.tail == null) {
        return -value;
      }
      for (args = args.tail; args != null; args = args.tail) {
        value -= eval(env, args.head);
      }
      return value;
    };
    _natives['*'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value *= eval(env, args.head);
      }
      return value;
    };
    _natives['/'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value /= eval(env, args.head);
      }
      return value;
    };
    _natives['%'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value %= eval(env, args.head);
      }
      return value;
    };
  }

  static void _arithmeticComparators() {
    _natives['<'] = (Environment env, Dynamic args) {
      return eval(env, args.head) < eval(env, args.tail.head);
    };
    _natives['<='] = (Environment env, Dynamic args) {
      return eval(env, args.head) <= eval(env, args.tail.head);
    };
    _natives['='] = (Environment env, Dynamic args) {
      return eval(env, args.head) == eval(env, args.tail.head);
    };
    _natives['!='] = (Environment env, Dynamic args) {
      return eval(env, args.head) != eval(env, args.tail.head);
    };
    _natives['>'] = (Environment env, Dynamic args) {
      return eval(env, args.head) > eval(env, args.tail.head);
    };
    _natives['>='] = (Environment env, Dynamic args) {
      return eval(env, args.head) >= eval(env, args.tail.head);
    };
  }

  static void _listOperators() {
    _natives['cons'] = (Environment env, Dynamic args) {
      return new Cons(eval(env, args.head), eval(env, args.tail.head));
    };
    _natives['car'] = (Environment env, Dynamic args) {
      var cons = eval(env, args.head);
      return cons != null ? cons.head : null;
    };
    _natives['car!'] = (Environment env, Dynamic args) {
      var cons = eval(env, args.head);
      if (cons != null) {
        cons.head = eval(env, args.tail.head);
      }
      return cons;
    };
    _natives['cdr'] = (Environment env, Dynamic args) {
      var cons = eval(env, args.head);
      return cons != null ? cons.tail : null;
    };
    _natives['cdr!'] = (Environment env, Dynamic args) {
      var cons = eval(env, args.head);
      if (cons != null) {
        cons.tail = eval(env, args.tail.head);
      }
      return cons;
    };
  }

}