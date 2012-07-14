// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('lisp_tests');

#import('/Applications/Dart/dart-sdk/lib/unittest/unittest.dart');

#import('../grammar/lisp/lisp.dart');

void main() {
  group('Cells', () {
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

}
