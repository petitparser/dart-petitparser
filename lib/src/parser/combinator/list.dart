import '../../core/parser.dart';

/// Abstract parser that parses a list of things in some way.
abstract class ListParser<R, S> extends Parser<S> {
  ListParser(Iterable<Parser<R>> children)
      : children = List<Parser<R>>.of(children, growable: false);

  /// The children parsers being delegated to.
  @override
  final List<Parser<R>> children;

  @override
  void replace(Parser source, Parser target) {
    super.replace(source, target);
    for (var i = 0; i < children.length; i++) {
      if (children[i] == source) {
        children[i] = target as Parser<R>;
      }
    }
  }
}
