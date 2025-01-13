import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart' hide anyOf;
import 'package:test/test.dart';

import 'utils/matchers.dart';

final identifier = letter() & word().star();
final labeledIdentifier =
    letter().labeled('first') & word().star().labeled('remaining');

void main() {
  group('profile', () {
    test('success', () {
      final frames = <ProfileFrame>[];
      final parser = profile(identifier, output: frames.add);
      expect(parser.parse('ab123') is Success, isTrue);
      expect(
          frames,
          orderedEquals([
            isProfileFrame(parser: isParserShallowEqual(identifier), count: 1),
            isProfileFrame(
                parser: isParserShallowEqual(identifier.children[0]), count: 1),
            isProfileFrame(
                parser: isParserShallowEqual(identifier.children[1]), count: 1),
            isProfileFrame(
                parser:
                    isParserShallowEqual(identifier.children[1].children[0]),
                count: 5),
          ]));
    });
    test('labeled', () {
      final frames = <ProfileFrame>[];
      final parser = profile(labeledIdentifier,
          output: frames.add, predicate: (parser) => parser is LabeledParser);
      expect(parser.parse('ab123') is Success, isTrue);
      expect(
          frames,
          orderedEquals([
            isProfileFrame(
                parser: isParserShallowEqual(labeledIdentifier.children[0]),
                toString: contains('first'),
                count: 1),
            isProfileFrame(
                parser: isParserShallowEqual(labeledIdentifier.children[1]),
                toString: contains('remaining'),
                count: 1),
          ]));
    });
    test('failure', () {
      final frames = <ProfileFrame>[];
      final parser = profile(identifier, output: frames.add);
      expect(parser.parse('1') is Failure, isTrue);
      expect(
          frames,
          orderedEquals([
            isProfileFrame(parser: isParserShallowEqual(identifier), count: 1),
            isProfileFrame(
                parser: isParserShallowEqual(identifier.children[0]), count: 1),
            isProfileFrame(
                parser: isParserShallowEqual(identifier.children[1])),
            isProfileFrame(
                parser:
                    isParserShallowEqual(identifier.children[1].children[0])),
          ]));
    });
  });
  group('progress', () {
    test('success', () {
      final frames = <ProgressFrame>[];
      final parser = progress(identifier, output: frames.add);
      expect(parser.parse('ab123') is Success, isTrue);
      expect(frames, [
        isProgressFrame(
            parser: isParserShallowEqual(identifier),
            position: 0,
            toString: startsWith('* ')),
        isProgressFrame(
            parser: isParserShallowEqual(identifier.children[0]),
            position: 0,
            toString: startsWith('* ')),
        isProgressFrame(
            parser: isParserShallowEqual(identifier.children[1]),
            position: 1,
            toString: startsWith('** ')),
        isProgressFrame(
            parser: isParserShallowEqual(identifier.children[1].children[0]),
            position: 1,
            toString: startsWith('** ')),
        isProgressFrame(
            parser: isParserShallowEqual(identifier.children[1].children[0]),
            position: 2,
            toString: startsWith('*** ')),
        isProgressFrame(
            parser: isParserShallowEqual(identifier.children[1].children[0]),
            position: 3,
            toString: startsWith('**** ')),
        isProgressFrame(
            parser: isParserShallowEqual(identifier.children[1].children[0]),
            position: 4,
            toString: startsWith('***** ')),
        isProgressFrame(
            parser: isParserShallowEqual(identifier.children[1].children[0]),
            position: 5,
            toString: startsWith('****** ')),
      ]);
    });
    test('labeled', () {
      final frames = <ProgressFrame>[];
      final parser = progress(labeledIdentifier,
          output: frames.add, predicate: (parser) => parser is LabeledParser);
      expect(parser.parse('ab123') is Success, isTrue);
      expect(frames, [
        isProgressFrame(
            parser: isParserShallowEqual(labeledIdentifier.children[0]),
            toString: allOf(startsWith('* '), contains('first')),
            position: 0),
        isProgressFrame(
            parser: isParserShallowEqual(labeledIdentifier.children[1]),
            toString: allOf(startsWith('** '), contains('remaining')),
            position: 1),
      ]);
    });
    test('failure', () {
      final frames = <ProgressFrame>[];
      final parser = progress(identifier, output: frames.add);
      expect(parser.parse('1') is Failure, isTrue);
      expect(frames, [
        isProgressFrame(
            parser: isParserShallowEqual(identifier),
            position: 0,
            toString: startsWith('* ')),
        isProgressFrame(
            parser: isParserShallowEqual(identifier.children[0]),
            position: 0,
            toString: startsWith('* ')),
      ]);
    });
  });
  group('trace', () {
    test('success', () {
      final events = <TraceEvent>[];
      final parser = trace(identifier, output: events.add);
      expect(parser.parse('a') is Success, isTrue);
      expect(events, [
        isTraceEvent(
            parser: isParserShallowEqual(identifier), result: isNull, level: 0),
        isTraceEvent(
            parser: isParserShallowEqual(identifier.children[0]),
            result: isNull,
            level: 1),
        isTraceEvent(
            parser: isParserShallowEqual(identifier.children[0]),
            result: isSuccess(value: 'a'),
            level: 1),
        isTraceEvent(
            parser: isParserShallowEqual(identifier.children[1]),
            result: isNull,
            level: 1),
        isTraceEvent(
            parser: isParserShallowEqual(identifier.children[1].children[0]),
            result: isNull,
            level: 2),
        isTraceEvent(
            parser: isParserShallowEqual(identifier.children[1].children[0]),
            result: isFailure(message: 'letter or digit expected'),
            level: 2),
        isTraceEvent(
            parser: isParserShallowEqual(identifier.children[1]),
            result: isSuccess(value: isEmpty),
            level: 1),
        isTraceEvent(
            parser: isParserShallowEqual(identifier),
            result: isSuccess(),
            level: 0),
      ]);
    });
    test('labeled', () {
      final events = <TraceEvent>[];
      final parser = trace(labeledIdentifier,
          output: events.add, predicate: (parser) => parser is LabeledParser);
      expect(parser.parse('ab123') is Success, isTrue);
      expect(events, [
        isTraceEvent(
            parser: isParserShallowEqual(labeledIdentifier.children[0]),
            result: isNull,
            level: 0),
        isTraceEvent(
            parser: isParserShallowEqual(labeledIdentifier.children[0]),
            result: isSuccess(value: 'a'),
            level: 0),
        isTraceEvent(
            parser: isParserShallowEqual(labeledIdentifier.children[1]),
            result: isNull,
            level: 0),
        isTraceEvent(
            parser: isParserShallowEqual(labeledIdentifier.children[1]),
            result: isSuccess(value: 'b123'.split('')),
            level: 0),
      ]);
    });
    test('failure', () {
      final events = <TraceEvent>[];
      final parser = trace(identifier, output: events.add);
      expect(parser.parse('1') is Failure, isTrue);
      expect(events, [
        isTraceEvent(
            parser: isParserShallowEqual(identifier), result: isNull, level: 0),
        isTraceEvent(
            parser: isParserShallowEqual(identifier.children[0]),
            result: isNull,
            level: 1),
        isTraceEvent(
            parser: isParserShallowEqual(identifier.children[0]),
            result: isFailure(message: 'letter expected'),
            level: 1),
        isTraceEvent(
            parser: isParserShallowEqual(identifier),
            result: isFailure(message: 'letter expected'),
            level: 0),
      ]);
    });
  });
}
