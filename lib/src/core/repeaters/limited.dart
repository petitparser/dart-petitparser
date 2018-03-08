library petitparser.core.repeaters.limited;

import 'package:petitparser/src/core/parser.dart';
import 'package:petitparser/src/core/repeaters/repeating.dart';

/// An abstract parser that repeatedly parses between 'min' and 'max' instances of
/// its delegate and that requires the input to be completed with a specified parser
/// 'limit'. Subclasses provide repeating behavior as typically seen in regular
/// expression implementations (non-blind).
abstract class LimitedRepeatingParser extends RepeatingParser {
  Parser limit;

  LimitedRepeatingParser(Parser delegate, this.limit, int min, int max)
      : super(delegate, min, max);

  @override
  List<Parser> get children => [delegate, limit];

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    if (limit == source) {
      limit = target;
    }
  }
}
