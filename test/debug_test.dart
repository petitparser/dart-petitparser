import 'package:checks/checks.dart';
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart' hide anyOf;
import 'package:test/scaffolding.dart';

import 'utils/checks.dart';

final identifier = letter() & word().star();
final labeledIdentifier =
    letter().labeled('first') & word().star().labeled('remaining');

void main() {
  group('profile', () {
    test('success', () {
      final frames = <ProfileFrame>[];
      final parser = profile(identifier, output: frames.add);
      check(parser.parse('ab123')).isA<Success<dynamic>>();
      check(frames).matchesInOrder([
        (f) => f.isProfileFrame(parser: identifier, count: 1),
        (f) => f.isProfileFrame(parser: identifier.children[0], count: 1),
        (f) => f.isProfileFrame(parser: identifier.children[1], count: 1),
        (f) => f.isProfileFrame(
          parser: identifier.children[1].children[0],
          count: 5,
        ),
      ]);
    });
    test('labeled', () {
      final frames = <ProfileFrame>[];
      final parser = profile(
        labeledIdentifier,
        output: frames.add,
        predicate: (parser) => parser is LabeledParser,
      );
      check(parser.parse('ab123')).isA<Success<dynamic>>();
      check(frames).matchesInOrder([
        (f) => f.isProfileFrame(
          parser: labeledIdentifier.children[0],
          toString: (it) => it.contains('first'),
          count: 1,
        ),
        (f) => f.isProfileFrame(
          parser: labeledIdentifier.children[1],
          toString: (it) => it.contains('remaining'),
          count: 1,
        ),
      ]);
    });
    test('failure', () {
      final frames = <ProfileFrame>[];
      final parser = profile(identifier, output: frames.add);
      check(parser.parse('1')).isA<Failure>();
      check(frames).matchesInOrder([
        (f) => f.isProfileFrame(parser: identifier, count: 1),
        (f) => f.isProfileFrame(parser: identifier.children[0], count: 1),
        (f) => f.isProfileFrame(parser: identifier.children[1]),
        (f) => f.isProfileFrame(parser: identifier.children[1].children[0]),
      ]);
    });
  });
  group('progress', () {
    test('success', () {
      final frames = <ProgressFrame>[];
      final parser = progress(identifier, output: frames.add);
      check(parser.parse('ab123')).isA<Success<dynamic>>();
      check(frames).matchesInOrder([
        (f) => f.isProgressFrame(
          parser: identifier,
          position: 0,
          toString: (it) => it.startsWith('* '),
        ),
        (f) => f.isProgressFrame(
          parser: identifier.children[0],
          position: 0,
          toString: (it) => it.startsWith('* '),
        ),
        (f) => f.isProgressFrame(
          parser: identifier.children[1],
          position: 1,
          toString: (it) => it.startsWith('** '),
        ),
        (f) => f.isProgressFrame(
          parser: identifier.children[1].children[0],
          position: 1,
          toString: (it) => it.startsWith('** '),
        ),
        (f) => f.isProgressFrame(
          parser: identifier.children[1].children[0],
          position: 2,
          toString: (it) => it.startsWith('*** '),
        ),
        (f) => f.isProgressFrame(
          parser: identifier.children[1].children[0],
          position: 3,
          toString: (it) => it.startsWith('**** '),
        ),
        (f) => f.isProgressFrame(
          parser: identifier.children[1].children[0],
          position: 4,
          toString: (it) => it.startsWith('***** '),
        ),
        (f) => f.isProgressFrame(
          parser: identifier.children[1].children[0],
          position: 5,
          toString: (it) => it.startsWith('****** '),
        ),
      ]);
    });
    test('labeled', () {
      final frames = <ProgressFrame>[];
      final parser = progress(
        labeledIdentifier,
        output: frames.add,
        predicate: (parser) => parser is LabeledParser,
      );
      check(parser.parse('ab123')).isA<Success<dynamic>>();
      check(frames).matchesInOrder([
        (f) => f.isProgressFrame(
          parser: labeledIdentifier.children[0],
          toString: (it) => it
            ..startsWith('* ')
            ..contains('first'),
          position: 0,
        ),
        (f) => f.isProgressFrame(
          parser: labeledIdentifier.children[1],
          toString: (it) => it
            ..startsWith('** ')
            ..contains('remaining'),
          position: 1,
        ),
      ]);
    });
    test('failure', () {
      final frames = <ProgressFrame>[];
      final parser = progress(identifier, output: frames.add);
      check(parser.parse('1')).isA<Failure>();
      check(frames).matchesInOrder([
        (f) => f.isProgressFrame(
          parser: identifier,
          position: 0,
          toString: (it) => it.startsWith('* '),
        ),
        (f) => f.isProgressFrame(
          parser: identifier.children[0],
          position: 0,
          toString: (it) => it.startsWith('* '),
        ),
      ]);
    });
  });
  group('trace', () {
    test('success', () {
      final events = <TraceEvent>[];
      final parser = trace(identifier, output: events.add);
      check(parser.parse('a')).isA<Success<dynamic>>();
      check(events).matchesInOrder([
        (e) => e.isTraceEvent(parser: identifier, result: null, level: 0),
        (e) => e.isTraceEvent(
          parser: identifier.children[0],
          result: null,
          level: 1,
        ),
        (e) => e.isTraceEvent(
          parser: identifier.children[0],
          whichResult: (it) => it.isSuccess(value: 'a'),
          level: 1,
        ),
        (e) => e.isTraceEvent(
          parser: identifier.children[1],
          result: null,
          level: 1,
        ),
        (e) => e.isTraceEvent(
          parser: identifier.children[1].children[0],
          result: null,
          level: 2,
        ),
        (e) => e.isTraceEvent(
          parser: identifier.children[1].children[0],
          whichResult: (it) =>
              it.isFailure(message: 'letter or digit expected'),
          level: 2,
        ),
        (e) => e.isTraceEvent(
          parser: identifier.children[1],
          whichResult: (it) => it.isSuccess(value: []),
          level: 1,
        ),
        (e) => e.isTraceEvent(
          parser: identifier,
          whichResult: (it) => it.isSuccess(),
          level: 0,
        ),
      ]);
    });
    test('labeled', () {
      final events = <TraceEvent>[];
      final parser = trace(
        labeledIdentifier,
        output: events.add,
        predicate: (parser) => parser is LabeledParser,
      );
      check(parser.parse('ab123')).isA<Success<dynamic>>();
      check(events).matchesInOrder([
        (e) => e.isTraceEvent(
          parser: labeledIdentifier.children[0],
          result: null,
          level: 0,
        ),
        (e) => e.isTraceEvent(
          parser: labeledIdentifier.children[0],
          whichResult: (it) => it.isSuccess(value: 'a'),
          level: 0,
        ),
        (e) => e.isTraceEvent(
          parser: labeledIdentifier.children[1],
          result: null,
          level: 0,
        ),
        (e) => e.isTraceEvent(
          parser: labeledIdentifier.children[1],
          whichResult: (it) => it.isSuccess(value: 'b123'.split('')),
          level: 0,
        ),
      ]);
    });
    test('failure', () {
      final events = <TraceEvent>[];
      final parser = trace(identifier, output: events.add);
      check(parser.parse('1')).isA<Failure>();
      check(events).matchesInOrder([
        (e) => e.isTraceEvent(parser: identifier, result: null, level: 0),
        (e) => e.isTraceEvent(
          parser: identifier.children[0],
          result: null,
          level: 1,
        ),
        (e) => e.isTraceEvent(
          parser: identifier.children[0],
          whichResult: (it) => it.isFailure(message: 'letter expected'),
          level: 1,
        ),
        (e) => e.isTraceEvent(
          parser: identifier,
          whichResult: (it) => it.isFailure(message: 'letter expected'),
          level: 0,
        ),
      ]);
    });
  });
}
