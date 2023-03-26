import 'package:meta/meta.dart';

import '../context/context_ext.dart';
import '../context/result.dart';
import '../core/parser.dart';
import '../parser/action/continuation.dart';
import '../reflection/transform.dart';
import '../shared/types.dart';

/// Returns a transformed [Parser] that when being used to read input
/// visually prints its progress while progressing.
///
/// For example, the snippet
///
///     final parser = letter() & word().star();
///     progress(parser).parse('f123');
///
/// prints the following output:
///
///     * Instance of 'SequenceParser'
///     * Instance of 'CharacterParser'[letter expected]
///     ** Instance of 'PossessiveRepeatingParser'[0..*]
///     ** Instance of 'CharacterParser'[letter or digit expected]
///     *** Instance of 'CharacterParser'[letter or digit expected]
///     **** Instance of 'CharacterParser'[letter or digit expected]
///     ***** Instance of 'CharacterParser'[letter or digit expected]
///
/// Jumps backwards mean that the parser is back-tracking. Often choices can
/// be reordered to avoid such expensive parses.
///
/// The optional [output] callback can be used to continuously receive
/// [ProgressFrame] updates with the current progress information.
@useResult
Parser<T> progress<T>(Parser<T> root,
    {VoidCallback<ProgressFrame> output = print,
    Predicate<Parser>? predicate}) {
  return transformParser(root, <T>(parser) {
    if (predicate == null || predicate(parser)) {
      return parser.callCC((continuation, context) {
        output(_ProgressFrame(parser, context.toResult()));
        continuation(context);
      });
    } else {
      return parser;
    }
  });
}

/// Encapsulates the data around a parser progress.
abstract class ProgressFrame {
  /// Return the parser of this frame.
  Parser get parser;

  /// Returns the activation context of this frame.
  Result get result;

  /// Returns the current position in the input.
  int get position => result.position;
}

class _ProgressFrame extends ProgressFrame {
  _ProgressFrame(this.parser, this.result);

  @override
  final Parser parser;

  @override
  final Result result;

  @override
  String toString() => '${'*' * (1 + position)} $parser';
}
