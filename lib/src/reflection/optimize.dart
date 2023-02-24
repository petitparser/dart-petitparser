import 'package:meta/meta.dart';

import '../core/parser.dart';
import 'transform.dart';

/// Returns a copy of [parser] with all duplicates parsers collapsed.
@useResult
Parser<T> removeDuplicates<T>(Parser<T> parser) {
  final uniques = <Parser>{};
  return transformParser(parser, <R>(source) {
    return uniques.firstWhere((each) {
      return source != each && source.isEqualTo(each);
    }, orElse: () {
      uniques.add(source);
      return source;
    }) as Parser<R>;
  });
}
