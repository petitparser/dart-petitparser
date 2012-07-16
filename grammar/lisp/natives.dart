// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/** Collection of all native functions. */
class Natives {

  static Map<String, Function> _natives;

  static Function find(String name) {
    if (_natives == null) {
      _natives = new Map();
      _initialize();
    }
    return _natives[name];
  }

  static void _initialize() {
    _basicFunctions();
    _controlStructures();
    _arithmeticMethods();
    _arithmeticComparators();
    _listOperators();
  }

  static void _basicFunctions() {
    _natives['lambda'] = (Environment lambda_env, Dynamic lambda_args) {
      return (Environment env, Dynamic args) {
        var inner = lambda_env.create();
        var names = lambda_args.head;
        var values = evalArgs(env, args);
        while (names is Cons && values is Cons) {
          inner[names.head] = values.head;
          names = names.tail;
          values = values.tail;
        }
        var result = null;
        var stmt = lambda_args.tail;
        while (stmt is Cons) {
          result = eval(inner, stmt.head);
          stmt = stmt.tail;
        }
        return result;
      };
    };
    _natives['eval'] = (Environment env, Dynamic args) {
      return eval(env, args);
    };
    _natives['let'] = (Environment env, Dynamic args) {
      var inner = env.create();
      var binding = args.head;
      while (binding is Cons) {
        inner[binding.head.head] = eval(env, binding.head.tail);
        binding = binding.tail;
      }
      var result = null;
      var statement = args.tail;
      while (statement is Cons) {
        result = eval(inner, statement.head);
        statement = statement.tail;
      }
      return eval(inner, statement);
    };
    _natives['print'] = (Environment env, Dynamic args) {
      print(args.toString());
    };
  }

  static void _controlStructures() {
    _natives['if'] = (Environment env, Dynamic args) {
      if (eval(env, args.head)) {
        return eval(env, args.tail.head);
      } else {
        return eval(env, args.tail.tail);
      }
    };
    _natives['while'] = (Environment env, Dynamic args) {
      var result = null;
      while (eval(env, args.head)) {
        result = eval(env, args.tail);
      }
      return result;
    };
    _natives['and'] = (Environment env, Dynamic args) {
      while (args is Cons) {
        if (eval(env, args.head)) {
          return false;
        }
        args = args.tail;
      }
      return true;
    };
    _natives['or'] = (Environment env, Dynamic args) {
      while (args is Cons) {
        if (eval(env, args.head)) {
          return true;
        }
        args = args.tail;
      }
      return false;
    };
  }

  static void _arithmeticMethods() {
    _natives['add'] = (Environment env, Dynamic args) {
      if (args is Cons) {
        num value = args.head;
        for (args = args.tail; args != null; args = args.tail) {
          value += args.head;
        }
        return value;
      } else if (args is num) {
        return args;
      }
    };
    _natives['sub'] = (Environment env, Dynamic args) {
      if (args is Cons) {
        num value = args.head;
        for (args = args.tail; args != null; args = args.tail) {
          value -= args.head;
        }
        return value;
      } else if (args is num) {
        return -args;
      }
    };
    _natives['mul'] = (Environment env, Dynamic args) {
      if (args is Cons) {
        num value = args.head;
        for (args = args.tail; args != null; args = args.tail) {
          value *= args.head;
        }
        return value;
      } else if (args is num) {
        return args;
      }
    };
    _natives['div'] = (Environment env, Dynamic args) {
      if (args is Cons) {
        num value = args.head;
        for (args = args.tail; args != null; args = args.tail) {
          value /= args.head;
        }
        return value;
      }
    };
    _natives['mod'] = (Environment env, Dynamic args) {
      if (args is Cons) {
        num value = args.head;
        for (args = args.tail; args != null; args = args.tail) {
          value %= args.head;
        }
        return value;
      }
    };
  }

  static void _arithmeticComparators() {
    _natives['less'] = (Environment env, Dynamic args) {
      for (var cell = args; args.tail != null; cell = cell.tail) {
        if (cell.head >= cell.tail.head) {
          return false;
        }
      }
      return true;
    };
    _natives['less_equal'] = (Environment env, Dynamic args) {
      for (var cell = args; args.tail != null; cell = cell.tail) {
        if (cell.head > cell.tail.head) {
          return false;
        }
      }
      return true;
    };
    _natives['equal'] = (Environment env, Dynamic args) {
      for (var cell = args; args.tail != null; cell = cell.tail) {
        if (cell.head != cell.tail.head) {
          return false;
        }
      }
      return true;
    };
    _natives['not_equal'] = (Environment env, Dynamic args) {
      for (var cell = args; args.tail != null; cell = cell.tail) {
        if (cell.head == cell.tail.head) {
          return false;
        }
      }
      return true;
    };
    _natives['larger'] = (Environment env, Dynamic args) {
      for (var cell = args; args.tail != null; cell = cell.tail) {
        if (cell.head <= cell.tail.head) {
          return false;
        }
      }
      return true;
    };
    _natives['larger_equal'] = (Environment env, Dynamic args) {
      for (var cell = args; args.tail != null; cell = cell.tail) {
        if (cell.head < cell.tail.head) {
          return false;
        }
      }
      return true;
    };
  }

  static void _listOperators() {
    _natives['cons'] = (Environment env, Dynamic args) {
      return new Cons(args.head, args.tail);
    };
    _natives['car'] = (Environment env, Dynamic args) {
      return args is Cons ? args.head : null;
    };
    _natives['cdr'] = (Environment env, Dynamic args) {
      return args is Cons ? args.tail : null;
    };
  }

}