import 'package:meta/meta.dart';

import '../shared/pragma.dart';
import 'context.dart';
import 'result.dart';

/// Abstract base class of all parsers that produce a parse result of type [R].
@optionalTypeArgs
abstract class Parser<R> {
  /// Creates a [Parser].
  new();

  /// Parses the given [context].
  ///
  /// Overridden in concrete subclasses to implement the parser-specific logic.
  /// Takes a parse [context] and returns the resulting context, which is either
  /// a [Success] or [Failure] context.
  Result<R> parseOn(Context context);

  /// Parses [buffer] starting at [position] without allocating a [Result].
  ///
  /// An optimized version of [parseOn] that gains its speed advantage by
  /// avoiding unnecessary memory allocations.
  ///
  /// Overridden in most concrete subclasses to implement the optimized logic.
  /// Takes a [buffer] and the current [position] in that buffer. Returns a new
  /// (positive) position in case of a successful parse, or `-1` in case of a
  /// failure.
  ///
  /// Subclasses do not necessarily have to override this method, since it is
  /// emulated using [parseOn].
  int fastParseOn(String buffer, int position) {
    final result = parseOn(Context(buffer, position));
    return result is Failure ? -1 : result.position;
  }

  /// Parses the [input] and returns the parse result.
  ///
  /// Creates a default parse context on the [input] starting at [start] and
  /// calls the internal parsing logic of this parser.
  ///
  /// For example, `letter().plus().parse('abc')` results in an instance of
  /// [Success], where [Context.position] is `3` and [Success.value] is
  /// `[a, b, c]`.
  ///
  /// Similarly, `letter().plus().parse('123')` results in an instance of
  /// [Failure], where [Context.position] is `0` and [Failure.message] is
  /// `'letter expected'`.
  @nonVirtual
  Result<R> parse(String input, {int start = 0}) =>
      parseOn(Context(input, start));

  /// Creates a shallow copy of this parser.
  ///
  /// Overridden in subclasses to return an instance of the specific parser type.
  Parser<R> copy();

  /// Tests if this parser is structurally equal to [other].
  ///
  /// Automatically deals with recursive parsers and parsers that refer to other
  /// parsers. Do not override this method; instead customize
  /// [hasEqualProperties] and [children].
  @nonVirtual
  bool isEqualTo(Parser other, [Set<Parser>? seen]) {
    if (this == other) {
      return true;
    }
    if (runtimeType != other.runtimeType || !hasEqualProperties(other)) {
      return false;
    }
    seen ??= {};
    return !seen.add(this) || hasEqualChildren(other, seen);
  }

  /// Compares the properties of this parser with [other].
  ///
  /// Overridden in subclasses that add new state.
  @protected
  @mustCallSuper
  bool hasEqualProperties(covariant Parser other) => true;

  /// Compares the children of this parser with [other].
  ///
  /// Normally does not need to be overridden, as it works generically on
  /// [children].
  @protected
  @nonVirtual
  bool hasEqualChildren(covariant Parser other, Set<Parser> seen) {
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

  /// The list of directly referenced parsers.
  ///
  /// For example, `letter().children` returns the empty collection `[]`,
  /// because the letter parser is a primitive or leaf parser that does not
  /// depend or call any other parser.
  ///
  /// In contrast, `letter().or(digit()).children` returns a collection
  /// containing both the `letter()` and `digit()` parser.
  ///
  /// Override this getter and [replace] in all subclasses that reference other
  /// parsers.
  List<Parser> get children => const [];

  /// Replaces [source] with [target] in this parser.
  ///
  /// Does nothing if [source] does not exist in [children].
  ///
  /// The following example creates a letter parser and then defines a parser
  /// called `example` that accepts one or more letters. Eventually the parser
  /// `example` is modified by replacing the `letter` parser with a new
  /// parser that accepts a digit. The resulting `example` parser accepts one
  /// or more digits:
  ///
  /// ```dart
  /// final letter = letter();
  /// final example = letter.plus();
  /// example.replace(letter, digit());
  /// ```
  ///
  /// Override this method and [children] in all subclasses that reference other
  /// parsers.
  @mustCallSuper
  void replace(Parser source, Parser target) {}

  /// Captures the generic parse result type [R].
  ///
  /// Passes this parser to [callback] with its generic result type [R] captured
  /// as type parameter `S`. This makes it possible to wrap the parser without
  /// losing type information.
  @internal
  @nonVirtual
  @preferInline
  T captureResultGeneric<T>(T Function<S>(Parser<S> self) callback) =>
      callback<R>(this);

  @override
  String toString() => '$runtimeType';
}
