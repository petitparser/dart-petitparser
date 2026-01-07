import '../../core/parser.dart';
import '../../parser/action/cast.dart';
import '../../parser/action/cast_list.dart';
import '../../parser/action/constant.dart';
import '../../parser/action/flatten.dart';
import '../../parser/action/map.dart';
import '../../parser/action/permute.dart';
import '../../parser/action/pick.dart';
import '../../parser/action/token.dart';
import '../../parser/action/where.dart';
import '../../parser/combinator/choice.dart';
import '../../parser/combinator/settable.dart';
import '../../parser/misc/failure.dart';
import '../../parser/misc/newline.dart';
import '../../parser/predicate/character.dart';
import '../../parser/predicate/predicate.dart';
import '../../parser/predicate/single_character.dart';
import '../../parser/repeater/character.dart';
import '../../parser/repeater/possessive.dart';
import '../../parser/repeater/repeating.dart';
import '../../parser/repeater/separated.dart';
import '../../parser/utils/resolvable.dart';
import '../analyzer.dart';
import '../linter.dart';
import 'formatting.dart';
import 'utilities.dart';

class CharacterRepeater extends LinterRule {
  const CharacterRepeater() : super(LinterType.warning, 'Character repeater');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser case FlattenParser(delegate: final repeating)) {
      if (repeating case PossessiveRepeatingParser(delegate: final character)) {
        if (character case SingleCharacterParser()) {
          callback(
            LinterIssue(
              this,
              parser,
              'A flattened repeater ($repeating) that delegates to a character '
              'parser ($character) can be much more efficiently implemented '
              'using `starString`, `plusString`, `timesString`, or '
              '`repeatString` that directly returns the underlying String '
              'instead of an intermediate List.',
            ),
          );
        }
      }
    }
  }
}

class DuplicateParser extends LinterRule {
  const DuplicateParser() : super(LinterType.info, 'Duplicate parser');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    final duplicates = analyzer.parsers.where(parser.isEqualTo).toList();
    if (duplicates.length > 1 && duplicates.first == parser) {
      callback(
        LinterIssue(
          this,
          parser,
          '${duplicates.length} instances of the same parser exist in this '
          'grammar. If possible, reuse the same parser instances to reduce '
          'memory footprint and increase performance.',
        ),
      );
    }
  }
}

class LeftRecursion extends LinterRule {
  const LeftRecursion() : super(LinterType.error, 'Left recursion');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (analyzer.cycleSet(parser).isNotEmpty) {
      callback(
        LinterIssue(
          this,
          parser,
          'The parsers directly or indirectly refers to itself without '
          'consuming input:\n'
          '${formatIterable(analyzer.cycleSet(parser), offset: 1)}\n'
          'This causes an infinite loop when parsing.',
        ),
      );
    }
  }
}

class NestedChoice extends LinterRule {
  const NestedChoice() : super(LinterType.info, 'Nested choice');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser case ChoiceParser(children: final children)) {
      for (var i = 0; i < children.length - 1; i++) {
        final child = children[i];
        if (child case ChoiceParser()) {
          callback(
            LinterIssue(
              this,
              parser,
              'The choice at index $i is another choice ($child) that adds '
              'unnecessary overhead that can be avoided by flattening it into '
              'the parent.',
            ),
          );
        }
      }
    }
  }
}

class NullableRepeater extends LinterRule {
  const NullableRepeater() : super(LinterType.error, 'Nullable repeater');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser is RepeatingParser && analyzer.isNullable(parser.delegate)) {
      // Separated repeating parsers are fine, unless separator is nullable.
      if (parser is SeparatedRepeatingParser &&
          !analyzer.isNullable(parser.separator)) {
        return;
      }
      callback(
        LinterIssue(
          this,
          parser,
          'A repeater that delegates to a nullable parser causes an infinite '
          'loop when parsing.',
        ),
      );
    }
  }
}

class OverlappingChoice extends LinterRule {
  const OverlappingChoice() : super(LinterType.info, 'Overlapping choice');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser case ChoiceParser(children: final children)) {
      for (var i = 0; i < children.length; i++) {
        final firstI = analyzer.firstSet(children[i]);
        for (var j = i + 1; j < children.length; j++) {
          final firstJ = analyzer.firstSet(children[j]);
          if (isParserIterableEqual(firstI, firstJ)) {
            callback(
              LinterIssue(
                this,
                parser,
                'The choices at index $i and $j have overlapping first-sets, '
                'which can be an indication of an inefficient grammar:\n'
                '${formatIterable(firstI)}\n'
                'If possible, try extracting common prefixes from choices.',
              ),
            );
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
    if (parser case ChoiceParser(children: final children)) {
      for (var i = 0; i < children.length; i++) {
        for (var j = i + 1; j < children.length; j++) {
          if (children[i].isEqualTo(children[j])) {
            callback(
              LinterIssue(
                this,
                parser,
                'The choices at index $i and $j are identical:\n'
                ' $i: ${children[i]}\n'
                ' $j: ${children[j]}\n'
                'The second choice can never succeed and can therefore be '
                'removed.',
              ),
            );
          }
        }
      }
    }
  }
}

class UnnecessaryFlatten extends LinterRule {
  const UnnecessaryFlatten() : super(LinterType.warning, 'Unnecessary flatten');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser case FlattenParser(message: null, delegate: final delegate)) {
      if (delegate is CharacterParser ||
          delegate is FlattenParser ||
          delegate is NewlineParser ||
          delegate is PredicateParser ||
          delegate is RepeatingCharacterParser) {
        callback(
          LinterIssue(
            this,
            parser,
            'A flatten parser delegating to a parser ($delegate) that is '
            'returning the accepted input string adds unnecessary overhead and '
            'can be removed.',
          ),
        );
      }
    }
  }
}

class UnnecessaryResolvable extends LinterRule {
  const UnnecessaryResolvable()
    : super(LinterType.warning, 'Unnecessary resolvable');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser case ResolvableParser()) {
      callback(
        LinterIssue(
          this,
          parser,
          'Resolvable parsers are used during construction of recursive '
          'grammars. While they typically dispatch to their delegate, '
          'they add unnecessary overhead and can be avoided by removing '
          'them before parsing using `resolve(parser)`.',
        ),
      );
    }
  }
}

class UnoptimizedFlatten extends LinterRule {
  const UnoptimizedFlatten() : super(LinterType.info, 'Unoptimized flatten');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser case FlattenParser(message: null)) {
      callback(
        LinterIssue(
          this,
          parser,
          'A flatten parser without an error message is unable to switch '
          'to the fast parsing mode. This can lead to inefficient parsers '
          'and can usually easily fixed by providing an error message '
          'that should be used in case the delegate fails to parse.',
        ),
      );
    }
  }
}

class UnreachableChoice extends LinterRule {
  const UnreachableChoice() : super(LinterType.warning, 'Unreachable choice');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser case ChoiceParser(children: final children)) {
      for (var i = 0; i < children.length - 1; i++) {
        if (analyzer.isNullable(children[i])) {
          callback(
            LinterIssue(
              this,
              parser,
              'The choice at index $i is nullable:\n'
              ' $i: ${children[i]}\n'
              'thus the choices after that can never be reached and can be '
              'removed:\n'
              '${formatIterable(children.sublist(i + 1), offset: i + 1)}',
            ),
          );
        }
      }
    }
  }
}

class UnresolvedSettable extends LinterRule {
  const UnresolvedSettable() : super(LinterType.error, 'Unresolved settable');

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) {
    if (parser case SettableParser(delegate: FailureParser())) {
      callback(
        LinterIssue(
          this,
          parser,
          'This error is typically a bug in the code where a recursive '
          'grammar was created with `undefined()` that has not been '
          'resolved.',
        ),
      );
    }
  }
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
          parser,
          (path) => ignoredResults.contains(path.target),
        )!;
        callback(
          LinterIssue(
            this,
            parser,
            'The flatten parser discards the result of its children and '
            'instead returns the consumed input. Yet this flatten parser '
            '(indirectly) refers to one or more other parsers that explicitly '
            'produce a result which is then ignored when called from this '
            'context:\n'
            '${formatIterable(path.parsers, offset: 1)}\n'
            'This might point to an inefficient grammar or a possible bug.',
          ),
        );
      }
    }
  }

  bool isResultProducing(Parser parser) =>
      parser is CastParser ||
      parser is CastListParser ||
      parser is ConstantParser ||
      parser is FlattenParser ||
      (parser is MapParser && !parser.hasSideEffects) ||
      parser is PermuteParser ||
      parser is PickParser ||
      parser is TokenParser ||
      parser is WhereParser;
}
