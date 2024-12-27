// ignore_for_file: deprecated_member_use_from_same_package

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/matchers.dart';

void main() {
  const buffer = 'a\nc';
  const context = Context(buffer, 0);
  test('context', () {
    expect(context.buffer, buffer);
    expect(context.position, 0);
    expect(context.toString(), isNot(startsWith('Instance of')));
    expect(context.toString(), stringContainsInOrder(['Context', '[1:1]']));
  });
  group('success', () {
    test('default', () {
      final success = context.success('result');
      expect(success.buffer, buffer);
      expect(success.position, 0);
      expect(success.value, 'result');
      expect(() => success.message, throwsA(isUnsupportedError));
      expect(success.toString(), isNot(startsWith('Instance of')));
      expect(success.toString(),
          stringContainsInOrder(['Success', '[1:1]: result']));
    });
    test('with position', () {
      final success = context.success('result', 2);
      expect(success.buffer, buffer);
      expect(success.position, 2);
      expect(success.value, 'result');
      expect(() => success.message, throwsA(isUnsupportedError));
      expect(success.toString(), isNot(startsWith('Instance of')));
      expect(success.toString(),
          stringContainsInOrder(['Success', '[2:1]: result']));
    });
  });
  group('failure', () {
    test('default', () {
      final failure = context.failure('error');
      expect(failure.buffer, buffer);
      expect(failure.position, 0);
      expect(
          () => failure.value,
          throwsA(isParserException
              .having((error) => error.failure, 'failure', same(failure))
              .having((error) => error.message, 'message', 'error')
              .having((error) => error.offset, 'offset', 0)
              .having((error) => error.source, 'source', same(buffer))
              .having((error) => error.toString(), 'toString',
                  stringContainsInOrder(['ParserException', '[1:1]: error']))));
      expect(failure.message, 'error');
      expect(failure.toString(), isNot(startsWith('Instance of')));
      expect(failure.toString(),
          stringContainsInOrder(['Failure[1:1]', ': error']));
    });
    test('with position', () {
      final failure = context.failure('problem', 2);
      expect(failure.buffer, buffer);
      expect(failure.position, 2);
      expect(
          () => failure.value,
          throwsA(isParserException
              .having((error) => error.failure, 'failure', same(failure))
              .having((error) => error.message, 'message', 'problem')
              .having((error) => error.offset, 'offset', 2)
              .having((error) => error.source, 'source', same(buffer))
              .having(
                  (error) => error.toString(),
                  'toString',
                  stringContainsInOrder(
                      ['ParserException', '[2:1]: problem']))));
      expect(failure.message, 'problem');
      expect(failure.toString(), isNot(startsWith('Instance of')));
      expect(failure.toString(),
          stringContainsInOrder(['Failure', '[2:1]: problem']));
    });
  });
}
