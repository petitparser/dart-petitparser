library petitparser.example.test.lisp_test;

import 'package:example/prolog.dart';
import 'package:test/test.dart';

void main() {
  group('Forrester family', () {
    final db = Database.parse('''
      father_child(massimo, ridge).
      father_child(eric, thorne).
      father_child(thorne, alexandria).
      
      mother_child(stephanie, thorne).
      mother_child(stephanie, kristen).
      mother_child(stephanie, felicia).
      
      parent_child(X, Y) :- father_child(X, Y).
      parent_child(X, Y) :- mother_child(X, Y).
      
      sibling(X, Y) :- parent_child(Z, X), parent_child(Z, Y).
      
      ancestor(X, Y) :- parent_child(X, Y).
      ancestor(X, Y) :- parent_child(X, Z), ancestor(Z, Y).
    ''');
    test('eric son of thorne', () async {
      final query = Term.parse('father_child(eric, thorne)');
      expect(
          db.query(query),
          emitsInOrder([
            Term.parse('father_child(eric, thorne)'),
          ]));
    });
    test('children of sephanie', () async {
      final query = Term.parse('mother_child(stephanie, X)');
      expect(
          db.query(query),
          emitsInOrder([
            Term.parse('mother_child(stephanie, thorne)'),
            Term.parse('mother_child(stephanie, kristen)'),
            Term.parse('mother_child(stephanie, felicia)'),
          ]));
    });
    test('fathers and children', () async {
      final query = Term.parse('father_child(X, Y)');
      expect(
          db.query(query),
          emitsInOrder([
            Term.parse('father_child(massimo, ridge)'),
            Term.parse('father_child(eric, thorne)'),
            Term.parse('father_child(thorne, alexandria)'),
          ]));
    });
    test('parents of thorne', () async {
      final query = Term.parse('parent_child(X, thorne)');
      expect(
          db.query(query),
          emitsInOrder([
            Term.parse('parent_child(eric, thorne)'),
            Term.parse('parent_child(stephanie, thorne)'),
          ]));
    });
    test('parents and children', () async {
      final query = Term.parse('parent_child(X, Y)');
      expect(
          db.query(query),
          emitsInOrder([
            Term.parse('parent_child(massimo, ridge)'),
            Term.parse('parent_child(eric, thorne)'),
            Term.parse('parent_child(thorne, alexandria)'),
            Term.parse('parent_child(stephanie, thorne)'),
            Term.parse('parent_child(stephanie, kristen)'),
            Term.parse('parent_child(stephanie, felicia)'),
          ]));
    });
    test('siblings of felicia', () async {
      final query = Term.parse('sibling(X, felicia)');
      expect(
          db.query(query),
          emitsInOrder([
            Term.parse('sibling(thorne, felicia)'),
            Term.parse('sibling(kristen, felicia)'),
            Term.parse('sibling(felicia, felicia)'),
          ]));
    });
    test('ancestors of alexandria', () {
      final query = Term.parse('ancestor(X, alexandria)');
      expect(
          db.query(query),
          emitsInOrder([
            Term.parse('ancestor(thorne, alexandria)'),
            Term.parse('ancestor(eric, alexandria)'),
            Term.parse('ancestor(stephanie, alexandria)'),
          ]));
    });
  });
  group('Einstein\'s Problem', () {
    // http://mathforum.org/library/drmath/view/60971.html
    final db = Database.parse('''
      exists(A, list(A, _, _, _, _)).
      exists(A, list(_, A, _, _, _)).
      exists(A, list(_, _, A, _, _)).
      exists(A, list(_, _, _, A, _)).
      exists(A, list(_, _, _, _, A)).
      
      rightOf(R, L, list(L, R, _, _, _)).
      rightOf(R, L, list(_, L, R, _, _)).
      rightOf(R, L, list(_, _, L, R, _)).
      rightOf(R, L, list(_, _, _, L, R)).
      
      middle(A, list(_, _, A, _, _)).
      
      first(A, list(A, _, _, _, _)).
      
      nextTo(A, B, list(B, A, _, _, _)).
      nextTo(A, B, list(_, B, A, _, _)).
      nextTo(A, B, list(_, _, B, A, _)).
      nextTo(A, B, list(_, _, _, B, A)).
      nextTo(A, B, list(A, B, _, _, _)).
      nextTo(A, B, list(_, A, B, _, _)).
      nextTo(A, B, list(_, _, A, B, _)).
      nextTo(A, B, list(_, _, _, A, B)).
      
      puzzle(Houses) :-
        exists(house(red, british, _, _, _), Houses),
        exists(house(_, swedish, _, _, dog), Houses),
        exists(house(green, _, coffee, _, _), Houses),
        exists(house(_, danish, tea, _, _), Houses),
        rightOf(house(white, _, _, _, _), house(green, _, _, _, _), Houses),
        exists(house(_, _, _, pall_mall, bird), Houses),
        exists(house(yellow, _, _, dunhill, _), Houses),
        middle(house(_, _, milk, _, _), Houses),
        first(house(_, norwegian, _, _, _), Houses),
        nextTo(house(_, _, _, blend, _), house(_, _, _, _, cat), Houses),
        nextTo(house(_, _, _, dunhill, _),house(_, _, _, _, horse), Houses),
        exists(house(_, _, beer, bluemaster, _), Houses),
        exists(house(_, german, _, prince, _), Houses),
        nextTo(house(_, norwegian, _, _, _), house(blue, _, _, _, _), Houses),
        nextTo(house(_, _, _, blend, _), house(_, _, water_, _, _), Houses).
      
      solution(FishOwner) :-
        puzzle(Houses),
        exists(house(_, FishOwner, _, _, fish), Houses).
    ''');
    test('Who Owns the Fish?', () {
      final query = Term.parse('solution(FishOwner)');
      expect(
          db.query(query),
          emitsInOrder([
            Term.parse('solution(german)'),
          ]));
    });
  });
}
