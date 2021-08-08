import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

final identifier = letter() & word().star();

void main() {
  group('trace', () {
    test('success', () {
      final lines = <Object?>[];
      expect(trace(identifier, output: lines.add).parse('a').isSuccess, isTrue);
      expect(lines, [
        "Instance of 'SequenceParser<dynamic>'",
        "  Instance of 'CharacterParser'[letter expected]",
        "  Success[1:2]: a",
        "  Instance of 'PossessiveRepeatingParser<String>'[0..*]",
        "    Instance of 'CharacterParser'[letter or digit expected]",
        "    Failure[1:2]: letter or digit expected",
        "  Success[1:2]: []",
        "Success[1:2]: [a, []]",
      ]);
    });
    test('failure', () {
      final lines = <Object?>[];
      expect(trace(identifier, output: lines.add).parse('1').isFailure, isTrue);
      expect(lines, [
        "Instance of 'SequenceParser<dynamic>'",
        "  Instance of 'CharacterParser'[letter expected]",
        "  Failure[1:1]: letter expected",
        "Failure[1:1]: letter expected",
      ]);
    });
  });
  group('profile', () {
    Matcher isProfileFrame({required String parser, int count = 0}) =>
        isA<ProfileFrame>()
            .having(
                (frame) => frame.parser.toString(), 'parser', contains(parser))
            .having((frame) => frame.count, 'count', count)
            .having((frame) => frame.elapsed.inMicroseconds, 'elapsed',
                count == 0 ? 0 : isPositive);

    test('success', () {
      final frames = <ProfileFrame>[];
      final parser = profile(identifier, output: frames.add);
      expect(parser.parse('ab123').isSuccess, isTrue);
      expect(frames, [
        isProfileFrame(parser: 'SequenceParser', count: 1),
        isProfileFrame(parser: '[0..*]', count: 1),
        isProfileFrame(parser: 'letter or digit expected', count: 5),
        isProfileFrame(parser: 'letter expected', count: 1),
      ]);
    });
    test('failure', () {
      final frames = <ProfileFrame>[];
      final parser = profile(identifier, output: frames.add);
      expect(parser.parse('1').isFailure, isTrue);
      expect(frames, [
        isProfileFrame(parser: 'SequenceParser', count: 1),
        isProfileFrame(parser: '[0..*]'),
        isProfileFrame(parser: 'letter or digit expected'),
        isProfileFrame(parser: 'letter expected', count: 1),
      ]);
    });
  });
  group('progress', () {
    test('success', () {
      final lines = <Object?>[];
      expect(progress(identifier, output: lines.add).parse('ab123').isSuccess,
          isTrue);
      expect(lines, [
        "* Instance of 'SequenceParser<dynamic>'",
        "* Instance of 'CharacterParser'[letter expected]",
        "** Instance of 'PossessiveRepeatingParser<String>'[0..*]",
        "** Instance of 'CharacterParser'[letter or digit expected]",
        "*** Instance of 'CharacterParser'[letter or digit expected]",
        "**** Instance of 'CharacterParser'[letter or digit expected]",
        "***** Instance of 'CharacterParser'[letter or digit expected]",
        "****** Instance of 'CharacterParser'[letter or digit expected]",
      ]);
    });
    test('failure', () {
      final lines = <Object?>[];
      expect(
          progress(identifier, output: lines.add).parse('1').isFailure, isTrue);
      expect(lines, [
        "* Instance of 'SequenceParser<dynamic>'",
        "* Instance of 'CharacterParser'[letter expected]",
      ]);
    });
  });
}
