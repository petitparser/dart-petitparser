import '../core/parser.dart';
import 'analyzer.dart';
import 'internal/linter_rules.dart';

/// The type of a linter issue.
enum LinterType {
  info,
  warning,
  error,
}

/// Encapsulates a single linter issue.
class LinterIssue {
  /// Parser object with the issue.
  final Parser parser;

  /// Type of the issue found (info, warning, error).
  final LinterType type;

  /// Title of the issue.
  final String title;

  /// Issue specific description with more details about the problem.
  final String description;

  /// Optional function to fix the issue in-place.
  final void Function()? fixer;

  LinterIssue(this.parser, this.type, this.title, this.description,
      [this.fixer]);

  @override
  String toString() => '$type: $title\n$description';
}

/// Function signature of a linter callback that is called whenever a linter
/// rule identifies an issue.
typedef LinterCallback = void Function(LinterIssue issue);

/// Function signature of a linter rule.
typedef LinterRule = void Function(
    Analyzer analyzer, Parser parser, LinterCallback callback);

/// Default linter rules to be run.
final defaultLinterRules = [
  unresolvedSettable,
  unnecessaryResolvable,
  nestedChoice,
  repeatedChoice,
  unreachableChoice,
  nullableRepeater,
  leftRecursion,
];

/// Returns a list of linter issues found when analyzing the parser graph
/// reachable from [parser].
///
/// The optional [callback] is triggered during the search for each issue
/// discovered. A custom list of [rules] can be provided, otherwise the
/// [defaultLinterRules] are used. Last but not least, a set of [excludedRules]
/// can be specified by title.
List<LinterIssue> linter(Parser parser,
    {LinterCallback? callback,
    List<LinterRule>? rules,
    Set<String> excludedRules = const {}}) {
  final issues = <LinterIssue>[];
  final analyzer = Analyzer(parser);
  for (final parser in analyzer.parsers) {
    for (final rule in rules ?? defaultLinterRules) {
      rule(analyzer, parser, (issue) {
        if (!excludedRules.contains(issue.title)) {
          if (callback != null) {
            callback(issue);
          }
          issues.add(issue);
        }
      });
    }
  }
  return issues;
}
