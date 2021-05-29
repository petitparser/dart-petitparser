import '../core/parser.dart';
import 'analyzer.dart';
import 'internal/linter_rules.dart';

enum LinterType {
  info,
  warning,
  error,
}

class LinterIssue {
  final Parser parser;
  final LinterType type;
  final String title;
  final String description;
  final void Function()? fixer;

  LinterIssue(this.parser, this.type, this.title, this.description,
      [this.fixer]);

  @override
  String toString() => '$type: $title\n$description';
}

typedef LinterRule = void Function(
    Analyzer analyzer, Parser parser, LinterCallback callback);

typedef LinterCallback = void Function(LinterIssue issue);

final linterRules = [
  unresolvedSettable,
  unnecessaryResolvable,
  nestedChoice,
  repeatedChoice,
  unreachableChoice,
  nullableRepeater,
  leftRecursion,
];

List<LinterIssue> linter(Parser parser,
    {List<LinterRule>? rules, Set<String> excludedRules = const {}}) {
  final issues = <LinterIssue>[];
  final analyzer = Analyzer(parser);
  for (final parser in analyzer.parsers) {
    for (final rule in rules ?? linterRules) {
      rule(analyzer, parser, (issue) {
        if (!excludedRules.contains(issue.title)) {
          issues.add(issue);
        }
      });
    }
  }
  return issues;
}
