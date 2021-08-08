import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

const isParserException = TypeMatcher<ParserException>();

/// Returns a [Matcher] that asserts the context under test is a [Success].
TypeMatcher<Success<T>> isSuccessContext<T>(dynamic value, [int? position]) =>
    isA<Success<T>>()
        .having((context) => context.isSuccess, 'isSuccess', isTrue)
        .having((context) => context.isFailure, 'isFailure', isFalse)
        .having((context) => context.value, 'value', value)
        .having((context) => context.position, 'position', position);

/// Returns a [Matcher] that asserts the parser under test yields a successful
/// parse result with the given [input].
Matcher isParseSuccess<T>(String input, dynamic resultMatcher,
    [int? position]) {
  final expectedPosition = position ?? input.length;
  return isA<Parser<T>>()
      .having((parser) => parser.parse(input), 'parse',
          isSuccessContext<T>(resultMatcher, expectedPosition))
      .having((parser) => parser.fastParseOn(input, 0), 'fastParseOn',
          expectedPosition)
      .having((parser) => parser.accept(input), 'accept', isTrue);
}

/// Returns a [Matcher] that asserts the context under test is a [Failure].
/// Optionally also asserts [position] and [message].
TypeMatcher<Failure<T>> isFailureContext<T>(
        {dynamic position = anything, dynamic message = anything}) =>
    isA<Failure<T>>()
        .having((context) => context.isSuccess, 'isSuccess', isFalse)
        .having((context) => context.isFailure, 'isFailure', isTrue)
        .having((context) => () => context.value, 'value',
            throwsA(isParserException))
        .having((context) => context.message, 'message', message)
        .having((context) => context.position, 'position', position);

/// Returns a [Matcher] that asserts the parser under test yields a parse
/// failure for the given [input].
Matcher isParseFailure<T>(String input,
        {dynamic position = 0, dynamic message = anything}) =>
    isA<Parser<T>>()
        .having((parser) => parser.parse(input), 'parse',
            isFailureContext<T>(position: position, message: message))
        .having((parser) => parser.fastParseOn(input, 0), 'fastParseOn', -1)
        .having((parser) => parser.accept(input), 'accept', isFalse);
