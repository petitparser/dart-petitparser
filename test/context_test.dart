import 'package:petitparser/context.dart';
import 'package:petitparser/core.dart';
import 'package:test/test.dart';

void main() {
  test('context', () {
    final context = Context('abc');
    expect(context.buffer, 'abc');
    expect(context.position, 0);
    expect(context.isSuccess, isTrue);
    expect(context.value, isNull);
    expect(context.message, '');
    expect(context.isCut, isFalse);
    expect(context.toString(), startsWith('Context'));
  });
  test('success', () {
    final context = Context('abc');
    context.success(42, position: 2);
    final result = context.toResult<int>();
    expect(result.buffer, 'abc');
    expect(result.position, 2);
    expect(result.isSuccess, isTrue);
    expect(result.isFailure, isFalse);
    expect(result.value, 42);
    expect(() => result.message, throwsUnsupportedError);
    expect(result.toString(), 'Success[1:3]: 42');
  });
  test('failure', () {
    final context = Context('abc');
    context.failure('42 expected', position: 2);
    final result = context.toResult<int>();
    expect(result.buffer, 'abc');
    expect(result.position, 2);
    expect(result.isSuccess, isFalse);
    expect(result.isFailure, isTrue);
    expect(
        () => result.value,
        throwsA(isA<ParserException>()
            .having((e) => e.failure, 'failure', same(result))
            .having((e) => e.message, 'message', '42 expected')
            .having((e) => e.offset, 'offset', 2)
            .having((e) => e.source, 'source', 'abc')));
    expect(result.message, '42 expected');
    expect(result.toString(), 'Failure[1:3]: 42 expected');
  });
  test('copy', () {
    final context = Context('abc');
    context.success(42, position: 2);
    final copy = context.copy();
    context.failure('42 expected', position: 3);
    expect(copy.buffer, 'abc');
    expect(copy.position, 2);
    expect(copy.isSuccess, isTrue);
    expect(copy.value, 42);
    expect(copy.message, '');
    expect(copy.isCut, isFalse);
  });
}
