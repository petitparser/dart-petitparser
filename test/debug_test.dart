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
      var storage = new List();
      var parser = new ContinuationParser(digit(), (continuation, Context context) {
        storage.add([continuation, context]);
        // we have to return something for now
        return context.failure('Abort');
      });
      // execute the parser twice to collect the continuations
      expect(parser.parse('1').isSuccess, isFalse);
      expect(parser.parse('a').isSuccess, isFalse);
      // later we can execute the continuations
      expect(storage[0][0](storage[0][1]).isSuccess, isTrue);
      expect(storage[1][0](storage[1][1]).isSuccess, isFalse);
      // of course the continuations can be resumed multiple times
      expect(storage[0][0](storage[0][1]).isSuccess, isTrue);
      expect(storage[1][0](storage[1][1]).isSuccess, isFalse);
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
    extract(buffer) => buffer.toString().trim().split('\n');
    test('success', () {
      var buffer = new StringBuffer();
      expect(trace(identifier, buffer).parse('a').isSuccess, isTrue);
      expect(extract(buffer), [
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
      var buffer = new StringBuffer();
      expect(trace(identifier, buffer).parse('1').isFailure, isTrue);
      expect(extract(buffer), [
        'Instance of \'SequenceParser\'',
        '  Instance of \'CharacterParser\'[letter expected]',
        '  Failure[1:1]: letter expected',
        'Failure[1:1]: letter expected']);
    });
  });

  group('profile', () {
    extract(buffer) => buffer.toString().trim().split('\n')
        .map((line) => line.split('\t'))
        .map((row) => [int.parse(row[0]), int.parse(row[1]), row[2]]);
    test('success', () {
      var buffer = new StringBuffer();
      profile(identifier, buffer).parse('ab123');
      var extracted = extract(buffer);
      expect(extracted, hasLength(4));
      expect(extracted.every((row) => row[0] == 0 ? row[1] == 0 : row[1] > 0), isTrue);
      expect(extracted.firstWhere((row) => row[2].indexOf('SequenceParser') > 0)[0], 1);
      expect(extracted.firstWhere((row) => row[2].indexOf('letter expected') > 0)[0], 1);
      expect(extracted.firstWhere((row) => row[2].indexOf('PossessiveRepeatingParser') > 0)[0], 1);
      expect(extracted.firstWhere((row) => row[2].indexOf('letter or digit expected') > 0)[0], 5);
    });
    test('failure', () {
      var buffer = new StringBuffer();
      profile(identifier, buffer).parse('1');
      var extracted = extract(buffer);
      expect(extracted, hasLength(4));
      expect(extracted.every((row) => row[0] == 0 ? row[1] == 0 : row[1] > 0), isTrue);
      expect(extracted.firstWhere((row) => row[2].indexOf('SequenceParser') > 0)[0], 1);
      expect(extracted.firstWhere((row) => row[2].indexOf('letter expected') > 0)[0], 1);
      expect(extracted.firstWhere((row) => row[2].indexOf('PossessiveRepeatingParser') > 0)[0], 0);
      expect(extracted.firstWhere((row) => row[2].indexOf('letter or digit expected') > 0)[0], 0);
    });
  });

  group('progress', () {
    extract(buffer) => buffer.toString().trim().split('\n');
    test('success', () {
      var buffer = new StringBuffer();
      expect(progress(identifier, buffer).parse('ab123').isSuccess, isTrue);
      expect(extract(buffer), [
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
      var buffer = new StringBuffer();
      expect(progress(identifier, buffer).parse('1').isFailure, isTrue);
      expect(extract(buffer), [
        '* Instance of \'SequenceParser\'',
        '* Instance of \'CharacterParser\'[letter expected]']);
    });
  });


}
