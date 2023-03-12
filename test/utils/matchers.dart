import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart' hide predicate;
import 'package:test/test.dart' as test show predicate;

import 'context.dart';

/// Returns a [Matcher] that asserts on a [ParserException].
const isParserException = TypeMatcher<ParserException>();

/// Returns [true], if assertions are enabled.
bool hasAssertionsEnabled() {
  try {
    assert(false);
    return false;
  } catch (exception) {
    return true;
  }
}

/// Returns a [Matcher] that asserts on a [AssertionError].
final isAssertionError = hasAssertionsEnabled()
    ? const TypeMatcher<AssertionError>()
    : throw UnsupportedError('Assertions are disabled');

/// Returns a [Matcher] that asserts two parsers are structurally equivalent.
Matcher isParserEqual<T>(Parser<T> parser) => test.predicate(
    (actual) => actual is Parser<T> && actual.isEqualTo(parser),
    'structurally equal');

/// Returns a [Mater] that asserts on the [Context].
TypeMatcher<Context> isContext({
  dynamic buffer = anything,
  dynamic position = anything,
  dynamic isSuccess = anything,
  dynamic value = anything,
  dynamic message = anything,
  dynamic isCut = anything,
}) =>
    isA<Context>()
        .having((context) => context.buffer, 'buffer', buffer)
        .having((context) => context.position, 'position', position)
        .having((context) => context.isSuccess, 'value', isSuccess)
        .having((context) => context.value, 'value', value)
        .having((context) => context.message, 'value', message)
        .having((context) => context.isCut, 'value', isCut);

/// Returns a [Matcher] that asserts the context under test is a [Success].
/// Optionally also asserts [position] and [value].
@optionalTypeArgs
Matcher isSuccess<T>({
  dynamic buffer = anything,
  dynamic position = anything,
  dynamic value = anything,
}) =>
    isA<Success<T>>()
        .having((success) => success.buffer, 'buffer', buffer)
        .having((success) => success.value, 'value', value)
        .having((success) => success.position, 'position', position);

/// Returns a [Matcher] that asserts the context under test is a [Failure].
/// Optionally also asserts [position] and [message].
@optionalTypeArgs
Matcher isFailure<T>({
  dynamic buffer = anything,
  dynamic position = anything,
  dynamic message = anything,
}) =>
    isA<Failure<T>>()
        .having((failure) => failure.buffer, 'buffer', buffer)
        .having((failure) => failure.position, 'position', position)
        .having((failure) => failure.message, 'message', message);

/// Returns a [Matcher] that asserts the parser under test yields a successful
/// parse [result] for the given [input]. If no [position] is provided, assert
/// that the parsing fails at the end of the input.
@optionalTypeArgs
Matcher isParseSuccess<T>(
  String input, {
  dynamic result = anything,
  dynamic position,
}) =>
    isA<Parser<T>>()
        .having(
            (parser) => parser.parse(input),
            'parse',
            isSuccess<T>(
                buffer: input,
                value: result,
                position: position ?? input.length))
        .having((parser) => parser.accept(input), 'accept', isTrue)
        .having((parser) {
      final context = DebugContext(input);
      parser.parseOn(context);
      expect(context.isSuccess, isTrue);
      expect(context.isSkip, isFalse);
      return true;
    }, 'parseOn', isTrue).having((parser) {
      final context = DebugContext(input, isSkip: true);
      parser.parseOn(context);
      expect(context.isSuccess, isTrue);
      expect(context.isSkip, isTrue);
      return true;
    }, 'parseOn (isSkip)', isTrue);

/// Returns a [Matcher] that asserts the parser under test yields a parse
/// failure for the given [input]. If no [position] is provided, assert that
/// parsing fails at the beginning of the input. An optional [message] can be
/// provided to assert on the error message.
@optionalTypeArgs
Matcher isParseFailure<T>(
  String input, {
  dynamic position = 0,
  dynamic message = anything,
}) =>
    isA<Parser<T>>()
        .having((parser) => parser.parse(input), 'parse',
            isFailure<T>(buffer: input, position: position, message: message))
        .having((parser) => parser.accept(input), 'accept', isFalse)
        .having((parser) {
      final context = DebugContext(input);
      parser.parseOn(context);
      expect(context.isSuccess, isFalse);
      expect(context.isSkip, isFalse);
      return true;
    }, 'parseOn', isTrue).having((parser) {
      final context = DebugContext(input, isSkip: true);
      parser.parseOn(context);
      expect(context.isSuccess, isFalse);
      expect(context.isSkip, isTrue);
      return true;
    }, 'parseOn (isSkip)', isTrue);

/// Returns a [Matcher] that asserts on a [Match], the result of a [Pattern].
Matcher isPatternMatch(
  String match, {
  dynamic start = anything,
  dynamic end = anything,
  dynamic groups = anything,
}) =>
    isA<Match>()
        .having((match) => match.group(0), 'match', match)
        .having((match) => match.start, 'start', start)
        .having((match) => match.end, 'end', end)
        .having(
            (match) => List.generate(
                match.groupCount, (group) => match.group(1 + group)),
            'groups',
            groups);
