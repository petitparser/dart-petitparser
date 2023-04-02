import '../../core/parser.dart';
import '../../parser/action/cast.dart';
import '../../parser/action/cast_list.dart';
import '../../parser/action/flatten.dart';
import '../../parser/action/map.dart';
import '../../parser/action/permute.dart';
import '../../parser/action/pick.dart';
import '../../parser/action/token.dart';
import '../../parser/action/where.dart';
import '../../parser/combinator/choice.dart';
import '../../parser/combinator/optional.dart';
import '../../parser/combinator/settable.dart';
import '../../parser/misc/cut.dart';
import '../../parser/misc/failure.dart';
import '../../parser/predicate/any.dart';
import '../../parser/predicate/single_char.dart';
import '../../parser/repeater/lazy.dart';
import '../../parser/repeater/possessive.dart';
import '../../parser/repeater/repeating.dart';
import '../../parser/repeater/separated.dart';
import '../../parser/utils/resolvable.dart';
import '../../parser/utils/sequential.dart';
import '../analyzer.dart';
import '../linter.dart';
import 'utilities.dart';

class CharacterRepeater extends LinterRule {
  const CharacterRepeater() : super(LinterType.warning, 'Character repeater');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser is FlattenParser) {
      final repeating = parser.delegate;
      if (repeating is PossessiveRepeatingParser) {
        final character = repeating.delegate;
        if (character is SingleCharacterParser || character is AnyParser) {
          callback(LinterIssue(
              this,
              parser,
              'A flattened repeater ($repeating) that delegates to a character '
              'parser ($character) can be much more efficiently implemented '
              'using `starString`, `plusString`, `timesString`, or '
              '`repeatString` that directly returns the underlying String '
              'instead of an intermediate List.'));
        }
      }
    }
  }
}

class LeftRecursion extends LinterRule {
  const LeftRecursion() : super(LinterType.error, 'Left recursion');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (analyzer.cycleSet(parser).isNotEmpty) {
      callback(LinterIssue(
          this,
          parser,
          'The parsers directly or indirectly refers to itself without '
          'consuming input: ${analyzer.cycleSet(parser)}. This causes an '
          'infinite loop when parsing.'));
    }
  }
}

class NestedChoice extends LinterRule {
  const NestedChoice() : super(LinterType.info, 'Nested choice');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser is ChoiceParser) {
      final children = parser.children;
      for (var i = 0; i < children.length - 1; i++) {
        final child = children[i];
        if (child is ChoiceParser && parser.strategy == child.strategy) {
          callback(LinterIssue(
              this,
              parser,
              'The choice at index $i is another choice ($child) that adds '
              'unnecessary overhead that can be avoided by flattening it into '
              'the parent.'));
        }
      }
    }
  }
}

class NullableRepeater extends LinterRule {
  const NullableRepeater() : super(LinterType.error, 'Nullable repeater');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser is RepeatingParser) {
      final isNullable = parser is SequentialParser
          ? parser.children.every((each) => analyzer.isNullable(each))
          : analyzer.isNullable(parser.delegate);
      if (isNullable) {
        callback(LinterIssue(
            this,
            parser,
            'A repeater that delegates to a nullable parser causes an infinite '
            'loop when parsing.'));
      }
    }
  }
}

class OverlappingChoice extends LinterRule {
  const OverlappingChoice() : super(LinterType.info, 'Overlapping choice');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser is ChoiceParser) {
      final children = parser.children;
      for (var i = 0; i < children.length; i++) {
        final firstI = analyzer.firstSet(children[i]);
        for (var j = i + 1; j < children.length; j++) {
          final firstJ = analyzer.firstSet(children[j]);
          if (isParserIterableEqual(firstI, firstJ)) {
            callback(LinterIssue(
                this,
                parser,
                'The choices at index $i and $j have overlapping first-sets '
                '(${firstI.join(', ')}), which can be an indication of '
                'an inefficient grammar. If possible, try extracting '
                'common prefixes from choices.'));
          }
        }
      }
    }
  }
}

class RepeatedChoice extends LinterRule {
  const RepeatedChoice() : super(LinterType.warning, 'Repeated choice');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser is ChoiceParser) {
      final children = parser.children;
      for (var i = 0; i < children.length; i++) {
        for (var j = i + 1; j < children.length; j++) {
          if (children[i].isEqualTo(children[j])) {
            callback(LinterIssue(
                this,
                parser,
                'The choices at index $i and $j are identical '
                '(${children[i]}). The second choice can never succeed and '
                'can therefore be removed.'));
          }
        }
      }
    }
  }
}

class UnnecessaryResolvable extends LinterRule {
  const UnnecessaryResolvable()
      : super(LinterType.warning, 'Unnecessary resolvable');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser is ResolvableParser) {
      callback(LinterIssue(
          this,
          parser,
          'Resolvable parsers are used during construction of recursive '
          'grammars. While they typically dispatch to their delegate, '
          'they add unnecessary overhead and can be avoided by removing '
          'them before parsing using `resolve(parser)`.'));
    }
  }
}

class UnreachableChoice extends LinterRule {
  const UnreachableChoice() : super(LinterType.warning, 'Unreachable choice');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser is ChoiceParser) {
      final children = parser.children;
      for (var i = 0; i < children.length - 1; i++) {
        if (analyzer.isNullable(children[i])) {
          callback(LinterIssue(
              this,
              parser,
              'The choice at index $i is nullable (${children[i]}), thus the '
              'choices after that (${children.sublist(i + 1).join(', ')}) '
              'can never be reached and can be removed.'));
        }
      }
    }
  }
}

class UnresolvedSettable extends LinterRule {
  const UnresolvedSettable() : super(LinterType.error, 'Unresolved settable');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser is SettableParser && parser.delegate is FailureParser) {
      callback(LinterIssue(
          this,
          parser,
          'This error is typically a bug in the code where a recursive '
          'grammar was created with `undefined()` that has not been '
          'resolved.'));
    }
  }
}

class UnusedCut extends LinterRule {
  const UnusedCut() : super(LinterType.info, 'Unused cut');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser is CutParser) {
      final paths = analyzer.findAllPathsTo(analyzer.root, parser).toList();
      final noBacktrackPaths =
          paths.where((path) => !path.parsers.any(isBacktracking)).toList();
      if (noBacktrackPaths.isNotEmpty) {
        final backtrackPath =
            paths.where((path) => path.parsers.any(isBacktracking)).toList();
        callback(LinterIssue(
            this,
            parser,
            [
              'The cut parsers prevents backtracking from happening.',
              if (backtrackPath.isEmpty)
                'Yet, this parser is only called through paths that do not '
                    'backtrack: ${noBacktrackPaths.first.description}.'
              else
                'While this parser is called through at least one path that '
                    'backtracks: ${backtrackPath.first.description}; it is '
                    'also called through at least one path that does not: '
                    '${noBacktrackPaths.first.description}.',
              'This might point to an inefficient grammar or a possible bug.'
            ].join(' ')));
      }
    }
  }

  bool isBacktracking(Parser parser) =>
      parser is ChoiceParser ||
      parser is OptionalParser ||
      parser is PossessiveRepeatingParser ||
      parser is LazyRepeatingParser ||
      parser is SeparatedRepeatingParser;
}

class UnusedResult extends LinterRule {
  const UnusedResult() : super(LinterType.info, 'Unused result');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser is FlattenParser) {
      final deepChildren = analyzer.allChildren(parser);
      final ignoredResults = deepChildren.where(isResultProducing).toSet();
      if (ignoredResults.isNotEmpty) {
        final path = analyzer.findPath(
            parser, (path) => ignoredResults.contains(path.target))!;
        callback(LinterIssue(
            this,
            parser,
            'The flatten parser discards the result of its children and '
            'instead returns the consumed input. Yet this flatten parser '
            'refers (indirectly) to one or more other parsers that explicitly '
            'produce a result which is then ignored when called from this '
            'context: ${path.description}. This might point to an inefficient '
            'grammar or a possible bug.'));
      }
    }
  }

  bool isResultProducing(Parser parser) =>
      parser is CastParser ||
      parser is CastListParser ||
      parser is FlattenParser ||
      parser is MapParser ||
      parser is PermuteParser ||
      parser is PickParser ||
      parser is TokenParser ||
      parser is WhereParser;
}
