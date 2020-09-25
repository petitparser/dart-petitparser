import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

const isSuccess = TypeMatcher<Success>();
const isFailure = TypeMatcher<Failure>();

const isParserException = TypeMatcher<ParserException>();

void expectSuccess(Parser parser, String input, Object expected,
    [int position]) {
  final result = parser.parse(input);
  expect(
      result,
      isSuccess
          .having((result) => result.isSuccess, 'isSuccess', isTrue)
          .having((result) => result.isFailure, 'isFailure', isFalse)
          .having((result) => result.value, 'value', expected)
          .having((result) => result.position, 'position',
              position ?? input.length));
  expect(parser.fastParseOn(input, 0), result.position,
      reason: 'Expected fast parsed result to succeed at same position.');
  expect(parser.accept(input), isTrue,
      reason: 'Expected input to be accepted.');
}

void expectFailure(Parser parser, String input,
    [int position = 0, String message]) {
  final result = parser.parse(input);
  expect(
      result,
      isFailure
          .having((result) => result.isSuccess, 'isSuccess', isFalse)
          .having((result) => result.isFailure, 'isFailure', isTrue)
          .having((result) => result.position, 'position', position)
          .having(
              (result) => result.message, 'message', message ?? isNotEmpty));
  expect(parser.fastParseOn(input, 0), -1,
      reason: 'Expected fast parse to fail.');
  expect(parser.accept(input), isFalse,
      reason: 'Expected input to be rejected.');
  expect(
      () => result.value,
      throwsA(isParserException.having(
          (exception) => exception.failure, 'failure', result)));
}
