import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart' as test show predicate;
import 'package:test/test.dart' hide predicate;

/// Returns a [Matcher] that asserts on a [ParserException].
const isParserException = TypeMatcher<ParserException>();

/// Returns `true`, if assertions are enabled.
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
Matcher isParserEqual<R>(Parser<R> parser) => test.predicate(
    (actual) => actual is Parser<R> && actual.isEqualTo(parser),
    'structurally equal');

/// Returns a [Matcher] that asserts on the [Context].
TypeMatcher<Context> isContext({
  dynamic buffer = anything,
  dynamic position = anything,
}) =>
    isA<Context>()
        .having((context) => context.buffer, 'buffer', buffer)
        .having((context) => context.position, 'position', position);

/// Returns a [Matcher] that asserts the context under test is a [Success].
/// Optionally also asserts [position] and [value].
@optionalTypeArgs
Matcher isSuccess<R>({
  dynamic buffer = anything,
  dynamic position = anything,
  dynamic value = anything,
}) =>
    isA<Success<R>>()
        .having((success) => success.buffer, 'buffer', buffer)
        .having((success) => success.value, 'value', value)
        .having((success) => success.position, 'position', position);

/// Returns a [Matcher] that asserts the context under test is a [Failure].
/// Optionally also asserts [position] and [message].
@optionalTypeArgs
Matcher isFailure({
  dynamic buffer = anything,
  dynamic position = anything,
  dynamic message = anything,
}) =>
    isA<Failure>()
        .having((failure) => failure.buffer, 'buffer', buffer)
        .having((failure) => failure.position, 'position', position)
        .having((failure) => failure.message, 'message', message);

/// Returns a [Matcher] that asserts the parser under test yields a successful
/// parse [result] for the given [input]. If no [position] is provided, assert
/// that the parsing fails at the end of the input.
@optionalTypeArgs
Matcher isParseSuccess<R>(
  String input, {
  dynamic result = anything,
  dynamic position,
}) =>
    isA<Parser<R>>()
        .having(
            (parser) => parser.parse(input),
            'parse',
            isSuccess<R>(
                buffer: input,
                value: result,
                position: position ?? input.length))
        .having((parser) => parser.accept(input), 'accept', isTrue);

/// Returns a [Matcher] that asserts the parser under test yields a parse
/// failure for the given [input]. If no [position] is provided, assert that
/// parsing fails at the beginning of the input. An optional [message] can be
/// provided to assert on the error message.
@optionalTypeArgs
Matcher isParseFailure(
  String input, {
  dynamic position = 0,
  dynamic message = anything,
}) =>
    isA<Parser>()
        .having((parser) => parser.parse(input), 'parse',
            isFailure(buffer: input, position: position, message: message))
        .having((parser) => parser.accept(input), 'accept', isFalse);

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

/// Returns a [Matcher] that asserts a [LinterRule].
Matcher isLinterRule({
  dynamic type = anything,
  dynamic title = anything,
  dynamic toString = anything,
}) =>
    isA<LinterRule>()
        .having((rule) => rule.type, 'type', type)
        .having((rule) => rule.title, 'title', title)
        .having((rule) => rule.toString(), 'toString()', toString);

/// Returns a [Matcher] that asserts a [LinterIssue].
Matcher isLinterIssue({
  dynamic rule = anything,
  dynamic type = anything,
  dynamic title = anything,
  dynamic parser = anything,
  dynamic description = anything,
  dynamic toString = anything,
}) =>
    isA<LinterIssue>()
        .having((issue) => issue.rule, 'rule', rule)
        .having((issue) => issue.type, 'type', type)
        .having((issue) => issue.title, 'title', title)
        .having((issue) => issue.parser, 'parser', parser)
        .having((issue) => issue.description, 'description', description)
        .having((issue) => issue.toString(), 'toString()', toString);
