import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('parse()', () {
    final parser = char('a');
    check(parser.parse('a')).isA<Success<dynamic>>();
    check(parser.parse('b')).isA<Failure>();
  });
  test('parse (start)', () {
    final parser = char('b');
    check(parser.parse('abc', start: 0)).isA<Failure>();
    check(parser.parse('abc', start: 1)).isA<Success<dynamic>>();
    check(parser.parse('abc', start: 2)).isA<Failure>();
    check(parser.parse('abc', start: 3)).isA<Failure>();
    check(parser.parse('abc', start: 4)).isA<Failure>();
  });
  test('accept()', () {
    final parser = char('a');
    check(parser.accept('a')).isTrue();
    check(parser.accept('b')).isFalse();
  });
  test('accept (start)', () {
    final parser = char('b');
    check(parser.accept('abc', start: 0)).isFalse();
    check(parser.accept('abc', start: 1)).isTrue();
    check(parser.accept('abc', start: 2)).isFalse();
    check(parser.accept('abc', start: 3)).isFalse();
    check(parser.accept('abc', start: 4)).isFalse();
  });
  group('allMatches', () {
    const input = 'a123b456';
    final parser = digit().seq(digit()).flatten();
    test('allMatches()', () {
      check(parser.allMatches(input)).deepEquals(['12', '45']);
    });
    test('allMatches(start: 3)', () {
      check(parser.allMatches(input, start: 3)).deepEquals(['45']);
    });
    test('allMatches(overlapping: true)', () {
      check(parser.allMatches(input, overlapping: true))
          .deepEquals(['12', '23', '45', '56']);
    });
    test('allMatches(start: 3, overlapping: true)', () {
      check(parser.allMatches(input, start: 3, overlapping: true))
          .deepEquals(['45', '56']);
    });
  });
  group('pattern', () {
    const input = 'a123b45';
    final pattern = digit().seq(digit()).toPattern();
    test('allMatches()', () {
      final matches = pattern.allMatches(input);
      check(matches.map((matcher) => matcher.pattern))
          .deepEquals([pattern, pattern]);
      check(matches.map((matcher) => matcher.input)).deepEquals([input, input]);
      check(matches.map((matcher) => matcher.start)).deepEquals([1, 5]);
      check(matches.map((matcher) => matcher.end)).deepEquals([3, 7]);
      check(matches.map((matcher) => matcher.groupCount)).deepEquals([0, 0]);
      check(matches.map((matcher) => matcher[0])).deepEquals(['12', '45']);
      check(matches.map((matcher) => matcher.group(0)))
          .deepEquals(['12', '45']);
      check(matches.map((matcher) => matcher.groups([0, 1]))).deepEquals([
        ['12', null],
        ['45', null],
      ]);
    });
    test('allMatches() (empty match)', () {
      final pattern = digit().star().toPattern();
      final matches = pattern.allMatches(input);
      check(matches.map((matcher) => matcher[0]))
          .deepEquals(['', '123', '', '45', '']);
    });
    test('matchAsPrefix()', () {
      final match1 = pattern.matchAsPrefix(input);
      check(match1).isNull();
      final match2 = pattern.matchAsPrefix(input, 2);
      check(match2).isNotNull()
        ..has((m) => m.pattern, 'pattern').equals(pattern)
        ..has((m) => m.input, 'input').equals(input)
        ..has((m) => m.start, 'start').equals(2)
        ..has((m) => m.end, 'end').equals(4)
        ..has((m) => m.groupCount, 'groupCount').equals(0)
        ..has((m) => m[0], '[0]').equals('23')
        ..has((m) => m.group(0), 'group(0)').equals('23')
        ..has(
          (m) => m.groups([0, 1]),
          'groups([0, 1])',
        ).deepEquals(['23', null]);
    });
    test('startsWith()', () {
      check(input.startsWith(pattern)).isFalse();
      check(input.startsWith(pattern, 1)).isTrue();
      check(input.startsWith(pattern, 2)).isTrue();
      check(input.startsWith(pattern, 3)).isFalse();
    });
    test('indexOf()', () {
      check(input.indexOf(pattern)).equals(1);
      check(input.indexOf(pattern)).equals(1);
      check(input.indexOf(pattern, 1)).equals(1);
      check(input.indexOf(pattern, 2)).equals(2);
      check(input.indexOf(pattern, 3)).equals(5);
    });
    test('lastIndexOf()', () {
      check(input.lastIndexOf(pattern)).equals(5);
      check(input.lastIndexOf(pattern, 0)).equals(-1);
      check(input.lastIndexOf(pattern, 1)).equals(1);
      check(input.lastIndexOf(pattern, 2)).equals(2);
      check(input.lastIndexOf(pattern, 3)).equals(2);
    });
    test('contains()', () {
      check(input.contains(pattern)).isTrue();
    });
    test('replaceFirst()', () {
      check(input.replaceFirst(pattern, '!')).equals('a!3b45');
    });
    test('replaceFirstMapped()', () {
      check(input.replaceFirstMapped(pattern, (match) => '!${match[0]}!'))
          .equals('a!12!3b45');
    });
    test('replaceAll()', () {
      check(input.replaceAll(pattern, '!')).equals('a!3b!');
    });
    test('replaceAllMapped()', () {
      check(input.replaceAllMapped(pattern, (match) => '!${match[0]}!'))
          .equals('a!12!3b!45!');
    });
    test('split()', () {
      check(input.split(pattern)).deepEquals(['a', '3b', '']);
    });
    test('splitMapJoin()', () {
      check(
        input.splitMapJoin(
          pattern,
          onMatch: (match) => '!${match[0]}!',
          onNonMatch: (nonMatch) => '?$nonMatch?',
        ),
      ).equals('?a?!12!?3b?!45!??');
    });
  });
}
