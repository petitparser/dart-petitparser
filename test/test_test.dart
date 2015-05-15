library test_test;

import 'package:test/test.dart';

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/test.dart';

void main() {
  group('accept', () {
    test('success', () {
      var matcher = accept(char('a'));
      var state = new Map();
      expect(matcher.matches('a', state), isTrue);
      expect(state, isEmpty);
      var description = new StringDescription();
      matcher.describe(description);
      expect(description.toString(), '"Instance of \'CharacterParser\'["a" expected]" accepts input');
    });
    test('failure', () {
      var matcher = accept(char('a'));
      var state = new Map();
      expect(matcher.matches('b', state), isFalse);
      expect(state, isNot(isEmpty));
      var description = new StringDescription();
      matcher.describeMismatch('b', description, state, false);
      expect(description.toString(), '"Instance of \'CharacterParser\'["a" expected]" produces "Failure[1:1]: "a" expected" which is not accepted');
    });
  });
  group('parse', () {
    test('success', () {
      var matcher = parse(char('a'), 'a');
      var state = new Map();
      expect(matcher.matches('a', state), isTrue);
      expect(state, isEmpty);
      var description = new StringDescription();
      matcher.describe(description);
      expect(description.toString(), '"Instance of \'CharacterParser\'["a" expected]" '
          'accepts \'a\'');
    });
    test('failure', () {
      var matcher = parse(char('a'), 'a');
      var state = new Map();
      expect(matcher.matches('b', state), isFalse);
      expect(state, isNot(isEmpty));
      var description = new StringDescription();
      matcher.describeMismatch('b', description, state, false);
      expect(description.toString(), '"Instance of \'CharacterParser\'["a" expected]" '
          'produces "Failure[1:1]: "a" expected" which is not accepted');
    });
    test('matcher', () {
      var matcher = parse(char('a'), 'b');
      var state = new Map();
      expect(matcher.matches('a', state), isFalse);
      expect(state, isNot(isEmpty));
      var description = new StringDescription();
      matcher.describeMismatch('a', description, state, false);
      expect(description.toString(), '"Instance of \'CharacterParser\'["a" expected]" '
          'produces "Success[1:2]: a" which parse result is different.\n'
          'Expected: b\n  Actual: a\n          ^\n Differ at offset 0');
    });
    test('position', () {
      var matcher = parse(char('a'), 'a', 0);
      var state = new Map();
      expect(matcher.matches('a', state), isFalse);
      expect(state, isNot(isEmpty));
      var description = new StringDescription();
      matcher.describeMismatch('a', description, state, false);
      expect(description.toString(), '"Instance of \'CharacterParser\'["a" expected]" '
      'produces "Success[1:2]: a" that consumes input to 1 instead of 0');
    });
  });
}
