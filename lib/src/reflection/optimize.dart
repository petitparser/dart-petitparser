part of reflection;

/**
 * Returns a copy of [parser] with all setable parsers removed.
 */
Parser removeSetables(Parser parser) {
  return transformParser(parser, (each) {
    while (each is SetableParser) {
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
      return source != each && source.equals(each);
    }, orElse: () => null);
    if (target == null) {
      uniques.add(source);
      return source;
    } else {
      return target;
    }
  });
}