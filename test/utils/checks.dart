import 'package:checks/checks.dart';
import 'package:checks/context.dart' hide Context;
import 'package:meta/meta.dart';
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/scaffolding.dart' show TestFailure;

/// Signals that the test has failed with [message].
Never fail(String message) => throw TestFailure(message);

/// Sentinel class for default argument detection.
class _Default {
  const new();
}

const _default = _Default();

/// Returns `true`, if assertions are enabled.
bool hasAssertionsEnabled() {
  try {
    assert(false);
    return false;
  } catch (exception) {
    return true;
  }
}

/// Extensions for assertion error checks.
extension AssertionChecks on Subject<void Function()> {
  Subject<AssertionError> throwsAssertionError({Object? message = _default}) {
    if (!hasAssertionsEnabled()) {
      throw UnsupportedError('Assertions are disabled');
    }
    final error = throws<AssertionError>();
    if (message is! _Default) {
      final msg = error.has((e) => e.message, 'message');
      if (message is Pattern) {
        msg.isA<String>().matchesPattern(message);
      } else if (message is String) {
        msg.equals(message);
      } else if (message is void Function(Subject<Object?>)) {
        message(msg);
      } else {
        msg.equals(message);
      }
    }
    return error;
  }
}

/// Extensions on [Parser] for checks.
extension ParserChecks<P extends Parser> on Subject<P> {
  /// Asserts that two parsers are structurally equivalent.
  void isDeepEqualTo(Parser expected) {
    context.expect(() => ['is deep equal to $expected'], (actual) {
      if (actual.isEqualTo(expected) && expected.isEqualTo(actual)) {
        return null;
      }
      return Rejection(which: ['is not deep equal to $expected']);
    });
  }

  /// Asserts that two parsers are equivalent ignoring children.
  void isShallowEqualTo(Parser expected) {
    context.expect(() => ['is shallow equal to $expected'], (actual) {
      if (actual.isEqualTo(expected, {actual}) &&
          expected.isEqualTo(actual, {expected})) {
        return null;
      }
      return Rejection(which: ['is not shallow equal to $expected']);
    });
  }
}

/// Extensions on `Parser<R>` for parse checks.
extension ParseResultChecks<R> on Subject<Parser<R>> {
  /// Asserts that the parser yields a successful parse [result] for the given [input].
  void parseSuccess(String input, {Object? result = _default, int? position}) {
    has((p) => p.accept(input), 'accept').isTrue();
    final parseResult = has((p) => p.parse(input), 'parse').isA<Success<R>>();
    parseResult.has((s) => s.buffer, 'buffer').equals(input);
    parseResult
        .has((s) => s.position, 'position')
        .equals(position ?? input.length);
    if (result is! _Default) {
      final valueSubject = parseResult.has((s) => s.value, 'value');
      if (result == null) {
        valueSubject.isNull();
      } else if (result is void Function(Subject<R>)) {
        result(valueSubject);
      } else if (result is Iterable) {
        valueSubject.isA<Iterable<dynamic>>().deepEquals(result);
      } else if (result is Map) {
        valueSubject.isA<Map<dynamic, dynamic>>().deepEquals(result);
      } else {
        valueSubject.isA<Object?>().equals(result);
      }
    }
  }

  /// Asserts that the parser yields a parse failure for the given [input].
  void parseFailure(
    String input, {
    int position = 0,
    Object? message = _default,
  }) {
    has((p) => p.accept(input), 'accept').isFalse();
    final parseResult = has((p) => p.parse(input), 'parse').isA<Failure>();
    parseResult.has((f) => f.buffer, 'buffer').equals(input);
    parseResult.has((f) => f.position, 'position').equals(position);
    if (message is! _Default) {
      final messageSubject = parseResult.has((f) => f.message, 'message');
      if (message is Pattern) {
        messageSubject.matchesPattern(message);
      } else if (message is void Function(Subject<String>)) {
        message(messageSubject);
      } else if (message is String) {
        messageSubject.equals(message);
      } else {
        messageSubject.isA<Object?>().equals(message);
      }
    }
  }
}

/// Extensions on [CharacterParser].
extension CharacterParserChecks<P extends CharacterParser> on Subject<P> {
  Subject<CharacterPredicate> get predicate =>
      has((p) => p.predicate, 'predicate');
  Subject<String> get message => has((p) => p.message, 'message');

  void isCharacterParser({
    Object? predicate = _default,
    Object? message = _default,
  }) {
    if (predicate is! _Default) {
      if (predicate is CharacterPredicate) {
        this.predicate.isEqualToPredicate(predicate);
      } else if (predicate is void Function(Subject<CharacterPredicate>)) {
        predicate(this.predicate);
      }
    }
    if (message is! _Default) {
      if (message is String) {
        this.message.equals(message);
      } else if (message is void Function(Subject<String>)) {
        message(this.message);
      } else {
        this.message.isA<Object?>().equals(message);
      }
    }
  }
}

/// Extensions on [CharacterPredicate].
extension CharacterPredicateChecks<CP extends CharacterPredicate>
    on Subject<CP> {
  void isEqualToPredicate(CharacterPredicate expected) {
    context.expect(() => ['is equal to predicate $expected'], (actual) {
      if (actual.isEqualTo(expected) && expected.isEqualTo(actual)) {
        return null;
      }
      return Rejection(which: ['is not equal to predicate $expected']);
    });
  }
}

/// Extensions on `toString` outputs.
extension CustomToStringChecks on Subject<String> {
  void isCustomToString({
    String? name,
    String? generic,
    Iterable<String>? rest,
  }) {
    isNotEmpty();
    not((it) => it.startsWith('Instance of'));
    final expected = [
      if (name != null && hasAssertionsEnabled()) name,
      if (generic != null && hasAssertionsEnabled()) generic,
      ...?rest,
    ];
    if (expected.isNotEmpty) {
      containsInOrder(expected);
    }
  }
}

/// Returns a condition checking custom toString format.
Condition<String> isToString({
  String? name,
  String? generic,
  Iterable<String>? rest,
}) => (Subject<String> it) {
  it.isCustomToString(name: name, generic: generic, rest: rest);
};

/// Extensions on [Context].
extension ParserContextChecks<C extends Context> on Subject<C> {
  Subject<String> get buffer => has((c) => c.buffer, 'buffer');
  Subject<int> get position => has((c) => c.position, 'position');

  void isContext({String? buffer, int? position}) {
    if (buffer != null) {
      this.buffer.equals(buffer);
    }
    if (position != null) {
      this.position.equals(position);
    }
  }

  @optionalTypeArgs
  Subject<Success<R>> isSuccess<R>({
    String? buffer,
    int? position,
    Object? value = _default,
  }) {
    final success = isA<Success<R>>();
    if (buffer != null) {
      success.buffer.equals(buffer);
    }
    if (position != null) {
      success.position.equals(position);
    }
    if (value is! _Default) {
      final valueSubject = success.has((s) => s.value, 'value');
      if (value == null) {
        valueSubject.isNull();
      } else if (value is void Function(Subject<R>)) {
        value(valueSubject);
      } else if (value is Iterable) {
        valueSubject.isA<Iterable<dynamic>>().deepEquals(value);
      } else if (value is Map) {
        valueSubject.isA<Map<dynamic, dynamic>>().deepEquals(value);
      } else {
        valueSubject.isA<Object?>().equals(value);
      }
    }
    return success;
  }

  Subject<Failure> isFailure({
    String? buffer,
    int? position,
    Object? message = _default,
  }) {
    final failure = isA<Failure>();
    if (buffer != null) {
      failure.buffer.equals(buffer);
    }
    if (position != null) {
      failure.position.equals(position);
    }
    if (message is! _Default) {
      if (message is Pattern) {
        failure.message.matchesPattern(message);
      } else if (message is void Function(Subject<String>)) {
        message(failure.message);
      } else if (message is String) {
        failure.message.equals(message);
      } else {
        failure.message.isA<Object?>().equals(message);
      }
    }
    return failure;
  }
}

/// Extensions on nullable [Result].
extension ResultSubjectChecks on Subject<Result<dynamic>?> {
  @optionalTypeArgs
  Subject<Success<R>> isSuccess<R>({
    String? buffer,
    int? position,
    Object? value = _default,
  }) {
    final success = isNotNull().isA<Success<R>>();
    if (buffer != null) {
      success.buffer.equals(buffer);
    }
    if (position != null) {
      success.position.equals(position);
    }
    if (value is! _Default) {
      final valueSubject = success.has((s) => s.value, 'value');
      if (value == null) {
        valueSubject.isNull();
      } else if (value is void Function(Subject<R>)) {
        value(valueSubject);
      } else if (value is Iterable) {
        valueSubject.isA<Iterable<dynamic>>().deepEquals(value);
      } else if (value is Map) {
        valueSubject.isA<Map<dynamic, dynamic>>().deepEquals(value);
      } else {
        valueSubject.isA<Object?>().equals(value);
      }
    }
    return success;
  }

  Subject<Failure> isFailure({
    String? buffer,
    int? position,
    Object? message = _default,
  }) {
    final failure = isNotNull().isA<Failure>();
    if (buffer != null) {
      failure.buffer.equals(buffer);
    }
    if (position != null) {
      failure.position.equals(position);
    }
    if (message is! _Default) {
      if (message is Pattern) {
        failure.message.matchesPattern(message);
      } else if (message is void Function(Subject<String>)) {
        message(failure.message);
      } else if (message is String) {
        failure.message.equals(message);
      } else {
        failure.message.isA<Object?>().equals(message);
      }
    }
    return failure;
  }
}

/// Extensions on [Success].
extension SuccessChecks<R, S extends Success<R>> on Subject<S> {
  Subject<R> get value => has((s) => s.value, 'value');
}

/// Extensions on [Failure].
extension FailureChecks<F extends Failure> on Subject<F> {
  Subject<String> get message => has((f) => f.message, 'message');
}

/// Extensions on [Match].
extension PatternMatchChecks on Subject<Match> {
  Subject<String?> get match => has((m) => m.group(0), 'group(0)');
  Subject<int> get matchStart => has((m) => m.start, 'start');
  Subject<int> get matchEnd => has((m) => m.end, 'end');
  Subject<List<String?>> get groups => has(
    (m) => List.generate(m.groupCount, (group) => m.group(1 + group)),
    'groups',
  );

  void isPatternMatch(
    String match, {
    int? start,
    int? end,
    Object? groups = _default,
  }) {
    this.match.equals(match);
    if (start != null) {
      matchStart.equals(start);
    }
    if (end != null) {
      matchEnd.equals(end);
    }
    if (groups is! _Default) {
      if (groups is Iterable<String?>) {
        this.groups.deepEquals(groups);
      } else if (groups is void Function(Subject<List<String?>>)) {
        groups(this.groups);
      } else {
        this.groups.isA<Object?>().equals(groups);
      }
    }
  }
}

/// Extensions on [LinterRule].
extension LinterRuleChecks on Subject<LinterRule> {
  Subject<LinterType> get type => has((rule) => rule.type, 'type');
  Subject<String> get title => has((rule) => rule.title, 'title');

  void isLinterRule({
    LinterType? type,
    String? title,
    Condition<String>? toString,
  }) {
    if (type != null) {
      this.type.equals(type);
    }
    if (title != null) {
      this.title.equals(title);
    }
    if (toString != null) {
      toString(has((rule) => rule.toString(), 'toString()'));
    }
  }
}

/// Extensions on [LinterIssue].
extension LinterIssueChecks on Subject<LinterIssue> {
  Subject<LinterRule> get rule => has((issue) => issue.rule, 'rule');
  Subject<LinterType> get type => has((issue) => issue.type, 'type');
  Subject<String> get title => has((issue) => issue.title, 'title');
  Subject<Parser> get parser => has((issue) => issue.parser, 'parser');
  Subject<String> get description =>
      has((issue) => issue.description, 'description');

  void isLinterIssue({
    Object? rule = _default,
    LinterType? type,
    String? title,
    Object? parser = _default,
    String? description,
    Condition<String>? toString,
  }) {
    if (rule is! _Default) {
      if (rule is LinterRule) {
        this.rule.equals(rule);
      } else if (rule is void Function(Subject<LinterRule>)) {
        rule(this.rule);
      }
    }
    if (type != null) {
      this.type.equals(type);
    }
    if (title != null) {
      this.title.equals(title);
    }
    if (parser is! _Default) {
      if (parser is Parser) {
        this.parser.isDeepEqualTo(parser);
      } else if (parser is void Function(Subject<Parser>)) {
        parser(this.parser);
      }
    }
    if (description != null) {
      this.description.equals(description);
    }
    if (toString != null) {
      toString(has((issue) => issue.toString(), 'toString()'));
    }
  }
}

/// Returns a condition asserting properties on a [LinterRule].
Condition<LinterRule> isLinterRule({
  LinterType? type,
  String? title,
  Condition<String>? toString,
}) => (Subject<LinterRule> it) {
  it.isLinterRule(type: type, title: title, toString: toString);
};

/// Returns a condition asserting properties on a [LinterIssue].
Condition<LinterIssue> isLinterIssue({
  Object? rule = _default,
  LinterType? type,
  String? title,
  Object? parser = _default,
  String? description,
  Condition<String>? toString,
}) => (Subject<LinterIssue> it) {
  it.isLinterIssue(
    rule: rule,
    type: type,
    title: title,
    parser: parser,
    description: description,
    toString: toString,
  );
};

/// Extensions on [SeparatedList].
extension SeparatedListChecks<R, S> on Subject<SeparatedList<R, S>> {
  Subject<List<R>> get elements => has((list) => list.elements, 'elements');
  Subject<List<S>> get separators =>
      has((list) => list.separators, 'separators');

  void isSeparatedList({
    Object? elements = _default,
    Object? separators = _default,
  }) {
    if (elements is! _Default) {
      if (elements is Iterable<R>) {
        this.elements.deepEquals(elements);
      } else if (elements is void Function(Subject<List<R>>)) {
        elements(this.elements);
      } else {
        this.elements.isA<Object?>().equals(elements);
      }
    }
    if (separators is! _Default) {
      if (separators is Iterable<S>) {
        this.separators.deepEquals(separators);
      } else if (separators is void Function(Subject<List<S>>)) {
        separators(this.separators);
      } else {
        this.separators.isA<Object?>().equals(separators);
      }
    }
  }
}

/// Returns a condition asserting properties on a [SeparatedList].
Condition<dynamic> isSeparatedList<R, S>({
  Object? elements = _default,
  Object? separators = _default,
}) => (Subject<dynamic> subject) {
  subject.isA<SeparatedList<R, S>>().isSeparatedList(
    elements: elements,
    separators: separators,
  );
};

/// Extensions on [ProfileFrame].
extension ProfileFrameChecks on Subject<ProfileFrame> {
  Subject<Parser> get parser => has((frame) => frame.parser, 'parser');
  Subject<int> get count => has((frame) => frame.count, 'count');
  Subject<Duration> get elapsed => has((frame) => frame.elapsed, 'elapsed');

  void isProfileFrame({
    Object? parser = _default,
    Object? count = _default,
    Object? elapsed = _default,
    Condition<String>? toString,
  }) {
    if (parser is! _Default) {
      if (parser is Parser) {
        this.parser.isShallowEqualTo(parser);
      } else if (parser is void Function(Subject<Parser>)) {
        parser(this.parser);
      }
    }
    if (count is! _Default) {
      if (count is int) {
        this.count.equals(count);
      } else if (count is void Function(Subject<int>)) {
        count(this.count);
      } else {
        this.count.isA<Object?>().equals(count);
      }
    }
    if (elapsed is! _Default) {
      if (elapsed is Duration) {
        this.elapsed.equals(elapsed);
      } else if (elapsed is void Function(Subject<Duration>)) {
        elapsed(this.elapsed);
      } else {
        this.elapsed.isA<Object?>().equals(elapsed);
      }
    }
    if (toString != null) {
      toString(has((frame) => frame.toString(), 'toString()'));
    }
  }
}

/// Extensions on [ProgressFrame].
extension ProgressFrameChecks on Subject<ProgressFrame> {
  Subject<Parser> get parser => has((frame) => frame.parser, 'parser');
  Subject<Context> get contextSubject =>
      has((frame) => frame.context, 'context');
  Subject<int> get framePosition => has((frame) => frame.position, 'position');

  void isProgressFrame({
    Object? parser = _default,
    Object? context = _default,
    Object? position = _default,
    Condition<String>? toString,
  }) {
    if (parser is! _Default) {
      if (parser is Parser) {
        this.parser.isShallowEqualTo(parser);
      } else if (parser is void Function(Subject<Parser>)) {
        parser(this.parser);
      }
    }
    if (context is! _Default) {
      if (context is void Function(Subject<Context>)) {
        context(contextSubject);
      } else if (context is Context) {
        contextSubject.equals(context);
      } else {
        contextSubject.isA<Object?>().equals(context);
      }
    }
    if (position is! _Default) {
      if (position is int) {
        framePosition.equals(position);
      } else if (position is void Function(Subject<int>)) {
        position(framePosition);
      } else {
        framePosition.isA<Object?>().equals(position);
      }
    }
    if (toString != null) {
      toString(has((frame) => frame.toString(), 'toString()'));
    }
  }
}

/// Extensions on [TraceEvent].
extension TraceEventChecks on Subject<TraceEvent> {
  Subject<TraceEvent?> get parent => has((frame) => frame.parent, 'parent');
  Subject<Parser> get parser => has((frame) => frame.parser, 'parser');
  Subject<Context> get contextSubject =>
      has((frame) => frame.context, 'context');
  Subject<Result<dynamic>?> get result =>
      has((frame) => frame.result, 'result');
  Subject<int> get level => has((frame) => frame.level, 'level');

  void isTraceEvent({
    Object? parent = _default,
    Object? parser = _default,
    Object? context = _default,
    Object? result = _default,
    Condition<Result<dynamic>?>? whichResult,
    Object? level = _default,
    Condition<String>? toString,
  }) {
    if (parent is! _Default) {
      if (parent == null) {
        this.parent.isNull();
      } else if (parent is void Function(Subject<TraceEvent?>)) {
        parent(this.parent);
      } else if (parent is TraceEvent) {
        this.parent.equals(parent);
      } else {
        this.parent.isA<Object?>().equals(parent);
      }
    }
    if (parser is! _Default) {
      if (parser is Parser) {
        this.parser.isShallowEqualTo(parser);
      } else if (parser is void Function(Subject<Parser>)) {
        parser(this.parser);
      }
    }
    if (context is! _Default) {
      if (context is void Function(Subject<Context>)) {
        context(contextSubject);
      } else if (context is Context) {
        contextSubject.equals(context);
      } else {
        contextSubject.isA<Object?>().equals(context);
      }
    }
    if (whichResult != null) {
      whichResult(this.result);
    } else if (result is! _Default) {
      if (result == null) {
        this.result.isNull();
      } else if (result is void Function(Subject<Result<dynamic>?>)) {
        result(this.result);
      } else if (result is Result<dynamic>) {
        this.result.equals(result);
      } else {
        this.result.isA<Object?>().equals(result);
      }
    }
    if (level is! _Default) {
      if (level is int) {
        this.level.equals(level);
      } else if (level is void Function(Subject<int>)) {
        level(this.level);
      } else {
        this.level.isA<Object?>().equals(level);
      }
    }
    if (toString != null) {
      toString(has((frame) => frame.toString(), 'toString()'));
    }
  }
}

/// Extensions on [Iterable] to check a list of conditions in order.
extension IterableConditionsChecks<T> on Subject<Iterable<T>> {
  void matchesInOrder(List<void Function(Subject<T>)> conditions) {
    context.expect(() => ['matches ${conditions.length} conditions in order'], (
      actual,
    ) {
      final list = actual.toList();
      if (list.length != conditions.length) {
        return Rejection(
          which: [
            'has length ${list.length}, expected exactly ${conditions.length}',
          ],
        );
      }
      for (var i = 0; i < conditions.length; i++) {
        final failure = softCheck(list[i], conditions[i]);
        if (failure != null) {
          final which = failure.rejection.which;
          return Rejection(
            which: [
              'element at index $i failed condition:',
              if (which != null) ...which else ...failure.detail.actual,
            ],
          );
        }
      }
      return null;
    });
  }
}

/// Returns a condition checking that a number is close to [other] within [delta].
Condition<num> closeTo(num other, num delta) =>
    (Subject<num> it) => it.isCloseTo(other, delta);
