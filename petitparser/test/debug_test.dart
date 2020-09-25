import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

final Parser identifier = letter() & word().star();

void main() {
  group('trace', () {
    test('success', () {
      final frames = <TraceFrame>[];
      final result = trace(identifier, frames.add).parse('a');
      expect(result.isSuccess, isTrue);
      expect(frames.first.level, 0);
      expect(frames.first.result, isNull);
      expect(frames.last.level, 0);
      expect(frames.last.result, isA<Success>());
      expect(frames.map((frame) => frame.toString()), [
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
      final frames = <TraceFrame>[];
      final result = trace(identifier, frames.add).parse('1');
      expect(result.isFailure, isTrue);
      expect(frames.first.level, 0);
      expect(frames.first.result, isNull);
      expect(frames.last.level, 0);
      expect(frames.last.result, isA<Failure>());
      expect(frames.map((frame) => frame.toString()), [
        'Instance of \'SequenceParser\'',
        '  Instance of \'CharacterParser\'[letter expected]',
        '  Failure[1:1]: letter expected',
        'Failure[1:1]: letter expected'
      ]);
    });
  });
  group('profile', () {
    test('success', () {
      final frames = <ProfileFrame>[];
      final result = profile(identifier, frames.add).parse('ab123');
      expect(result.isSuccess, isTrue);
      expect(frames, hasLength(4));
      final counts = frames.map((frame) => frame.count);
      final times = frames.map((frame) => frame.elapsed.inMicroseconds);
      final lines = frames.map((frame) => frame.toString());
      expect(counts, everyElement(isNonNegative));
      expect(times, everyElement(isNonNegative));
      expect(lines.any((cell) => cell.indexOf('SequenceParser') > 0), isTrue);
      expect(lines.any((cell) => cell.indexOf('letter expected') > 0), isTrue);
      expect(lines.any((cell) => cell.indexOf('PossessiveRepeatingParser') > 0),
          isTrue);
      expect(lines.any((cell) => cell.indexOf('letter or digit expected') > 0),
          isTrue);
    });
    test('failure', () {
      final frames = <ProfileFrame>[];
      final result = profile(identifier, frames.add).parse('1');
      expect(result.isFailure, isTrue);
      expect(frames, hasLength(4));
      final counts = frames.map((frame) => frame.count);
      final times = frames.map((frame) => frame.elapsed.inMicroseconds);
      final lines = frames.map((frame) => frame.toString());
      expect(counts, everyElement(isNonNegative));
      expect(times, everyElement(isNonNegative));
      expect(lines.any((cell) => cell.indexOf('SequenceParser') > 0), isTrue);
      expect(lines.any((cell) => cell.indexOf('letter expected') > 0), isTrue);
      expect(lines.any((cell) => cell.indexOf('PossessiveRepeatingParser') > 0),
          isTrue);
      expect(lines.any((cell) => cell.indexOf('letter or digit expected') > 0),
          isTrue);
    });
  });
  group('progress', () {
    test('success', () {
      final frames = <ProgressFrame>[];
      final result = progress(identifier, frames.add).parse('ab123');
      expect(result.isSuccess, isTrue);
      expect(frames.map((frame) => frame.toString()), [
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
      final frames = <ProgressFrame>[];
      final result = progress(identifier, frames.add).parse('1');
      expect(result.isFailure, isTrue);
      expect(frames.map((frame) => frame.toString()), [
        '* Instance of \'SequenceParser\'',
        '* Instance of \'CharacterParser\'[letter expected]'
      ]);
    });
  });
}
