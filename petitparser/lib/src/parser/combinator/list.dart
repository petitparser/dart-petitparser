library petitparser.parser.combinator.list;

import '../../core/parser.dart';

/// Abstract parser that parses a list of things in some way.
abstract class ListParser<T> extends Parser<T> {
  ListParser(Iterable<Parser> children)
      : children = List.of(children, growable: false);

  @override
  final List<Parser> children;

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    for (var i = 0; i < children.length; i++) {
      if (children[i] == source) {
        children[i] = target;
      }
    }
  }
}
