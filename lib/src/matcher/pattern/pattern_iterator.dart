import '../../context/context.dart';
import '../../core/parser.dart';
import 'parser_match.dart';
import 'parser_pattern.dart';

class PatternIterator extends Iterator<ParserMatch> {
  PatternIterator(this.pattern, this.parser, this.input, this.start)
      : context = Context(input, position: start, isSkip: true);

  final ParserPattern pattern;
  final Parser parser;
  final String input;
  final Context context;
  int start;

  @override
  late ParserMatch current;

  @override
  bool moveNext() {
    while (start <= input.length) {
      context.position = start;
      parser.parseOn(context);
      if (context.isSuccess) {
        current = ParserMatch(pattern, input, start, context.position);
        if (start == context.position) {
          start++;
        } else {
          start = context.position;
        }
        return true;
      } else {
        start++;
      }
    }
    return false;
  }
}
