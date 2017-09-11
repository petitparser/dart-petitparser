library petitparser.test.lisp_test;

import 'package:test/test.dart';

import '../example/lisp/lisp.dart';

void main() {
  var native = new NativeEnvironment();
  var standard = new StandardEnvironment(native);

  dynamic exec(String value, [Environment env]) {
    return evalString(lispParser, env ?? standard.create(), value);
  }

  group('Cell', () {
    test('Name', () {
      var cell1 = new Name('foo');
      var cell2 = new Name('foo');
      var cell3 = new Name('bar');
      expect(cell1, cell2);
      expect(cell1, same(cell2));
      expect(cell1, isNot(cell3));
      expect(cell1, isNot(same(cell3)));
    });
    test('Cons', () {
      var cell = new Cons(1, 2);
      expect(cell.car, 1);
      expect(cell.head, 1);
      expect(cell.cdr, 2);
      expect(() => cell.tail, throwsStateError);
      cell.car = 3;
      expect(cell.car, 3);
      expect(cell.head, 3);
      expect(cell.cdr, 2);
      expect(() => cell.tail, throwsStateError);
      cell.cdr = new Cons(4, 5);
      expect(cell.car, 3);
      expect(cell.head, 3);
      expect(cell.tail.car, 4);
      expect(cell.tail.head, 4);
      expect(cell.tail.cdr, 5);
      expect(cell == cell, isTrue);
      expect(cell.hashCode, isNonZero);
      expect(cell.toString(), '(3 4 . 5)');
    });
  });
  group('Environment', () {
    var env = standard.create();
    test('Standard', () {
      expect(env.owner, isNotNull);
      expect(env.keys, isEmpty);
      expect(env.owner.keys, isNot(isEmpty));
    });
    test('Create', () {
      var sub = env.create();
      expect(sub.owner, same(env));
      expect(sub.keys, isEmpty);
    });
  });
  group('Grammar', () {
    var grammar = new LispGrammar();
    test('Name', () {
      var result = grammar.parse('foo').value;
      expect(result, ['foo']);
    });
    test('Name for operator', () {
      var result = grammar.parse('+').value;
      expect(result, ['+']);
    });
    test('Name for special', () {
      var result = grammar.parse('set!').value;
      expect(result, ['set!']);
    });
    test('String', () {
      var result = grammar.parse('"foo"').value;
      expect(result, [['"', ['f', 'o', 'o'], '"']]);
    });
    test('String with escape', () {
      var result = grammar.parse('"\\""').value;
      expect(result, [['"', [['\\', '"']], '"']]);
    });
    test('Number integer', () {
      var result = grammar.parse('123').value;
      expect(result, ['123']);
    });
    test('Number negative integer', () {
      var result = grammar.parse('-123').value;
      expect(result, ['-123']);
    });
    test('Number positive integer', () {
      var result = grammar.parse('+123').value;
      expect(result, ['+123']);
    });
    test('Number floating', () {
      var result = grammar.parse('123.45').value;
      expect(result, ['123.45']);
    });
    test('Number floating exponential', () {
      var result = grammar.parse('1.23e4').value;
      expect(result, ['1.23e4']);
    });
    test('List empty', () {
      var result = grammar.parse('()').value;
      expect(result, [['(', [], ')']]);
    });
    test('List empty []', () {
      var result = grammar.parse('[]').value;
      expect(result, [['[', [], ']']]);
    });
    test('List empty {}', () {
      var result = grammar.parse('{}').value;
      expect(result, [['{', [], '}']]);
    });
    test('List one element', () {
      var result = grammar.parse('(1)').value;
      expect(result, [['(', ['1', []], ')']]);
    });
    test('List two elements', () {
      var result = grammar.parse('(1 2)').value;
      expect(result, [['(', ['1', ['2', []]], ')']]);
    });
    test('List three elements', () {
      var result = grammar.parse('(+ 1 2)').value;
      expect(result, [['(', ['+', ['1', ['2', []]]], ')']]);
    });
  });
  group('Parser', () {
    var definition = new LispParserDefinition();
    var atom = definition.build(start: definition.atom);
    test('Name', () {
      var cell = atom.parse('foo').value;
      expect(cell, new isInstanceOf<Name>());
      expect(cell.toString(), 'foo');
    });
    test('Name for operator', () {
      var cell = atom.parse('+').value;
      expect(cell, new isInstanceOf<Name>());
      expect(cell.toString(), '+');
    });
    test('Name for special', () {
      var cell = atom.parse('set!').value;
      expect(cell, new isInstanceOf<Name>());
      expect(cell.toString(), 'set!');
    });
    test('String', () {
      var cell = atom.parse('"foo"').value;
      expect(cell, new isInstanceOf<String>());
      expect(cell, 'foo');
    });
    test('String with escape', () {
      var cell = atom.parse('"\\""').value;
      expect(cell, '"');
    });
    test('Number integer', () {
      var cell = atom.parse('123').value;
      expect(cell, 123);
    });
    test('Number negative integer', () {
      var cell = atom.parse('-123').value;
      expect(cell, -123);
    });
    test('Number positive integer', () {
      var cell = atom.parse('+123').value;
      expect(cell, 123);
    });
    test('Number floating', () {
      var cell = atom.parse('123.45').value;
      expect(cell, 123.45);
    });
    test('Number floating exponential', () {
      var cell = atom.parse('1.23e4').value;
      expect(cell, 1.23e4);
    });
    test('List empty', () {
      var cell = atom.parse('()').value;
      expect(cell, isNull);
    });
    test('List empty []', () {
      var cell = atom.parse('[ ]').value;
      expect(cell, isNull);
    });
    test('List empty {}', () {
      var cell = atom.parse('{   }').value;
      expect(cell, isNull);
    });
    test('List one element', () {
      var cell = atom.parse('(1)').value;
      expect(cell, new isInstanceOf<Cons>());
      expect(cell.head, 1);
      expect(cell.tail, isNull);
    });
    test('List two elements', () {
      var cell = atom.parse('(1 2)').value;
      expect(cell, new isInstanceOf<Cons>());
      expect(cell.head, 1);
      expect(cell.tail, new isInstanceOf<Cons>());
      expect(cell.tail.head, 2);
      expect(cell.tail.tail, isNull);
    });
    test('List three elements', () {
      var cell = atom.parse('(+ 1 2)').value;
      expect(cell, new isInstanceOf<Cons>());
      expect(cell.head, new isInstanceOf<Name>());
      expect(cell.head.toString(), '+');
      expect(cell.tail, new isInstanceOf<Cons>());
      expect(cell.tail.head, 1);
      expect(cell.tail.tail, new isInstanceOf<Cons>());
      expect(cell.tail.tail.head, 2);
      expect(cell.tail.tail.tail, isNull);
    });
  });
  group('Natives', () {
    test('Define', () {
      expect(exec('(define a 1)'), 1);
      expect(exec('(define a 2) a'), 2);
      expect(exec('((define (a) 3))'), 3);
      expect(exec('(define (a) 4) (a)'), 4);
      expect(exec('((define (a x) x) 5)'), 5);
      expect(exec('(define (a x) x) (a 6)'), 6);
      expect(() => exec('(define 12)'), throwsArgumentError);
    });
    test('Lambda', () {
      expect(exec('((lambda () 1) 2)'), 1);
      expect(exec('((lambda (x) x) 2)'), 2);
      expect(exec('((lambda (x) (+ x x)) 2)'), 4);
      expect(exec('((lambda (x y) (+ x y)) 2 4)'), 6);
      expect(exec('((lambda (x y z) (+ x y z)) 2 4 6)'), 12);
    });
    test('Quote', () {
      expect(exec('(quote)'), null);
      expect(exec('(quote 1)'), new Cons(1, null));
      expect(exec('(quote + 1)'), new Cons(new Name('+'), new Cons(1, null)));
    });
    test('Quote (syntax)', () {
      expect(exec('\'()'), null);
      expect(exec('\'(1)'), new Cons(1, null));
      expect(exec('\'(+ 1)'), new Cons(new Name('+'), new Cons(1, null)));
    });
    test('Eval', () {
      expect(exec('(eval (quote + 1 2))'), 3);
    });
    test('Apply', () {
      expect(exec('(apply + 1 2 3)'), 6);
      expect(exec('(apply + 1 2 3 (+ 2 2))'), 10);
    });
    test('Let', () {
      expect(exec('(let ((a 1)) a)'), 1);
      expect(exec('(let ((a 1) (b 2)) a)'), 1);
      expect(exec('(let ((a 1) (b 2)) b)'), 2);
      expect(exec('(let ((a 1) (b 2)) (+ a b))'), 3);
      expect(exec('(let ((a 1) (b 2)) (+ a b) 4)'), 4);
    });
    group('Print', () {
      var buffer = new StringBuffer();
      setUp(() {
        printer = buffer.write;
      });
      tearDown(() {
        printer = print;
        buffer.clear();
      });
      test('empty', () {
        expect(exec('(print)'), isNull);
        expect(buffer.toString(), isEmpty);
      });
      test('elements', () {
        expect(exec('(print 1 2 3)'), isNull);
        expect(buffer.toString(), '123');
      });
      test('expression', () {
        expect(exec('(print (+ 1 2) " " (+ 3 4))'), isNull);
        expect(buffer.toString(), '3 7');
      });
    });
    test('Set!', () {
      var env = standard.create();
      env.define(new Name('a'), null);
      expect(exec('(set! a 1)', env), 1);
      expect(exec('(set! a (+ 1 2))', env), 3);
      expect(exec('(set! a (+ 1 2)) (+ a 1)', env), 4);
    });
    test('Set! (undefined)', () {
      expect(() => exec('(set! a 1)'), throwsArgumentError);
      expect(() => standard[new Name('a')], throwsArgumentError);
    });
    test('If', () {
      expect(exec('(if true)'), isNull);
      expect(exec('(if false)'), isNull);
      expect(exec('(if true 1)'), 1);
      expect(exec('(if false 1)'), isNull);
      expect(exec('(if true 1 2)'), 1);
      expect(exec('(if false 1 2)'), 2);
    });
    test('If (lazyness)', () {
      expect(exec('(if (= 1 1) 3 4)'), 3);
      expect(exec('(if (= 1 2) 3 4)'), 4);
    });
    test('While', () {
      var env = standard.create();
      env.define(new Name('a'), 0);
      exec('(while (< a 3) (set! a (+ a 1)))', env);
      expect(env[new Name('a')], 3);
    });
    test('True', () {
      expect(exec('true'), isTrue);
    });
    test('False', () {
      expect(exec('false'), isFalse);
    });
    test('And', () {
      expect(exec('(and)'), isTrue);
      expect(exec('(and true)'), isTrue);
      expect(exec('(and false)'), isFalse);
      expect(exec('(and true true)'), isTrue);
      expect(exec('(and true false)'), isFalse);
      expect(exec('(and false true)'), isFalse);
      expect(exec('(and false false)'), isFalse);
      expect(exec('(and true true true)'), isTrue);
      expect(exec('(and true true false)'), isFalse);
      expect(exec('(and true false true)'), isFalse);
      expect(exec('(and true false false)'), isFalse);
      expect(exec('(and false true true)'), isFalse);
      expect(exec('(and false true false)'), isFalse);
      expect(exec('(and false false true)'), isFalse);
      expect(exec('(and false false false)'), isFalse);
    });
    test('And (lazyness)', () {
      var env = standard.create();
      env.define(new Name('a'), null);
      exec('(and false (set! a true))', env);
      expect(env[new Name('a')], isNull);
      exec('(and true (set! a true))', env);
      expect(env[new Name('a')], isTrue);
    });
    test('Or', () {
      expect(exec('(or)'), isFalse);
      expect(exec('(or true)'), isTrue);
      expect(exec('(or false)'), isFalse);
      expect(exec('(or true true)'), isTrue);
      expect(exec('(or true false)'), isTrue);
      expect(exec('(or false true)'), isTrue);
      expect(exec('(or false false)'), isFalse);
      expect(exec('(or true true true)'), isTrue);
      expect(exec('(or true true false)'), isTrue);
      expect(exec('(or true false true)'), isTrue);
      expect(exec('(or true false false)'), isTrue);
      expect(exec('(or false true true)'), isTrue);
      expect(exec('(or false true false)'), isTrue);
      expect(exec('(or false false true)'), isTrue);
      expect(exec('(or false false false)'), isFalse);
    });
    test('Or (lazyness)', () {
      var env = standard.create();
      env.define(new Name('a'), null);
      exec('(or true (set! a true))', env);
      expect(env[new Name('a')], isNull);
      exec('(or false (set! a true))', env);
      expect(env[new Name('a')], isTrue);
    });
    test('Not', () {
      expect(exec('(not true)'), isFalse);
      expect(exec('(not false)'), isTrue);
    });
    test('Add', () {
      expect(exec('(+ 1)'), 1);
      expect(exec('(+ 1 2)'), 3);
      expect(exec('(+ 1 2 3)'), 6);
      expect(exec('(+ 1 2 3 4)'), 10);
    });
    test('Sub', () {
      expect(exec('(- 1)'), -1);
      expect(exec('(- 1 2)'), -1);
      expect(exec('(- 1 2 3)'), -4);
      expect(exec('(- 1 2 3 4)'), -8);
    });
    test('Mul', () {
      expect(exec('(* 2)'), 2);
      expect(exec('(* 2 3)'), 6);
      expect(exec('(* 2 3 4)'), 24);
    });
    test('Div', () {
      expect(exec('(/ 24)'), 24);
      expect(exec('(/ 24 3)'), 8);
      expect(exec('(/ 24 3 2)'), 4);
    });
    test('Mod', () {
      expect(exec('(% 24)'), 24);
      expect(exec('(% 24 5)'), 4);
      expect(exec('(% 24 5 3)'), 1);
    });
    test('Less', () {
      expect(exec('(< 1 2)'), isTrue);
      expect(exec('(< 1 1)'), isFalse);
      expect(exec('(< 2 1)'), isFalse);
    });
    test('Less equal', () {
      expect(exec('(<= 1 2)'), isTrue);
      expect(exec('(<= 1 1)'), isTrue);
      expect(exec('(<= 2 1)'), isFalse);
    });
    test('Equal', () {
      expect(exec('(= 1 1)'), isTrue);
      expect(exec('(= 1 2)'), isFalse);
      expect(exec('(= 2 1)'), isFalse);
    });
    test('Not equal', () {
      expect(exec('(!= 1 1)'), isFalse);
      expect(exec('(!= 1 2)'), isTrue);
      expect(exec('(!= 2 1)'), isTrue);
    });
    test('Larger', () {
      expect(exec('(> 1 1)'), isFalse);
      expect(exec('(> 1 2)'), isFalse);
      expect(exec('(> 2 1)'), isTrue);
    });
    test('Larger equal', () {
      expect(exec('(>= 1 1)'), isTrue);
      expect(exec('(>= 1 2)'), isFalse);
      expect(exec('(>= 2 1)'), isTrue);
    });
    test('Cons', () {
      expect(exec('(cons 1 2)'), new Cons(1, 2));
      expect(exec('(cons 1 null)'), new Cons(1, null));
      expect(exec('(cons null 2)'), new Cons(null, 2));
      expect(exec('(cons null null)'), new Cons(null, null));
      expect(exec('(cons 1 (cons 2 (cons 3 null)))'), new Cons(1, new Cons(2, new Cons(3))));
    });
    test('Car', () {
      expect(exec('(car null)'), isNull);
      expect(exec('(car (cons 1 2))'), 1);
    });
    test('Car!', () {
      expect(exec('(car! null 3)'), isNull);
      expect(exec('(car! (cons 1 2) 3)'), new Cons(3, 2));
    });
    test('Cdr', () {
      expect(exec('(cdr null)'), isNull);
      expect(exec('(cdr (cons 1 2))'), 2);
    });
    test('Cdr!', () {
      expect(exec('(cdr! null 3)'), isNull);
      expect(exec('(cdr! (cons 1 2) 3)'), new Cons(1, 3));
    });
  });
  group('Library', () {
    test('Null', () {
      expect(exec('null'), isNull);
    });
    test('Null? (true)', () {
      expect(exec('(null? \'())'), isTrue);
      expect(exec('(null? null)'), isTrue);
    });
    test('Null? (false)', () {
      expect(exec('(null? 1)'), isFalse);
      expect(exec('(null? "a")'), isFalse);
      expect(exec('(null? (quote a))'), isFalse);
      expect(exec('(null? true)'), isFalse);
      expect(exec('(null? false)'), isFalse);
    });
    test('Length', () {
      expect(exec('(length \'())'), 0);
      expect(exec('(length \'(1))'), 1);
      expect(exec('(length \'(1 1))'), 2);
      expect(exec('(length \'(1 1 1))'), 3);
      expect(exec('(length \'(1 1 1 1))'), 4);
      expect(exec('(length \'(1 1 1 1 1))'), 5);
    });
    test('Append', () {
      expect(exec('(append \'() \'())'), isNull);
      expect(exec('(append \'(1) \'())'), exec('\'(1)'));
      expect(exec('(append \'() \'(1))'), exec('\'(1)'));
      expect(exec('(append \'(1) \'(2))'), exec('\'(1 2)'));
      expect(exec('(append \'(1 2) \'(3))'), exec('\'(1 2 3)'));
      expect(exec('(append \'(1) \'(2 3))'), exec('\'(1 2 3)'));
    });
    test('List Head', () {
      expect(exec('(list-head \'(5 6 7) 0)'), 5);
      expect(exec('(list-head \'(5 6 7) 1)'), 6);
      expect(exec('(list-head \'(5 6 7) 2)'), 7);
      expect(exec('(list-head \'(5 6 7) 3)'), isNull);
    });
    test('List Tail', () {
      expect(exec('(list-tail \'(5 6 7) 0)'), exec('\'(6 7)'));
      expect(exec('(list-tail \'(5 6 7) 1)'), exec('\'(7)'));
      expect(exec('(list-tail \'(5 6 7) 2)'), isNull);
    });
    test('Map', () {
      expect(exec('(map \'() (lambda (x) (* 2 x)))'), isNull);
      expect(exec('(map \'(2) (lambda (x) (* 2 x)))'), exec('\'(4)'));
      expect(exec('(map \'(2 3) (lambda (x) (* 2 x)))'), exec('\'(4 6)'));
      expect(exec('(map \'(2 3 4) (lambda (x) (* 2 x)))'), exec('\'(4 6 8)'));
    });
    test('Inject', () {
      expect(exec('(inject \'() 5 (lambda (s e) (+ s e 1)))'), 5);
      expect(exec('(inject \'(2) 5 (lambda (s e) (+ s e 1)))'), 8);
      expect(exec('(inject \'(2 3) 5 (lambda (s e) (+ s e 1)))'), 12);
    });
  });
  group('Examples', () {
    test('Fibonacci', () {
      var env = standard.create();
      exec('(define (fib n)'
           '  (if (<= n 1)'
           '    1'
           '    (+ (fib (- n 1)) (fib (- n 2)))))', env);
      expect(exec('(fib 0)', env), 1);
      expect(exec('(fib 1)', env), 1);
      expect(exec('(fib 2)', env), 2);
      expect(exec('(fib 3)', env), 3);
      expect(exec('(fib 4)', env), 5);
      expect(exec('(fib 5)', env), 8);
    });
    test('Closure', () {
      var env = standard.create();
      exec('(define (mul n)'
           '  (lambda (x) (* n x)))', env);
      expect(exec('((mul 2) 3)', env), 6);
      expect(exec('((mul 3) 4)', env), 12);
      expect(exec('((mul 4) 5)', env), 20);
    });
    test('Object', () {
      var env = standard.create();
      exec('(define (counter start)'
           '  (let ((count start))'
           '    (lambda ()'
           '      (set! count (+ count 1)))))', env);
      exec('(define a (counter 10))', env);
      exec('(define b (counter 20))', env);
      expect(exec('(a)', env), 11);
      expect(exec('(b)', env), 21);
      expect(exec('(a)', env), 12);
      expect(exec('(b)', env), 22);
      expect(exec('(a)', env), 13);
      expect(exec('(b)', env), 23);
    });
  });
}
