// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/** Collection of native functions. */
class Natives {

  static Map<String, Dynamic> _natives;

  /** Looks a native function up. */
  static Dynamic find(String name) {
    _initialize();
    return _natives[name];
  }
  
  /** Imports all the native functions into the [environment]. */
  static void importAllInto(Environment env) {
    _initialize();
    _natives.forEach((key, value) {
      env[new Symbol(key)] = value;
    });
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
    _natives['lambda'] = (Environment lambda_env, Dynamic lambda_args) {
      return (Environment env, Dynamic args) {
        var inner = lambda_env.create();
        var names = lambda_args.head;
        var values = evalArgs(env, args);
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
      return eval(env.create(), args);
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
      return eval(env, eval(env, args.head) ? args.tail.head : args.tail.tail.head);
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
    _natives['add'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value += eval(env, args.head);
      }
      return value;
    };
    _natives['sub'] = (Environment env, Dynamic args) {
      if (args.tail == null) {
        return -eval(env, args.head);
      } else {
        var value = eval(env, args.head);
        for (args = args.tail; args != null; args = args.tail) {
          value -= eval(env, args.head);
        }
        return value;
      }
    };
    _natives['mul'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value *= eval(env, args.head);
      }
      return value;
    };
    _natives['div'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value /= eval(env, args.head);
      }
      return value;
    };
    _natives['mod'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value %= eval(env, args.head);
      }
      return value;
    };
  }

  static void _arithmeticComparators() {
    _natives['less'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        if (eval(env, args.head) < value) {
          return false;
        }
      }
      return true;
    };
    _natives['less_equal'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        if (eval(env, args.head) <= value) {
          return false;
        }
      }
      return true;
    };
    _natives['equal'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        if (eval(env, args.head) != value) {
          return false;
        }
      }
      return true;
    };
    _natives['not_equal'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        if (eval(env, args.head) == value) {
          return false;
        }
      }
      return true;
    };
    _natives['larger'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        if (eval(env, args.head) > value) {
          return false;
        }
      }
      return true;
    };
    _natives['larger_equal'] = (Environment env, Dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        if (eval(env, args.head) >= value) {
          return false;
        }
      }
      return true;
    };
  }

  static void _listOperators() {
    _natives['cons'] = (Environment env, Dynamic args) {
      return new Cons(eval(env, args.head), eval(env, args.tail));
    };
    _natives['car'] = (Environment env, Dynamic args) {
      return args is Cons ? eval(env, args.head) : null;
    };
    _natives['car!'] = (Environment env, Dynamic args) {
      if (args.head is Cons) {
        return args.head.head = eval(env, args.tail.head);
      }
    };
    _natives['cdr'] = (Environment env, Dynamic args) {
      return args is Cons ? eval(env, args.tail) : null;
    };
    _natives['cdr!'] = (Environment env, Dynamic args) {
      if (args.head is Cons) {
        return args.head.tail = eval(env, args.tail.head);
      }
    };
  }

}