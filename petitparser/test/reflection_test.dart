import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

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
  final grammar = <Symbol, SettableParser>{
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
  final grammar = <Symbol, SettableParser>{
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
  final grammar = <Symbol, SettableParser>{
    for (final symbol in [#S, #P, #p]) symbol: undefined(),
  };
  grammar[#S]!.set(grammar[#P]! | grammar[#p]!);
  grammar[#P]!.set(grammar[#S]! & char('+') & grammar[#S]!);
  grammar[#p]!.set(char('p'));
  return grammar;
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

// ignore_for_file: deprecated_member_use_from_same_package
void main() {
  group('analyzer', () {
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
    });
    group('cycle-set', () {
      test('übersetzerbau grammar', () {
        final parsers = createUebersetzerbau();
        final analyzer = Analyzer(parsers[#S]!);
        expect(analyzer.cycleSet, isEmpty);
      });
      test('dragon grammar', () {
        final parsers = createDragon();
        final analyzer = Analyzer(parsers[#E]!);
        expect(analyzer.cycleSet, isEmpty);
      });
      test('ambiguous grammar', () {
        final parsers = createAmbiguous();
        final analyzer = Analyzer(parsers[#S]!);
        expect(analyzer.cycleSet, hasLength(6));
      });
      test('recursive grammar', () {
        final parsers = createRecursive();
        final analyzer = Analyzer(parsers[#S]!);
        expect(analyzer.cycleSet, hasLength(4));
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
      expect(parsers, [parser1, parser3, parser2]);
    });
    test('duplicated', () {
      final parser2 = uppercase();
      final parser1 = parser2.seq(parser2);
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2]);
    });
    test('knot', () {
      final parser1 = undefined();
      parser1.set(parser1);
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1]);
    });
    test('looping', () {
      final parser1 = undefined();
      final parser2 = undefined();
      final parser3 = undefined();
      parser1.set(parser2);
      parser2.set(parser3);
      parser3.set(parser1);
      final parsers = allParser(parser1).toList();
      expect(parsers, [parser1, parser2, parser3]);
    });
  });
  // group('queries', () {
  //   group('isNullable', () {
  //     test('true', () {
  //       expect(isNullable(char('a').optional()), isTrue);
  //       expect(isNullable(char('a').optionalWith('b')), isTrue);
  //       expect(isNullable(char('a').star()), isTrue);
  //       expect(isNullable(char('a').starGreedy(char('b'))), isTrue);
  //       expect(isNullable(char('a').starLazy(char('b'))), isTrue);
  //       expect(isNullable(epsilon()), isTrue);
  //     });
  //     test('false', () {
  //       expect(isNullable(char('a')), isFalse);
  //       expect(isNullable(char('a').and()), isFalse);
  //       expect(isNullable(char('a').not()), isFalse);
  //       expect(isNullable(char('a').or(char('b'))), isFalse);
  //       expect(isNullable(char('a').plus()), isFalse);
  //       expect(isNullable(char('a').seq(char('b'))), isFalse);
  //       expect(isNullable(failure()), isFalse);
  //     });
  //   });
  //   group('isTerminal', () {
  //     test('true', () {
  //       expect(isTerminal(char('a')), isTrue);
  //       expect(isTerminal(epsilon()), isTrue);
  //       expect(isTerminal(failure()), isTrue);
  //       expect(isTerminal(string('a')), isTrue);
  //     });
  //     test('false', () {
  //       expect(isTerminal(char('a').and()), isFalse);
  //       expect(isTerminal(char('a').not()), isFalse);
  //       expect(isTerminal(char('a').or(char('b'))), isFalse);
  //       expect(isTerminal(char('a').plus()), isFalse);
  //       expect(isTerminal(char('a').seq(char('b'))), isFalse);
  //     });
  //   });
  // });
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
      final output = transformParser(input, <T>(parser) {
        return source.isEqualTo(parser) ? target as Parser<T> : parser;
      });
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input, source);
      expect(output, target);
    });
    test('single', () {
      final source = lowercase();
      final input = source.settable();
      final target = uppercase();
      final output = transformParser(input, <T>(parser) {
        return source.isEqualTo(parser) ? target as Parser<T> : parser;
      });
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input.children.single, source);
      expect(output.children.single, target);
    });
    test('double', () {
      final source = lowercase();
      final input = source & source;
      final target = uppercase();
      final output = transformParser(input, <T>(parser) {
        return source.isEqualTo(parser) ? target as Parser<T> : parser;
      });
      expect(input, isNot(output));
      expect(input.isEqualTo(output), isFalse);
      expect(input.isEqualTo(source & source), isTrue);
      expect(input.children.first, input.children.last);
      expect(output.isEqualTo(target & target), isTrue);
      expect(output.children.first, output.children.last);
    });
    test('loop (existing)', () {
      final inner = failure().settable();
      final outer = inner.settable().settable();
      inner.set(outer);
      final output = transformParser(outer, <T>(parser) {
        return parser;
      });
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
    group('remove settables', () {
      test('basic settables', () {
        final input = lowercase().settable();
        final output = removeSettables(input);
        expect(output.isEqualTo(lowercase()), isTrue);
      });
      test('nested settables', () {
        final input = lowercase().settable().star();
        final output = removeSettables(input);
        expect(output.isEqualTo(lowercase().star()), isTrue);
      });
      test('double settables', () {
        final input = lowercase().settable().settable();
        final output = removeSettables(input);
        expect(output.isEqualTo(lowercase()), isTrue);
      });
    });
    test('remove duplicate', () {
      final input = lowercase() & lowercase();
      final output = removeDuplicates(input);
      expect(input.isEqualTo(output), isTrue);
      expect(input.children.first, isNot(input.children.last));
      expect(output.children.first, output.children.last);
    });
  });
}
