library petitparser.core.parser;

import 'package:meta/meta.dart';

import 'contexts/context.dart';
import 'contexts/failure.dart';
import 'contexts/result.dart';
import 'contexts/success.dart';

/// Abstract base class of all parsers.
@optionalTypeArgs
abstract class Parser<T> {
  const Parser();

  /// Primitive method doing the actual parsing.
  ///
  /// The method is overridden in concrete subclasses to implement the
  /// parser specific logic. The methods takes a parse [context] and
  /// returns the resulting context, which is either a [Success] or
  /// [Failure] context.
  Result<T> parseOn(Context context);

  /// Primitive method doing the actual parsing.
  ///
  /// This method is an optimized version of [Parser.parseOn(Context)] that is
  /// getting its speed advantage by avoiding any unnecessary memory
  /// allocations.
  ///
  /// The method is overridden in most concrete subclasses to implement the
  /// optimized logic. As an input the method takes a [buffer] and the current
  /// [position] in that buffer. It returns a new (positive) position in case
  /// of a successful parse, or `-1` in case of a failure.
  ///
  /// Subclasses don't necessarily have to override this method, since it is
  /// emulated using its slower brother.
  int fastParseOn(String buffer, int position) {
    final result = parseOn(Context(buffer, position));
    return result.isSuccess ? result.position : -1;
  }

  /// Returns the parse result of the [input].
  ///
  /// The implementation creates a default parse context on the input and calls
  /// the internal parsing logic of the receiving parser.
  ///
  /// For example, `letter().plus().parse('abc')` results in an instance of
  /// [Success], where [Context.position] is `3` and [Success.value] is
  /// `[a, b, c]`.
  ///
  /// Similarly, `letter().plus().parse('123')` results in an instance of
  /// [Failure], where [Context.position] is `0` and [Failure.message] is
  /// ['letter expected'].
  Result<T> parse(String input) => parseOn(Context(input, 0));

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
