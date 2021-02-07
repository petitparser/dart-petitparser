import '../../../buffer.dart';
import '../../core/parser.dart';
import 'parser_match.dart';
import 'parser_pattern.dart';

class PatternIterator extends Iterator<ParserMatch> {
  final ParserPattern pattern;
  final Parser parser;
  final String input;
  final Buffer buffer;
  int start;

  PatternIterator(this.pattern, this.parser, this.input, this.start)
      : buffer = Buffer.fromString(input);

  @override
  late ParserMatch current;

  @override
  bool moveNext() {
    while (start <= buffer.length) {
      final end = parser.fastParseOn(buffer, start);
      if (end < 0) {
        start++;
      } else {
        current = ParserMatch(pattern, input, start, end);
        if (start == end) {
          start++;
        } else {
          start = end;
        }
        return true;
      }
    }
    return false;
  }
}
