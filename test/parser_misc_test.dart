import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/scaffolding.dart';

import 'utils/assertions.dart';
import 'utils/checks.dart';

void main() {
  group('end', () {
    expectParserInvariants(endOfInput());
    test('default', () {
      final parser = char('a').end();
      check(parser).parseFailure('', message: '"a" expected');
      check(parser).parseSuccess('a', result: 'a');
      check(parser)
          .parseFailure('aa', position: 1, message: 'end of input expected');
    });
  });
  group('epsilon', () {
    expectParserInvariants(epsilon());
    test('default', () {
      final parser = epsilon();
      check(parser).parseSuccess('', result: null);
      check(parser).parseSuccess('a', result: null, position: 0);
    });
  });
  group('failure', () {
    expectParserInvariants(failure<String>());
    test('default', () {
      final parser = failure<String>(message: 'failure');
      check(parser).parseFailure('', message: 'failure');
      check(parser).parseFailure('a', message: 'failure');
    });
  });
  group('label', () {
    expectParserInvariants(any().labeled('anything'));
    test('default', () {
      final parser = char('*').labeled('asterisk');
      check(parser.label).equals('asterisk');
      check(parser).parseSuccess('*', result: '*');
      check(parser).parseFailure('a', message: '"*" expected');
    });
  });
  group('newline', () {
    expectParserInvariants(newline());
    test('default', () {
      final parser = newline();
      check(parser).parseSuccess('\n', result: '\n');
      check(parser).parseSuccess('\r\n', result: '\r\n');
      check(parser).parseSuccess('\r', result: '\r');
      check(parser).parseFailure('', message: 'newline expected');
      check(parser).parseFailure('\f', message: 'newline expected');
    });
  });
  group('position', () {
    expectParserInvariants(position());
    test('default', () {
      final parser = (any().star() & position()).pick(-1);
      check(parser).parseSuccess('', result: 0);
      check(parser).parseSuccess('a', result: 1);
      check(parser).parseSuccess('aa', result: 2);
      check(parser).parseSuccess('aaa', result: 3);
    });
  });
}
