import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../../shared/pragma.dart';
import '../utils/failure_joiner.dart';
import 'list.dart';

extension ChoiceParserExtension on Parser {
  /// Returns a parser that accepts the receiver or [other] (ordered choice).
  ///
  /// Evaluates the receiver first; if it succeeds, its result is returned.
  /// If it fails, parsing falls back to [other]. If called on an existing
  /// [ChoiceParser], this flattens [other] into the existing choice rather
  /// than nesting choices.
  ///
  /// The optional [failureJoiner] determines which [Failure] to report when
  /// all alternatives fail. Defaults to [selectLast], though [selectFarthest]
  /// can sometimes provide more helpful error messages.
  ///
  /// Order is significant. Because alternatives are tested sequentially, earlier
  /// branches take precedence over later, overlapping ones:
  ///
  /// ```dart
  /// // Evaluates to Object (String or int):
  /// final parser = letter() | digit().map(int.parse);
  ///
  /// // In this example, char('a') is unreachable because letter() matches first:
  /// final shadowed = letter() | char('a');
  /// ```
  ///
  /// The returned parser has result type `dynamic` due to Dart's lack of union
  /// types (https://github.com/dart-lang/language/issues/1557). For better type
  /// safety, prefer [ChoiceIterableExtension.toChoiceParser].
  @useResult
  ChoiceParser<dynamic> or(Parser other, {FailureJoiner? failureJoiner}) =>
      switch (this) {
        ChoiceParser(
          children: final children,
          failureJoiner: final thisFailureJoiner,
        ) =>
          [
            ...children,
            other,
          ].toChoiceParser(failureJoiner: failureJoiner ?? thisFailureJoiner),
        _ => [this, other].toChoiceParser(failureJoiner: failureJoiner),
      };

  /// Syntactic sugar for [or].
  ///
  /// Returns an ordered choice parser trying the receiver first, followed
  /// by [other].
  ///
  /// ```dart
  /// final parser = letter() | digit().map(int.parse);
  /// parser.parse('a'); // Success: 'a'
  /// parser.parse('1'); // Success: 1
  /// ```
  ///
  /// The result type is `dynamic`. For better type safety, prefer
  /// [ChoiceIterableExtension.toChoiceParser].
  @useResult
  ChoiceParser<dynamic> operator |(Parser other) => or(other);
}

extension ChoiceIterableExtension<R> on Iterable<Parser<R>> {
  /// Combines this iterable of parsers into a single [ChoiceParser].
  ///
  /// Tries each parser in sequence, returning the result of the first successful
  /// match. If all parsers fail, a joined [Failure] is produced according to
  /// [failureJoiner] (defaults to [selectLast]).
  ///
  /// Because all elements in the collection must share a single type parameter
  /// [R], combining parsers of different types causes Dart to infer their
  /// closest common supertype (typically `Object` or `Object?`):
  ///
  /// ```dart
  /// // Inferred as ChoiceParser<Object>:
  /// final choice = [
  ///   letter(),                  // Parser<String>
  ///   digit().map(int.parse),     // Parser<int>
  /// ].toChoiceParser();
  /// ```
  ///
  /// For homogeneous collections, the concrete type is preserved directly:
  ///
  /// ```dart
  /// // Inferred as ChoiceParser<String>:
  /// final keywords = [string('if'), string('else')].toChoiceParser();
  /// ```
  ChoiceParser<R> toChoiceParser({FailureJoiner? failureJoiner}) =>
      ChoiceParser<R>(this, failureJoiner: failureJoiner);
}

/// A parser that uses the first parser that succeeds.
class ChoiceParser<R> extends ListParser<R, R> {
  new(super.children, {FailureJoiner? failureJoiner})
    : assert(children.isNotEmpty, 'Choice parser cannot be empty'),
      failureJoiner = failureJoiner ?? selectLast;

  /// Strategy to join multiple parse errors.
  final FailureJoiner failureJoiner;

  @override
  @noBoundsChecks
  Result<R> parseOn(Context context) {
    // Check the first choice:
    final result = children[0].parseOn(context);
    if (result is! Failure) return result;
    var failure = result;
    // Check all other choices:
    for (var i = 1; i < children.length; i++) {
      final result = children[i].parseOn(context);
      if (result is! Failure) return result;
      failure = failureJoiner(failure, result);
    }
    return failure;
  }

  @override
  @noBoundsChecks
  int fastParseOn(String buffer, int position) {
    var result = -1;
    for (var i = 0; i < children.length; i++) {
      result = children[i].fastParseOn(buffer, position);
      if (result >= 0) return result;
    }
    return result;
  }

  @override
  bool hasEqualProperties(ChoiceParser<R> other) =>
      super.hasEqualProperties(other) && failureJoiner == other.failureJoiner;

  @override
  ChoiceParser<R> copy() =>
      ChoiceParser<R>(children, failureJoiner: failureJoiner);
}
