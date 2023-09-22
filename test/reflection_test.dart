import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:petitparser/src/reflection/internal/linter_rules.dart'
    as linter_rules;
import 'package:petitparser/src/reflection/internal/optimize_rules.dart'
    as optimize_rules;
import 'package:test/test.dart';

import 'utils/matchers.dart';

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
        if (parser.accept(character)) character
  };
  expect(actualInputs, expectedInputs);
}

class PluggableLinterRule extends LinterRule {
  const PluggableLinterRule(super.type, super.title, this._run);

  final void Function(LinterRule rule, Analyzer, Parser, LinterCallback) _run;

  @override
  void run(Analyzer analyzer, Parser parser, LinterCallback callback) =>
      _run(this, analyzer, parser, callback);
}

class PluggableOptimizeRule extends OptimizeRule {
  const PluggableOptimizeRule(this._run);

  final void Function<R>(OptimizeRule rule, Analyzer analyzer, Parser<R> parser,
      ReplaceParser<R> replace) _run;

  @override
  void run<R>(Analyzer analyzer, Parser<R> parser, ReplaceParser<R> replace) =>
      _run<R>(this, analyzer, parser, replace);
}

void main() {
  group('analyzer', () {
    test('root', () {
      final parser = char('a').plus();
      final analyzer = Analyzer(parser);
      expect(analyzer.root, parser);
    });
    test('parsers', () {
      final parser = char('a').plus();
      final analyzer = Analyzer(parser);
      expect(analyzer.parsers, {parser, parser.children.first});
    });
    group('allChildren', () {
      test('single', () {
        final inner = char('a');
        final parser = inner.plus();
        final analyzer = Analyzer(parser);
        expect(analyzer.allChildren(parser), {inner});
        expect(analyzer.allChildren(inner), isEmpty);
      });
      test('multiple', () {
        final inner1 = char('a');
        final inner2 = char('b');
        final parser = inner1 & inner2;
        final analyzer = Analyzer(parser);
        expect(analyzer.allChildren(parser), {inner1, inner2});
        expect(analyzer.allChildren(inner1), isEmpty);
        expect(analyzer.allChildren(inner2), isEmpty);
      });
      test('repeated', () {
        final inner1 = char('a');
        final inner2 = char('b');
        final parser = inner1 | inner2 | inner2;
        final analyzer = Analyzer(parser);
        expect(analyzer.allChildren(parser), {inner1, inner2});
        expect(analyzer.allChildren(inner1), isEmpty);
        expect(analyzer.allChildren(inner2), isEmpty);
      });
      test('recursive', () {
        final inner1 = char('a');
        final inner2 = undefined<String>();
        final parser = [inner1, inner2].toChoiceParser();
        inner2.set(parser);
        final analyzer = Analyzer(parser);
        expect(analyzer.allChildren(parser), {inner1, inner2, parser});
        expect(analyzer.allChildren(inner1), isEmpty);
        expect(analyzer.allChildren(inner2), {inner1, inner2, parser});
      });
      test('übersetzerbau grammar', () {
        final parsers = createUebersetzerbau();
        final analyzer = Analyzer(parsers[#S]!);
        expect(analyzer.allChildren(parsers[#S]!), {
          parsers[#A],
          parsers[#B],
          parsers[#a],
          parsers[#b],
          parsers[#c],
          parsers[#d],
          parsers[#e],
        });
        expect(analyzer.allChildren(parsers[#A]!), {
          parsers[#B],
          parsers[#a],
          parsers[#b],
          parsers[#e],
        });
        expect(analyzer.allChildren(parsers[#B]!), {
          parsers[#b],
          parsers[#e],
        });
        expect(analyzer.allChildren(parsers[#a]!), isEmpty);
        expect(analyzer.allChildren(parsers[#b]!), isEmpty);
        expect(analyzer.allChildren(parsers[#c]!), isEmpty);
        expect(analyzer.allChildren(parsers[#d]!), isEmpty);
        expect(analyzer.allChildren(parsers[#e]!), isEmpty);
      });
      test('recursive grammar', () {
        final parsers = createRecursive();
        final analyzer = Analyzer(parsers[#S]!);
        expect(analyzer.allChildren(parsers[#S]!), analyzer.parsers);
        expect(analyzer.allChildren(parsers[#P]!), analyzer.parsers);
        expect(analyzer.allChildren(parsers[#p]!), {
          parsers[#p]!.children.first,
        });
        expect(analyzer.allChildren(parsers[#+]!), {
          parsers[#+]!.children.first,
        });
      });
      test('self reference', () {
        final parser = createSelfReference();
        final analyzer = Analyzer(parser);
        expect(analyzer.allChildren(parser), {parser});
      });
    });
    group('findPath', () {
      test('simple', () {
        final parser = char('a');
        final analyzer = Analyzer(parser);
        final path = analyzer.findPathTo(parser, parser)!;
        expect(path.source, parser);
        expect(path.target, parser);
        expect(path.parsers, [parser]);
        expect(path.indexes, isEmpty);
        final paths = analyzer.findAllPathsTo(parser, parser).toList();
        expect(paths, hasLength(1));
        expect(paths[0].parsers, [parser]);
        expect(paths[0].indexes, isEmpty);
      });
      test('choice', () {
        final terminal = char('a');
        final parser = terminal | terminal;
        final analyzer = Analyzer(parser);
        final path = analyzer.findPathTo(parser, terminal)!;
        expect(path.source, parser);
        expect(path.target, terminal);
        expect(path.parsers, [parser, terminal]);
        expect(path.indexes, [0]);
        final paths = analyzer.findAllPathsTo(parser, terminal).toList();
        expect(paths, hasLength(2));
        expect(paths[0].parsers, [parser, terminal]);
        expect(paths[0].indexes, [0]);
        expect(paths[1].parsers, [parser, terminal]);
        expect(paths[1].indexes, [1]);
      });
      test('length', () {
        final terminal = char('a');
        final repeated = terminal.star();
        final parser = repeated | terminal;
        final analyzer = Analyzer(parser);
        final path = analyzer.findPathTo(parser, terminal)!;
        expect(path.source, parser);
        expect(path.target, terminal);
        expect(path.parsers, [parser, terminal]);
        expect(path.indexes, [1]);
        final paths = analyzer.findAllPathsTo(parser, terminal).toList();
        expect(paths, hasLength(2));
        expect(paths[0].parsers, [parser, repeated, terminal]);
        expect(paths[0].indexes, [0, 0]);
        expect(paths[1].parsers, [parser, terminal]);
        expect(paths[1].indexes, [1]);
      });
      test('recursive grammar', () {
        final parsers = createRecursive();
        final analyzer = Analyzer(parsers[#S]!);
        expect(
            analyzer.findAllPaths(analyzer.root, (target) => false), isEmpty);
      });
      test('self reference', () {
        final parser = createSelfReference();
        final analyzer = Analyzer(parser);
        expect(
            analyzer.findAllPaths(analyzer.root, (target) => false), isEmpty);
      });
    });
    group('isNullable', () {
      test('plus', () {
        final parser = char('a').plus();
        final analyzer = Analyzer(parser);
        expect(analyzer.isNullable(parser), isFalse);
      });
      test('star', () {
        final parser = char('a').star();
        final analyzer = Analyzer(parser);
        expect(analyzer.isNullable(parser), isTrue);
      });
      test('optional', () {
        final parser = char('a').optional();
        final analyzer = Analyzer(parser);
        expect(analyzer.isNullable(parser), isTrue);
      });
      test('choice', () {
        final parser = char('a').or(char('b'));
        final analyzer = Analyzer(parser);
        expect(analyzer.isNullable(parser), isFalse);
      });
      test('epsilon choice', () {
        final parser = char('a').or(epsilon());
        final analyzer = Analyzer(parser);
        expect(analyzer.isNullable(parser), isTrue);
      });
      test('sequence', () {
        final parser = char('a').seq(char('b'));
        final analyzer = Analyzer(parser);
        expect(analyzer.isNullable(parser), isFalse);
      });
      test('epsilon sequence', () {
        final parser = epsilon().seq(char('a'));
        final analyzer = Analyzer(parser);
        expect(analyzer.isNullable(parser), isFalse);
      });
      test('optional sequence', () {
        final parser = char('a').optional().seq(char('b'));
        final analyzer = Analyzer(parser);
        expect(analyzer.isNullable(parser), isFalse);
      });
      test('übersetzerbau grammar', () {
        final parsers = createUebersetzerbau();
        final analyzer = Analyzer(parsers[#S]!);
        expect(analyzer.isNullable(parsers[#S]!), isFalse);
        expect(analyzer.isNullable(parsers[#A]!), isTrue);
        expect(analyzer.isNullable(parsers[#B]!), isTrue);
        expect(analyzer.isNullable(parsers[#a]!), isFalse);
        expect(analyzer.isNullable(parsers[#b]!), isFalse);
        expect(analyzer.isNullable(parsers[#c]!), isFalse);
        expect(analyzer.isNullable(parsers[#d]!), isFalse);
        expect(analyzer.isNullable(parsers[#e]!), isTrue);
      });
      test('dragon grammar', () {
        final parsers = createDragon();
        final analyzer = Analyzer(parsers[#E]!);
        expect(analyzer.isNullable(parsers[#E]!), isFalse);
        expect(analyzer.isNullable(parsers[#Ep]!), isTrue);
        expect(analyzer.isNullable(parsers[#T]!), isFalse);
        expect(analyzer.isNullable(parsers[#Tp]!), isTrue);
        expect(analyzer.isNullable(parsers[#F]!), isFalse);
      });
      test('ambiguous grammar', () {
        final parsers = createAmbiguous();
        final analyzer = Analyzer(parsers[#S]!);
        expect(analyzer.isNullable(parsers[#S]!), isFalse);
        expect(analyzer.isNullable(parsers[#A]!), isFalse);
        expect(analyzer.isNullable(parsers[#B]!), isFalse);
        expect(analyzer.isNullable(parsers[#a]!), isFalse);
        expect(analyzer.isNullable(parsers[#b]!), isFalse);
      });
      test('recursive grammar', () {
        final parsers = createRecursive();
        final analyzer = Analyzer(parsers[#S]!);
        expect(analyzer.isNullable(parsers[#S]!), isFalse);
        expect(analyzer.isNullable(parsers[#P]!), isFalse);
        expect(analyzer.isNullable(parsers[#p]!), isFalse);
      });
      test('self reference', () {
        final parser = createSelfReference();
        final analyzer = Analyzer(parser);
        expect(analyzer.isNullable(parser), isFalse);
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
          expect(analyzer.cycleSet(parser), isEmpty);
        }
      });
      test('dragon grammar', () {
        final parsers = createDragon();
        final analyzer = Analyzer(parsers[#E]!);
        for (final parser in parsers.values) {
          expect(analyzer.cycleSet(parser), isEmpty);
        }
      });
      test('ambiguous grammar', () {
        final parsers = createAmbiguous();
        final analyzer = Analyzer(parsers[#S]!);
        expect(analyzer.cycleSet(parsers[#S]!),
            allOf(hasLength(6), containsAll([parsers[#S], parsers[#A]])));
        expect(analyzer.cycleSet(parsers[#A]!),
            allOf(hasLength(6), containsAll([parsers[#S], parsers[#A]])));
        expect(analyzer.cycleSet(parsers[#B]!),
            allOf(hasLength(3), containsAll([parsers[#B]])));
        expect(analyzer.cycleSet(parsers[#a]!), isEmpty);
        expect(analyzer.cycleSet(parsers[#b]!), isEmpty);
      });
      test('recursive grammar', () {
        final parsers = createRecursive();
        final analyzer = Analyzer(parsers[#S]!);
        expect(analyzer.cycleSet(parsers[#S]!),
            allOf(hasLength(4), containsAll([parsers[#S], parsers[#P]])));
        expect(analyzer.cycleSet(parsers[#P]!),
            allOf(hasLength(4), containsAll([parsers[#S], parsers[#P]])));
        expect(analyzer.cycleSet(parsers[#p]!), isEmpty);
      });
      test('self reference', () {
        final parser = createSelfReference();
        final analyzer = Analyzer(parser);
        expect(analyzer.cycleSet(parser),
            allOf(hasLength(1), containsAll([parser])));
      });
    });
  });
  group('iterable', () {
    test('single', () {
      final parser1 = lowercase();
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1]);
    });
    test('nested', () {
      final parser3 = lowercase();
      final parser2 = parser3.star();
      final parser1 = parser2.flatten();
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2, parser3]);
    });
    test('branched', () {
      final parser3 = lowercase();
      final parser2 = uppercase();
      final parser1 = parser2.seq(parser3);
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2, parser3]);
    });
    test('duplicated', () {
      final parser2 = uppercase();
      final parser1 = parser2.seq(parser2);
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2]);
    });
    test('knot', () {
      final parser1 = undefined<void>();
      parser1.set(parser1);
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1]);
    });
    test('looping', () {
      final parser1 = undefined<void>();
      final parser2 = undefined<void>();
      final parser3 = undefined<void>();
      parser1.set(parser2);
      parser2.set(parser3);
      parser3.set(parser1);
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2, parser3]);
    });
  });
  group('linter', () {
    test('rules called on all parsers', () {
      final seen = <Parser>{};
      final input = char('a') | char('b');
      final rule = PluggableLinterRule(LinterType.error, 'Fake Rule',
          (rule, analyzer, parser, callback) => seen.add(parser));
      final results = linter(input,
          rules: [rule], callback: (issue) => fail('Unexpected callback'));
      expect(results, isEmpty);
      expect(seen, {input, input.children[0], input.children[1]});
    });
    test('issue triggered', () {
      final input = 'trigger'.toParser();
      final called = <LinterIssue>[];
      final rule = PluggableLinterRule(LinterType.error, 'Fake Rule',
          (rule, analyzer, parser, callback) {
        expect(parser, same(input));
        callback(LinterIssue(rule, parser, 'Described'));
      });
      expect(
          rule,
          isLinterRule(
              type: LinterType.error,
              title: 'Fake Rule',
              toString:
                  'LinterRule(type: LinterType.error, title: Fake Rule)'));
      final results = linter(input, rules: [rule], callback: called.add);
      expect(results, [
        isLinterIssue(
            rule: same(rule),
            type: LinterType.error,
            title: 'Fake Rule',
            parser: same(input),
            description: 'Described',
            toString: 'LinterIssue(type: LinterType.error, title: Fake Rule, '
                'parser: PredicateParser["trigger" expected], description: '
                'Described)')
      ]);
      expect(called, results);
    });
    group('rules', () {
      group('character repetition', () {
        const rules = [linter_rules.CharacterRepeater()];
        test('with character predicate parser', () {
          final parser = char('a').star().flatten();
          final results = linter(parser, rules: rules);
          expect(results, [
            isLinterIssue(
                parser: parser,
                type: LinterType.warning,
                title: 'Character repeater')
          ]);
        });
        test('with any parser', () {
          final parser = any().plus().flatten();
          final results = linter(parser, rules: rules);
          expect(results, [
            isLinterIssue(
                parser: parser,
                type: LinterType.warning,
                title: 'Character repeater')
          ]);
        });
        test('without issue', () {
          final parser = char('a').plus().token();
          final results = linter(parser, rules: rules);
          expect(results, isEmpty);
        });
      });
      group('left recursion', () {
        const rules = [linter_rules.LeftRecursion()];
        test('with issue', () {
          final parser = createSelfReference();
          final results = linter(parser, rules: rules);
          expect(results, [
            isLinterIssue(
                parser: parser.children[0],
                type: LinterType.error,
                title: 'Left recursion')
          ]);
        });
        test('without issue', () {
          final parser = digit();
          final results = linter(parser, rules: rules);
          expect(results, isEmpty);
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
          expect(results, [
            isLinterIssue(
                parser: parser, type: LinterType.info, title: 'Nested choice')
          ]);
        });
        test('without issue', () {
          final parser = [
            char('1'),
            [char('2'), char('3')].toChoiceParser().flatten(),
            char('4'),
          ].toChoiceParser();
          final results = linter(parser, rules: rules);
          expect(results, isEmpty);
        });
      });
      group('nullable repeater', () {
        const rules = [linter_rules.NullableRepeater()];
        test('with issue', () {
          final parser = epsilon().star().optional();
          final results = linter(parser, rules: rules);
          expect(results, [
            isLinterIssue(
                parser: parser.children[0],
                type: LinterType.error,
                title: 'Nullable repeater')
          ]);
        });
        test('without issue', () {
          final parser = digit().star().optional();
          final results = linter(parser, rules: rules);
          expect(results, isEmpty);
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
          expect(results, [
            isLinterIssue(
                parser: parser,
                type: LinterType.info,
                title: 'Overlapping choice')
          ]);
        });
        test('without issue', () {
          final parser = [
            char('1'),
            char('2'),
            char('3'),
          ].toChoiceParser();
          final results = linter(parser, rules: rules);
          expect(results, isEmpty);
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
          expect(results, [
            isLinterIssue(
                parser: parser,
                type: LinterType.warning,
                title: 'Repeated choice')
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
          expect(results, isEmpty);
        });
      });
      group('unnecessary flatten', () {
        const rules = [linter_rules.UnnecessaryFlatten()];
        test('with issue', () {
          final parser = any().flatten();
          final results = linter(parser, rules: rules);
          expect(results, [
            isLinterIssue(
                parser: parser,
                type: LinterType.warning,
                title: 'Unnecessary flatten')
          ]);
        });
        test('without issue', () {
          final parser = any().optional().flatten();
          final results = linter(parser, rules: rules);
          expect(results, isEmpty);
        });
      });
      group('unnecessary resolvable', () {
        const rules = [linter_rules.UnnecessaryResolvable()];
        test('with issue', () {
          final parser = char('a').settable();
          final results = linter(parser, rules: rules);
          expect(results, [
            isLinterIssue(
                parser: parser,
                type: LinterType.warning,
                title: 'Unnecessary resolvable')
          ]);
        });
        test('without issue', () {
          final parser = char('a');
          final results = linter(parser, rules: rules);
          expect(results, isEmpty);
        });
      });
      group('unoptimized flatten', () {
        const rules = [linter_rules.UnoptimizedFlatten()];
        test('with issue', () {
          final parser = any().flatten();
          final results = linter(parser, rules: rules);
          expect(results, [
            isLinterIssue(
                parser: parser,
                type: LinterType.info,
                title: 'Unoptimized flatten')
          ]);
        });
        test('without issue', () {
          final parser = any().flatten('anything really');
          final results = linter(parser, rules: rules);
          expect(results, isEmpty);
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
          expect(results, [
            isLinterIssue(
                parser: parser,
                type: LinterType.warning,
                title: 'Unreachable choice')
          ]);
        });
        test('without issue', () {
          final parser = [
            char('1'),
            char('2'),
            char('3'),
          ].toChoiceParser();
          final results = linter(parser, rules: rules);
          expect(results, isEmpty);
        });
      });
      group('unresolved settable', () {
        const rules = [linter_rules.UnresolvedSettable()];
        test('with issue', () {
          final parser = undefined<void>();
          final results = linter(parser, rules: rules);
          expect(results, [
            isLinterIssue(
                parser: parser,
                type: LinterType.error,
                title: 'Unresolved settable')
          ]);
        });
        test('without issue', () {
          final parser = digit().settable();
          final results = linter(parser, rules: rules);
          expect(results, isEmpty);
        });
      });
      group('unused result', () {
        const rules = [linter_rules.UnusedResult()];
        test('with issue', () {
          final parser = digit().map(int.parse).star().flatten();
          final results = linter(parser, rules: rules);
          expect(results, [
            isLinterIssue(
                parser: parser, type: LinterType.info, title: 'Unused result')
          ]);
        });
        test('without issue', () {
          final parser = digit().star().flatten();
          final results = linter(parser, rules: rules);
          expect(results, isEmpty);
        });
      });
    });
    group('regressions', () {
      test('separatedBy and nullable repeater', () {
        const rules = [linter_rules.NullableRepeater()];
        // Both repeater and separator are nullable, this might cause an
        // infinite loop.
        expect(linter(epsilon().starSeparated(epsilon()), rules: rules),
            [isLinterIssue(title: 'Nullable repeater')]);
        // If either the repeater or the separator is non-nullable, everything
        // is fine.
        expect(linter(epsilon().starSeparated(any()), rules: rules), isEmpty);
        expect(linter(any().starSeparated(epsilon()), rules: rules), isEmpty);
      });
    });
  });
  group('transform', () {
    test('copy', () {
      final input = lowercase().settable();
      final output = transformParser(input, <T>(parser) => parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isTrue);
      expect(input.children.single, isNot(output.children.single));
    });
    test('root', () {
      final source = lowercase();
      final input = source;
      final target = uppercase();
      final output = transformParser(
          input,
          <T>(parser) =>
              source.isEqualTo(parser) ? target as Parser<T> : parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input, source);
      expect(output, target);
    });
    test('single', () {
      final source = lowercase();
      final input = source.settable();
      final target = uppercase();
      final output = transformParser(
          input,
          <T>(parser) =>
              source.isEqualTo(parser) ? target as Parser<T> : parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input.children.single, source);
      expect(output.children.single, target);
    });
    test('double', () {
      final source = lowercase();
      final input = source & source;
      final target = uppercase();
      final output = transformParser(
          input,
          <T>(parser) =>
              source.isEqualTo(parser) ? target as Parser<T> : parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input.isEqualTo(source & source), isTrue);
      expect(input.children.first, input.children.last);
      expect(output.isEqualTo(target & target), isTrue);
      expect(output.children.first, output.children.last);
    });
    test('loop (existing)', () {
      final inner = failure<void>().settable();
      final outer = inner.settable().settable();
      inner.set(outer);
      final output = transformParser(outer, <T>(parser) => parser);
      expect(outer, isNot(output));
      expect(outer.isEqualTo(output), isTrue);
      final inputs = allParser(outer).toSet();
      final outputs = allParser(output).toSet();
      for (final input in inputs) {
        expect(outputs.contains(input), isFalse);
      }
      for (final output in outputs) {
        expect(inputs.contains(output), isFalse);
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
          <T>(parser) =>
              source.isEqualTo(parser) ? outer as Parser<T> : parser);
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(output.isEqualTo(outer), isTrue);
    });
  });
  group('optimize', () {
    test('rules called on all parsers', () {
      final seen = <Parser>{};
      final input = char('a') | char('b');
      final rule = PluggableOptimizeRule(
          <R>(rule, analyzer, parser, replace) => seen.add(parser));
      final result = optimize(
        input,
        rules: [rule],
        callback: (source, target) => fail('No callback expected'),
      );
      expect(result, same(input));
      expect(seen, {input, input.children[0], input.children[1]});
    });
    test('root replacement performed', () {
      final input = 'input'.toParser(), output = 'output'.toParser();
      final rule = PluggableOptimizeRule(<R>(rule, analyzer, parser, replace) {
        expect(parser, same(input));
        replace(input as Parser<R>, output as Parser<R>);
      });
      final result = optimize(input, rules: [rule], callback: (source, target) {
        expect(source, input);
        expect(target, output);
      });
      expect(result, same(output));
    });
    test('child replacement performed', () {
      final input = char('a') | char('b'), replacement = char('c');
      final rule = PluggableOptimizeRule(<R>(rule, analyzer, parser, replace) {
        if (parser is SingleCharacterParser &&
            (parser as SingleCharacterParser).message == '"b" expected') {
          replace(parser, replacement as Parser<R>);
        }
      });
      final result = optimize(input, rules: [rule], callback: (source, target) {
        expect(source, input.children[1]);
        expect(target, replacement);
      });
      expect(result, same(input));
      expect(result.children[1], same(replacement));
    });
    group('rules', () {
      group('character repeater', () {
        const rules = [optimize_rules.CharacterRepeater()];
        test('with predicate parser', () {
          final character = char('a');
          final parser = character.repeat(2, 3).flatten();
          final result = optimize(parser, rules: rules);
          expect(
              result,
              isA<RepeatingCharacterParser>()
                  .having((p) => p.min, 'min', 2)
                  .having((p) => p.max, 'max', 3)
                  .having((p) => p.message, 'message', '"a" expected'));
        });
        test('with any parser', () {
          final character = any();
          final parser = character.repeat(3, 5).flatten();
          final result = optimize(parser, rules: rules);
          expect(
              result,
              isA<RepeatingCharacterParser>()
                  .having((p) => p.min, 'min', 3)
                  .having((p) => p.max, 'max', 5)
                  .having((p) => p.message, 'message', 'input expected'));
        });
        test('without optimization', () {
          final parser = char('a').plus().token();
          final result = optimize(parser, rules: rules);
          expect(result, same(parser));
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
          expect(
              result,
              isA<ChoiceParser<String>>()
                  .having(
                      (p) => p.children,
                      'children',
                      containsAllInOrder([
                        parser.children[0],
                        parser.children[1].children[0],
                        parser.children[1].children[1],
                        parser.children[2],
                      ]))
                  .having(
                      (p) => p.failureJoiner, 'failureJoiner', selectFarthest));
        });
        test('without optimization (no nesting)', () {
          final parser = [
            char('1'),
            char('2'),
            char('3'),
          ].toChoiceParser();
          final result = optimize(parser,
              rules: rules,
              callback: (source, target) => fail('No replacement expected'));
          expect(result, same(parser));
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
          final result = optimize(parser,
              rules: rules,
              callback: (source, target) => fail('No replacement expected'));
          expect(result, same(parser));
        });
      });
      group('remove delegate', () {
        const rules = [optimize_rules.RemoveDelegate()];
        test('with single settable', () {
          final parser = char('a').settable();
          final result = optimize(parser, rules: rules);
          expect(result, same(parser.children[0]));
        });
        test('with single label', () {
          final parser = char('a').labeled("hello");
          final result = optimize(parser, rules: rules);
          expect(result, same(parser.children[0]));
        });
        test('with repeated settable', () {
          final parser = char('a').settable().settable();
          final result = optimize(parser, rules: rules);
          expect(result, same(parser.children[0]));
        });
        test('with loop', () {
          final parser = undefined<Object?>();
          parser.set(parser);
          final result = optimize(parser, rules: rules);
          expect(result, same(parser));
        });
        test('deprecated code', () {
          final parser = char('a').settable();
          // ignore: deprecated_member_use_from_same_package
          final result = removeSettables(parser);
          expect(result, same(parser.children[0]));
        });
      });
      group('remove duplicate', () {
        const rules = [optimize_rules.RemoveDuplicate()];
        test('with duplicate', () {
          final parser = lowercase() & lowercase();
          final result = optimize(parser, rules: rules);
          expect(result.children.first, same(result.children.last));
        });
        test('without duplicate', () {
          final parser = lowercase() & lowercase('lower');
          final result = optimize(parser,
              rules: rules,
              callback: (source, target) => fail('No replacement expected'));
          expect(result.children.first, isNot(same(result.children.last)));
        });
        test('deprecated code', () {
          final parser = lowercase() & lowercase();
          // ignore: deprecated_member_use_from_same_package
          final result = removeDuplicates(parser);
          expect(result.children.first, same(result.children.last));
        });
      });
    });
  });
}
