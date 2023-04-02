import '../core/parser.dart';
import '../parser/combinator/settable.dart';
import '../parser/utils/resolvable.dart';
import 'reference.dart';

/// Resolves all parser references reachable through [parser]. Returns an
/// optimized parser graph that inlines all references directly.
///
/// This code in-lines parsers that purely reference another one (subclasses
/// of [ResolvableParser]). This includes, but is not limited to, parsers
/// created with [ref0], [ref1], [ref2], ..., [undefined], or
/// [SettableParserExtension],
Parser<R> resolve<R>(Parser<R> parser) {
  final mapping = <ResolvableParser, Parser>{};
  parser = _dereference(parser, mapping);
  final todo = <Parser>[parser];
  final seen = <Parser>{parser};
  while (todo.isNotEmpty) {
    final parent = todo.removeLast();
    for (var child in parent.children) {
      if (child is ResolvableParser) {
        final referenced = _dereference(child, mapping);
        parent.replace(child, referenced);
        child = referenced;
      }
      if (seen.add(child)) {
        todo.add(child);
      }
    }
  }
  return parser;
}

/// Internal helper to dereference and resolve a chain of [ResolvableParser]
/// instances to their resolved counterpart. Throws a [StateError] if the there
/// is a directly cyclic dependency on itself.
Parser<R> _dereference<R>(Parser<R> parser, Map<Parser, Parser> mapping) {
  final references = <ResolvableParser<R>>{};
  while (parser is ResolvableParser<R>) {
    if (mapping.containsKey(parser)) {
      return mapping[parser]! as Parser<R>;
    } else if (!references.add(parser)) {
      throw StateError('Recursive references detected: $references');
    }
    parser = parser.resolve();
  }
  for (final reference in references) {
    mapping[reference] = parser;
  }
  return parser;
}
