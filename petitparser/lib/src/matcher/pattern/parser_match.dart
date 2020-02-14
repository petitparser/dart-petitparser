library petitparser.matcher.parser_match;

import 'package:meta/meta.dart';

@immutable
class ParserMatch implements Match {
  @override
  final Pattern pattern;

  @override
  final String input;

  @override
  final int start;

  @override
  final int end;

  const ParserMatch(this.pattern, this.input, this.start, this.end);

  @override
  String group(int group) => this[group];

  @override
  String operator [](int group) =>
      group == 0 ? input.substring(start, end) : null;

  @override
  List<String> groups(List<int> groupIndices) =>
      groupIndices.map(group).toList(growable: false);

  @override
  int get groupCount => 1;
}
