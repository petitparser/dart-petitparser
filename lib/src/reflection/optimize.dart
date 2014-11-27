part of reflection;

/**
 * Returns a copy of [parser] with all settable parsers removed.
 */
Parser removeSettables(Parser parser) {
  return transformParser(parser, (each) {
    while (each is SettableParser) {
      each = each.children.first;
    }
    return each;
  });
}

/**
 * Returns a copy of [parser] with all duplicates parsers collapsed.
 */
Parser removeDuplicates(Parser parser) {
  var uniques = new Set();
  return transformParser(parser, (source) {
    var target = uniques.firstWhere((each) {
      return source != each && source.isEqualTo(each);
    }, orElse: () => null);
    if (target == null) {
      uniques.add(source);
      return source;
    } else {
      return target;
    }
  });
}
