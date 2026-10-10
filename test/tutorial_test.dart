import 'dart:math' as math;

import 'package:checks/checks.dart';
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/scaffolding.dart';

import 'utils/checks.dart';

class ExpressionGrammarDefinition extends GrammarDefinition<num> {
  @override
  Parser<num> start() => ref0(term).end();

  Parser<num> term() => [ref0(add), ref0(prod)].toChoiceParser();

  Parser<num> add() =>
      ref0(prod)
          .then(char('+').trim())
          .then(ref0(term))
          .map3((left, _, right) => left + right);

  Parser<num> prod() => [ref0(mul), ref0(prim)].toChoiceParser();

  Parser<num> mul() =>
      ref0(prim)
          .then(char('*').trim())
          .then(ref0(prod))
          .map3((left, _, right) => left * right);

  Parser<num> prim() => [ref0(parens), ref0(number)].toChoiceParser();

  Parser<num> parens() =>
      char('(')
          .trim()
          .then(ref0(term))
          .then(char(')').trim())
          .map3((_, value, _) => value);

  Parser<num> number() => digit().plus().flatten().trim().map(num.parse);
}

void main() {
  test('quick start', () {
    final key = letter().plus().flatten();
    final value = digit().plus().flatten().map(int.parse);
    final entry = key.trim().skip(after: char('=')).then(value.trim());

    final parser = entry.map2((k, v) => (key: k, value: v));
    final result = parser.parse('port = 8080');

    check(result.value).equals((key: 'port', value: 8080));
  });

  test('primitive parsers', () {
    check(char('a').parse('a').value).equals('a');
    check(string('dart').parse('dart').value).equals('dart');
    check(digit().parse('7').value).equals('7');
    check(letter().parse('x').value).equals('x');
    check(word().parse('_').value).equals('_');
    check(whitespace().parse(' ').value).equals(' ');
    check(pattern('0-9a-fA-F').parse('f').value).equals('f');
    check(any().parse('!').value).equals('!');
  });

  test('combining parsers', () {
    final pair = letter().then(digit());
    check(pair.parse('a1').value).equals(('a', '1'));

    final id = [letter(), digit()].toChoiceParser();
    check(id.parse('a').value).equals('a');
    check(id.parse('1').value).equals('1');

    final stars = letter().star();
    check(stars.parse('abc').value).deepEquals(['a', 'b', 'c']);

    final pluses = digit().plus();
    check(pluses.parse('123').value).deepEquals(['1', '2', '3']);

    final opt = char('-').optional();
    check(opt.parse('-').value).equals('-');
    check(opt.parse('+').value).isNull();

    final exact = letter().times(3);
    check(exact.parse('abc').value).deepEquals(['a', 'b', 'c']);

    final separated = digit().plusSeparated(char(','));
    check(separated.parse('1,2,3').value.elements).deepEquals(['1', '2', '3']);
  });

  test('transformations', () {
    final flattened = digit().plus().flatten();
    check(flattened.parse('123').value).equals('123');

    final number = digit().plus().flatten().map(int.parse);
    check(number.parse('42').value).equals(42);

    final trimmed = string('true').trim();
    check(trimmed.parse('  true  ').value).equals('true');

    final pair = letter().then(digit());
    final mapped = pair.map2((l, d) => '$l:$d');
    check(mapped.parse('x9').value).equals('x:9');

    final triple = (
      letter(),
      char(':'),
      digit(),
    ).toSequenceParser().map3((l, sep, d) => '$l$sep$d');
    check(triple.parse('a:1').value).equals('a:1');
  });

  test('handling results', () {
    final parser = digit().plus().flatten().map(int.parse);

    final output = <String>[];
    void handleResult(Result<int> result) {
      switch (result) {
        case Success(value: final value):
          output.add('Parsed $value');
        case Failure(message: final message, position: final position):
          output.add('Error at $position: $message');
      }
    }

    handleResult(parser.parse('123'));
    handleResult(parser.parse('abc'));
    check(output).deepEquals(['Parsed 123', 'Error at 0: digit expected']);

    check(parser.accept('123')).isTrue();
    check(parser.accept('abc')).isFalse();

    final words = letter().plus().flatten();
    check(words.allMatches('two words 123')).deepEquals(['two', 'words']);
  });

  test('delimited lists', () {
    final number = digit().plus().flatten().map(int.parse);
    final numbers = number
        .plusSeparated(char(',').trim())
        .map((list) => list.elements);

    final result = numbers.parse('1, 2, 3');
    check(result.value).deepEquals([1, 2, 3]);
  });

  test('expression builder', () {
    final builder = ExpressionBuilder<num>();

    builder.primitive(
      digit()
          .plus()
          .then(char('.').then(digit().plus()).optional())
          .flatten()
          .trim()
          .map(num.parse),
    );

    builder.group().wrapper(
      char('(').trim(),
      char(')').trim(),
      (left, value, right) => value,
    );

    builder.group().prefix(char('-').trim(), (op, value) => -value);

    builder.group().right(
      char('^').trim(),
      (left, op, right) => math.pow(left, right),
    );

    builder.group()
      ..left(char('*').trim(), (left, op, right) => left * right)
      ..left(char('/').trim(), (left, op, right) => left / right);

    builder.group()
      ..left(char('+').trim(), (left, op, right) => left + right)
      ..left(char('-').trim(), (left, op, right) => left - right);

    final parser = builder.build().end();

    check(parser.parse('1 + 2 * 3').value).equals(7);
    check(parser.parse('(1 + 2) * 3').value).equals(9);
    check(parser.parse('2 ^ 2 ^ 3').value).equals(256);
    check(parser.parse('-8 + 2').value).equals(-6);
  });

  test('recursive structures', () {
    final value = undefined<Object>();

    final array = char('[')
        .trim()
        .then(value.starSeparated(char(',').trim()))
        .then(char(']').trim())
        .map3((open, elements, close) => elements.elements);

    final number = digit().plus().flatten().map(int.parse);

    value.set([number, array].toChoiceParser());

    final parser = value.end();

    check(parser.parse('[1, [2, 3], 4]').value)
        .isA<List<dynamic>>()
        .deepEquals([
          1,
          [2, 3],
          4,
        ]);
  });

  test('large grammars', () {
    final definition = ExpressionGrammarDefinition();
    final parser = definition.build();
    check(parser.parse('1 + 2 * 3').value).equals(7);
    check(parser.parse('(1 + 2) * 3').value).equals(9);

    final numberParser = definition.buildFrom(ref0(definition.number));
    check(numberParser.parse('42').value).equals(42);
  });

  test('debugging parser', () {
    final output = <TraceEvent>[];
    final parser = letter().then(digit());
    trace(parser, output: output.add).parse('a1');
    check(output.map((each) => each.toString())).deepEquals([
      'SequenceParser2<String, String>',
      '  SingleCharacterParser[letter expected]',
      '  Success<String>[1:2]: a',
      '  SingleCharacterParser[digit expected]',
      '  Success<String>[1:3]: 1',
      'Success<(String, String)>[1:3]: (a, 1)',
    ]);
  }, skip: !hasAssertionsEnabled());

  test('tokens and positions', () {
    final id = letter().plus().flatten().token();
    final token = id.parse('hello').value;
    check(token.value).equals('hello');
    check(token.start).equals(0);
    check(token.stop).equals(5);
    check(token.line).equals(1);
    check(token.column).equals(1);
  });

  test('lookahead', () {
    final keyword = string('let').skip(after: word().not());
    check(keyword.parse('let').value).equals('let');
    check(keyword.accept('letter')).isFalse();
  });

  test('lazy repetition', () {
    final comment = string('/*')
        .then(any().starLazy(string('*/')).flatten())
        .then(string('*/'))
        .map3((start, body, end) => body);
    check(comment.parse('/* note */').value).equals(' note ');
  });

  test('linter', () {
    final parser = letter().plus();
    check(linter(parser)).isEmpty();
  });
}
