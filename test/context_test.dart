import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/matchers.dart';

void main() {
  const buffer = 'a\nc';
  const context = Context(buffer, 0);
  test('context', () {
    expect(context.buffer, buffer);
    expect(context.position, 0);
    expect(context.toPositionString(), '1:1');
    expect(context.toString(), isToString(name: 'Context', rest: ['[1:1]']));
  });
  group('success', () {
    test('default', () {
      final success = context.success('result');
      expect(success.buffer, buffer);
      expect(success.position, 0);
      expect(success.value, 'result');
      expect(() => success.message, throwsA(isUnsupportedError));
      expect(
        success.toString(),
        isToString(
          name: 'Success',
          generic: '<String>',
          rest: ['[1:1]: result'],
        ),
      );
    });
    test('with position', () {
      final success = context.success('result', 2);
      expect(success.buffer, buffer);
      expect(success.position, 2);
      expect(success.value, 'result');
      expect(() => success.message, throwsA(isUnsupportedError));
      expect(
        success.toString(),
        isToString(
          name: 'Success',
          generic: '<String>',
          rest: ['[2:1]: result'],
        ),
      );
    });
  });
  group('failure', () {
    test('default', () {
      final failure = context.failure('error');
      expect(failure.buffer, buffer);
      expect(failure.position, 0);
      expect(
        () => failure.value,
        throwsA(
          isParserException
              .having((error) => error.failure, 'failure', same(failure))
              .having((error) => error.message, 'message', 'error')
              .having((error) => error.offset, 'offset', 0)
              .having((error) => error.source, 'source', same(buffer))
              .having(
                (error) => error.toString(),
                'toString',
                isToString(name: 'ParserException', rest: ['[1:1]: error']),
              ),
        ),
      );
      expect(failure.message, 'error');
      expect(
        failure.toString(),
        isToString(name: 'Failure', rest: ['[1:1]: error']),
      );
    });
    test('with position', () {
      final failure = context.failure('error', 2);
      expect(failure.buffer, buffer);
      expect(failure.position, 2);
      expect(
        () => failure.value,
        throwsA(
          isParserException
              .having((error) => error.failure, 'failure', same(failure))
              .having((error) => error.message, 'message', 'error')
              .having((error) => error.offset, 'offset', 2)
              .having((error) => error.source, 'source', same(buffer))
              .having(
                (error) => error.toString(),
                'toString',
                isToString(name: 'ParserException', rest: ['[2:1]: error']),
              ),
        ),
      );
      expect(failure.message, 'error');
      expect(
        failure.toString(),
        isToString(name: 'Failure', rest: ['[2:1]: error']),
      );
    });
  });
  group('token', () {
    const buffer = 'a\nb';
    test('lineAndColumnOf', () {
      expect(Token.lineAndColumnOf('', 0), [1, 1]);
      expect(Token.lineAndColumnOf(buffer, 0), [1, 1]);
      expect(Token.lineAndColumnOf(buffer, 1), [1, 2]);
      expect(Token.lineAndColumnOf(buffer, 2), [2, 1]);
      expect(Token.lineAndColumnOf(buffer, 3), [2, 2]);
    });
    test('lineAndColumnOf (newlines)', () {
      const multiline = '1\r12\r\n123\n1234';
      expect(Token.lineAndColumnOf(multiline, 0), [1, 1]);
      expect(Token.lineAndColumnOf(multiline, 1), [1, 2]);
      expect(Token.lineAndColumnOf(multiline, 2), [2, 1]);
      expect(Token.lineAndColumnOf(multiline, 4), [2, 3]);
      expect(Token.lineAndColumnOf(multiline, 5), [2, 4]);
      expect(Token.lineAndColumnOf(multiline, 6), [3, 1]);
      expect(Token.lineAndColumnOf(multiline, 9), [3, 4]);
      expect(Token.lineAndColumnOf(multiline, 10), [4, 1]);
      expect(Token.lineAndColumnOf(multiline, 14), [4, 5]);
    });
    test('positionString', () {
      expect(Token.positionString('', 0), '1:1');
      expect(Token.positionString(buffer, 0), '1:1');
      expect(Token.positionString(buffer, 1), '1:2');
      expect(Token.positionString(buffer, 2), '2:1');
      expect(Token.positionString(buffer, 3), '2:2');
    });
    test('positionString (newlines)', () {
      const multiline = '1\r12\r\n123\n1234';
      expect(Token.positionString(multiline, 0), '1:1');
      expect(Token.positionString(multiline, 2), '2:1');
      expect(Token.positionString(multiline, 6), '3:1');
      expect(Token.positionString(multiline, 10), '4:1');
      expect(Token.positionString(multiline, 14), '4:5');
    });
  });
}
