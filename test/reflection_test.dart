import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:petitparser/src/reflection/internal/linter_rules.dart'
    as linter_rules;
import 'package:petitparser/src/reflection/internal/optimize_rules.dart'
    as optimize_rules;
import 'package:test/scaffolding.dart';

import 'utils/checks.dart';

// Güting, Erwig, Übersetzerbau, Springer (p.63)
Map<Symbol, Parser> createUebersetzerbau() {
  final grammar = <Symbol, Parser>{};
  grammar[#a] = char('a');
  grammar[#b] = char('b');
  grammar[#c] = char('c');
  grammar[#d] = char('d');
  grammar[#e] = epsilon();
  grammar[#B] = grammar[#b]! | grammar[#e]!;
  grammar[#A] = grammar[#a]! | grammar[#B]!;
  grammar[#S] = grammar[#A]! & grammar[#B]! & grammar[#c]! & grammar[#d]!;
  return grammar;
}

// The canonical grammar to exercise first- and follow-set calculation,
// likely originally from the dragon-book.
Map<Symbol, Parser> createDragon() {
  final grammar = <Symbol, SettableParser<dynamic>>{
    for (final symbol in [#E, #Ep, #T, #Tp, #F]) symbol: undefined(),
  };
  grammar[#E]!.set(grammar[#T]! & grammar[#Ep]!);
  grammar[#Ep]!.set((char('+') & grammar[#T]! & grammar[#Ep]!).optional());
  grammar[#T]!.set(grammar[#F]! & grammar[#Tp]!);
  grammar[#Tp]!.set((char('*') & grammar[#F]! & grammar[#Tp]!).optional());
  grammar[#F]!.set((char('(') & grammar[#E]! & char(')')) | char('i'));
  return grammar;
}

// A highly ambiguous grammar by Saichaitanya Jampana. Exploring the problem of
// ambiguity in context-free grammars.
Map<Symbol, Parser> createAmbiguous() {
  final grammar = <Symbol, SettableParser<dynamic>>{
    for (final symbol in [#S, #A, #a, #B, #b]) symbol: undefined(),
  };
  grammar[#S]!.set((grammar[#A]! & grammar[#B]!) | grammar[#a]!);
  grammar[#A]!.set((grammar[#S]! & grammar[#B]!) | grammar[#b]!);
  grammar[#a]!.set(char('a'));
  grammar[#B]!.set((grammar[#B]! & grammar[#A]!) | grammar[#a]!);
  grammar[#b]!.set(char('b'));
  return grammar;
}

// A highly recursive parser.
Map<Symbol, Parser> createRecursive() {
  final grammar = <Symbol, SettableParser<dynamic>>{
    for (final symbol in [#S, #P, #p, #+]) symbol: undefined(),
  };
  grammar[#S]!.set(grammar[#P]! | grammar[#p]!);
  grammar[#P]!.set(grammar[#S]! & grammar[#+]! & grammar[#S]!);
  grammar[#p]!.set(char('p'));
  grammar[#+]!.set(char('+'));
  return grammar;
}

// A parser that references itself.
Parser<void> createSelfReference() {
  final parser = undefined<void>();
  parser.set(parser);
  return parser;
}

void expectTerminals(Iterable<Parser> parsers, Iterable<String> inputs) {
  final expectedInputs = {...inputs};
  final actualInputs = {
    for (final parser in [for (final parser in parsers) parser.end()])
      for (final character in [
        for (var code = 32; code <= 126; code++) String.fromCharCode(code),
        '',
      ])
        if (parser.accept(character)) character,
  };
  check(actualInputs).deepEquals(expectedInputs);
}

class PluggableLinterRule extends LinterRule {
  const new(super.type, super.title, this._run);

  final void Function(LinterRule rule, Analyzer, Parser, LinterCallback) _run;

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) =>
      _run(this, analyzer, parser, callback);
}

class PluggableOptimizeRule extends OptimizeRule {
  const new(this._run);

  final void Function<R>(
    OptimizeRule rule,
    Analyzer analyzer,
    Parser<R> parser,
    ReplaceParser<R> replace,
  )
  _run;

  @override
  void run<R>(Analyzer analyzer, Parser<R> parser, ReplaceParser<R> replace) =>
      _run<R>(this, analyzer, parser, replace);
}

void main() {
  group('analyzer', () {
    test('root', () {
      final parser = char('a').plus();
      final analyzer = Analyzer(parser);
      check(analyzer.root).equals(parser);
    });
    test('parsers', () {
      final parser = char('a').plus();
      final analyzer = Analyzer(parser);
      check(analyzer.parsers).deepEquals({parser, parser.children.first});
    });
    group('allChildren', () {
      test('single', () {
        final inner = char('a');
        final parser = inner.plus();
        final analyzer = Analyzer(parser);
        check(analyzer.allChildren(parser)).deepEquals({inner});
        check(analyzer.allChildren(inner)).isEmpty();
      });
      test('multiple', () {
        final inner1 = char('a');
        final inner2 = char('b');
        final parser = inner1 & inner2;
        final analyzer = Analyzer(parser);
        check(analyzer.allChildren(parser)).deepEquals({inner1, inner2});
        check(analyzer.allChildren(inner1)).isEmpty();
        check(analyzer.allChildren(inner2)).isEmpty();
      });
      test('repeated', () {
        final inner1 = char('a');
        final inner2 = char('b');
        final parser = inner1 | inner2 | inner2;
        final analyzer = Analyzer(parser);
        check(analyzer.allChildren(parser)).deepEquals({inner1, inner2});
        check(analyzer.allChildren(inner1)).isEmpty();
        check(analyzer.allChildren(inner2)).isEmpty();
      });
      test('recursive', () {
        final inner1 = char('a');
        final inner2 = undefined<String>();
        final parser = [inner1, inner2].toChoiceParser();
        inner2.set(parser);
        final analyzer = Analyzer(parser);
        check(analyzer.allChildren(parser))
            .deepEquals({inner1, inner2, parser});
        check(analyzer.allChildren(inner1)).isEmpty();
        check(analyzer.allChildren(inner2))
            .deepEquals({inner1, inner2, parser});
      });
      test('übersetzerbau grammar', () {
        final parsers = createUebersetzerbau();
        final analyzer = Analyzer(parsers[#S]!);
        check(analyzer.allChildren(parsers[#S]!)).deepEquals({
          parsers[#A],
          parsers[#B],
          parsers[#a],
          parsers[#b],
          parsers[#c],
          parsers[#d],
          parsers[#e],
        });
        check(analyzer.allChildren(parsers[#A]!))
            .deepEquals({parsers[#B], parsers[#a], parsers[#b], parsers[#e]});
        check(analyzer.allChildren(parsers[#B]!))
            .deepEquals({parsers[#b], parsers[#e]});
        check(analyzer.allChildren(parsers[#a]!)).isEmpty();
        check(analyzer.allChildren(parsers[#b]!)).isEmpty();
        check(analyzer.allChildren(parsers[#c]!)).isEmpty();
        check(analyzer.allChildren(parsers[#d]!)).isEmpty();
        check(analyzer.allChildren(parsers[#e]!)).isEmpty();
      });
      test('recursive grammar', () {
        final parsers = createRecursive();
        final analyzer = Analyzer(parsers[#S]!);
        check(analyzer.allChildren(parsers[#S]!)).deepEquals(analyzer.parsers);
        check(analyzer.allChildren(parsers[#P]!)).deepEquals(analyzer.parsers);
        check(analyzer.allChildren(parsers[#p]!))
            .deepEquals({parsers[#p]!.children.first});
        check(analyzer.allChildren(parsers[#+]!))
            .deepEquals({parsers[#+]!.children.first});
      });
      test('self reference', () {
        final parser = createSelfReference();
        final analyzer = Analyzer(parser);
        check(analyzer.allChildren(parser)).deepEquals({parser});
      });
    });
    group('findPath', () {
      test('simple', () {
        final parser = char('a');
        final analyzer = Analyzer(parser);
        final path = analyzer.findPathTo(parser, parser)!;
        check(path.source).equals(parser);
        check(path.target).equals(parser);
        check(path.parsers).deepEquals([parser]);
        check(path.indexes).isEmpty();
        final paths = analyzer.findAllPathsTo(parser, parser).toList();
        check(paths).length.equals(1);
        check(paths[0].parsers).deepEquals([parser]);
        check(paths[0].indexes).isEmpty();
      });
      test('choice', () {
        final terminal = char('a');
        final parser = terminal | terminal;
        final analyzer = Analyzer(parser);
        final path = analyzer.findPathTo(parser, terminal)!;
        check(path.source).equals(parser);
        check(path.target).equals(terminal);
        check(path.parsers).deepEquals([parser, terminal]);
        check(path.indexes).deepEquals([0]);
        final paths = analyzer.findAllPathsTo(parser, terminal).toList();
        check(paths).length.equals(2);
        check(paths[0].parsers).deepEquals([parser, terminal]);
        check(paths[0].indexes).deepEquals([0]);
        check(paths[1].parsers).deepEquals([parser, terminal]);
        check(paths[1].indexes).deepEquals([1]);
      });
      test('length', () {
        final terminal = char('a');
        final repeated = terminal.star();
        final parser = repeated | terminal;
        final analyzer = Analyzer(parser);
        final path = analyzer.findPathTo(parser, terminal)!;
        check(path.source).equals(parser);
        check(path.target).equals(terminal);
        check(path.parsers).deepEquals([parser, terminal]);
        check(path.indexes).deepEquals([1]);
        final paths = analyzer.findAllPathsTo(parser, terminal).toList();
        check(paths).length.equals(2);
        check(paths[0].parsers).deepEquals([parser, repeated, terminal]);
        check(paths[0].indexes).deepEquals([0, 0]);
        check(paths[1].parsers).deepEquals([parser, terminal]);
        check(paths[1].indexes).deepEquals([1]);
      });
      test('recursive grammar', () {
        final parsers = createRecursive();
        final analyzer = Analyzer(parsers[#S]!);
        check(analyzer.findAllPaths(analyzer.root, (target) => false))
            .isEmpty();
      });
      test('self reference', () {
        final parser = createSelfReference();
        final analyzer = Analyzer(parser);
        check(analyzer.findAllPaths(analyzer.root, (target) => false))
            .isEmpty();
      });
    });
    group('isNullable', () {
      test('plus', () {
        final parser = char('a').plus();
        final analyzer = Analyzer(parser);
        check(analyzer.isNullable(parser)).isFalse();
      });
      test('star', () {
        final parser = char('a').star();
        final analyzer = Analyzer(parser);
        check(analyzer.isNullable(parser)).isTrue();
      });
      test('optional', () {
        final parser = char('a').optional();
        final analyzer = Analyzer(parser);
        check(analyzer.isNullable(parser)).isTrue();
      });
      test('choice', () {
        final parser = char('a').or(char('b'));
        final analyzer = Analyzer(parser);
        check(analyzer.isNullable(parser)).isFalse();
      });
      test('epsilon choice', () {
        final parser = char('a').or(epsilon());
        final analyzer = Analyzer(parser);
        check(analyzer.isNullable(parser)).isTrue();
      });
      test('sequence', () {
        final parser = char('a').seq(char('b'));
        final analyzer = Analyzer(parser);
        check(analyzer.isNullable(parser)).isFalse();
      });
      test('epsilon sequence', () {
        final parser = epsilon().seq(char('a'));
        final analyzer = Analyzer(parser);
        check(analyzer.isNullable(parser)).isFalse();
      });
      test('optional sequence', () {
        final parser = char('a').optional().seq(char('b'));
        final analyzer = Analyzer(parser);
        check(analyzer.isNullable(parser)).isFalse();
      });
      test('übersetzerbau grammar', () {
        final parsers = createUebersetzerbau();
        final analyzer = Analyzer(parsers[#S]!);
        check(analyzer.isNullable(parsers[#S]!)).isFalse();
        check(analyzer.isNullable(parsers[#A]!)).isTrue();
        check(analyzer.isNullable(parsers[#B]!)).isTrue();
        check(analyzer.isNullable(parsers[#a]!)).isFalse();
        check(analyzer.isNullable(parsers[#b]!)).isFalse();
        check(analyzer.isNullable(parsers[#c]!)).isFalse();
        check(analyzer.isNullable(parsers[#d]!)).isFalse();
        check(analyzer.isNullable(parsers[#e]!)).isTrue();
      });
      test('dragon grammar', () {
        final parsers = createDragon();
        final analyzer = Analyzer(parsers[#E]!);
        check(analyzer.isNullable(parsers[#E]!)).isFalse();
        check(analyzer.isNullable(parsers[#Ep]!)).isTrue();
        check(analyzer.isNullable(parsers[#T]!)).isFalse();
        check(analyzer.isNullable(parsers[#Tp]!)).isTrue();
        check(analyzer.isNullable(parsers[#F]!)).isFalse();
      });
      test('ambiguous grammar', () {
        final parsers = createAmbiguous();
        final analyzer = Analyzer(parsers[#S]!);
        check(analyzer.isNullable(parsers[#S]!)).isFalse();
        check(analyzer.isNullable(parsers[#A]!)).isFalse();
        check(analyzer.isNullable(parsers[#B]!)).isFalse();
        check(analyzer.isNullable(parsers[#a]!)).isFalse();
        check(analyzer.isNullable(parsers[#b]!)).isFalse();
      });
      test('recursive grammar', () {
        final parsers = createRecursive();
        final analyzer = Analyzer(parsers[#S]!);
        check(analyzer.isNullable(parsers[#S]!)).isFalse();
        check(analyzer.isNullable(parsers[#P]!)).isFalse();
        check(analyzer.isNullable(parsers[#p]!)).isFalse();
      });
      test('self reference', () {
        final parser = createSelfReference();
        final analyzer = Analyzer(parser);
        check(analyzer.isNullable(parser)).isFalse();
      });
    });
    group('first-set', () {
      test('plus', () {
        final parser = char('a').plus();
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.firstSet(parser), ['a']);
      });
      test('star', () {
        final parser = char('a').star();
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.firstSet(parser), ['a', '']);
      });
      test('optional', () {
        final parser = char('a').optional();
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.firstSet(parser), ['a', '']);
      });
      test('choice', () {
        final parser = char('a').or(char('b'));
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.firstSet(parser), ['a', 'b']);
      });
      test('epsilon choice', () {
        final parser = char('a').or(epsilon());
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.firstSet(parser), ['a', '']);
      });
      test('sequence', () {
        final parser = char('a').seq(char('b'));
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.firstSet(parser), ['a']);
      });
      test('epsilon sequence', () {
        final parser = epsilon().seq(char('a'));
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.firstSet(parser), ['a']);
      });
      test('optional sequence', () {
        final parser = char('a').optional().seq(char('b'));
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.firstSet(parser), ['a', 'b']);
      });
      test('übersetzerbau grammar', () {
        final parsers = createUebersetzerbau();
        final analyzer = Analyzer(parsers[#S]!);
        expectTerminals(analyzer.firstSet(parsers[#S]!), ['a', 'b', 'c']);
        expectTerminals(analyzer.firstSet(parsers[#A]!), ['a', 'b', '']);
        expectTerminals(analyzer.firstSet(parsers[#B]!), ['b', '']);
        expectTerminals(analyzer.firstSet(parsers[#a]!), ['a']);
        expectTerminals(analyzer.firstSet(parsers[#b]!), ['b']);
        expectTerminals(analyzer.firstSet(parsers[#c]!), ['c']);
        expectTerminals(analyzer.firstSet(parsers[#d]!), ['d']);
        expectTerminals(analyzer.firstSet(parsers[#e]!), ['']);
      });
      test('dragon grammar', () {
        final parsers = createDragon();
        final analyzer = Analyzer(parsers[#E]!);
        expectTerminals(analyzer.firstSet(parsers[#E]!), ['(', 'i']);
        expectTerminals(analyzer.firstSet(parsers[#Ep]!), ['+', '']);
        expectTerminals(analyzer.firstSet(parsers[#T]!), ['(', 'i']);
        expectTerminals(analyzer.firstSet(parsers[#Tp]!), ['*', '']);
        expectTerminals(analyzer.firstSet(parsers[#F]!), ['(', 'i']);
      });
      test('ambiguous grammar', () {
        final parsers = createAmbiguous();
        final analyzer = Analyzer(parsers[#S]!);
        expectTerminals(analyzer.firstSet(parsers[#S]!), ['a', 'b']);
        expectTerminals(analyzer.firstSet(parsers[#A]!), ['a', 'b']);
        expectTerminals(analyzer.firstSet(parsers[#B]!), ['a']);
        expectTerminals(analyzer.firstSet(parsers[#a]!), ['a']);
        expectTerminals(analyzer.firstSet(parsers[#b]!), ['b']);
      });
      test('recursive grammar', () {
        final parsers = createRecursive();
        final analyzer = Analyzer(parsers[#S]!);
        expectTerminals(analyzer.firstSet(parsers[#S]!), ['p']);
        expectTerminals(analyzer.firstSet(parsers[#P]!), ['p']);
        expectTerminals(analyzer.firstSet(parsers[#p]!), ['p']);
      });
      test('self reference', () {
        final parser = createSelfReference();
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.firstSet(parser), []);
      });
    });
    group('follow-set', () {
      test('plus', () {
        final parser = char('a').plus();
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.followSet(parser), ['']);
        expectTerminals(analyzer.followSet(parser.children[0]), ['a', '']);
      });
      test('star', () {
        final parser = char('a').star();
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.followSet(parser), ['']);
        expectTerminals(analyzer.followSet(parser.children[0]), ['a', '']);
      });
      test('optional', () {
        final parser = char('a').optional();
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.followSet(parser), ['']);
        expectTerminals(analyzer.followSet(parser.children[0]), ['']);
      });
      test('choice', () {
        final parser = char('a').or(char('b'));
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.followSet(parser), ['']);
        expectTerminals(analyzer.followSet(parser.children[0]), ['']);
        expectTerminals(analyzer.followSet(parser.children[1]), ['']);
      });
      test('epsilon choice', () {
        final parser = char('a').or(epsilon());
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.followSet(parser), ['']);
        expectTerminals(analyzer.followSet(parser.children[0]), ['']);
        expectTerminals(analyzer.followSet(parser.children[1]), ['']);
      });
      test('sequence', () {
        final parser = char('a').seq(char('b'));
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.followSet(parser), ['']);
        expectTerminals(analyzer.followSet(parser.children[0]), ['b']);
        expectTerminals(analyzer.followSet(parser.children[1]), ['']);
      });
      test('epsilon sequence', () {
        final parser = epsilon().seq(char('a'));
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.followSet(parser), ['']);
        expectTerminals(analyzer.followSet(parser.children[0]), ['a']);
        expectTerminals(analyzer.followSet(parser.children[1]), ['']);
      });
      test('optional sequence', () {
        final parser = char('a').seq(char('b').optional());
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.followSet(parser), ['']);
        expectTerminals(analyzer.followSet(parser.children[0]), ['b', '']);
        expectTerminals(analyzer.followSet(parser.children[1]), ['']);
      });
      test('übersetzerbau grammar', () {
        final parsers = createUebersetzerbau();
        final analyzer = Analyzer(parsers[#S]!);
        expectTerminals(analyzer.followSet(parsers[#S]!), ['']);
        expectTerminals(analyzer.followSet(parsers[#A]!), ['b', 'c']);
        expectTerminals(analyzer.followSet(parsers[#B]!), ['b', 'c']);
        expectTerminals(analyzer.followSet(parsers[#a]!), ['b', 'c']);
        expectTerminals(analyzer.followSet(parsers[#b]!), ['b', 'c']);
        expectTerminals(analyzer.followSet(parsers[#c]!), ['d']);
        expectTerminals(analyzer.followSet(parsers[#d]!), ['']);
        expectTerminals(analyzer.followSet(parsers[#e]!), ['b', 'c']);
      });
      test('dragon grammar', () {
        final parsers = createDragon();
        final analyzer = Analyzer(parsers[#E]!);
        expectTerminals(analyzer.followSet(parsers[#E]!), [')', '']);
        expectTerminals(analyzer.followSet(parsers[#Ep]!), [')', '']);
        expectTerminals(analyzer.followSet(parsers[#T]!), [')', '+', '']);
        expectTerminals(analyzer.followSet(parsers[#Tp]!), [')', '+', '']);
        expectTerminals(analyzer.followSet(parsers[#F]!), [')', '+', '*', '']);
      });
      test('ambiguous grammar', () {
        final parsers = createAmbiguous();
        final analyzer = Analyzer(parsers[#S]!);
        expectTerminals(analyzer.followSet(parsers[#S]!), ['a', '']);
        expectTerminals(analyzer.followSet(parsers[#A]!), ['a', 'b', '']);
        expectTerminals(analyzer.followSet(parsers[#B]!), ['a', 'b', '']);
        expectTerminals(analyzer.followSet(parsers[#a]!), ['a', 'b', '']);
        expectTerminals(analyzer.followSet(parsers[#b]!), ['a', 'b', '']);
      });
      test('recursive grammar', () {
        final parsers = createRecursive();
        final analyzer = Analyzer(parsers[#S]!);
        expectTerminals(analyzer.followSet(parsers[#S]!), ['+', '']);
        expectTerminals(analyzer.followSet(parsers[#P]!), ['+', '']);
        expectTerminals(analyzer.followSet(parsers[#p]!), ['+', '']);
      });
      test('self reference', () {
        final parser = createSelfReference();
        final analyzer = Analyzer(parser);
        expectTerminals(analyzer.followSet(parser), ['']);
      });
    });
    group('cycle-set', () {
      test('übersetzerbau grammar', () {
        final parsers = createUebersetzerbau();
        final analyzer = Analyzer(parsers[#S]!);
        for (final parser in parsers.values) {
          check(analyzer.cycleSet(parser)).isEmpty();
        }
      });
      test('dragon grammar', () {
        final parsers = createDragon();
        final analyzer = Analyzer(parsers[#E]!);
        for (final parser in parsers.values) {
          check(analyzer.cycleSet(parser)).isEmpty();
        }
      });
      test('ambiguous grammar', () {
        final parsers = createAmbiguous();
        final analyzer = Analyzer(parsers[#S]!);
        check(analyzer.cycleSet(parsers[#S]!))
          ..length.equals(6)
          ..contains(parsers[#S]!)
          ..contains(parsers[#A]!);
        check(analyzer.cycleSet(parsers[#A]!))
          ..length.equals(6)
          ..contains(parsers[#S]!)
          ..contains(parsers[#A]!);
        check(analyzer.cycleSet(parsers[#B]!))
          ..length.equals(3)
          ..contains(parsers[#B]!);
        check(analyzer.cycleSet(parsers[#a]!)).isEmpty();
        check(analyzer.cycleSet(parsers[#b]!)).isEmpty();
      });
      test('recursive grammar', () {
        final parsers = createRecursive();
        final analyzer = Analyzer(parsers[#S]!);
        check(analyzer.cycleSet(parsers[#S]!))
          ..length.equals(4)
          ..contains(parsers[#S]!)
          ..contains(parsers[#P]!);
        check(analyzer.cycleSet(parsers[#P]!))
          ..length.equals(4)
          ..contains(parsers[#S]!)
          ..contains(parsers[#P]!);
        check(analyzer.cycleSet(parsers[#p]!)).isEmpty();
      });
      test('self reference', () {
        final parser = createSelfReference();
        final analyzer = Analyzer(parser);
        check(analyzer.cycleSet(parser))
          ..length.equals(1)
          ..contains(parser);
      });
    });
  });
  group('iterable', () {
    test('single', () {
      final parser1 = lowercase();
      final parsers = allParser(parser1).toList();
      check(parsers).deepEquals([parser1]);
    });
    test('nested', () {
      final parser3 = lowercase();
      final parser2 = parser3.star();
      final parser1 = parser2.flatten();
      final parsers = allParser(parser1).toList();
      check(parsers).deepEquals([parser1, parser2, parser3]);
    });
    test('branched', () {
      final parser3 = lowercase();
      final parser2 = uppercase();
      final parser1 = parser2.seq(parser3);
      final parsers = allParser(parser1).toList();
      check(parsers).deepEquals([parser1, parser2, parser3]);
    });
    test('duplicated', () {
      final parser2 = uppercase();
      final parser1 = parser2.seq(parser2);
      final parsers = allParser(parser1).toList();
      check(parsers).deepEquals([parser1, parser2]);
    });
    test('knot', () {
      final parser1 = undefined<void>();
      parser1.set(parser1);
      final parsers = allParser(parser1).toList();
      check(parsers).deepEquals([parser1]);
    });
    test('looping', () {
      final parser1 = undefined<void>();
      final parser2 = undefined<void>();
      final parser3 = undefined<void>();
      parser1.set(parser2);
      parser2.set(parser3);
      parser3.set(parser1);
      final parsers = allParser(parser1).toList();
      check(parsers).deepEquals([parser1, parser2, parser3]);
    });
  });
  group('linter', () {
    test('rules called on all parsers', () {
      final seen = <Parser>{};
      final input = char('a') | char('b');
      final rule = PluggableLinterRule(
        LinterType.error,
        'Fake Rule',
        (rule, analyzer, parser, callback) => seen.add(parser),
      );
      final results = linter(
        input,
        rules: [rule],
        callback: (issue) => fail('Unexpected callback'),
      );
      check(results).isEmpty();
      check(seen).deepEquals({input, input.children[0], input.children[1]});
    });
    test('issue triggered', () {
      final input = 'trigger'.toParser();
      final called = <LinterIssue>[];
      final rule = PluggableLinterRule(LinterType.error, 'Fake Rule', (
        rule,
        analyzer,
        parser,
        callback,
      ) {
        check(identical(parser, input)).isTrue();
        callback(LinterIssue(rule, parser, 'Described'));
      });
      check(rule).isLinterRule(
        type: LinterType.error,
        title: 'Fake Rule',
        toString: isToString(
          name: 'LinterRule',
          rest: ['(type: LinterType.error, title: Fake Rule)'],
        ),
      );
      final results = linter(input, rules: [rule], callback: called.add);
      check(results).matchesInOrder([
        isLinterIssue(
          rule: rule,
          type: LinterType.error,
          title: 'Fake Rule',
          parser: input,
          description: 'Described',
          toString: isToString(
            name: 'LinterIssue',
            rest: [
              '(type: LinterType.error, title: Fake Rule',
              'description: Described)',
            ],
          ),
        ),
      ]);
      check(called).deepEquals(results);
    });
    group('rules', () {
      group('character repetition', () {
        const rules = [linter_rules.CharacterRepeater()];
        test('with character predicate parser', () {
          final parser = char('a').star().flatten();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser,
              type: LinterType.warning,
              title: 'Character repeater',
            ),
          ]);
        });
        test('with any parser', () {
          final parser = any().plus().flatten();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser,
              type: LinterType.warning,
              title: 'Character repeater',
            ),
          ]);
        });
        test('without issue', () {
          final parser = char('a').plus().token();
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('duplicate parser', () {
        const rules = [linter_rules.DuplicateParser()];
        test('with issue', () {
          final parser = seq2(digit(), digit());
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser.children[0],
              type: LinterType.info,
              title: 'Duplicate parser',
            ),
          ]);
        });
        test('without issue', () {
          final parser = seq2(
            digit(message: 'first'),
            digit(message: 'second'),
          );
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('left recursion', () {
        const rules = [linter_rules.LeftRecursion()];
        test('with issue', () {
          final parser = createSelfReference();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser.children[0],
              type: LinterType.error,
              title: 'Left recursion',
            ),
          ]);
        });
        test('without issue', () {
          final parser = digit();
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('nested choice', () {
        const rules = [linter_rules.NestedChoice()];
        test('with issue', () {
          final parser = [
            char('1'),
            [char('2'), char('3')].toChoiceParser(),
            char('4'),
          ].toChoiceParser();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser,
              type: LinterType.info,
              title: 'Nested choice',
            ),
          ]);
        });
        test('without issue', () {
          final parser = [
            char('1'),
            [char('2'), char('3')].toChoiceParser().flatten(),
            char('4'),
          ].toChoiceParser();
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('nullable repeater', () {
        const rules = [linter_rules.NullableRepeater()];
        test('with issue', () {
          final parser = epsilon().star().optional();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser.children[0],
              type: LinterType.error,
              title: 'Nullable repeater',
            ),
          ]);
        });
        test('without issue', () {
          final parser = digit().star().optional();
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('overlapping choice', () {
        const rules = [linter_rules.OverlappingChoice()];
        test('with issue', () {
          final parser = [
            char('1'),
            char('2') & char('a'),
            char('2') & char('b'),
            char('3'),
          ].toChoiceParser();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser,
              type: LinterType.info,
              title: 'Overlapping choice',
            ),
          ]);
        });
        test('without issue', () {
          final parser = [char('1'), char('2'), char('3')].toChoiceParser();
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('repeated choice', () {
        const rules = [linter_rules.RepeatedChoice()];
        test('with issue', () {
          final parser = [
            char('1'),
            char('2'),
            char('3'),
            char('2'),
            char('4'),
          ].toChoiceParser();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser,
              type: LinterType.warning,
              title: 'Repeated choice',
            ),
          ]);
        });
        test('without issue', () {
          final parser = [
            char('1'),
            char('2'),
            char('3'),
            char('4'),
          ].toChoiceParser();
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('unnecessary flatten', () {
        const rules = [linter_rules.UnnecessaryFlatten()];
        test('with issue', () {
          final parser = any().flatten();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser,
              type: LinterType.warning,
              title: 'Unnecessary flatten',
            ),
          ]);
        });
        test('without issue', () {
          final parser = any().optional().flatten();
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('unnecessary resolvable', () {
        const rules = [linter_rules.UnnecessaryResolvable()];
        test('with issue', () {
          final parser = char('a').settable();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser,
              type: LinterType.warning,
              title: 'Unnecessary resolvable',
            ),
          ]);
        });
        test('without issue', () {
          final parser = char('a');
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('unoptimized flatten', () {
        const rules = [linter_rules.UnoptimizedFlatten()];
        test('with issue', () {
          final parser = any().flatten();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser,
              type: LinterType.info,
              title: 'Unoptimized flatten',
            ),
          ]);
        });
        test('without issue', () {
          final parser = any().flatten(message: 'anything really');
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('unreachable choice', () {
        const rules = [linter_rules.UnreachableChoice()];
        test('with issue', () {
          final parser = [
            char('1'),
            char('2'),
            epsilon(),
            char('3'),
          ].toChoiceParser();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser,
              type: LinterType.warning,
              title: 'Unreachable choice',
            ),
          ]);
        });
        test('without issue', () {
          final parser = [char('1'), char('2'), char('3')].toChoiceParser();
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('unresolved settable', () {
        const rules = [linter_rules.UnresolvedSettable()];
        test('with issue', () {
          final parser = undefined<void>();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser,
              type: LinterType.error,
              title: 'Unresolved settable',
            ),
          ]);
        });
        test('without issue', () {
          final parser = digit().settable();
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
      group('unused result', () {
        const rules = [linter_rules.UnusedResult()];
        test('with issue', () {
          final parser = digit().map(int.parse).star().flatten();
          final results = linter(parser, rules: rules);
          check(results).matchesInOrder([
            isLinterIssue(
              parser: parser,
              type: LinterType.info,
              title: 'Unused result',
            ),
          ]);
        });
        test('without issue', () {
          final parser = digit().star().flatten();
          final results = linter(parser, rules: rules);
          check(results).isEmpty();
        });
      });
    });
    group('regressions', () {
      test('separatedBy and nullable repeater', () {
        const rules = [linter_rules.NullableRepeater()];
        // Both repeater and separator are nullable, this might cause an
        // infinite loop.
        check(linter(epsilon().starSeparated(epsilon()), rules: rules))
            .matchesInOrder([isLinterIssue(title: 'Nullable repeater')]);
        // If either the repeater or the separator is non-nullable, everything
        // is fine.
        check(linter(epsilon().starSeparated(any()), rules: rules)).isEmpty();
        check(linter(any().starSeparated(epsilon()), rules: rules)).isEmpty();
      });
    });
  });
  group('transform', () {
    test('copy', () {
      final input = lowercase().settable();
      final output = transformParser(input, <T>(parser) => parser);
      check(input == output).isFalse();
      check(input.isEqualTo(output)).isTrue();
      check(input.children.single == output.children.single).isFalse();
    });
    test('root', () {
      final source = lowercase();
      final input = source;
      final target = uppercase();
      final output = transformParser(
        input,
        <T>(parser) => source.isEqualTo(parser) ? target as Parser<T> : parser,
      );
      check(input == output).isFalse();
      check(input.isEqualTo(output)).isFalse();
      check(input).equals(source);
      check(output).equals(target);
    });
    test('single', () {
      final source = lowercase();
      final input = source.settable();
      final target = uppercase();
      final output = transformParser(
        input,
        <T>(parser) => source.isEqualTo(parser) ? target as Parser<T> : parser,
      );
      check(input == output).isFalse();
      check(input.isEqualTo(output)).isFalse();
      check(input.children.single).equals(source);
      check(output.children.single).equals(target);
    });
    test('double', () {
      final source = lowercase();
      final input = source & source;
      final target = uppercase();
      final output = transformParser(
        input,
        <T>(parser) => source.isEqualTo(parser) ? target as Parser<T> : parser,
      );
      check(input == output).isFalse();
      check(input.isEqualTo(output)).isFalse();
      check(input.isEqualTo(source & source)).isTrue();
      check(input.children.first).equals(input.children.last);
      check(output.isEqualTo(target & target)).isTrue();
      check(output.children.first).equals(output.children.last);
    });
    test('loop (existing)', () {
      final inner = failure<void>().settable();
      final outer = inner.settable().settable();
      inner.set(outer);
      final output = transformParser(outer, <T>(parser) => parser);
      check(outer == output).isFalse();
      check(outer.isEqualTo(output)).isTrue();
      final inputs = allParser(outer).toSet();
      final outputs = allParser(output).toSet();
      for (final input in inputs) {
        check(outputs.contains(input)).isFalse();
      }
      for (final output in outputs) {
        check(inputs.contains(output)).isFalse();
      }
    });
    test('loop (new)', () {
      final source = lowercase();
      final input = source;
      final inner = failure<String>().settable();
      final outer = inner.settable().settable();
      inner.set(outer);
      final output = transformParser(
        input,
        <T>(parser) => source.isEqualTo(parser) ? outer as Parser<T> : parser,
      );
      check(input == output).isFalse();
      check(input.isEqualTo(output)).isFalse();
      check(output.isEqualTo(outer)).isTrue();
    });
  });
  group('optimize', () {
    test('rules called on all parsers', () {
      final seen = <Parser>{};
      final input = char('a') | char('b');
      final rule = PluggableOptimizeRule(
        <R>(rule, analyzer, parser, replace) => seen.add(parser),
      );
      final result = optimize(
        input,
        rules: [rule],
        callback: (source, target) => fail('No callback expected'),
      );
      check(identical(result, input)).isTrue();
      check(seen).deepEquals({input, input.children[0], input.children[1]});
    });
    test('root replacement performed', () {
      final input = 'input'.toParser(), output = 'output'.toParser();
      final rule = PluggableOptimizeRule(<R>(rule, analyzer, parser, replace) {
        check(identical(parser, input)).isTrue();
        replace(input as Parser<R>, output as Parser<R>);
      });
      final result = optimize(
        input,
        rules: [rule],
        callback: (source, target) {
          check(source).equals(input);
          check(target).equals(output);
        },
      );
      check(identical(result, output)).isTrue();
    });
    test('child replacement performed', () {
      final input = char('a') | char('b'), replacement = char('c');
      final rule = PluggableOptimizeRule(<R>(rule, analyzer, parser, replace) {
        if (parser is CharacterParser &&
            (parser as CharacterParser).message == '"b" expected') {
          replace(parser, replacement as Parser<R>);
        }
      });
      final result = optimize(
        input,
        rules: [rule],
        callback: (source, target) {
          check(source).equals(input.children[1]);
          check(target).equals(replacement);
        },
      );
      check(identical(result, input)).isTrue();
      check(identical(result.children[1], replacement)).isTrue();
    });
    group('rules', () {
      group('character repeater', () {
        const rules = [optimize_rules.CharacterRepeater()];
        test('with predicate parser', () {
          final character = char('a');
          final parser = character.repeat(2, 3).flatten();
          final result = optimize(parser, rules: rules);
          check(result).isA<RepeatingCharacterParser>()
            ..has((p) => p.min, 'min').equals(2)
            ..has((p) => p.max, 'max').equals(3)
            ..has((p) => p.message, 'message').equals('"a" expected');
        });
        test('with any parser', () {
          final character = any();
          final parser = character.repeat(3, 5).flatten();
          final result = optimize(parser, rules: rules);
          check(result).isA<RepeatingCharacterParser>()
            ..has((p) => p.min, 'min').equals(3)
            ..has((p) => p.max, 'max').equals(5)
            ..has((p) => p.message, 'message').equals('input expected');
        });
        test('without optimization', () {
          final parser = char('a').plus().token();
          final result = optimize(parser, rules: rules);
          check(identical(result, parser)).isTrue();
        });
      });
      group('nested choice', () {
        const rules = [optimize_rules.FlattenChoice()];
        test('with issue', () {
          final parser = [
            char('1'),
            [
              char('2'),
              char('3'),
            ].toChoiceParser(failureJoiner: selectFarthest),
            char('4'),
          ].toChoiceParser(failureJoiner: selectFarthest);
          final result = optimize(parser, rules: rules);
          check(result).isA<ChoiceParser<String>>()
            ..has((p) => p.children, 'children').deepEquals([
              parser.children[0],
              parser.children[1].children[0],
              parser.children[1].children[1],
              parser.children[2],
            ])
            ..has(
              (p) => p.failureJoiner,
              'failureJoiner',
            ).equals(selectFarthest);
        });
        test('without optimization (no nesting)', () {
          final parser = [char('1'), char('2'), char('3')].toChoiceParser();
          final result = optimize(
            parser,
            rules: rules,
            callback: (source, target) => fail('No replacement expected'),
          );
          check(identical(result, parser)).isTrue();
        });
        test('without optimization (different joiner)', () {
          final parser = [
            char('1'),
            [
              char('2'),
              char('3'),
            ].toChoiceParser(failureJoiner: selectFarthest),
            char('4'),
          ].toChoiceParser();
          final result = optimize(
            parser,
            rules: rules,
            callback: (source, target) => fail('No replacement expected'),
          );
          check(identical(result, parser)).isTrue();
        });
      });
      group('remove delegate', () {
        const rules = [optimize_rules.RemoveDelegate()];
        test('with single settable', () {
          final parser = char('a').settable();
          final result = optimize(parser, rules: rules);
          check(identical(result, parser.children[0])).isTrue();
        });
        test('with single label', () {
          final parser = char('a').labeled('hello');
          final result = optimize(parser, rules: rules);
          check(identical(result, parser.children[0])).isTrue();
        });
        test('with repeated settable', () {
          final parser = char('a').settable().settable();
          final result = optimize(parser, rules: rules);
          check(identical(result, parser.children[0])).isTrue();
        });
        test('with loop', () {
          final parser = undefined<Object?>();
          parser.set(parser);
          final result = optimize(parser, rules: rules);
          check(identical(result, parser)).isTrue();
        });
      });
      group('remove duplicate', () {
        const rules = [optimize_rules.RemoveDuplicate()];
        test('with duplicate', () {
          final parser = seq2(digit(), digit());
          final result = optimize(parser, rules: rules);
          check(identical(result.children.first, result.children.last))
              .isTrue();
        });
        test('without duplicate', () {
          final parser = seq2(
            digit(message: 'first'),
            digit(message: 'second'),
          );
          final result = optimize(
            parser,
            rules: rules,
            callback: (source, target) => fail('No replacement expected'),
          );
          check(identical(result.children.first, result.children.last))
              .isFalse();
        });
      });
    });
  });
}
