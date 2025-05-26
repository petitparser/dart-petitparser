import 'package:meta/meta.dart';

import '../core/parser.dart';
import 'analyzer.dart';
import 'internal/optimize_rules.dart';

/// Function signature of a linter callback that is called whenever a linter
/// rule identifies an issue.
typedef ReplaceParser<R> = void Function(Parser<R> source, Parser<R> target);

/// Encapsulates a single optimization rule.
@immutable
abstract class OptimizeRule {
  /// Constructs a new optimization rule.
  const OptimizeRule();

  /// Executes this rule using a provided [analyzer] on a [parser].
  void run<R>(Analyzer analyzer, Parser<R> parser, ReplaceParser<R> replace);
}

// All default optimizer rules to be run.
const allOptimizerRules = [
  CharacterRepeater(),
  FlattenChoice(),
  RemoveDelegate(),
  RemoveDuplicate(),
];

/// Returns an in-place optimized version of the parser.
@useResult
Parser<R> optimize<R>(
  Parser<R> parser, {
  ReplaceParser<dynamic>? callback,
  List<OptimizeRule>? rules,
}) {
  final analyzer = Analyzer(parser);
  final selectedRules = rules ?? allOptimizerRules;
  final replacements = <Parser, Parser>{};
  for (final parser in analyzer.parsers) {
    parser.captureResultGeneric(<R>(parser) {
      for (final rule in selectedRules) {
        rule.run<R>(analyzer, parser, (a, b) {
          if (callback != null) callback(a, b);
          replacements[a] = b;
        });
      }
    });
  }
  if (replacements.isNotEmpty) {
    for (final parser in analyzer.parsers) {
      for (final replacement in replacements.entries) {
        parser.replace(replacement.key, replacement.value);
      }
    }
    return replacements[parser] as Parser<R>? ?? parser;
  }
  return parser;
}
