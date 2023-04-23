import 'dart:collection';

import 'package:meta/meta.dart';

import '../../core/parser.dart';
import 'matches_iterator.dart';

@immutable
class MatchesIterable<R> extends IterableBase<R> {
  const MatchesIterable(this.parser, this.input, this.start, this.overlapping);

  final Parser<R> parser;
  final String input;
  final int start;
  final bool overlapping;

  @override
  Iterator<R> get iterator =>
      MatchesIterator<R>(parser, input, start, overlapping);
}
