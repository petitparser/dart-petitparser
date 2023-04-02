import '../../context/context.dart';
import '../../core/parser.dart';

class MatchesIterator<R> extends Iterator<R> {
  MatchesIterator(this.parser, this.input, this.start, this.overlapping)
      : context = Context(input, position: start);

  final Parser<R> parser;
  final String input;
  final bool overlapping;
  final Context context;

  int start;

  @override
  R get current => context.value as R;

  @override
  bool moveNext() {
    while (start <= input.length) {
      context.position = start;
      parser.parseOn(context);
      if (context.isSuccess) {
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
