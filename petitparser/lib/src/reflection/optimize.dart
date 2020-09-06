import '../core/parser.dart';
import '../parser/combinator/settable.dart';
import 'transform.dart';

/// Returns a copy of [parser] with all settable parsers removed.
Parser removeSettables(Parser parser) {
  return transformParser(parser, (each) {
    while (each is SettableParser) {
      each = each.children.first;
    }
    return each;
  });
}

/// Returns a copy of [parser] with all duplicates parsers collapsed.
Parser removeDuplicates(Parser parser) {
  final uniques = <Parser>{};
  return transformParser(parser, (source) {
    return uniques.firstWhere((each) {
      return source != each && source.isEqualTo(each);
    }, orElse: () {
      uniques.add(source);
      return source;
    });
  });
}
