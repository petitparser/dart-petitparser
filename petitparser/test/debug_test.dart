library petitparser.test.debug_test;

import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

final identifier = letter() & word().star();

main() {
  group('continuation', () {
    test('delegation', () {
      final parser = ContinuationParser(digit(), (continuation, context) {
        return continuation(context);
      });
      expect(parser.parse('1').isSuccess, isTrue);
      expect(parser.parse('a').isSuccess, isFalse);
    });
    test('divertion', () {
      final parser = ContinuationParser(digit(), (continuation, context) {
        return letter().parseOn(context);
      });
      expect(parser.parse('1').isSuccess, isFalse);
      expect(parser.parse('a').isSuccess, isTrue);
    });
    test('resume', () {
      final continuations = <ContinuationCallback>[];
      final contexts = <Context>[];
      final parser = ContinuationParser(digit(), (continuation, context) {
        continuations.add(continuation);
        contexts.add(context);
        // we have to return something for now
        return context.failure('Abort');
      });
      // execute the parser twice to collect the continuations
      expect(parser.parse('1').isSuccess, isFalse);
      expect(parser.parse('a').isSuccess, isFalse);
      // later we can execute the captured continuations
      expect(continuations[0](contexts[0]).isSuccess, isTrue);
      expect(continuations[1](contexts[1]).isSuccess, isFalse);
      // of course the continuations can be resumed multiple times
      expect(continuations[0](contexts[0]).isSuccess, isTrue);
      expect(continuations[1](contexts[1]).isSuccess, isFalse);
    });
    test('success', () {
      final parser = ContinuationParser(digit(), (continuation, context) {
        return context.success('Always succeed');
      });
      expect(parser.parse('1').isSuccess, isTrue);
      expect(parser.parse('a').isSuccess, isTrue);
    });
    test('failure', () {
      final parser = ContinuationParser(digit(), (continuation, context) {
        return context.failure('Always fail');
      });
      expect(parser.parse('1').isSuccess, isFalse);
      expect(parser.parse('a').isSuccess, isFalse);
    });
    test('copy', () {
      final parser = ContinuationParser(digit(), (continuation, context) {
        return continuation(context);
      });
      final copy = parser.copy();
      expect(copy.parse('1').isSuccess, isTrue);
      expect(copy.parse('a').isSuccess, isFalse);
    });
  });
  group('trace', () {
    test('success', () {
      final lines = <String>[];
      expect(trace(identifier, lines.add).parse('a').isSuccess, isTrue);
      expect(lines, [
        'Instance of \'SequenceParser\'',
        '  Instance of \'CharacterParser\'[letter expected]',
        '  Success[1:2]: a',
        '  Instance of \'PossessiveRepeatingParser<String>\'[0..*]',
        '    Instance of \'CharacterParser\'[letter or digit expected]',
        '    Failure[1:2]: letter or digit expected',
        '  Success[1:2]: []',
        'Success[1:2]: [a, []]'
      ]);
    });
    test('failure', () {
      final lines = <String>[];
      expect(trace(identifier, lines.add).parse('1').isFailure, isTrue);
      expect(lines, [
        'Instance of \'SequenceParser\'',
        '  Instance of \'CharacterParser\'[letter expected]',
        '  Failure[1:1]: letter expected',
        'Failure[1:1]: letter expected'
      ]);
    });
  });
  group('profile', () {
    test('success', () {
      final lines = <String>[];
      expect(profile(identifier, lines.add).parse('ab123').isSuccess, isTrue);
      expect(lines, hasLength(4));
      final splitLines = lines.map((row) => row.split('\t'));
      final counts = splitLines.map((row) => int.parse(row[0]));
      final times = splitLines.map((row) => int.parse(row[1]));
      final names = splitLines.map((row) => row[2]);
      expect(counts.every((cell) => cell >= 0), isTrue);
      expect(times.every((cell) => cell >= 0), isTrue);
      expect(names.any((cell) => cell.indexOf('SequenceParser') > 0), isTrue);
      expect(names.any((cell) => cell.indexOf('letter expected') > 0), isTrue);
      expect(names.any((cell) => cell.indexOf('PossessiveRepeatingParser') > 0),
          isTrue);
      expect(names.any((cell) => cell.indexOf('letter or digit expected') > 0),
          isTrue);
    });
    test('failure', () {
      final lines = <String>[];
      expect(profile(identifier, lines.add).parse('1').isFailure, isTrue);
      expect(lines, hasLength(4));
      final splitLines = lines.map((row) => row.split('\t'));
      final counts = splitLines.map((row) => int.parse(row[0]));
      final times = splitLines.map((row) => int.parse(row[1]));
      final names = splitLines.map((row) => row[2]);
      expect(counts.every((cell) => cell >= 0), isTrue);
      expect(times.every((cell) => cell >= 0), isTrue);
      expect(names.any((cell) => cell.indexOf('SequenceParser') > 0), isTrue);
      expect(names.any((cell) => cell.indexOf('letter expected') > 0), isTrue);
      expect(names.any((cell) => cell.indexOf('PossessiveRepeatingParser') > 0),
          isTrue);
      expect(names.any((cell) => cell.indexOf('letter or digit expected') > 0),
          isTrue);
    });
  });
  group('progress', () {
    test('success', () {
      final lines = <String>[];
      expect(progress(identifier, lines.add).parse('ab123').isSuccess, isTrue);
      expect(lines, [
        '* Instance of \'SequenceParser\'',
        '* Instance of \'CharacterParser\'[letter expected]',
        '** Instance of \'PossessiveRepeatingParser<String>\'[0..*]',
        '** Instance of \'CharacterParser\'[letter or digit expected]',
        '*** Instance of \'CharacterParser\'[letter or digit expected]',
        '**** Instance of \'CharacterParser\'[letter or digit expected]',
        '***** Instance of \'CharacterParser\'[letter or digit expected]',
        '****** Instance of \'CharacterParser\'[letter or digit expected]'
      ]);
    });
    test('failure', () {
      final lines = <String>[];
      expect(progress(identifier, lines.add).parse('1').isFailure, isTrue);
      expect(lines, [
        '* Instance of \'SequenceParser\'',
        '* Instance of \'CharacterParser\'[letter expected]'
      ]);
    });
  });
}
