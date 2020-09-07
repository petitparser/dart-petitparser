import '../core/parser.dart';
import '../parser/action/continuation.dart';
import '../reflection/transform.dart';
import 'output.dart';

/// Returns a transformed [Parser] that when being used measures
/// the activation count and total time of each parser.
///
/// For example, the snippet
///
///     final parser = letter() & word().star();
///     profile(parser).parse('f1234567890');
///
/// produces the following output:
///
///      1  2006  Instance of 'SequenceParser'
///      1   697  Instance of 'PossessiveRepeatingParser'[0..*]
///     11   406  Instance of 'CharacterParser'[letter or digit expected]
///      1   947  Instance of 'CharacterParser'[letter expected]
///
/// The first number refers to the number of activations of each parser, and
/// the second number is the microseconds spent in this parser and all its
/// children.
Parser profile(Parser root, [OutputHandler output = print]) {
  final frames = <FrameProfile>[];
  return transformParser(root, (parser) {
    final frame = FrameProfile(parser);
    frames.add(frame);
    return parser.callCC((continuation, context) {
      frame.count++;
      frame.watch.start();
      final result = continuation(context);
      frame.watch.stop();
      return result;
    });
  }).callCC((continuation, context) {
    final result = continuation(context);
    for (final frame in frames) {
      output('${frame.count}\t'
          '${frame.watch.elapsedMicroseconds}\t'
          '${frame.parser}');
    }
    return result;
  });
}

class FrameProfile {
  int count = 0;
  final watch = Stopwatch();
  final Parser parser;

  FrameProfile(this.parser);
}
