import '../core/parser.dart';
import 'analyzer.dart';
import 'internal/linter_rules.dart';

enum LinterType {
  info,
  warning,
  error,
}

typedef LinterRule = void Function(
    Analyzer analyzer, Parser parser, LinterCallback callback);

typedef LinterCallback = void Function(
    Parser parser, LinterType type, String title, String description,
    [void Function()? fixer]);

final linterRules = [
  unresolvedSettable,
  unnecessaryResolvable,
  nestedChoice,
  unreachableChoice,
];

void linter(Parser parser, LinterCallback callback, {List<LinterRule>? rules}) {
  final analyzer = Analyzer(parser);
  for (final parser in analyzer.parsers) {
    for (final rule in rules ?? linterRules) {
      rule(analyzer, parser, callback);
    }
  }
}
