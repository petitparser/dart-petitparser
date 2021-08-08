import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

const isParserException = TypeMatcher<ParserException>();

/// Returns a [Matcher] that asserts the context under test is a [Success].
TypeMatcher<Success<T>> isSuccess<T>(dynamic matcher, [int? position]) =>
    isA<Success<T>>()
        .having((context) => context.isSuccess, 'isSuccess', isTrue)
        .having((context) => context.isFailure, 'isFailure', isFalse)
        .having((context) => context.value, 'value', matcher)
        .having((context) => context.position, 'position', position);

/// Returns a [Matcher] that asserts the parser under test yields a successful
/// parse result with the given [input].
Matcher isParseSuccess<T>(String input, dynamic resultMatcher,
    [int? position]) {
  final expectedPosition = position ?? input.length;
  return isA<Parser<T>>()
      .having((parser) => parser.parse(input), 'parse',
          isSuccess<T>(resultMatcher, expectedPosition))
      .having((parser) => parser.fastParseOn(input, 0), 'fastParseOn',
          expectedPosition)
      .having((parser) => parser.accept(input), 'accept', isTrue);
}

/// Returns a [Matcher] that asserts the context under test is a [Failure].
TypeMatcher<Failure<T>> isFailure<T>([int? position, String? message]) =>
    isA<Failure<T>>()
        .having((context) => context.isSuccess, 'isSuccess', isFalse)
        .having((context) => context.isFailure, 'isFailure', isTrue)
        .having((context) => () => context.value, 'value',
            throwsA(isParserException))
        .having((context) => context.message, 'message', message ?? anything)
        .having(
            (context) => context.position, 'position', position ?? anything);

/// Returns a [Matcher] that asserts the parser under test yields a parse
/// failure for the given [input].
Matcher isParseFailure<T>(String input, [int position = 0, String? message]) =>
    isA<Parser<T>>()
        .having((parser) => parser.parse(input), 'parse',
            isFailure<T>(position, message))
        .having((parser) => parser.fastParseOn(input, 0), 'fastParseOn', -1)
        .having((parser) => parser.accept(input), 'accept', isFalse);
