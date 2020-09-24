import '../core/parser.dart';
import '../parser/action/continuation.dart';
import '../reflection/transform.dart';
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
Parser progress(Parser parser, [Consumer<ProgressFrame> output = print]) {
  return transformParser(parser, (each) {
    return each.callCC((continuation, context) {
      output(ProgressFrame(context.position, each));
      return continuation(context);
    });
  });
}

class ProgressFrame {
  final int position;
  final Parser parser;

  ProgressFrame(this.position, this.parser);

  @override
  String toString() => '${'*' * (1 + position)} $parser';
}
