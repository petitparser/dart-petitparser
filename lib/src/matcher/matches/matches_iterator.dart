import '../../core/context.dart';
import '../../core/parser.dart';

class MatchesIterator<R> implements Iterator<R> {
  MatchesIterator(this.parser, this.input, this.start, this.overlapping);

  final Parser<R> parser;
  final String input;
  final bool overlapping;

  int start;

  @override
  late R current;

  @override
  bool moveNext() {
    while (start <= input.length) {
      final end = parser.fastParseOn(input, start);
      if (end < 0) {
        start++;
      } else {
        current = parser.parseOn(Context(input, start)).value;
        if (overlapping || start == end) {
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
