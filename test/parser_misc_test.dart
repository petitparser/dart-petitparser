import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart' hide anyOf;

import 'utils/assertions.dart';
import 'utils/matchers.dart';

void main() {
  group('end', () {
    expectParserInvariants(endOfInput());
    test('default', () {
      final parser = char('a').end();
      expect(parser, isParseFailure('', message: '"a" expected'));
      expect(parser, isParseSuccess('a', result: 'a'));
      expect(parser,
          isParseFailure('aa', position: 1, message: 'end of input expected'));
    });
  });
  group('epsilon', () {
    expectParserInvariants(epsilon());
    test('default', () {
      final parser = epsilon();
      expect(parser, isParseSuccess('', result: isNull));
      expect(parser, isParseSuccess('a', result: isNull, position: 0));
    });
  });
  group('failure', () {
    expectParserInvariants(failure<String>());
    test('default', () {
      final parser = failure<String>(message: 'failure');
      expect(parser, isParseFailure('', message: 'failure'));
      expect(parser, isParseFailure('a', message: 'failure'));
    });
  });
  group('label', () {
    expectParserInvariants(any().labeled('anything'));
    test('default', () {
      final parser = char('*').labeled('asterisk');
      expect(parser.label, 'asterisk');
      expect(parser, isParseSuccess('*', result: '*'));
      expect(parser, isParseFailure('a', message: '"*" expected'));
    });
  });
  group('newline', () {
    expectParserInvariants(newline());
    test('default', () {
      final parser = newline();
      expect(parser, isParseSuccess('\n', result: '\n'));
      expect(parser, isParseSuccess('\r\n', result: '\r\n'));
      expect(parser, isParseSuccess('\r', result: '\r'));
      expect(parser, isParseFailure('', message: 'newline expected'));
      expect(parser, isParseFailure('\f', message: 'newline expected'));
    });
  });
  group('position', () {
    expectParserInvariants(position());
    test('default', () {
      final parser = (any().star() & position()).pick(-1);
      expect(parser, isParseSuccess('', result: 0));
      expect(parser, isParseSuccess('a', result: 1));
      expect(parser, isParseSuccess('aa', result: 2));
      expect(parser, isParseSuccess('aaa', result: 3));
    });
  });
}
