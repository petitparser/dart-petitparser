library petitparser.debug.progress;

import '../core/parser.dart';
import '../reflection/transform.dart';
import 'continuation.dart';
import 'output.dart';

/// Returns a transformed [parser] that when being used to read input
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
Parser progress(Parser parser, [OutputHandler output = print]) {
  return transformParser(parser, (each) {
    return ContinuationParser(each, (continuation, context) {
      output('${'*' * (1 + context.position)} $each');
      return continuation(context);
    });
  });
}
