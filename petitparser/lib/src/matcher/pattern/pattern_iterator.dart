library petitparser.matcher.pattern_iterator;

import '../../core/parser.dart';
import 'parser_match.dart';

class PatternIterator extends Iterator<Match> {
  final Pattern pattern;
  final Parser parser;
  final String input;
  int start;

  PatternIterator(this.pattern, this.parser, this.input, this.start);

  @override
  Match current;

  @override
  bool moveNext() {
    while (start <= input.length) {
      final end = parser.fastParseOn(input, start);
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
    current = null;
    return false;
  }
}
