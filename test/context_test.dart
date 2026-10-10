import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/scaffolding.dart';

import 'utils/checks.dart';

void main() {
  const buffer = 'a\nc';
  const context = Context(buffer, 0);
  test('context', () {
    check(context.buffer).equals(buffer);
    check(context.position).equals(0);
    check(context.toPositionString()).equals('1:1');
    check(context.toString())
        .isCustomToString(name: 'Context', rest: ['[1:1]']);
  });
  group('success', () {
    test('default', () {
      final success = context.success('result');
      check(success.buffer).equals(buffer);
      check(success.position).equals(0);
      check(success.value).equals('result');
      check(() => success.message).throws<UnsupportedError>();
      check(success.toString()).isCustomToString(
        name: 'Success',
        generic: '<String>',
        rest: ['[1:1]: result'],
      );
    });
    test('with position', () {
      final success = context.success('result', 2);
      check(success.buffer).equals(buffer);
      check(success.position).equals(2);
      check(success.value).equals('result');
      check(() => success.message).throws<UnsupportedError>();
      check(success.toString()).isCustomToString(
        name: 'Success',
        generic: '<String>',
        rest: ['[2:1]: result'],
      );
    });
  });
  group('failure', () {
    test('default', () {
      final failure = context.failure('error');
      check(failure.buffer).equals(buffer);
      check(failure.position).equals(0);
      check(() => failure.value).throws<ParserException>()
        ..has((error) => error.failure, 'failure').identicalTo(failure)
        ..has((error) => error.message, 'message').equals('error')
        ..has((error) => error.offset, 'offset').equals(0)
        ..has((error) => error.source, 'source').identicalTo(buffer)
        ..has(
          (error) => error.toString(),
          'toString',
        ).isCustomToString(name: 'ParserException', rest: ['[1:1]: error']);
      check(failure.message).equals('error');
      check(failure.toString())
          .isCustomToString(name: 'Failure', rest: ['[1:1]: error']);
    });
    test('with position', () {
      final failure = context.failure('error', 2);
      check(failure.buffer).equals(buffer);
      check(failure.position).equals(2);
      check(() => failure.value).throws<ParserException>()
        ..has((error) => error.failure, 'failure').identicalTo(failure)
        ..has((error) => error.message, 'message').equals('error')
        ..has((error) => error.offset, 'offset').equals(2)
        ..has((error) => error.source, 'source').identicalTo(buffer)
        ..has(
          (error) => error.toString(),
          'toString',
        ).isCustomToString(name: 'ParserException', rest: ['[2:1]: error']);
      check(failure.message).equals('error');
      check(failure.toString())
          .isCustomToString(name: 'Failure', rest: ['[2:1]: error']);
    });
  });
  group('token', () {
    const buffer = 'a\nb';
    test('lineAndColumnOf', () {
      check(Token.lineAndColumnOf('', 0)).deepEquals([1, 1]);
      check(Token.lineAndColumnOf(buffer, 0)).deepEquals([1, 1]);
      check(Token.lineAndColumnOf(buffer, 1)).deepEquals([1, 2]);
      check(Token.lineAndColumnOf(buffer, 2)).deepEquals([2, 1]);
      check(Token.lineAndColumnOf(buffer, 3)).deepEquals([2, 2]);
    });
    test('lineAndColumnOf (newlines)', () {
      const multiline = '1\r12\r\n123\n1234';
      check(Token.lineAndColumnOf(multiline, 0)).deepEquals([1, 1]);
      check(Token.lineAndColumnOf(multiline, 1)).deepEquals([1, 2]);
      check(Token.lineAndColumnOf(multiline, 2)).deepEquals([2, 1]);
      check(Token.lineAndColumnOf(multiline, 4)).deepEquals([2, 3]);
      check(Token.lineAndColumnOf(multiline, 5)).deepEquals([2, 4]);
      check(Token.lineAndColumnOf(multiline, 6)).deepEquals([3, 1]);
      check(Token.lineAndColumnOf(multiline, 9)).deepEquals([3, 4]);
      check(Token.lineAndColumnOf(multiline, 10)).deepEquals([4, 1]);
      check(Token.lineAndColumnOf(multiline, 14)).deepEquals([4, 5]);
    });
    test('positionString', () {
      check(Token.positionString('', 0)).equals('1:1');
      check(Token.positionString(buffer, 0)).equals('1:1');
      check(Token.positionString(buffer, 1)).equals('1:2');
      check(Token.positionString(buffer, 2)).equals('2:1');
      check(Token.positionString(buffer, 3)).equals('2:2');
    });
    test('positionString (newlines)', () {
      const multiline = '1\r12\r\n123\n1234';
      check(Token.positionString(multiline, 0)).equals('1:1');
      check(Token.positionString(multiline, 2)).equals('2:1');
      check(Token.positionString(multiline, 6)).equals('3:1');
      check(Token.positionString(multiline, 10)).equals('4:1');
      check(Token.positionString(multiline, 14)).equals('4:5');
    });
  });
}
