library petitparser.test.debug_test;

import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

final identifier = letter() & word().star();

main() {
  group('continuation', () {
    test('delegation', () {
      var parser = ContinuationParser(digit(), (continuation, context) {
        return continuation(context);
      });
      expect(parser.parse('1').isSuccess, isTrue);
      expect(parser.parse('a').isSuccess, isFalse);
    });
    test('divertion', () {
      var parser = ContinuationParser(digit(), (continuation, context) {
        return letter().parseOn(context);
      });
      expect(parser.parse('1').isSuccess, isFalse);
      expect(parser.parse('a').isSuccess, isTrue);
    });
    test('resume', () {
      var continuations = <ContinuationCallback>[];
      var contexts = <Context>[];
      var parser = ContinuationParser(digit(), (continuation, context) {
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
      var parser = ContinuationParser(digit(), (continuation, context) {
        return context.success('Always succeed');
      });
      expect(parser.parse('1').isSuccess, isTrue);
      expect(parser.parse('a').isSuccess, isTrue);
    });
    test('failure', () {
      var parser = ContinuationParser(digit(), (continuation, context) {
        return context.failure('Always fail');
      });
      expect(parser.parse('1').isSuccess, isFalse);
      expect(parser.parse('a').isSuccess, isFalse);
    });
    test('copy', () {
      var parser = ContinuationParser(digit(), (continuation, context) {
        return continuation(context);
      });
      var copy = parser.copy();
      expect(copy.parse('1').isSuccess, isTrue);
      expect(copy.parse('a').isSuccess, isFalse);
    });
  });
  group('trace', () {
    test('success', () {
      var lines = <String>[];
      expect(trace(identifier, (line) => lines.add(line)).parse('a').isSuccess,
          isTrue);
      expect(lines, [
        'Instance of \'SequenceParser\'',
        '  Instance of \'CharacterParser\'[letter expected]',
        '  Success[1:2]: a',
        '  Instance of \'PossessiveRepeatingParser\'[0..*]',
        '    Instance of \'CharacterParser\'[letter or digit expected]',
        '    Failure[1:2]: letter or digit expected',
        '  Success[1:2]: []',
        'Success[1:2]: [a, []]'
      ]);
    });
    test('failure', () {
      var lines = <String>[];
      expect(trace(identifier, (line) => lines.add(line)).parse('1').isFailure,
          isTrue);
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
      var lines = <String>[];
      expect(
          profile(identifier, (line) => lines.add(line))
              .parse('ab123')
              .isSuccess,
          isTrue);
      expect(lines, hasLength(4));
      var splitLines = lines.map((row) => row.split('\t'));
      var counts = splitLines.map((row) => int.parse(row[0]));
      var times = splitLines.map((row) => int.parse(row[1]));
      var names = splitLines.map((row) => row[2]);
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
      var lines = <String>[];
      expect(
          profile(identifier, (line) => lines.add(line)).parse('1').isFailure,
          isTrue);
      expect(lines, hasLength(4));
      var splitLines = lines.map((row) => row.split('\t'));
      var counts = splitLines.map((row) => int.parse(row[0]));
      var times = splitLines.map((row) => int.parse(row[1]));
      var names = splitLines.map((row) => row[2]);
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
      var lines = <String>[];
      expect(
          progress(identifier, (line) => lines.add(line))
              .parse('ab123')
              .isSuccess,
          isTrue);
      expect(lines, [
        '* Instance of \'SequenceParser\'',
        '* Instance of \'CharacterParser\'[letter expected]',
        '** Instance of \'PossessiveRepeatingParser\'[0..*]',
        '** Instance of \'CharacterParser\'[letter or digit expected]',
        '*** Instance of \'CharacterParser\'[letter or digit expected]',
        '**** Instance of \'CharacterParser\'[letter or digit expected]',
        '***** Instance of \'CharacterParser\'[letter or digit expected]',
        '****** Instance of \'CharacterParser\'[letter or digit expected]'
      ]);
    });
    test('failure', () {
      var lines = <String>[];
      expect(
          progress(identifier, (line) => lines.add(line)).parse('1').isFailure,
          isTrue);
      expect(lines, [
        '* Instance of \'SequenceParser\'',
        '* Instance of \'CharacterParser\'[letter expected]'
      ]);
    });
  });
}
