// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('lisp_tests');

#import('package:unittest/unittest.dart');
#import('package:petitparser/petitparser.dart');

#import('../grammar/lisp/lisplib.dart');

void main() {
  CompositeParser parser = new LispParser();
  Parser atom = parser['atom'];

  Environment root = new RootEnvironment();
  Natives.importAllInto(root);

  Dynamic exec(String value, [Environment env]) {
    return evalString(parser, env != null ? env : root.create(), value);
  }

  group('Cell', () {
    test('Symbol', () {
      var cell1 = new Symbol('foo');
      var cell2 = new Symbol('foo');
      var cell3 = new Symbol('bar');
      expect(cell1, cell2);
      expect(cell1, same(cell2));
      expect(cell1, isNot(cell3));
      expect(cell1, isNot(same(cell3)));
    });
    test('Cons', () {
      var cell = new Cons(1, 2);
      expect(cell.head, 1);
      expect(cell.tail, 2);
      cell.head = 3;
      expect(cell.head, 3);
      expect(cell.tail, 2);
      cell.tail = 4;
      expect(cell.head, 3);
      expect(cell.tail, 4);
    });
  });
  group('Parser', () {
    test('Symbol', () {
      var cell = atom.parse('foo').getResult();
      expect(cell, new isInstanceOf<Symbol>());
      expect(cell.name, 'foo');
      expect(cell.toString(), 'foo');
    });
    test('Symbol for operator', () {
      var cell = atom.parse('+').getResult();
      expect(cell, new isInstanceOf<Symbol>());
      expect(cell.name, '+');
    });
    test('Symbol for special', () {
      var cell = atom.parse('set!').getResult();
      expect(cell, new isInstanceOf<Symbol>());
      expect(cell.name, 'set!');
    });
    test('String', () {
      var cell = atom.parse('"foo"').getResult();
      expect(cell, new isInstanceOf<String>());
      expect(cell, 'foo');
    });
    test('String with escape', () {
      var cell = atom.parse('"\\""').getResult();
      expect(cell, '"');
    });
    test('Number integer', () {
      var cell = atom.parse('123').getResult();
      expect(cell, 123);
    });
    test('Number negative integer', () {
      var cell = atom.parse('-123').getResult();
      expect(cell, -123);
    });
    test('Number positive integer', () {
      var cell = atom.parse('+123').getResult();
      expect(cell, 123);
    });
    test('Number floating', () {
      var cell = atom.parse('123.45').getResult();
      expect(cell, 123.45);
    });
    test('Number floating exponential', () {
      var cell = atom.parse('1.23e4').getResult();
      expect(cell, 1.23e4);
    });
    test('List empty', () {
      var cell = atom.parse('()').getResult();
      expect(cell, isNull);
    });
    test('List empty []', () {
      var cell = atom.parse('[ ]').getResult();
      expect(cell, isNull);
    });
    test('List empty {}', () {
      var cell = atom.parse('{   }').getResult();
      expect(cell, isNull);
    });
    test('List one element', () {
      var cell = atom.parse('(1)').getResult();
      expect(cell, new isInstanceOf<Cons>());
      expect(cell.head, 1);
      expect(cell.tail, isNull);
    });
    test('List two elements', () {
      var cell = atom.parse('(1 2)').getResult();
      expect(cell, new isInstanceOf<Cons>());
      expect(cell.head, 1);
      expect(cell.tail, new isInstanceOf<Cons>());
      expect(cell.tail.head, 2);
      expect(cell.tail.tail, isNull);
    });
    test('List three elements', () {
      var cell = atom.parse('(+ 1 2)').getResult();
      expect(cell, new isInstanceOf<Cons>());
      expect(cell.head, new isInstanceOf<Symbol>());
      expect(cell.head.name, '+');
      expect(cell.tail, new isInstanceOf<Cons>());
      expect(cell.tail.head, 1);
      expect(cell.tail.tail, new isInstanceOf<Cons>());
      expect(cell.tail.tail.head, 2);
      expect(cell.tail.tail.tail, isNull);
    });
  });
  group('Natives', () {
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
      expect(exec('(quote + 1)'), new Cons(new Symbol('+'), new Cons(1, null)));
    });
    test('Quote (syntax)', () {
      expect(exec('\'()'), null);
      expect(exec('\'(1)'), new Cons(1, null));
      expect(exec('\'(+ 1)'), new Cons(new Symbol('+'), new Cons(1, null)));
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
    test('Set!', () {
      expect(exec('(set! a 1)'), 1);
      expect(exec('(set! b (+ 1 2))'), 3);
      expect(exec('(set! c (+ 1 2)) (+ c 1)'), 4);
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
      expect(exec('(if (= 1 1) (set! a 1) (set! b 2)) (cons a b)'), new Cons(1, null));
      expect(exec('(if (= 1 2) (set! a 1) (set! b 2)) (cons a b)'), new Cons(null, 2));
    });
    test('While', () {
      expect(exec('(set! i 0) (while (< i 3) (set! i (+ i 1))) i'), 3);
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
      expect(exec('(and false (set! a true)) a'), isNull);
      expect(exec('(and true (set! a true)) a'), isTrue);
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
      expect(exec('(or false (set! a true)) a'), isTrue);
      expect(exec('(or true (set! a true)) a'), isNull);
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
}