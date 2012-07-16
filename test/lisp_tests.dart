// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('lisp_tests');

#import('/Applications/Dart/dart-sdk/lib/unittest/unittest.dart');

#import('../grammar/lisp/lisplib.dart');
#import('../lib/petitparser.dart');

void main() {
  Parser atom = new LispParser()['atom'];

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
  group('Evaluate', () {

  });

}
