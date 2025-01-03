import '../../core/parser.dart';
import '../../parser/action/flatten.dart';
import '../../parser/combinator/choice.dart';
import '../../parser/combinator/delegate.dart';
import '../../parser/combinator/settable.dart';
import '../../parser/misc/label.dart';
import '../../parser/predicate/single_character.dart';
import '../../parser/repeater/character.dart';
import '../../parser/repeater/possessive.dart';
import '../analyzer.dart';
import '../optimize.dart';

class CharacterRepeater extends OptimizeRule {
  const CharacterRepeater();

  @override
  void run<R>(Analyzer analyzer, Parser<R> parser, ReplaceParser<R> replace) {
    if (parser case FlattenParser(delegate: final repeating)) {
      if (repeating
          case PossessiveRepeatingParser<String>(delegate: final character)) {
        if (character case SingleCharacterParser()) {
          replace(
              parser,
              RepeatingCharacterParser(character.predicate, character.message,
                  repeating.min, repeating.max) as Parser<R>);
        }
      }
    }
  }
}

class FlattenChoice extends OptimizeRule {
  const FlattenChoice();

  @override
  void run<R>(Analyzer analyzer, Parser<R> parser, ReplaceParser<R> replace) {
    if (parser is ChoiceParser<R>) {
      final children = parser.children.expand((child) =>
          child is ChoiceParser<R> &&
                  parser.failureJoiner == child.failureJoiner
              ? child.children
              : [child]);
      if (parser.children.length < children.length) {
        replace(parser,
            children.toChoiceParser(failureJoiner: parser.failureJoiner));
      }
    }
  }
}

class RemoveDelegate extends OptimizeRule {
  const RemoveDelegate();

  @override
  void run<R>(Analyzer analyzer, Parser<R> parser, ReplaceParser<R> replace) {
    final settables = <Parser<R>>{};
    while (parser is DelegateParser<R, R> &&
        (parser is SettableParser<R> || parser is LabelParser<R>)) {
      if (!settables.add(parser)) {
        break; // The grammar is looping.
      }
      parser = parser.delegate;
    }
    for (final settable in settables) {
      replace(settable, parser);
    }
  }
}

class RemoveDuplicate extends OptimizeRule {
  const RemoveDuplicate();

  @override
  void run<R>(Analyzer analyzer, Parser<R> parser, ReplaceParser<R> replace) {
    final other = analyzer.parsers.firstWhere(
      (each) => parser.isEqualTo(each),
      orElse: () => parser,
    );
    if (parser != other) {
      replace(parser, other as Parser<R>);
    }
  }
}
