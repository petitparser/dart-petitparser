library petitparser.test.context_test;

import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  const buffer = 'a\nc';
  const context = Context(buffer, 0);
  test('context', () {
    expect(context.buffer, buffer);
    expect(context.position, 0);
    expect(context.toString(), 'Context[1:1]');
  });
  test('success', () {
    final success = context.success('result');
    expect(success.buffer, buffer);
    expect(success.position, 0);
    expect(success.value, 'result');
    expect(success.message, isNull);
    expect(success.isSuccess, isTrue);
    expect(success.isFailure, isFalse);
    expect(success.toString(), 'Success[1:1]: result');
  });
  test('success with position', () {
    final success = context.success('result', 2);
    expect(success.buffer, buffer);
    expect(success.position, 2);
    expect(success.value, 'result');
    expect(success.message, isNull);
    expect(success.isSuccess, isTrue);
    expect(success.isFailure, isFalse);
    expect(success.toString(), 'Success[2:1]: result');
  });
  test('sucess with mapping', () {
    final success = context.success('result', 2).map((value) {
      expect(value, 'result');
      return 123;
    });
    expect(success.buffer, buffer);
    expect(success.position, 2);
    expect(success.value, 123);
    expect(success.message, isNull);
    expect(success.isSuccess, isTrue);
    expect(success.isFailure, isFalse);
    expect(success.toString(), 'Success[2:1]: 123');
  });
  test('failure', () {
    final failure = context.failure('error');
    expect(failure.buffer, buffer);
    expect(failure.position, 0);
    try {
      failure.value;
      fail('Expected ParserError to be thrown');
    } on ParserException catch (error) {
      expect(error.failure, same(failure));
      expect(error.message, 'error');
      expect(error.offset, 0);
      expect(error.source, buffer);
      expect(error.toString(), 'error at 1:1');
    }
    expect(failure.message, 'error');
    expect(failure.isSuccess, isFalse);
    expect(failure.isFailure, isTrue);
    expect(failure.toString(), 'Failure[1:1]: error');
  });
  test('failure with position', () {
    final failure = context.failure('error', 2);
    expect(failure.buffer, buffer);
    expect(failure.position, 2);
    try {
      failure.value;
      fail('Expected ParserError to be thrown');
    } on ParserException catch (error) {
      expect(error.failure, same(failure));
      expect(error.message, 'error');
      expect(error.offset, 2);
      expect(error.source, buffer);
      expect(error.toString(), 'error at 2:1');
    }
    expect(failure.message, 'error');
    expect(failure.isSuccess, isFalse);
    expect(failure.isFailure, isTrue);
    expect(failure.toString(), 'Failure[2:1]: error');
  });
  test('failure with mapping', () {
    final failure = context
        .failure('error', 2)
        .map((value) => fail('Not expected to be called'));
    expect(failure.buffer, buffer);
    expect(failure.position, 2);
    try {
      failure.value;
      fail('Expected ParserError to be thrown');
    } on ParserException catch (error) {
      expect(error.failure, same(failure));
      expect(error.message, 'error');
      expect(error.offset, 2);
      expect(error.source, buffer);
      expect(error.toString(), 'error at 2:1');
    }
    expect(failure.message, 'error');
    expect(failure.isSuccess, isFalse);
    expect(failure.isFailure, isTrue);
    expect(failure.toString(), 'Failure[2:1]: error');
  });
}
