import 'dart:math' as math;

import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

import 'utils/matchers.dart';

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

    expect(result.value, (key: 'port', value: 8080));
  });

  test('primitive parsers', () {
    expect(char('a').parse('a').value, 'a');
    expect(string('dart').parse('dart').value, 'dart');
    expect(digit().parse('7').value, '7');
    expect(letter().parse('x').value, 'x');
    expect(word().parse('_').value, '_');
    expect(whitespace().parse(' ').value, ' ');
    expect(pattern('0-9a-fA-F').parse('f').value, 'f');
  });

  test('combining parsers', () {
    final pair = letter().then(digit());
    expect(pair.parse('a1').value, ('a', '1'));

    final id = [letter(), digit()].toChoiceParser();
    expect(id.parse('a').value, 'a');
    expect(id.parse('1').value, '1');

    final stars = letter().star();
    expect(stars.parse('abc').value, ['a', 'b', 'c']);

    final pluses = digit().plus();
    expect(pluses.parse('123').value, ['1', '2', '3']);

    final opt = char('-').optional();
    expect(opt.parse('-').value, '-');
    expect(opt.parse('+').value, isNull);

    final exact = letter().times(3);
    expect(exact.parse('abc').value, ['a', 'b', 'c']);
  });

  test('transformations', () {
    final number = digit().plus().flatten().map(int.parse);
    expect(number.parse('42').value, 42);

    final trimmed = string('true').trim();
    expect(trimmed.parse('  true  ').value, 'true');

    final pair = letter().then(digit());
    final mapped = pair.map2((l, d) => '$l:$d');
    expect(mapped.parse('x9').value, 'x:9');

    final triple = (
      letter(),
      char(':'),
      digit(),
    ).toSequenceParser().map3((l, sep, d) => '$l$sep$d');
    expect(triple.parse('a:1').value, 'a:1');
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
    expect(output, ['Parsed 123', 'Error at 0: digit expected']);

    expect(parser.accept('123'), isTrue);
    expect(parser.accept('abc'), isFalse);

    final words = letter().plus().flatten();
    expect(words.allMatches('two words 123'), ['two', 'words']);
  });

  test('delimited lists', () {
    final number = digit().plus().flatten().map(int.parse);
    final numbers = number
        .plusSeparated(char(',').trim())
        .map((list) => list.elements);

    final result = numbers.parse('1, 2, 3');
    expect(result.value, [1, 2, 3]);
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

    expect(parser.parse('1 + 2 * 3').value, 7);
    expect(parser.parse('(1 + 2) * 3').value, 9);
    expect(parser.parse('2 ^ 2 ^ 3').value, 256);
    expect(parser.parse('-8 + 2').value, -6);
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

    expect(parser.parse('[1, [2, 3], 4]').value, [
      1,
      [2, 3],
      4,
    ]);
  });

  test('large grammars', () {
    final definition = ExpressionGrammarDefinition();
    final parser = definition.build();
    expect(parser.parse('1 + 2 * 3').value, 7);
    expect(parser.parse('(1 + 2) * 3').value, 9);

    final numberParser = definition.buildFrom(ref0(definition.number));
    expect(numberParser.parse('42').value, 42);
  });

  test('debugging parser', () {
    final output = <TraceEvent>[];
    final parser = letter().then(digit());
    trace(parser, output: output.add).parse('a1');
    expect(output.map((each) => each.toString()), [
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
    expect(token.value, 'hello');
    expect(token.start, 0);
    expect(token.stop, 5);
    expect(token.line, 1);
    expect(token.column, 1);
  });

  test('lookahead', () {
    final keyword = string('let').skip(after: word().not());
    expect(keyword.parse('let').value, 'let');
    expect(keyword.accept('letter'), isFalse);
  });

  test('lazy repetition', () {
    final comment = string('/*')
        .then(any().starLazy(string('*/')).flatten())
        .then(string('*/'))
        .map3((start, body, end) => body);
    expect(comment.parse('/* note */').value, ' note ');
  });

  test('linter', () {
    final parser = letter().plus();
    expect(linter(parser), isEmpty);
  });
}
