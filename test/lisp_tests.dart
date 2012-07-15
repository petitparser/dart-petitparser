// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('lisp_tests');

#import('/Applications/Dart/dart-sdk/lib/unittest/unittest.dart');

#import('../grammar/lisp/lisplib.dart');
#import('../lib/petitparser.dart');

void main() {
  Parser atom = new LispParser()['atom'];

  group('Cell', () {
    test('Symbol', () {
      var cell1 = new SymbolCell('foo');
      var cell2 = new SymbolCell('foo');
      var cell3 = new SymbolCell('bar');
      expect(cell1, cell2);
      expect(cell1, same(cell2));
      expect(cell1, isNot(cell3));
      expect(cell1, isNot(same(cell3)));
    });
    test('String', () {
      var cell1 = new StringCell('foo');
      var cell2 = new StringCell('foo');
      var cell3 = new StringCell('bar');
      expect(cell1, cell2);
      expect(cell1, isNot(same(cell2)));
      expect(cell1, isNot(cell3));
      expect(cell1, isNot(same(cell3)));
    });
    test('Number', () {
      var cell1 = new NumberCell(1);
      var cell2 = new NumberCell(1);
      var cell3 = new NumberCell(2);
      expect(cell1, cell2);
      expect(cell1, isNot(same(cell2)));
      expect(cell1, isNot(cell3));
      expect(cell1, isNot(same(cell3)));
    });
  });
  group('Parser', () {
    test('Symbol', () {
      var cell = atom.parse('foo').getResult();
      expect(cell, new isInstanceOf<SymbolCell>());
      expect(cell.name, 'foo');
      expect(cell.toString(), 'foo');
    });
    test('Symbol for operator', () {
      var cell = atom.parse('+').getResult();
      expect(cell, new isInstanceOf<SymbolCell>());
      expect(cell.name, '+');
      expect(cell.toString(), '+');
    });
    test('Symbol for special', () {
      var cell = atom.parse('set!').getResult();
      expect(cell, new isInstanceOf<SymbolCell>());
      expect(cell.name, 'set!');
      expect(cell.toString(), 'set!');
    });
    test('String', () {
      var cell = atom.parse('"foo"').getResult();
      expect(cell, new isInstanceOf<StringCell>());
      expect(cell.value, 'foo');
      expect(cell.toString(), '"foo"');
    });
    test('String with escape', () {
      var cell = atom.parse('"\\""').getResult();
      expect(cell, new isInstanceOf<StringCell>());
      expect(cell.value, '"');
      expect(cell.toString(), '"\\""');
    });
    test('Number integer', () {
      var cell = atom.parse('123').getResult();
      expect(cell, new isInstanceOf<NumberCell>());
      expect(cell.value, 123);
      expect(cell.toString(), '123');
    });
    test('Number negative integer', () {
      var cell = atom.parse('-123').getResult();
      expect(cell, new isInstanceOf<NumberCell>());
      expect(cell.value, -123);
      expect(cell.toString(), '-123');
    });
    test('Number positive integer', () {
      var cell = atom.parse('+123').getResult();
      expect(cell, new isInstanceOf<NumberCell>());
      expect(cell.value, 123);
      expect(cell.toString(), '123');
    });
    test('Number floating', () {
      var cell = atom.parse('123.45').getResult();
      expect(cell, new isInstanceOf<NumberCell>());
      expect(cell.value, 123.45);
      expect(cell.toString(), '123.45');
    });
    test('Number floating exponential', () {
      var cell = atom.parse('1.23e4').getResult();
      expect(cell, new isInstanceOf<NumberCell>());
      expect(cell.value, 1.23e4);
      expect(cell.toString(), '12300.0');
    });
    test('List empty', () {
      var cell = atom.parse('()').getResult();
      expect(cell, same(NULL));
    });
    test('List empty []', () {
      var cell = atom.parse('[ ]').getResult();
      expect(cell, same(NULL));
    });
    test('List empty {}', () {
      var cell = atom.parse('{   }').getResult();
      expect(cell, same(NULL));
    });
    test('List one element', () {
      var cell = atom.parse('(1)').getResult();
      expect(cell, new isInstanceOf<ConsCell>());
      expect(cell.head, new isInstanceOf<NumberCell>());
      expect(cell.head.value, 1);
      expect(cell.tail, same(NULL));
    });
    test('List two elements', () {
      var cell = atom.parse('(1 2)').getResult();
      expect(cell, new isInstanceOf<ConsCell>());
      expect(cell.head, new isInstanceOf<NumberCell>());
      expect(cell.head.value, 1);
      expect(cell.tail, new isInstanceOf<ConsCell>());
      expect(cell.tail.head, new isInstanceOf<NumberCell>());
      expect(cell.tail.head.value, 2);
      expect(cell.tail.tail, same(NULL));
    });
    test('List three elements', () {
      var cell = atom.parse('(+ 1 2)').getResult();
      expect(cell, new isInstanceOf<ConsCell>());
      expect(cell.head, new isInstanceOf<SymbolCell>());
      expect(cell.head.name, '+');
      expect(cell.tail, new isInstanceOf<ConsCell>());
      expect(cell.tail.head, new isInstanceOf<NumberCell>());
      expect(cell.tail.head.value, 1);
      expect(cell.tail.tail, new isInstanceOf<ConsCell>());
      expect(cell.tail.tail.head, new isInstanceOf<NumberCell>());
      expect(cell.tail.tail.head.value, 2);
      expect(cell.tail.tail.tail, same(NULL));
    });
  });

}
