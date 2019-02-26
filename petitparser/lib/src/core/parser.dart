library petitparser.core.parser;

import 'package:petitparser/src/core/actions/action.dart';
import 'package:petitparser/src/core/actions/cast.dart';
import 'package:petitparser/src/core/actions/flatten.dart';
import 'package:petitparser/src/core/actions/token.dart';
import 'package:petitparser/src/core/actions/trimming.dart';
import 'package:petitparser/src/core/characters/whitespace.dart';
import 'package:petitparser/src/core/combinators/and.dart';
import 'package:petitparser/src/core/combinators/choice.dart';
import 'package:petitparser/src/core/combinators/not.dart';
import 'package:petitparser/src/core/combinators/optional.dart';
import 'package:petitparser/src/core/combinators/sequence.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/failure.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/contexts/success.dart';
import 'package:petitparser/src/core/parsers/eof.dart';
import 'package:petitparser/src/core/parsers/settable.dart';
import 'package:petitparser/src/core/predicates/any.dart';
import 'package:petitparser/src/core/repeaters/greedy.dart';
import 'package:petitparser/src/core/repeaters/lazy.dart';
import 'package:petitparser/src/core/repeaters/possesive.dart';
import 'package:petitparser/src/core/repeaters/unbounded.dart';
import 'package:petitparser/src/core/token.dart';

/// Abstract base class of all parsers.
abstract class Parser<T> {
  const Parser();

  /// Primitive method doing the actual parsing.
  ///
  /// The method is overridden in concrete subclasses to implement the
  /// parser specific logic. The methods takes a parse [context] and
  /// returns the resulting context, which is either a [Success] or
  /// [Failure] context.
  Result<T> parseOn(Context context);

  /// Returns the parse result of the [input].
  ///
  /// The implementation creates a default parse context on the input and calls
  /// the internal parsing logic of the receiving parser.
  ///
  /// For example, `letter().plus().parse('abc')` results in an instance of
  /// [Success], where [Result.position] is `3` and [Success.value] is
  /// `[a, b, c]`.
  ///
  /// Similarly, `letter().plus().parse('123')` results in an instance of
  /// [Failure], where [Result.position] is `0` and [Failure.message] is
  /// ['letter expected'].
  Result<T> parse(String input) => parseOn(Context(input, 0));

  /// Tests if the [input] can be successfully parsed.
  ///
  /// For example, `letter().plus().accept('abc')` returns `true`, and
  /// `letter().plus().accept('123')` returns `false`.
  bool accept(String input) => parse(input).isSuccess;

  /// Returns a list of all successful overlapping parses of the [input].
  ///
  /// For example, `letter().plus().matches('abc de')` results in the list
  /// `[['a', 'b', 'c'], ['b', 'c'], ['c'], ['d', 'e'], ['e']]`. See
  /// [Parser.matchesSkipping] to retrieve non-overlapping parse results.
  List<T> matches(String input) {
    final list = <T>[];
    and().map(list.add).seq(any()).or(any()).star().parse(input);
    return list;
  }

  /// Returns a list of all successful non-overlapping parses of the input.
  ///
  /// For example, `letter().plus().matchesSkipping('abc de')` results in the
  /// list `[['a', 'b', 'c'], ['d', 'e']]`. See [Parser.matches] to retrieve
  /// overlapping parse results.
  List<T> matchesSkipping(String input) {
    final list = <T>[];
    map(list.add).or(any()).star().parse(input);
    return list;
  }

  /// Returns new parser that accepts the receiver, if possible. The resulting
  /// parser returns the result of the receiver, or `null` if not applicable.
  /// The returned value can be provided as an optional argument [otherwise].
  ///
  /// For example, the parser `letter().optional()` accepts a letter as input
  /// and returns that letter. When given something else the parser succeeds as
  /// well, does not consume anything and returns `null`.
  Parser<T> optional([T otherwise]) => OptionalParser<T>(this, otherwise);

  /// Returns a parser that accepts the receiver zero or more times. The
  /// resulting parser returns a list of the parse results of the receiver.
  ///
  /// This is a greedy and blind implementation that tries to consume as much
  /// input as possible and that does not consider what comes afterwards.
  ///
  /// For example, the parser `letter().star()` accepts the empty string or
  /// any sequence of letters and returns a possibly empty list of the parsed
  /// letters.
  Parser<List<T>> star() => repeat(0, unbounded);

  /// Returns a parser that parses the receiver zero or more times until it
  /// reaches a [limit]. This is a greedy non-blind implementation of the
  /// [Parser.star] operator. The [limit] is not consumed.
  Parser<List<T>> starGreedy(Parser limit) => repeatGreedy(limit, 0, unbounded);

  /// Returns a parser that parses the receiver zero or more times until it
  /// reaches a [limit]. This is a lazy non-blind implementation of the
  /// [Parser.star] operator. The [limit] is not consumed.
  Parser<List<T>> starLazy(Parser limit) => repeatLazy(limit, 0, unbounded);

  /// Returns a parser that accepts the receiver one or more times. The
  /// resulting parser returns a list of the parse results of the receiver.
  ///
  /// This is a greedy and blind implementation that tries to consume as much
  /// input as possible and that does not consider what comes afterwards.
  ///
  /// For example, the parser `letter().plus()` accepts any sequence of
  /// letters and returns a list of the parsed letters.
  Parser<List<T>> plus() => repeat(1, unbounded);

  /// Returns a parser that parses the receiver one or more times until it
  /// reaches [limit]. This is a greedy non-blind implementation of the
  /// [Parser.plus] operator. The [limit] is not consumed.
  Parser<List<T>> plusGreedy(Parser limit) => repeatGreedy(limit, 1, unbounded);

  /// Returns a parser that parses the receiver one or more times until it
  /// reaches a [limit]. This is a lazy non-blind implementation of the
  /// [Parser.plus] operator. The [limit] is not consumed.
  Parser<List<T>> plusLazy(Parser limit) => repeatLazy(limit, 1, unbounded);

  /// Returns a parser that accepts the receiver exactly [count] times. The
  /// resulting parser returns a list of the parse results of the receiver.
  ///
  /// For example, the parser `letter().times(2)` accepts two letters and
  /// returns a list of the two parsed letters.
  Parser times(int count) => repeat(count, count);

  /// Returns a parser that accepts the receiver between [min] and [max] times.
  /// The resulting parser returns a list of the parse results of the receiver.
  ///
  /// This is a greedy and blind implementation that tries to consume as much
  /// input as possible and that does not consider what comes afterwards.
  ///
  /// For example, the parser `letter().repeat(2, 4)` accepts a sequence of
  /// two, three, or four letters and returns the accepted letters as a list.
  Parser<List<T>> repeat(int min, [int max]) =>
      PossessiveRepeatingParser<T>(this, min, max ?? min);

  /// Returns a parser that parses the receiver at least [min] and at most [max]
  /// times until it reaches a [limit]. This is a greedy non-blind
  /// implementation of the [Parser.repeat] operator. The [limit] is not
  /// consumed.
  Parser<List<T>> repeatGreedy(Parser limit, int min, int max) =>
      GreedyRepeatingParser<T>(this, limit, min, max);

  /// Returns a parser that parses the receiver at least [min] and at most [max]
  /// times until it reaches a [limit]. This is a lazy non-blind implementation
  /// of the [Parser.repeat] operator. The [limit] is not consumed.
  Parser<List<T>> repeatLazy(Parser limit, int min, int max) =>
      LazyRepeatingParser<T>(this, limit, min, max);

  /// Returns a parser that accepts the receiver followed by [other]. The
  /// resulting parser returns a list of the parse result of the receiver
  /// followed by the parse result of [other]. Calling this method on an
  /// existing sequence code not nest this sequence into a new one, but
  /// instead augments the existing sequence with [other].
  ///
  /// For example, the parser `letter().seq(digit()).seq(letter())` accepts a
  /// letter followed by a digit and another letter. The parse result of the
  /// input string `'a1b'` is the list `['a', '1', 'b']`.
  Parser<List> seq(Parser other) => SequenceParser([this, other]);

  /// Convenience operator returning a parser that accepts the receiver followed
  /// by [other]. See [Parser.seq] for details.
  Parser<List> operator &(Parser other) => seq(other);

  /// Returns a parser that accepts the receiver or [other]. The resulting
  /// parser returns the parse result of the receiver, if the receiver fails
  /// it returns the parse result of [other] (exclusive ordered choice).
  ///
  /// For example, the parser `letter().or(digit())` accepts a letter or a
  /// digit. An example where the order matters is the following choice between
  /// overlapping parsers: `letter().or(char('a'))`. In the example the parser
  /// `char('a')` will never be activated, because the input is always consumed
  /// `letter()`. This can be problematic if the author intended to attach a
  /// production action to `char('a')`.
  Parser or(Parser other) => ChoiceParser([this, other]);

  /// Convenience operator returning a parser that accepts the receiver or
  /// [other]. See [Parser.or] for details.
  Parser operator |(Parser other) => or(other);

  /// Returns a parser (logical and-predicate) that succeeds whenever the
  /// receiver does, but never consumes input.
  ///
  /// For example, the parser `char('_').and().seq(identifier)` accepts
  /// identifiers that start with an underscore character. Since the predicate
  /// does not consume accepted input, the parser `identifier` is given the
  /// ability to process the complete identifier.
  Parser<T> and() => AndParser<T>(this);

  /// Returns a parser (logical not-predicate) that succeeds whenever the
  /// receiver fails, but never consumes input.
  ///
  /// For example, the parser `char('_').not().seq(identifier)` accepts
  /// identifiers that do not start with an underscore character. If the parser
  /// `char('_')` accepts the input, the negation and subsequently the
  /// complete parser fails. Otherwise the parser `identifier` is given the
  /// ability to process the complete identifier.
  Parser<void> not([String message = 'success not expected']) =>
      NotParser(this, message);

  /// Returns a parser that consumes any input token (character), but the
  /// receiver.
  ///
  /// For example, the parser `letter().neg()` accepts any input but a letter.
  /// The parser fails for inputs like `'a'` or `'Z'`, but succeeds for
  /// input like `'1'`, `'_'` or `'$'`.
  Parser<String> neg([String message = 'input not expected']) =>
      not(message).seq(any()).pick(1);

  /// Returns a parser that discards the result of the receiver, and returns
  /// a sub-string of the consumed range in the string/list being parsed.
  ///
  /// For example, the parser `letter().plus().flatten()` returns `'abc'`
  /// for the input `'abc'`. In contrast, the parser `letter().plus()` would
  /// return `['a', 'b', 'c']` for the same input instead.
  Parser<String> flatten() => FlattenParser(this);

  /// Returns a parser that returns a [Token]. The token carries the parsed
  /// value of the receiver [Token.value], as well as the consumed input
  /// [Token.input] from [Token.start] to [Token.stop] of the input being
  /// parsed.
  ///
  /// For example, the parser `letter().plus().token()` returns the token
  /// `Token[start: 0, stop: 3, value: abc]` for the input `'abc'`.
  Parser<Token<T>> token() => TokenParser<T>(this);

  /// Returns a parser that consumes input before and after the receiver,
  /// discards the excess input and only returns returns the result of the
  /// receiver. The optional argument is a parser that consumes the excess
  /// input. By default `whitespace()` is used. Up to two arguments can be
  /// provided to have different parsers on the [left] and [right] side.
  ///
  /// For example, the parser `letter().plus().trim()` returns `['a', 'b']`
  /// for the input `' ab\n'` and consumes the complete input string.
  Parser<T> trim([Parser left, Parser right]) =>
      TrimmingParser(this, left ??= whitespace(), right ??= left);

  /// Returns a parser that succeeds only if the receiver consumes the complete
  /// input, otherwise return a failure with the optional [message].
  ///
  /// For example, the parser `letter().end()` succeeds on the input `'a'`
  /// and fails on `'ab'`. In contrast the parser `letter()` alone would
  /// succeed on both inputs, but not consume everything for the second input.
  Parser<T> end([String message = 'end of input expected']) =>
      SequenceParser([this, endOfInput(message)]).pick(0);

  /// Returns a parser that points to the receiver, but can be changed to point
  /// to something else at a later point in time.
  ///
  /// For example, the parser `letter().settable()` behaves exactly the same
  /// as `letter()`, but it can be replaced with another parser using
  /// [SettableParser.set].
  SettableParser<T> settable() => SettableParser<T>(this);

  /// Returns a parser that evaluates a [callback] as the production action
  /// on success of the receiver.
  ///
  /// For example, the parser `digit().map((char) => int.parse(char))` returns
  /// the number `1` for the input string `'1'`. If the delegate fail, the
  /// production action is not executed and the failure is passed on.
  Parser<R> map<R>(ActionCallback<T, R> callback) =>
      ActionParser<T, R>(this, callback);

  /// Returns a parser that casts itself to `Parser<R>`.
  Parser<R> cast<R>() => CastParser<R>(this);

  /// Returns a parser that casts itself to `Parser<List<R>>`. Assumes this
  /// parser to be of type `Parser<List>`.
  Parser<List<R>> castList<R>() => CastListParser<R>(this);

  /// Returns a parser that transform a successful parse result by returning
  /// the element at [index] of a list. A negative index can be used to access
  /// the elements from the back of the list. Assumes this parser to be of type
  /// `Parser<List<R>>`.
  ///
  /// For example, the parser `letter().star().pick(-1)` returns the last
  /// letter parsed. For the input `'abc'` it returns `'c'`.
  Parser<R> pick<R>(int index) {
    return castList<R>().map<R>((list) {
      return list[index < 0 ? list.length + index : index];
    });
  }

  /// Returns a parser that transforms a successful parse result by returning
  /// the permuted elements at [indexes] of a list. Negative indexes can be
  /// used to access the elements from the back of the list. Assumes this parser
  /// to be of type `Parser<List<R>>`.
  ///
  /// For example, the parser `letter().star().permute([0, -1])` returns the
  /// first and last letter parsed. For the input `'abc'` it returns
  /// `['a', 'c']`.
  Parser<List<R>> permute<R>(List<int> indexes) {
    return castList<R>().map<List<R>>((list) {
      return indexes.map((index) {
        return list[index < 0 ? list.length + index : index];
      }).toList(growable: false);
    });
  }

  /// Returns a parser that consumes the receiver one or more times separated
  /// by the [separator] parser. The resulting parser returns a flat list of
  /// the parse results of the receiver interleaved with the parse result of the
  /// separator parser. The type parameter `R` defines the type of the returned
  /// list.
  ///
  /// If the optional argument [includeSeparators] is set to `false`, then the
  /// separators are not included in the parse result. If the optional argument
  /// [optionalSeparatorAtEnd] is set to `true` the parser also accepts an
  /// optional separator at the end.
  ///
  /// For example, the parser `digit().separatedBy(char('-'))` returns a parser
  /// that consumes input like `'1-2-3'` and returns a list of the elements and
  /// separators: `['1', '-', '2', '-', '3']`.
  Parser<List<R>> separatedBy<R>(Parser separator,
      {bool includeSeparators = true, bool optionalSeparatorAtEnd = false}) {
    final repeater = SequenceParser([separator, this]).star();
    final parser = SequenceParser(optionalSeparatorAtEnd
        ? [this, repeater, separator.optional()]
        : [this, repeater]);
    return parser.map((list) {
      final result = <R>[];
      result.add(list[0]);
      for (var tuple in list[1]) {
        if (includeSeparators) {
          result.add(tuple[0]);
        }
        result.add(tuple[1]);
      }
      if (includeSeparators && optionalSeparatorAtEnd && list[2] != null) {
        result.add(list[2]);
      }
      return result;
    });
  }

  /// Returns a shallow copy of the receiver.
  ///
  /// Override this method in all subclasses, return its own type.
  Parser<T> copy();

  /// Recursively tests for structural equality of two parsers.
  ///
  /// The code can automatically deals with recursive parsers and parsers that
  /// refer to other parsers. This code is supposed to be overridden by parsers
  /// that add other state.
  bool isEqualTo(Parser other, [Set<Parser> seen]) {
    seen ??= {};
    if (this == other || seen.contains(this)) {
      return true;
    }
    seen.add(this);
    return runtimeType == other.runtimeType &&
        hasEqualProperties(other) &&
        hasEqualChildren(other, seen);
  }

  /// Compare the properties of two parsers. Normally this method should not be
  /// called directly, instead use [Parser#equals].
  ///
  /// Override this method in all subclasses that add new state.
  bool hasEqualProperties(covariant Parser<T> other) => true;

  /// Compare the children of two parsers. Normally this method should not be
  /// called directly, instead use [Parser#equals].
  ///
  /// Normally this method does not need to be overridden, as this method works
  /// generically on the returned [Parser#children].
  bool hasEqualChildren(Parser other, Set<Parser> seen) {
    final thisChildren = children, otherChildren = other.children;
    if (thisChildren.length != otherChildren.length) {
      return false;
    }
    for (var i = 0; i < thisChildren.length; i++) {
      if (!thisChildren[i].isEqualTo(otherChildren[i], seen)) {
        return false;
      }
    }
    return true;
  }

  /// Returns a list of directly referenced parsers.
  ///
  /// For example, `letter().children` returns the empty collection `[]`,
  /// because the letter parser is a primitive or leaf parser that does not
  /// depend or call any other parser.
  ///
  /// In contrast, `letter().or(digit()).children` returns a collection
  /// containing both the `letter()` and `digit()` parser.
  List<Parser> get children => const [];

  /// Changes the receiver by replacing [source] with [target]. Does nothing
  /// if [source] does not exist in [Parser.children].
  ///
  /// The following example creates a letter parser and then defines a parser
  /// called `example` that accepts one or more letters. Eventually the parser
  /// `example` is modified by replacing the `letter` parser with a new
  /// parser that accepts a digit. The resulting `example` parser accepts one
  /// or more digits.
  ///
  ///     final letter = letter();
  ///     final example = letter.plus();
  ///     example.replace(letter, digit());
  void replace(Parser source, Parser target) {
    // no children, nothing to do
  }
}
