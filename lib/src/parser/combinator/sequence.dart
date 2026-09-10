import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../../shared/pragma.dart';
import '../utils/sequential.dart';
import 'generated/sequence_2.dart';
import 'generated/sequence_3.dart';
import 'list.dart';

export 'generated/sequence_2.dart';
export 'generated/sequence_3.dart';
export 'generated/sequence_4.dart';
export 'generated/sequence_5.dart';
export 'generated/sequence_6.dart';
export 'generated/sequence_7.dart';
export 'generated/sequence_8.dart';
export 'generated/sequence_9.dart';

extension SequenceParserExtension<R1> on Parser<R1> {
  /// Returns a parser that accepts the receiver followed by [other].
  ///
  /// The resulting parser produces a flattened [List] containing the result
  /// of the receiver followed by the result of [other]. If called on an
  /// existing [SequenceParser], this flattens [other] into the sequence
  /// rather than nesting a new sequence within it.
  ///
  /// For example, the parser `letter().seq(digit().map(int.parse)).seq(letter())`
  /// accepts a letter followed by a digit and another letter. For the input
  /// `'a1b'`, it evaluates to `<dynamic>['a', 1, 'b']`.
  ///
  /// The resulting list element type is `dynamic`. For compile-time type safety,
  /// prefer using [then], [seq2], or [seq3].
  @useResult
  Parser<List<dynamic>> seq(Parser other) => switch (this) {
    SequenceParser(children: final children) => [
      ...children,
      other,
    ].toSequenceParser(),
    _ => [this, other].toSequenceParser(),
  };

  /// Syntactic sugar for [seq].
  ///
  /// Combines the receiver and [other] into a sequential parser producing
  /// a `List<dynamic>`.
  ///
  /// ```dart
  /// final parser = letter() & digit().map(int.parse) & letter();
  /// parser.parse('a1b'); // Success: ['a', 1, 'b']
  /// ```
  ///
  /// For type-safe alternatives, prefer [then], [seq2], or [seq3].
  @useResult
  Parser<List<dynamic>> operator &(Parser other) => seq(other);

  /// Returns a parser that sequences the receiver and [other], returning their
  /// results as a typed 2-element [Record].
  ///
  /// Unlike [seq], which returns an untyped `List<dynamic>`, [then] preserves
  /// the static types of all matched parsers. Chained invocations of [then]
  /// flatten automatically into larger typed records up to 9 elements.
  ///
  /// For example:
  /// ```dart
  /// // Produces a (String, int) record:
  /// final pair = letter().then(digit().map(int.parse));
  ///
  /// // Flattens into a 3-element record (String, int, String):
  /// final triplet = pair.then(letter());
  /// ```
  @useResult
  SequenceParser2<R1, R2> then<R2>(Parser<R2> other) =>
      SequenceParser2<R1, R2>(this, other);
}

extension SequenceIterableExtension<R> on Iterable<Parser<R>> {
  /// Combines this iterable of parsers into a single [SequenceParser].
  ///
  /// The parsers execute sequentially, collecting their outputs into a `List<R>`.
  /// If any parser in the sequence fails, the entire sequence fails at that point.
  ///
  /// For example:
  /// ```dart
  /// final sequence = [letter(), digit().map(int.parse), letter()].toSequenceParser();
  /// sequence.parse('a1b'); // Success: <Object>['a', 1, 'b']
  /// ```
  ///
  /// Heterogeneous sequences require casting or using a common base type. For
  /// compile-time typed safety, prefer [SequenceParserExtension.then], [seq2],
  /// or [seq3].
  @useResult
  Parser<List<R>> toSequenceParser() => SequenceParser<R>(this);
}

/// A parser that parses a sequence of parsers.
class SequenceParser<R> extends ListParser<R, List<R>>
    implements SequentialParser {
  new(super.children);

  @override
  @noBoundsChecks
  Result<List<R>> parseOn(Context context) {
    var current = context;
    final elements = <R>[];
    for (var i = 0; i < children.length; i++) {
      final result = children[i].parseOn(current);
      if (result is Failure) return result;
      elements.add(result.value);
      current = result;
    }
    return current.success(elements);
  }

  @override
  @noBoundsChecks
  int fastParseOn(String buffer, int position) {
    for (var i = 0; i < children.length; i++) {
      position = children[i].fastParseOn(buffer, position);
      if (position < 0) return position;
    }
    return position;
  }

  @override
  SequenceParser<R> copy() => SequenceParser<R>(children);
}
