import 'dart:math';

import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart' hide anyOf;

import 'utils/matchers.dart';

typedef Evaluator = num Function(num value);

Parser element() => char('(').seq(ref0(content)).seq(char(')'));

Parser content() => (ref0(element) | any()).star();
final nestedParser = resolve(ref0(content)).flatten().end();

class ParensGrammar extends GrammarDefinition {
  @override
  Parser start() => char('(') & ref0(start) & char(')') | epsilon();
}

class NestedGrammar1 {
  Parser start() => ref0(term).end();
  Parser term() => ref0(nestedTerm) | ref0(singleCharacter);
  Parser nestedTerm() =>
      char('(').map((value) => "'$value' (nestedTerm)") &
      ref0(term) &
      char(')').map((value) => "'$value' (nestedTerm)");
  Parser singleCharacter() =>
      char('(').map((value) => "'$value' (singleCharacter)") |
      char(')').map((value) => "'$value' (singleCharacter)") |
      char('0').map((value) => "'$value' (singleCharacter)");
}

class NestedGrammar2 {
  Parser start() => ref0(term).end();
  Parser term() => (ref0(nestedTerm) | ref0(singleCharacter)).plus();
  Parser nestedTerm() =>
      char('(').map((value) => "'$value' (nestedTerm)") &
      ref0(term) &
      char(')').map((value) => "'$value' (nestedTerm)");
  Parser singleCharacter() =>
      char('(').map((value) => "'$value' (singleCharacter)") |
      char(')').map((value) => "'$value' (singleCharacter)") |
      char('0').map((value) => "'$value' (singleCharacter)");
}

class NestedGrammar3 {
  Parser start() => ref0(term).end();
  Parser term() => (ref0(nestedTerm) | ref0(singleCharacter)).plus();
  Parser nestedTerm() =>
      char('(').map((value) => "'$value' (nestedTerm)") &
      ref0(term) &
      char(')').map((value) => "'$value' (nestedTerm)");
  Parser singleCharacter() =>
      char('(').map((value) => "'$value' (singleCharacter)") |
      char('0').map((value) => "'$value' (singleCharacter)");
}

void main() {
  test('flatten().trim()', () {
    final parser = word().plus().flatten().trim();
    expect(parser, isParseSuccess('ab1', result: 'ab1'));
    expect(parser, isParseSuccess(' ab1 ', result: 'ab1'));
    expect(parser, isParseSuccess('  ab1  ', result: 'ab1'));
  });
  test('trim().flatten()', () {
    final parser = word().plus().trim().flatten();
    expect(parser, isParseSuccess('ab1', result: 'ab1'));
    expect(parser, isParseSuccess(' ab1 ', result: ' ab1 '));
    expect(parser, isParseSuccess('  ab1  ', result: '  ab1  '));
  });
  group('separatedBy()', () {
    void testWith(String name, Parser<List<T>> Function<T>(Parser<T>) builder) {
      test(name, () {
        final string = letter();
        final stringList = builder(string);
        expect(stringList, const TypeMatcher<Parser<List<String>>>());
        expect(stringList, isParseSuccess('a,b,c', result: ['a', 'b', 'c']));

        final integer = digit().map(int.parse);
        final integerList = builder(integer);
        expect(integerList, const TypeMatcher<Parser<List<int>>>());
        expect(integerList, isParseSuccess('1,2,3', result: [1, 2, 3]));

        final mixed = string | integer;
        final mixedList = builder(mixed);
        expect(mixedList, const TypeMatcher<Parser<List<dynamic>>>());
        expect(mixedList, isParseSuccess('1,a,2', result: [1, 'a', 2]));
      });
    }

    Parser<List<T>> typeParam<T>(Parser<T> parser) =>
        // ignore: deprecated_member_use_from_same_package
        parser.separatedBy<T>(char(','), includeSeparators: false);
    Parser<List<T>> castList<T>(Parser<T> parser) =>
        // ignore: deprecated_member_use_from_same_package, inference_failure_on_function_invocation
        parser.separatedBy(char(','), includeSeparators: false).castList<T>();
    Parser<List<T>> smartCompiler<T>(Parser<T> parser) =>
        // ignore: deprecated_member_use_from_same_package
        parser.separatedBy(char(','), includeSeparators: false);

    testWith('with list created using desired type', typeParam);
    testWith('with generic list cast to desired type', castList);
    testWith('with compiler inferring desired type', smartCompiler);
  });
  test('parse padded and limited number', () {
    final parser =
        digit().repeat(2).flatten().callCC<String>((continuation, context) {
      final result = continuation(context);
      if (result is Success && int.parse(result.value) > 31) {
        return context.failure('00-31 expected');
      } else {
        return result;
      }
    });
    expect(parser, isParseSuccess('00', result: '00'));
    expect(parser, isParseSuccess('24', result: '24'));
    expect(parser, isParseSuccess('31', result: '31'));
    expect(parser, isParseFailure('32', message: '00-31 expected'));
    expect(parser, isParseFailure('3', position: 1, message: 'digit expected'));
  });
  group('date format parser', () {
    final day = 'dd'.toParser().map((token) => digit()
        .repeat(2)
        .flatten()
        .map((value) => MapEntry(#day, int.parse(value))));
    final month = 'mm'.toParser().map((token) => digit()
        .repeat(2)
        .flatten()
        .map((value) => MapEntry(#month, int.parse(value))));
    final year = 'yyyy'.toParser().map((token) => digit()
        .repeat(4)
        .flatten()
        .map((value) => MapEntry(#year, int.parse(value))));

    final spacing = whitespace().map((token) =>
        whitespace().star().map((value) => const MapEntry(#unused, 0)));
    final verbatim = any().map(
        (token) => token.toParser().map((value) => const MapEntry(#unused, 0)));

    final entries = [day, month, year, spacing, verbatim].toChoiceParser();
    final format = entries
        .star()
        .end()
        .map((parsers) => parsers.toSequenceParser().map((entries) {
              final arguments = Map.fromEntries(entries);
              return DateTime(
                arguments[#year] ?? DateTime.now().year,
                arguments[#month] ?? DateTime.january,
                arguments[#day] ?? 1,
              );
            }));

    test('iso', () {
      final date = format.parse('yyyy-mm-dd').value;
      expect(date, isParseSuccess('1980-06-11', result: DateTime(1980, 6, 11)));
      expect(date, isParseSuccess('1982-08-24', result: DateTime(1982, 8, 24)));
      expect(date,
          isParseFailure('1984.10.31', position: 4, message: '"-" expected'));
    });
    test('europe', () {
      final date = format.parse('dd.mm.yyyy').value;
      expect(date, isParseSuccess('11.06.1980', result: DateTime(1980, 6, 11)));
      expect(date, isParseSuccess('24.08.1982', result: DateTime(1982, 8, 24)));
      expect(
          date, isParseFailure('1984', position: 2, message: '"." expected'));
    });
    test('us', () {
      final date = format.parse('mm/dd/yyyy').value;
      expect(date, isParseSuccess('06/11/1980', result: DateTime(1980, 6, 11)));
      expect(date, isParseSuccess('08/24/1982', result: DateTime(1982, 8, 24)));
      expect(date, isParseFailure('Hello', message: 'digit expected'));
    });
  });
  test('stackoverflow.com/questions/64670722', () {
    final delimited = any().callCC<String>((continuation, context) {
      final delimiter = continuation(context).value.toParser();
      final parser = [
        delimiter,
        delimiter.neg().star().flatten(),
        delimiter,
      ].toSequenceParser().pick(1);
      return parser.parseOn(context);
    });
    expect(delimited, isParseSuccess('"hello"', result: 'hello'));
    expect(delimited, isParseSuccess('/hello/', result: 'hello'));
    expect(delimited, isParseSuccess(',hello,', result: 'hello'));
    expect(delimited, isParseSuccess('xhellox', result: 'hello'));
    expect(
        delimited, isParseFailure('abc', position: 3, message: '"a" expected'));
  });
  test('function evaluator', () {
    final builder = ExpressionBuilder<Evaluator>();
    builder
      ..primitive(digit()
          .plus()
          .seq(char('.').seq(digit().plus()).optional())
          .flatten()
          .trim()
          .map((a) {
        final number = num.parse(a);
        return (num value) => number;
      }))
      ..primitive(char('x').trim().map((_) => (value) => value));
    builder
        .group()
        .wrapper(char('(').trim(), char(')').trim(), (_, a, __) => a);
    // negation is a prefix operator
    builder
        .group()
        .prefix(char('-').trim(), (_, a) => (num value) => -a(value));
    // power is right-associative
    builder.group().right(
        char('^').trim(), (a, _, b) => (num value) => pow(a(value), b(value)));
    // multiplication and addition are left-associative
    builder.group()
      ..left(char('*').trim(), (a, _, b) => (num value) => a(value) * b(value))
      ..left(char('/').trim(), (a, _, b) => (num value) => a(value) / b(value));
    builder.group()
      ..left(char('+').trim(), (a, _, b) => (num value) => a(value) + b(value))
      ..left(char('-').trim(), (a, _, b) => (num value) => a(value) - b(value));
    final parser = builder.build().end();

    final expression = parser.parse('5 * x ^ 3 - 2').value;
    expect(expression(-2), -42);
    expect(expression(-1), -7);
    expect(expression(0), -2);
    expect(expression(1), 3);
    expect(expression(2), 38);
  });
  test('stackoverflow.com/q/67617000/82303', () {
    expect(nestedParser, isParseSuccess('()', result: '()'));
    expect(nestedParser, isParseSuccess('(a)', result: '(a)'));
    expect(nestedParser, isParseSuccess('(a()b)', result: '(a()b)'));
    expect(nestedParser, isParseSuccess('(a(b)c)', result: '(a(b)c)'));
    expect(nestedParser, isParseSuccess('(a()b(cd))', result: '(a()b(cd))'));
  });
  group('github.com/petitparser/dart-petitparser/issues/109', () {
    // The digit defines how many characters are read by the data parser.
    Parser<int> buildMetadataParser() => digit().flatten().map(int.parse);
    Parser<String> buildDataParser(int count) => any().repeat(count).flatten();

    const input = '4database';
    test('split', () {
      final metadataParser = buildMetadataParser();
      final metadataResult = metadataParser.parse(input);
      final dataParser = buildDataParser(metadataResult.value);
      final dataResult = dataParser.parseOn(metadataResult);
      expect(dataResult.value, 'data');
    });
    test('continuation', () {
      final parser = buildMetadataParser().callCC((continuation, context) {
        final metadataResult = continuation(context);
        final dataParser = buildDataParser(metadataResult.value);
        return dataParser.parseOn(metadataResult);
      });
      expect(parser.parse(input).value, 'data');
    });
  });
  group('stackoverflow.com/questions/68105573', () {
    const firstInput = '(use = "official").empty()';
    const secondInput = '((5 + 5) * 5) + 5';

    test('greedy', () {
      final parser =
          char('(') & any().starGreedy(char(')')).flatten() & char(')');
      expect(parser.parse(firstInput).value,
          ['(', 'use = "official").empty(', ')']);
      expect(parser.parse(secondInput).value, ['(', '(5 + 5) * 5', ')']);
    });
    test('lazy', () {
      final parser =
          char('(') & any().starLazy(char(')')).flatten() & char(')');
      expect(parser.parse(firstInput).value, ['(', 'use = "official"', ')']);
      expect(parser.parse(secondInput).value, ['(', '(5 + 5', ')']);
    });
    test('recursive', () {
      final inner = undefined<Object?>();
      final parser =
          char('(') & inner.starLazy(char(')')).flatten() & char(')');
      inner.set(parser | any());
      expect(parser.parse(firstInput).value, ['(', 'use = "official"', ')']);
      expect(parser.parse(secondInput).value, ['(', '(5 + 5) * 5', ')']);
    });
    test('recursive (better)', () {
      final inner = undefined<Object?>();
      final parser = char('(') & inner.star().flatten() & char(')');
      inner.set(parser | pattern('^)'));
      expect(parser.parse(firstInput).value, ['(', 'use = "official"', ')']);
      expect(parser.parse(secondInput).value, ['(', '(5 + 5) * 5', ')']);
    });
  });
  group('github.com/petitparser/dart-petitparser/issues/112', () {
    final inner = digit().repeat(2);
    test('original', () {
      final parser = inner.callCC<List<String>>((continuation, context) {
        final result = continuation(context);
        if (result is Success && result.value[0] != result.value[1]) {
          return context.failure('values do not match');
        } else {
          return result;
        }
      });
      expect(parser, isParseSuccess('11', result: ['1', '1']));
      expect(parser, isParseSuccess('22', result: ['2', '2']));
      expect(parser, isParseSuccess('33', result: ['3', '3']));
      expect(
          parser, isParseFailure('1', position: 1, message: 'digit expected'));
      expect(parser, isParseFailure('12', message: 'values do not match'));
      expect(parser, isParseFailure('21', message: 'values do not match'));
    });
    test('where', () {
      final parser = inner.where((value) => value[0] == value[1],
          factory: (context, success) =>
              context.failure('values do not match'));
      expect(parser, isParseSuccess('11', result: ['1', '1']));
      expect(parser, isParseSuccess('22', result: ['2', '2']));
      expect(parser, isParseSuccess('33', result: ['3', '3']));
      expect(
          parser, isParseFailure('1', position: 1, message: 'digit expected'));
      expect(parser, isParseFailure('12', message: 'values do not match'));
      expect(parser, isParseFailure('21', message: 'values do not match'));
    });
  });
  test('github.com/petitparser/dart-petitparser/issues/121', () {
    final parser = ((letter() | char('_')) &
            (letter() | digit() | anyOf('_- ()')).star() &
            char('.').not('end of id expected'))
        .flatten();
    expect(parser, isParseSuccess('foo', result: 'foo'));
    expect(parser,
        isParseFailure('foo.1', message: 'end of id expected', position: 3));
  });
  test('github.com/petitparser/dart-petitparser/issues/126', () {
    final parser = ParensGrammar().build();
    expect(parser, isParseSuccess('', result: null));
    expect(parser, isParseSuccess('()', result: ['(', null, ')']));
    expect(
        parser,
        isParseSuccess('(())', result: [
          '(',
          ['(', null, ')'],
          ')'
        ]));
    expect(
        parser,
        isParseSuccess('((()))', result: [
          '(',
          [
            '(',
            ['(', null, ')'],
            ')'
          ],
          ')'
        ]));
  });
  group('stackoverflow.com/questions/73260748', () {
    test('Case 1', () {
      final parser = resolve(NestedGrammar1().start());
      expect(
          parser,
          isParseSuccess('(0)', result: [
            "'(' (nestedTerm)",
            "'0' (singleCharacter)",
            "')' (nestedTerm)",
          ]));
    });
    test('Case 2', () {
      final parser = resolve(NestedGrammar2().start());
      expect(
          parser,
          isParseSuccess('(0)', result: [
            "'(' (singleCharacter)",
            "'0' (singleCharacter)",
            "')' (singleCharacter)",
          ]));
    });
    test('Case 3', () {
      final parser = resolve(NestedGrammar3().start());
      expect(
          parser,
          isParseSuccess('(0)', result: [
            [
              "'(' (nestedTerm)",
              ["'0' (singleCharacter)"],
              "')' (nestedTerm)",
            ]
          ]));
    });
  });
  group('stackoverflow.com/questions/75278583', () {
    final primitive =
        (uppercase() & char('|') & digit().plus() & char('|') & uppercase())
            .flatten()
            .trim();
    final parsers = {
      'poster': (() {
        final inner = undefined<dynamic>();
        final paren = char('(').trim() & inner.star() & char(')').trim();
        inner.set(paren | pattern('^)'));
        return inner.end();
      })(),
      'improved': (() {
        final outer = undefined<dynamic>();
        final inner = undefined<dynamic>();
        final operator = string('&&') | string('||');
        outer.set(inner.plusSeparated(operator));
        final paren = char('(').trim() & outer & char(')').trim();
        inner.set(paren | primitive);
        return outer.end();
      })(),
      'expression': (() {
        final builder = ExpressionBuilder<Object>();
        builder.primitive(primitive);
        builder.group().wrapper(
            char('(').trim(), char(')').trim(), (l, v, r) => [l, v, r]);
        builder.group()
          ..left(string('&&').trim(), (a, op, b) => [a, '&&', b])
          ..left(string('||').trim(), (a, op, b) => [a, '||', b]);
        return builder.build().end();
      })(),
    };
    final inputs = {
      'single': '(S|69|L)',
      '&&': '(S|69|L && S|69|L)',
      '||': '(S|69|L || S|69|L)',
      'short': '((S|69|L || S|69|L) || S|69|L)',
      'long': '(((S|69|L || S|69|R || S|72|L || S|72|R) && ((S|62|L && (S|78|L '
          '|| S|55|L) && (S|77|L || S|1|L)) || (S|62|R && (S|78|R || S|55|R) &&'
          ' (S|77|R || S|1|R)))) && (M|34|L || M|34|R) && (((M|40|L && M|39|L &'
          '& M|36|L) || (M|40|R && M|39|R && M|36|R)) || ((M|38|L && M|36|L && '
          'M|37|L) || (M|38|R && M|36|R && M|37|R))))',
    };
    for (final input in inputs.entries) {
      for (final parser in parsers.entries) {
        test('${parser.key} with ${input.key}', () {
          expect(parser.value.accept(input.value), isTrue);
        });
      }
    }
  });
  group('stackoverflow.com/questions/75503464', () {
    final builder = ExpressionBuilder<Object?>();
    final primitive =
        seq5(uppercase(), char('|'), digit().plus(), char('|'), uppercase())
            .flatten('value expected')
            .trim();
    builder.primitive(primitive);
    builder.group().wrapper(char('(').trim(), char(')').trim(), (l, v, r) => v);
    builder.group()
      ..left(string('&&').trim(), (a, op, b) => ['&&', a, b])
      ..left(string('||').trim(), (a, op, b) => ['||', a, b]);
    final parser = builder.build().end();
    test('success', () {
      expect(parser, isParseSuccess('S|69|L', result: 'S|69|L'));
      expect(parser, isParseSuccess('(S|69|L)', result: 'S|69|L'));
      expect(
          parser,
          isParseSuccess('S|69|L && S|69|R',
              result: ['&&', 'S|69|L', 'S|69|R']));
      expect(
          parser,
          isParseSuccess('S|69|L || S|69|R',
              result: ['||', 'S|69|L', 'S|69|R']));
    });
    test('value error', () {
      expect(parser,
          isParseFailure('S|fail|L', position: 0, message: 'value expected'));
      expect(parser,
          isParseFailure('(S|fail|L)', position: 0, message: 'value expected'));
      expect(
          parser,
          isParseFailure('S|69|L && S|fail|R',
              position: 7, message: 'end of input expected'));
      expect(
          parser,
          isParseFailure('S|69|L || S|fail|R',
              position: 7, message: 'end of input expected'));
    });
    test('other error', () {
      expect(parser,
          isParseFailure('(S|69|L', position: 0, message: 'value expected'));
      expect(
          parser,
          isParseFailure('S|69|L &',
              position: 7, message: 'end of input expected'));
    });
  });
  group('github.com/petitparser/dart-petitparser/issues/145', () {
    test('solution 1', () {
      final parser = seq3(
        char("*"),
        seq2(
          whitespace().not(),
          [seq2(whitespace(), char('*')), char('*')]
              .toChoiceParser()
              .neg()
              .plus(),
        ).flatten(),
        char("*"),
      ).map3((_, value, __) => value);
      expect(parser.parse('*valid*').value, 'valid');
      expect(parser.accept('* invalid*'), isFalse);
      expect(parser.accept('*invalid *'), isFalse);
    });
    test('solution 2', () {
      final parser = seq3(
        char("*"),
        char('*').neg().plus().flatten(),
        char("*"),
      ).map3((_, value, __) => value).where((value) => value.trim() == value);
      expect(parser.parse('*valid*').value, 'valid');
      expect(parser.accept('* invalid*'), isFalse);
      expect(parser.accept('*invalid *'), isFalse);
    });
  });
  group('github.com/petitparser/dart-petitparser/issues/147', () {
    final surrogatePair = seq2(
      pattern('\uD800-\uDBFF'),
      pattern('\uDC00-\uDFFF'),
    ).flatten();
    test('laughing emoji', () {
      const input = '\u{1f606}';
      expect(input, hasLength(2));
      expect(surrogatePair, isParseSuccess(input, result: '😆'));
    });
    test('heart character', () {
      const input = '\u2665';
      expect(input, hasLength(1));
      expect(surrogatePair, isParseFailure(input));
    });
  });
  group('github.com/petitparser/dart-petitparser/issues/155', () {
    Parser<String> chars() => anyOf('abc');
    Parser<String> direct() => chars().starString().end();
    Parser<String> reference() => ref0(chars).starString().end();

    test('direct', () {
      final parser = resolve(direct());
      expect(linter(parser), isEmpty);
    });
    test('reference', () {
      final parser = resolve(reference());
      expect(linter(parser), [isLinterIssue(title: 'Character repeater')]);
    });
    test('reference (optimized)', () {
      final parser = optimize(resolve(reference()));
      expect(linter(parser), isEmpty);
      expect(parser.isEqualTo(direct()), isTrue);
    });
  });
  test('github.com/petitparser/dart-petitparser/issues/158', () {
    final extended = pattern('À-ÿ');
    expect(extended, isParseSuccess('ä', result: 'ä'));
    expect(extended, isParseSuccess('ï', result: 'ï'));
  });
}
