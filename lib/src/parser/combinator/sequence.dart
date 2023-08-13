import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../utils/sequential.dart';
import 'list.dart';

export 'generated/sequence_2.dart';
export 'generated/sequence_3.dart';
export 'generated/sequence_4.dart';
export 'generated/sequence_5.dart';
export 'generated/sequence_6.dart';
export 'generated/sequence_7.dart';
export 'generated/sequence_8.dart';
export 'generated/sequence_9.dart';

extension SequenceParserExtension on Parser {
  /// Returns a parser that accepts the receiver followed by [other]. The
  /// resulting parser returns a list of the parse result of the receiver
  /// followed by the parse result of [other]. Calling this method on an
  /// existing sequence code does not nest this sequence into a new one, but
  /// instead augments the existing sequence with [other].
  ///
  /// For example, the parser `letter().seq(digit()).seq(letter())` accepts a
  /// letter followed by a digit and another letter. The parse result of the
  /// input string `'a1b'` is the list `<dynamic>['a', '1', 'b']`.
  @useResult
  Parser<List<dynamic>> seq(Parser other) => switch (this) {
        SequenceParser(children: final children) =>
          [...children, other].toSequenceParser(),
        _ => [this, other].toSequenceParser()
      };

  /// Convenience operator returning a parser that accepts the receiver followed
  /// by [other]. See [seq] for details.
  ///
  /// For example, the parser `letter() & digit() & letter()` accepts a
  /// letter followed by a digit and another letter. The parse result of the
  /// input string `'a1b'` is the list `<dynamic>['a', '1', 'b']`.
  @useResult
  Parser<List<dynamic>> operator &(Parser other) => seq(other);
}

extension SequenceIterableExtension<R> on Iterable<Parser<R>> {
  /// Converts the parser in this iterable to a sequence of parsers.
  ///
  /// For example, the parser `[letter(), digit(), letter()].toSequenceParser()`
  /// accepts a letter followed by a digit and another letter. The parse result
  /// of the input string `'a1b'` is the list `<String>['a', '1', 'b']`.
  @useResult
  Parser<List<R>> toSequenceParser() => SequenceParser<R>(this);
}

/// A parser that parses a sequence of parsers.
class SequenceParser<R> extends ListParser<R, List<R>>
    implements SequentialParser {
  SequenceParser(super.children);

  @override
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
