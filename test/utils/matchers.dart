import 'package:meta/meta.dart';
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart' hide anyOf, predicate;
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

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
Matcher isParserDeepEqual(Parser expected) => predicate(
  (actual) =>
      actual is Parser &&
      actual.isEqualTo(expected) &&
      expected.isEqualTo(actual),
  'deep equivalent',
);

/// Returns a [Matcher] that asserts two parsers are equivalent ignoring
/// children.
Matcher isParserShallowEqual(Parser expected) => predicate(
  (actual) =>
      actual is Parser &&
      actual.isEqualTo(expected, {actual}) &&
      expected.isEqualTo(actual, {expected}),
  'shallow equivalent',
);

/// Returns a [Matcher] that asserts a [CharacterParser].
@optionalTypeArgs
Matcher isCharacterParser<P extends CharacterParser>({
  dynamic predicate = anything,
  dynamic message = anything,
}) => isA<P>()
    .having(
      (parser) => parser.predicate,
      'predicate',
      predicate is CharacterPredicate
          ? isCharacterPredicate(predicate)
          : predicate,
    )
    .having((parser) => parser.message, 'message', message);

/// Returns a [Matcher] that asserts a [CharacterPredicate].
Matcher isCharacterPredicate(CharacterPredicate expected) => predicate(
  (actual) =>
      actual is CharacterPredicate &&
      actual.isEqualTo(expected) &&
      expected.isEqualTo(actual),
  'equal predicate',
);

/// Returns a [Matcher] that asserts on the `toString` output.
Matcher isToString({String? name, String? generic, Iterable<String>? rest}) =>
    allOf(
      isNotEmpty,
      isNot(startsWith('Instance of')),
      stringContainsInOrder([
        if (name != null && hasAssertionsEnabled()) name,
        if (generic != null && hasAssertionsEnabled()) generic,
        if (rest != null) ...rest,
      ]),
    );

/// Returns a [Matcher] that asserts on the [Context].
TypeMatcher<Context> isContext({
  dynamic buffer = anything,
  dynamic position = anything,
}) => isA<Context>()
    .having((context) => context.buffer, 'buffer', buffer)
    .having((context) => context.position, 'position', position);

/// Returns a [Matcher] that asserts the context under test is a [Success].
/// Optionally also asserts [position] and [value].
@optionalTypeArgs
Matcher isSuccess<R>({
  dynamic buffer = anything,
  dynamic position = anything,
  dynamic value = anything,
}) => isA<Success<R>>()
    .having((success) => success.buffer, 'buffer', buffer)
    .having((success) => success.value, 'value', value)
    .having((success) => success.position, 'position', position);

/// Returns a [Matcher] that asserts the context under test is a [Failure].
/// Optionally also asserts [position] and [message].
Matcher isFailure({
  dynamic buffer = anything,
  dynamic position = anything,
  dynamic message = anything,
}) => isA<Failure>()
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
}) => isA<Parser<R>>()
    .having(
      (parser) => parser.parse(input),
      'parse',
      isSuccess<R>(
        buffer: input,
        value: result,
        position: position ?? input.length,
      ),
    )
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
}) => isA<Parser>()
    .having(
      (parser) => parser.parse(input),
      'parse',
      isFailure(buffer: input, position: position, message: message),
    )
    .having((parser) => parser.accept(input), 'accept', isFalse);

/// Returns a [Matcher] that asserts on a [Match], the result of a [Pattern].
Matcher isPatternMatch(
  String match, {
  dynamic start = anything,
  dynamic end = anything,
  dynamic groups = anything,
}) => isA<Match>()
    .having((match) => match.group(0), 'match', match)
    .having((match) => match.start, 'start', start)
    .having((match) => match.end, 'end', end)
    .having(
      (match) =>
          List.generate(match.groupCount, (group) => match.group(1 + group)),
      'groups',
      groups,
    );

/// Returns a [Matcher] that asserts a [LinterRule].
Matcher isLinterRule({
  dynamic type = anything,
  dynamic title = anything,
  dynamic toString = anything,
}) => isA<LinterRule>()
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
}) => isA<LinterIssue>()
    .having((issue) => issue.rule, 'rule', rule)
    .having((issue) => issue.type, 'type', type)
    .having((issue) => issue.title, 'title', title)
    .having((issue) => issue.parser, 'parser', parser)
    .having((issue) => issue.description, 'description', description)
    .having((issue) => issue.toString(), 'toString()', toString);

/// Returns a [Matcher] that asserts a [SeparatedList].
@optionalTypeArgs
Matcher isSeparatedList<R, S>({
  dynamic elements = anything,
  dynamic separators = anything,
}) => isA<SeparatedList<R, S>>()
    .having((list) => list.elements, 'elements', elements)
    .having((list) => list.separators, 'separators', separators);

/// Returns a [Matcher] that asserts a [ProfileFrame].
Matcher isProfileFrame({
  dynamic parser = anything,
  dynamic count = anything,
  dynamic elapsed = anything,
  dynamic toString = anything,
}) => isA<ProfileFrame>()
    .having((frame) => frame.parser, 'parser', parser)
    .having((frame) => frame.count, 'count', count)
    .having((frame) => frame.elapsed, 'elapsed', elapsed)
    .having((frame) => frame.toString(), 'toString', toString);

/// Returns a [Matcher] that asserts a [ProgressFrame].
Matcher isProgressFrame({
  dynamic parser = anything,
  dynamic context = anything,
  dynamic position = anything,
  dynamic toString = anything,
}) => isA<ProgressFrame>()
    .having((frame) => frame.parser, 'parser', parser)
    .having((frame) => frame.context, 'context', context)
    .having((frame) => frame.position, 'position', position)
    .having((frame) => frame.toString(), 'toString', toString);

/// Returns a [Matcher] that asserts a [TraceEvent].
Matcher isTraceEvent({
  dynamic parent = anything,
  dynamic parser = anything,
  dynamic context = anything,
  dynamic result = anything,
  dynamic level = anything,
  dynamic toString = anything,
}) => isA<TraceEvent>()
    .having((frame) => frame.parent, 'parent', parent)
    .having((frame) => frame.parser, 'parser', parser)
    .having((frame) => frame.context, 'context', context)
    .having((frame) => frame.result, 'result', result)
    .having((frame) => frame.level, 'level', level)
    .having((frame) => frame.toString(), 'toString', toString);
