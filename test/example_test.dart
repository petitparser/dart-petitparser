import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

import 'utils/matchers.dart';

void main() {
  final identifier = letter().seq(word().star()).flatten();
  final number = char('-')
      .optional()
      .seq(digit().plus())
      .seq(char('.').seq(digit().plus()).optional())
      .flatten();
  final quoted = char('"').seq(char('"').neg().star()).seq(char('"')).flatten();
  final keyword = string('return')
      .seq(whitespace().plus().flatten())
      .seq(identifier.or(number).or(quoted))
      .map((list) => list.last);
  final javadoc =
      string('/**').seq(string('*/').neg().star()).seq(string('*/')).flatten();
  final multiLine = string('"""')
      .seq((string(r'\"""') | any()).starLazy(string('"""')).flatten())
      .seq(string('"""'))
      .pick(1);
  test('valid identifier', () {
    expect(identifier, isParseSuccess('a', result: 'a'));
    expect(identifier, isParseSuccess('a1', result: 'a1'));
    expect(identifier, isParseSuccess('a12', result: 'a12'));
    expect(identifier, isParseSuccess('ab', result: 'ab'));
    expect(identifier, isParseSuccess('a1b', result: 'a1b'));
  });
  test('incomplete identifier', () {
    expect(identifier, isParseSuccess('a=', result: 'a', position: 1));
    expect(identifier, isParseSuccess('a1-', result: 'a1', position: 2));
    expect(identifier, isParseSuccess('a12+', result: 'a12', position: 3));
    expect(identifier, isParseSuccess('ab ', result: 'ab', position: 2));
  });
  test('invalid identifier', () {
    expect(identifier, isParseFailure('', message: 'letter expected'));
    expect(identifier, isParseFailure('1', message: 'letter expected'));
    expect(identifier, isParseFailure('1a', message: 'letter expected'));
  });
  test('positive number', () {
    expect(number, isParseSuccess('1', result: '1'));
    expect(number, isParseSuccess('12', result: '12'));
    expect(number, isParseSuccess('12.3', result: '12.3'));
    expect(number, isParseSuccess('12.34', result: '12.34'));
  });
  test('negative number', () {
    expect(number, isParseSuccess('-1', result: '-1'));
    expect(number, isParseSuccess('-12', result: '-12'));
    expect(number, isParseSuccess('-12.3', result: '-12.3'));
    expect(number, isParseSuccess('-12.34', result: '-12.34'));
  });
  test('incomplete number', () {
    expect(number, isParseSuccess('1..', result: '1', position: 1));
    expect(number, isParseSuccess('12-', result: '12', position: 2));
    expect(number, isParseSuccess('12.3.', result: '12.3', position: 4));
    expect(number, isParseSuccess('12.34.', result: '12.34', position: 5));
  });
  test('invalid number', () {
    expect(number, isParseFailure('', position: 0, message: 'digit expected'));
    expect(number, isParseFailure('-', position: 1, message: 'digit expected'));
    expect(
        number, isParseFailure('-x', position: 1, message: 'digit expected'));
    expect(number, isParseFailure('.', message: 'digit expected'));
    expect(number, isParseFailure('.1', message: 'digit expected'));
  });
  test('valid string', () {
    expect(quoted, isParseSuccess('""', result: '""'));
    expect(quoted, isParseSuccess('"a"', result: '"a"'));
    expect(quoted, isParseSuccess('"ab"', result: '"ab"'));
    expect(quoted, isParseSuccess('"abc"', result: '"abc"'));
  });
  test('incomplete string', () {
    expect(quoted, isParseSuccess('""x', result: '""', position: 2));
    expect(quoted, isParseSuccess('"a"x', result: '"a"', position: 3));
    expect(quoted, isParseSuccess('"ab"x', result: '"ab"', position: 4));
    expect(quoted, isParseSuccess('"abc"x', result: '"abc"', position: 5));
  });
  test('invalid string', () {
    expect(quoted, isParseFailure('"', position: 1, message: '"\\"" expected'));
    expect(
        quoted, isParseFailure('"a', position: 2, message: '"\\"" expected'));
    expect(
        quoted, isParseFailure('"ab', position: 3, message: '"\\"" expected'));
    expect(quoted, isParseFailure('a"', message: '"\\"" expected'));
    expect(quoted, isParseFailure('ab"', message: '"\\"" expected'));
  });
  test('return statement', () {
    expect(keyword, isParseSuccess('return f', result: 'f'));
    expect(keyword, isParseSuccess('return  f', result: 'f'));
    expect(keyword, isParseSuccess('return foo', result: 'foo'));
    expect(keyword, isParseSuccess('return    foo', result: 'foo'));
    expect(keyword, isParseSuccess('return 1', result: '1'));
    expect(keyword, isParseSuccess('return  1', result: '1'));
    expect(keyword, isParseSuccess('return -2.3', result: '-2.3'));
    expect(keyword, isParseSuccess('return    -2.3', result: '-2.3'));
    expect(keyword, isParseSuccess('return "a"', result: '"a"'));
    expect(keyword, isParseSuccess('return  "a"', result: '"a"'));
  });
  test('invalid statement', () {
    expect(keyword, isParseFailure('retur f', message: '"return" expected'));
    expect(keyword,
        isParseFailure('return1', position: 6, message: 'whitespace expected'));
    expect(keyword,
        isParseFailure('return  _', position: 8, message: '"\\"" expected'));
  });
  test('javadoc', () {
    expect(javadoc, isParseSuccess('/** foo */', result: '/** foo */'));
    expect(javadoc, isParseSuccess('/** * * */', result: '/** * * */'));
  });
  test('multiline', () {
    expect(multiLine, isParseSuccess(r'"""abc"""', result: r'abc'));
    expect(multiLine, isParseSuccess(r'"""abc\n"""', result: r'abc\n'));
    expect(
        multiLine, isParseSuccess(r'"""abc\"""def"""', result: r'abc\"""def'));
  });
}
