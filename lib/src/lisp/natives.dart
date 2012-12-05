// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of lisplib;

/** Collection of native functions. */
class Natives {

  static Map<String, dynamic> _natives;

  /** Looks a native function up. */
  static dynamic find(String name) {
    _initialize();
    return _natives[name];
  }

  /** Imports all the native functions into the [environment]. */
  static Environment importNatives(Environment env) {
    _initialize();
    _natives.forEach((key, value) {
      env.define(new Symbol(key), value);
    });
    return env;
  }

  /** Imports the standard library into the [envoronment]. */
  static Environment importStandard(Environment env) {
    evalString(new LispParser(), env, _standardLibrary);
    return env;
  }

  /** A simple standard library, should be moved to external file. */
  static String _standardLibrary = """
; Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

; null functions
(define null '())
(define (null? x) (= '() x))

; list functions
(define (length list)
  (if (null? list)
      0
      (+ 1 (length (cdr list)))))

(define (append list1 list2)
  (if (null? list1)
    list2
    (cons (car list1) (append (cdr list1) list2))))

(define (list-head list index)
  (if (= index 0)
    (car list)
    (list-head
      (cdr list)
      (- index 1))))

(define (list-tail list index)
  (if (= index 0)
    (cdr list)
    (list-tail
      (cdr list)
      (- index 1))))

(define (for-each list proc)
  (while (not (null? list))
    (proc (car list))
    (set! list (cdr list))))

(define (map list proc)
  (if (null? list)
    '()
    (cons (proc (car list))
          (map (cdr list) proc))))

(define (inject list value proc)
  (if (null? list)
    value
    (inject
      (cdr list)
      (proc value (car list))
      proc)))
""";

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
    _natives['define'] = (Environment env, dynamic args) {
      if (args.head is Symbol) {
        return env.define(args.head, evalList(env, args.tail));
      } else if (args.head.head is Symbol) {
        return env.define(args.head.head, _natives['lambda'](env,
            new Cons(args.head.tail, args.tail)));
      } else {
        throw new ArgumentError('Invalid define: $args');
      }
    };
    _natives['lambda'] = (Environment lambda_env, dynamic lambda_args) {
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
    };
    _natives['quote'] = (Environment env, dynamic args) {
      return args;
    };
    _natives['eval'] = (Environment env, dynamic args) {
      return eval(env.create(), eval(env, args.head));
    };
    _natives['apply'] = (Environment env, dynamic args) {
      return eval(env, args.head)(env.create(), args.tail);
    };
    _natives['let'] = (Environment env, dynamic args) {
      var inner = env.create();
      var binding = args.head;
      while (binding != null) {
        inner.define(binding.head.head, eval(env, binding.head.tail.head));
        binding = binding.tail;
      }
      return evalList(inner, args.tail);
    };
    _natives['set!'] = (Environment env, dynamic args) {
      return env[args.head] = eval(env, args.tail.head);
    };
    _natives['print'] = (Environment env, dynamic args) {
      StringBuffer buffer = new StringBuffer();
      while (args != null) {
        buffer.add(eval(env, args.head));
        args = args.tail;
      }
      print(buffer.toString());
      return null;
    };
  }

  static void _controlStructures() {
    _natives['if'] = (Environment env, dynamic args) {
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
    _natives['while'] = (Environment env, dynamic args) {
      var result = null;
      while (eval(env, args.head)) {
        result = evalList(env, args.tail);
      }
      return result;
    };
    _natives['true'] = true;
    _natives['false'] = false;
    _natives['and'] = (Environment env, dynamic args) {
      while (args != null) {
        if (!eval(env, args.head)) {
          return false;
        }
        args = args.tail;
      }
      return true;
    };
    _natives['or'] = (Environment env, dynamic args) {
      while (args != null) {
        if (eval(env, args.head)) {
          return true;
        }
        args = args.tail;
      }
      return false;
    };
    _natives['not'] = (Environment env, dynamic args) {
      return !eval(env, args.head);
    };
  }

  static void _arithmeticMethods() {
    _natives['+'] = (Environment env, dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value += eval(env, args.head);
      }
      return value;
    };
    _natives['-'] = (Environment env, dynamic args) {
      var value = eval(env, args.head);
      if (args.tail == null) {
        return -value;
      }
      for (args = args.tail; args != null; args = args.tail) {
        value -= eval(env, args.head);
      }
      return value;
    };
    _natives['*'] = (Environment env, dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value *= eval(env, args.head);
      }
      return value;
    };
    _natives['/'] = (Environment env, dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value /= eval(env, args.head);
      }
      return value;
    };
    _natives['%'] = (Environment env, dynamic args) {
      var value = eval(env, args.head);
      for (args = args.tail; args != null; args = args.tail) {
        value %= eval(env, args.head);
      }
      return value;
    };
  }

  static void _arithmeticComparators() {
    _natives['<'] = (Environment env, dynamic args) {
      return eval(env, args.head) < eval(env, args.tail.head);
    };
    _natives['<='] = (Environment env, dynamic args) {
      return eval(env, args.head) <= eval(env, args.tail.head);
    };
    _natives['='] = (Environment env, dynamic args) {
      return eval(env, args.head) == eval(env, args.tail.head);
    };
    _natives['!='] = (Environment env, dynamic args) {
      return eval(env, args.head) != eval(env, args.tail.head);
    };
    _natives['>'] = (Environment env, dynamic args) {
      return eval(env, args.head) > eval(env, args.tail.head);
    };
    _natives['>='] = (Environment env, dynamic args) {
      return eval(env, args.head) >= eval(env, args.tail.head);
    };
  }

  static void _listOperators() {
    _natives['cons'] = (Environment env, dynamic args) {
      return new Cons(eval(env, args.head), eval(env, args.tail.head));
    };
    _natives['car'] = (Environment env, dynamic args) {
      var cons = eval(env, args.head);
      return cons is Cons ? cons.head : null;
    };
    _natives['car!'] = (Environment env, dynamic args) {
      var cons = eval(env, args.head);
      if (cons is Cons) {
        cons.head = eval(env, args.tail.head);
      }
      return cons;
    };
    _natives['cdr'] = (Environment env, dynamic args) {
      var cons = eval(env, args.head);
      return cons is Cons ? cons.tail : null;
    };
    _natives['cdr!'] = (Environment env, dynamic args) {
      var cons = eval(env, args.head);
      if (cons is Cons) {
        cons.tail = eval(env, args.tail.head);
      }
      return cons;
    };
  }

}