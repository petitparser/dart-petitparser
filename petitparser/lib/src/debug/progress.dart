import '../core/parser.dart';
import '../parser/action/continuation.dart';
import '../parser/utils/types.dart';
import '../reflection/transform.dart';

/// Returns a transformed [Parser] that when being used to read input
/// visually prints its progress while progressing.
///
/// For example, the snippet
///
///     final parser = letter() & word().star();
///     progress(parser).parse('f123');
///
/// produces the following output:
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
/// be reordered to such expensive parses.
Parser<T> progress<T>(Parser<T> root, {Callback<String, void> output = print}) {
  return transformParser(root, <T>(parser) {
    return parser.callCC((continuation, context) {
      output('${'*' * (1 + context.position)} $parser');
      return continuation(context);
    });
  });
}
