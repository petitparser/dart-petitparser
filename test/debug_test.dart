library debug_test;

import 'package:unittest/unittest.dart';

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/debug.dart';

// weird bug in transformation makes the test break if we don't start
// from a clean parser every time
get identifier => letter() & word().star();

main() {
  group('continuation', () {
    test('delegation', () {
      var parser = new ContinuationParser(digit(), (continuation, context) {
        return continuation(context);
      });
      expect(parser.parse('1').isSuccess, isTrue);
      expect(parser.parse('a').isSuccess, isFalse);
    });
    test('divertion', () {
      var parser = new ContinuationParser(digit(), (continuation, context) {
        return letter().parseOn(context);
      });
      expect(parser.parse('1').isSuccess, isFalse);
      expect(parser.parse('a').isSuccess, isTrue);
    });
    test('resume', () {
      var capture = new List();
      var parser = new ContinuationParser(digit(), (continuation, Context context) {
        capture.add([continuation, context]);
        // we have to return something for now
        return context.failure('Abort');
      });
      // execute the parser twice to collect the continuations
      expect(parser.parse('1').isSuccess, isFalse);
      expect(parser.parse('a').isSuccess, isFalse);
      // later we can execute the captured continuations
      expect(capture[0][0](capture[0][1]).isSuccess, isTrue);
      expect(capture[1][0](capture[1][1]).isSuccess, isFalse);
      // of course the continuations can be resumed multiple times
      expect(capture[0][0](capture[0][1]).isSuccess, isTrue);
      expect(capture[1][0](capture[1][1]).isSuccess, isFalse);
    });
    test('success', () {
      var parser = new ContinuationParser(digit(), (continuation, Context context) {
        return context.success('Always succeed');
      });
      expect(parser.parse('1').isSuccess, isTrue);
      expect(parser.parse('a').isSuccess, isTrue);
    });
    test('failure', () {
      var parser = new ContinuationParser(digit(), (continuation, Context context) {
        return context.failure('Always fail');
      });
      expect(parser.parse('1').isSuccess, isFalse);
      expect(parser.parse('a').isSuccess, isFalse);
    });
  });

  group('trace', () {
    test('success', () {
      var lines = new List();
      expect(trace(identifier, (line) => lines.add(line))
          .parse('a').isSuccess, isTrue);
      expect(lines, [
        'Instance of \'SequenceParser\'',
        '  Instance of \'CharacterParser\'[letter expected]',
        '  Success[1:2]: a',
        '  Instance of \'PossessiveRepeatingParser\'[0..*]',
        '    Instance of \'CharacterParser\'[letter or digit expected]',
        '    Failure[1:2]: letter or digit expected',
        '  Success[1:2]: []',
        'Success[1:2]: [a, []]']);
    });
    test('failure', () {
      var lines = new List();
      expect(trace(identifier, (line) => lines.add(line))
          .parse('1').isFailure, isTrue);
      expect(lines, [
        'Instance of \'SequenceParser\'',
        '  Instance of \'CharacterParser\'[letter expected]',
        '  Failure[1:1]: letter expected',
        'Failure[1:1]: letter expected']);
    });
  });

  group('profile', () {
    test('success', () {
      var lines = new List();
      expect(profile(identifier, (line) => lines.add(line))
          .parse('ab123').isSuccess, isTrue);
      lines = lines
          .map((row) => row.split('\t'))
          .map((row) => [int.parse(row[0]), int.parse(row[1]), row[2]]);
      print(lines);
      expect(lines, hasLength(4));
      expect(lines.every((row) => row[1] >= 0), isTrue);
      expect(lines.firstWhere((row) => row[2].indexOf('SequenceParser') > 0)[0], 1);
      expect(lines.firstWhere((row) => row[2].indexOf('letter expected') > 0)[0], 1);
      expect(lines.firstWhere((row) => row[2].indexOf('PossessiveRepeatingParser') > 0)[0], 1);
      expect(lines.firstWhere((row) => row[2].indexOf('letter or digit expected') > 0)[0], 5);
    });
    test('failure', () {
      var lines = new List();
      expect(profile(identifier, (line) => lines.add(line))
          .parse('1').isFailure, isTrue);
      lines = lines
          .map((row) => row.split('\t'))
          .map((row) => [int.parse(row[0]), int.parse(row[1]), row[2]]);
      print(lines);
      expect(lines, hasLength(4));
      expect(lines.every((row) => row[1] >= 0), isTrue);
      expect(lines.firstWhere((row) => row[2].indexOf('SequenceParser') > 0)[0], 1);
      expect(lines.firstWhere((row) => row[2].indexOf('letter expected') > 0)[0], 1);
      expect(lines.firstWhere((row) => row[2].indexOf('PossessiveRepeatingParser') > 0)[0], 0);
      expect(lines.firstWhere((row) => row[2].indexOf('letter or digit expected') > 0)[0], 0);
    });
  });

  group('progress', () {
    test('success', () {
      var lines = new List();
      expect(progress(identifier, (line) => lines.add(line))
          .parse('ab123').isSuccess, isTrue);
      expect(lines, [
        '* Instance of \'SequenceParser\'',
        '* Instance of \'CharacterParser\'[letter expected]',
        '** Instance of \'PossessiveRepeatingParser\'[0..*]',
        '** Instance of \'CharacterParser\'[letter or digit expected]',
        '*** Instance of \'CharacterParser\'[letter or digit expected]',
        '**** Instance of \'CharacterParser\'[letter or digit expected]',
        '***** Instance of \'CharacterParser\'[letter or digit expected]',
        '****** Instance of \'CharacterParser\'[letter or digit expected]']);
    });
    test('failure', () {
      var lines = new List();
      expect(progress(identifier, (line) => lines.add(line))
          .parse('1').isFailure, isTrue);
      expect(lines, [
        '* Instance of \'SequenceParser\'',
        '* Instance of \'CharacterParser\'[letter expected]']);
    });
  });
}
