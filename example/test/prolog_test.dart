library petitparser.example.test.lisp_test;

import 'package:example/prolog.dart';
import 'package:test/test.dart';

Stream<Node> run(String rules, String query) {
  final db = rulesParser.parse(rules).value;
  final goal = queryParser.parse(query).value;
  return db.query(goal);
}

void main() {
  group('Forrester family', () {
    final x = Variable('x');
    final y = Variable('y');

    final forresterFamily = Database([
      // Facts describing the fathers.
      Rule(
          Term(
            'father_child',
            [Variable('massimo'), Variable('ridge')],
          ),
          True()),
      Rule(
          Term(
            'father_child',
            [Variable('eric'), Variable('thorne')],
          ),
          True()),
      Rule(
          Term(
            'father_child',
            [Variable('thorne'), Variable('alexandria')],
          ),
          True()),

      // Facts describing the mothers.
      Rule(
          Term(
            'mother_child',
            [Variable('stephanie'), Variable('thorne')],
          ),
          True()),
      Rule(
          Term(
            'mother_child',
            [Variable('stephanie'), Variable('kristen')],
          ),
          True()),
      Rule(
          Term(
            'mother_child',
            [Variable('stephanie'), Variable('felicia')],
          ),
          True()),

      // Rule for parents.
      Rule(
        Term('parent_child', [x, y]),
        Term('father_child', [x, y]),
      ),
      Rule(
        Term('parent_child', [x, y]),
        Term('mother_child', [x, y]),
      ),
    ]);

    test('is eric the son of thorne', () async {
      await forresterFamily
          .query(Term(
            'father_child',
            [Variable('eric'), Variable('thorne')],
          ))
          .forEach(print);
    });

    test('all the children of sephanie', () async {
      await forresterFamily
          .query(Term(
            'mother_child',
            [Variable('stephanie'), Variable('X')],
          ))
          .forEach(print);
    });
  });
}
