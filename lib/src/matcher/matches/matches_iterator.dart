import '../../context/context.dart';
import '../../core/parser.dart';

class MatchesIterator<T> extends Iterator<T> {
  MatchesIterator(this.parser, this.input, this.start, this.overlapping)
      : context = Context(input, position: start);

  final Parser<T> parser;
  final String input;
  final bool overlapping;
  final Context context;

  int start;

  @override
  late T current;

  @override
  bool moveNext() {
    while (start <= input.length) {
      context.position = start;
      parser.parseOn(context);
      if (context.isSuccess) {
        current = context.value;
        if (overlapping || start == context.position) {
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
