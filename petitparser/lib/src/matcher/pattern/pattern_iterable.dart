library petitparser.matcher.pattern_iterable;

import 'dart:collection';

import 'package:meta/meta.dart';

import '../../core/parser.dart';
import 'pattern_iterator.dart';

@immutable
class PatternIterable extends IterableBase<Match> {
  final Pattern pattern;
  final Parser parser;
  final String input;
  final int start;

  const PatternIterable(this.pattern, this.parser, this.input, this.start);

  @override
  Iterator<Match> get iterator =>
      PatternIterator(pattern, parser, input, start);
}
