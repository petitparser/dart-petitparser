import 'dart:math';

import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/scaffolding.dart';

import 'utils/checks.dart';

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

class ProtobufGrammar extends GrammarDefinition {
  @override
  Parser start() => ref0(file);
  Parser file() =>
      ref0(definition).star() & (endOfInput().trim() | ref0(definition));
  Parser definition() => ref0(message);
  Parser message() =>
      string('message').trim() &
      ref0(identifier).trim() &
      char('{').trim() &
      char('}').trim();
  Parser identifier() =>
      (letter() & word().star()).flatten(message: 'identifier expected');
}

class AssignmentGrammar extends GrammarDefinition {
  @override
  Parser start() => (ref0(assignment) | ref0(expression)).end();
  Parser assignment() =>
      ref0(variable) & ref0(indexed).star() & char('=') & ref0(expression);
  Parser expression() {
    final expr = ExpressionBuilder<dynamic>();
    expr.primitive(ref0(number));
    expr.primitive(ref0(variable));
    expr.primitive(ref0(literalArray));
    expr.group().postfix(ref0(indexed), (a, b) => (a, b));
    expr.group().left(char('+'), (a, op, b) => (a, op, b));
    return expr.build();
  }

  Parser number() => digit();
  Parser variable() => letter();
  Parser literalArray() =>
      char('[') & ref0(expression).starSeparated(char(',')) & char(']');
  Parser indexed() => char('[') & ref0(expression) & char(']');
}

void main() {
  test('flatten().trim()', () {
    final parser = word().plus().flatten().trim();
    check(parser).parseSuccess('ab1', result: 'ab1');
    check(parser).parseSuccess(' ab1 ', result: 'ab1');
    check(parser).parseSuccess('  ab1  ', result: 'ab1');
  });
  test('trim().flatten()', () {
    final parser = word().plus().trim().flatten();
    check(parser).parseSuccess('ab1', result: 'ab1');
    check(parser).parseSuccess(' ab1 ', result: ' ab1 ');
    check(parser).parseSuccess('  ab1  ', result: '  ab1  ');
  });
  test('parse padded and limited number', () {
    final parser = digit().repeat(2).flatten().callCC<String>((
      continuation,
      context,
    ) {
      final result = continuation(context);
      if (result is Success && int.parse(result.value) > 31) {
        return context.failure('00-31 expected');
      } else {
        return result;
      }
    });
    check(parser).parseSuccess('00', result: '00');
    check(parser).parseSuccess('24', result: '24');
    check(parser).parseSuccess('31', result: '31');
    check(parser).parseFailure('32', message: '00-31 expected');
    check(parser).parseFailure('3', position: 1, message: 'digit expected');
  });
  group('date format parser', () {
    final day = 'dd'.toParser().map(
      (token) => digit()
          .repeat(2)
          .flatten()
          .map((value) => MapEntry(#day, int.parse(value))),
    );
    final month = 'mm'.toParser().map(
      (token) => digit()
          .repeat(2)
          .flatten()
          .map((value) => MapEntry(#month, int.parse(value))),
    );
    final year = 'yyyy'.toParser().map(
      (token) => digit()
          .repeat(4)
          .flatten()
          .map((value) => MapEntry(#year, int.parse(value))),
    );

    final spacing = whitespace().map(
      (token) => whitespace().star().map((value) => const MapEntry(#unused, 0)),
    );
    final verbatim = any().map(
      (token) => token.toParser().map((value) => const MapEntry(#unused, 0)),
    );

    final entries = [day, month, year, spacing, verbatim].toChoiceParser();
    final format = entries.star().end().map(
      (parsers) => parsers.toSequenceParser().map((entries) {
        final arguments = Map.fromEntries(entries);
        return DateTime(
          arguments[#year] ?? DateTime.now().year,
          arguments[#month] ?? DateTime.january,
          arguments[#day] ?? 1,
        );
      }),
    );

    test('iso', () {
      final date = format.parse('yyyy-mm-dd').value;
      check(date).parseSuccess('1980-06-11', result: DateTime(1980, 6, 11));
      check(date).parseSuccess('1982-08-24', result: DateTime(1982, 8, 24));
      check(date)
          .parseFailure('1984.10.31', position: 4, message: '"-" expected');
    });
    test('europe', () {
      final date = format.parse('dd.mm.yyyy').value;
      check(date).parseSuccess('11.06.1980', result: DateTime(1980, 6, 11));
      check(date).parseSuccess('24.08.1982', result: DateTime(1982, 8, 24));
      check(date).parseFailure('1984', position: 2, message: '"." expected');
    });
    test('us', () {
      final date = format.parse('mm/dd/yyyy').value;
      check(date).parseSuccess('06/11/1980', result: DateTime(1980, 6, 11));
      check(date).parseSuccess('08/24/1982', result: DateTime(1982, 8, 24));
      check(date).parseFailure('Hello', message: 'digit expected');
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
    check(delimited).parseSuccess('"hello"', result: 'hello');
    check(delimited).parseSuccess('/hello/', result: 'hello');
    check(delimited).parseSuccess(',hello,', result: 'hello');
    check(delimited).parseSuccess('xhellox', result: 'hello');
    check(delimited).parseFailure('abc', position: 3, message: '"a" expected');
  });
  test('function evaluator', () {
    final builder = ExpressionBuilder<Evaluator>();
    builder
      ..primitive(
        digit()
            .plus()
            .seq(char('.').seq(digit().plus()).optional())
            .flatten()
            .trim()
            .map((a) {
              final number = num.parse(a);
              return (num value) => number;
            }),
      )
      ..primitive(
        char('x').trim().map(
          (_) =>
              (value) => value,
        ),
      );
    builder.group().wrapper(char('(').trim(), char(')').trim(), (_, a, _) => a);
    // negation is a prefix operator
    builder.group().prefix(
      char('-').trim(),
      (_, a) =>
          (num value) => -a(value),
    );
    // power is right-associative
    builder.group().right(
      char('^').trim(),
      (a, _, b) =>
          (num value) => pow(a(value), b(value)),
    );
    // multiplication and addition are left-associative
    builder.group()
      ..left(
        char('*').trim(),
        (a, _, b) =>
            (num value) => a(value) * b(value),
      )
      ..left(
        char('/').trim(),
        (a, _, b) =>
            (num value) => a(value) / b(value),
      );
    builder.group()
      ..left(
        char('+').trim(),
        (a, _, b) =>
            (num value) => a(value) + b(value),
      )
      ..left(
        char('-').trim(),
        (a, _, b) =>
            (num value) => a(value) - b(value),
      );
    final parser = builder.build().end();

    final expression = parser.parse('5 * x ^ 3 - 2').value;
    check(expression(-2)).equals(-42);
    check(expression(-1)).equals(-7);
    check(expression(0)).equals(-2);
    check(expression(1)).equals(3);
    check(expression(2)).equals(38);
  });
  test('stackoverflow.com/q/67617000/82303', () {
    check(nestedParser).parseSuccess('()', result: '()');
    check(nestedParser).parseSuccess('(a)', result: '(a)');
    check(nestedParser).parseSuccess('(a()b)', result: '(a()b)');
    check(nestedParser).parseSuccess('(a(b)c)', result: '(a(b)c)');
    check(nestedParser).parseSuccess('(a()b(cd))', result: '(a()b(cd))');
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
      check(dataResult.value).equals('data');
    });
    test('continuation', () {
      final parser = buildMetadataParser().callCC((continuation, context) {
        final metadataResult = continuation(context);
        final dataParser = buildDataParser(metadataResult.value);
        return dataParser.parseOn(metadataResult);
      });
      check(parser.parse(input).value).equals('data');
    });
  });
  group('stackoverflow.com/questions/68105573', () {
    const firstInput = '(use = "official").empty()';
    const secondInput = '((5 + 5) * 5) + 5';

    test('greedy', () {
      final parser =
          char('(') & any().starGreedy(char(')')).flatten() & char(')');
      check(parser.parse(firstInput).value)
          .deepEquals(['(', 'use = "official").empty(', ')']);
      check(parser.parse(secondInput).value)
          .deepEquals(['(', '(5 + 5) * 5', ')']);
    });
    test('lazy', () {
      final parser =
          char('(') & any().starLazy(char(')')).flatten() & char(')');
      check(parser.parse(firstInput).value)
          .deepEquals(['(', 'use = "official"', ')']);
      check(parser.parse(secondInput).value).deepEquals(['(', '(5 + 5', ')']);
    });
    test('recursive', () {
      final inner = undefined<Object?>();
      final parser =
          char('(') & inner.starLazy(char(')')).flatten() & char(')');
      inner.set(parser | any());
      check(parser.parse(firstInput).value)
          .deepEquals(['(', 'use = "official"', ')']);
      check(parser.parse(secondInput).value)
          .deepEquals(['(', '(5 + 5) * 5', ')']);
    });
    test('recursive (better)', () {
      final inner = undefined<Object?>();
      final parser = char('(') & inner.star().flatten() & char(')');
      inner.set(parser | pattern('^)'));
      check(parser.parse(firstInput).value)
          .deepEquals(['(', 'use = "official"', ')']);
      check(parser.parse(secondInput).value)
          .deepEquals(['(', '(5 + 5) * 5', ')']);
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
      check(parser).parseSuccess('11', result: ['1', '1']);
      check(parser).parseSuccess('22', result: ['2', '2']);
      check(parser).parseSuccess('33', result: ['3', '3']);
      check(parser).parseFailure('1', position: 1, message: 'digit expected');
      check(parser).parseFailure('12', message: 'values do not match');
      check(parser).parseFailure('21', message: 'values do not match');
    });
    test('where', () {
      final parser = inner.where(
        (value) => value[0] == value[1],
        factory: (context, success) => context.failure('values do not match'),
      );
      check(parser).parseSuccess('11', result: ['1', '1']);
      check(parser).parseSuccess('22', result: ['2', '2']);
      check(parser).parseSuccess('33', result: ['3', '3']);
      check(parser).parseFailure('1', position: 1, message: 'digit expected');
      check(parser).parseFailure('12', message: 'values do not match');
      check(parser).parseFailure('21', message: 'values do not match');
    });
  });
  test('github.com/petitparser/dart-petitparser/issues/121', () {
    final parser =
        ((letter() | char('_')) &
                (letter() | digit() | anyOf('_- ()')).star() &
                char('.').not(message: 'end of id expected'))
            .flatten();
    check(parser).parseSuccess('foo', result: 'foo');
    check(parser)
        .parseFailure('foo.1', message: 'end of id expected', position: 3);
  });
  test('github.com/petitparser/dart-petitparser/issues/126', () {
    final parser = ParensGrammar().build();
    check(parser).parseSuccess('', result: null);
    check(parser).parseSuccess('()', result: ['(', null, ')']);
    check(parser).parseSuccess(
      '(())',
      result: [
        '(',
        ['(', null, ')'],
        ')',
      ],
    );
    check(parser).parseSuccess(
      '((()))',
      result: [
        '(',
        [
          '(',
          ['(', null, ')'],
          ')',
        ],
        ')',
      ],
    );
  });
  group('stackoverflow.com/questions/73260748', () {
    test('Case 1', () {
      final parser = resolve(NestedGrammar1().start());
      check(parser).parseSuccess(
        '(0)',
        result: [
          "'(' (nestedTerm)",
          "'0' (singleCharacter)",
          "')' (nestedTerm)",
        ],
      );
    });
    test('Case 2', () {
      final parser = resolve(NestedGrammar2().start());
      check(parser).parseSuccess(
        '(0)',
        result: [
          "'(' (singleCharacter)",
          "'0' (singleCharacter)",
          "')' (singleCharacter)",
        ],
      );
    });
    test('Case 3', () {
      final parser = resolve(NestedGrammar3().start());
      check(parser).parseSuccess(
        '(0)',
        result: [
          [
            "'(' (nestedTerm)",
            ["'0' (singleCharacter)"],
            "')' (nestedTerm)",
          ],
        ],
      );
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
          char('(').trim(),
          char(')').trim(),
          (l, v, r) => [l, v, r],
        );
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
      'long':
          '(((S|69|L || S|69|R || S|72|L || S|72|R) && ((S|62|L && (S|78|L '
          '|| S|55|L) && (S|77|L || S|1|L)) || (S|62|R && (S|78|R || S|55|R) &&'
          ' (S|77|R || S|1|R)))) && (M|34|L || M|34|R) && (((M|40|L && M|39|L &'
          '& M|36|L) || (M|40|R && M|39|R && M|36|R)) || ((M|38|L && M|36|L && '
          'M|37|L) || (M|38|R && M|36|R && M|37|R))))',
    };
    for (final input in inputs.entries) {
      for (final parser in parsers.entries) {
        test('${parser.key} with ${input.key}', () {
          check(parser.value.accept(input.value)).isTrue();
        });
      }
    }
  });
  group('stackoverflow.com/questions/75503464', () {
    final builder = ExpressionBuilder<Object?>();
    final primitive = seq5(
      uppercase(),
      char('|'),
      digit().plus(),
      char('|'),
      uppercase(),
    ).flatten(message: 'value expected').trim();
    builder.primitive(primitive);
    builder.group().wrapper(char('(').trim(), char(')').trim(), (l, v, r) => v);
    builder.group()
      ..left(string('&&').trim(), (a, op, b) => ['&&', a, b])
      ..left(string('||').trim(), (a, op, b) => ['||', a, b]);
    final parser = builder.build().end();
    test('success', () {
      check(parser).parseSuccess('S|69|L', result: 'S|69|L');
      check(parser).parseSuccess('(S|69|L)', result: 'S|69|L');
      check(parser)
          .parseSuccess('S|69|L && S|69|R', result: ['&&', 'S|69|L', 'S|69|R']);
      check(parser)
          .parseSuccess('S|69|L || S|69|R', result: ['||', 'S|69|L', 'S|69|R']);
    });
    test('value error', () {
      check(parser)
          .parseFailure('S|fail|L', position: 0, message: 'value expected');
      check(parser)
          .parseFailure('(S|fail|L)', position: 0, message: 'value expected');
      check(parser).parseFailure(
        'S|69|L && S|fail|R',
        position: 7,
        message: 'end of input expected',
      );
      check(parser).parseFailure(
        'S|69|L || S|fail|R',
        position: 7,
        message: 'end of input expected',
      );
    });
    test('other error', () {
      check(parser)
          .parseFailure('(S|69|L', position: 0, message: 'value expected');
      check(
        parser,
      ).parseFailure('S|69|L &', position: 7, message: 'end of input expected');
    });
  });
  group('github.com/petitparser/dart-petitparser/issues/145', () {
    test('solution 1', () {
      final parser = seq3(
        char('*'),
        seq2(
          whitespace().not(),
          [
            seq2(whitespace(), char('*')),
            char('*'),
          ].toChoiceParser().neg().plus(),
        ).flatten(),
        char('*'),
      ).map3((_, value, _) => value);
      check(parser.parse('*valid*').value).equals('valid');
      check(parser.accept('* invalid*')).isFalse();
      check(parser.accept('*invalid *')).isFalse();
    });
    test('solution 2', () {
      final parser = seq3(
        char('*'),
        char('*').neg().plus().flatten(),
        char('*'),
      ).map3((_, value, _) => value).where((value) => value.trim() == value);
      check(parser.parse('*valid*').value).equals('valid');
      check(parser.accept('* invalid*')).isFalse();
      check(parser.accept('*invalid *')).isFalse();
    });
  });
  group('github.com/petitparser/dart-petitparser/issues/147', () {
    final surrogatePair = seq2(
      pattern('\uD800-\uDBFF'),
      pattern('\uDC00-\uDFFF'),
    ).flatten();
    test('laughing emoji', () {
      const input = '\u{1f606}';
      check(input).length.equals(2);
      check(surrogatePair).parseSuccess(input, result: '😆');
    });
    test('heart character', () {
      const input = '\u2665';
      check(input).length.equals(1);
      check(surrogatePair).parseFailure(input);
    });
  });
  group('github.com/petitparser/dart-petitparser/issues/155', () {
    Parser<String> chars() => anyOf('abc');
    Parser<String> direct() => chars().starString().end();
    Parser<String> reference() => ref0(chars).starString().end();

    test('direct', () {
      final parser = resolve(direct());
      check(linter(parser)).isEmpty();
    });
    test('reference', () {
      final parser = resolve(reference());
      check(linter(parser))
          .matchesInOrder([isLinterIssue(title: 'Character repeater')]);
    });
    test('reference (optimized)', () {
      final parser = optimize(resolve(reference()));
      check(linter(parser)).isEmpty();
      check(parser.isEqualTo(direct())).isTrue();
    });
  });
  test('github.com/petitparser/dart-petitparser/issues/158', () {
    final extended = pattern('À-ÿ');
    check(extended).parseSuccess('ä', result: 'ä');
    check(extended).parseSuccess('ï', result: 'ï');
  });
  group('github.com/petitparser/dart-petitparser/issues/162', () {
    final uppercase = char('A').plus().map((_) => 'success');
    final anycase = char('A', ignoreCase: true).plus().map((_) => 'fallback');
    test('question', () {
      final parser = [uppercase, anycase].toChoiceParser().end();
      check(parser).parseSuccess('AAAA', result: 'success');
      check(parser).parseSuccess('aaaAAaaa', result: 'fallback');
      check(
        parser,
      ).parseFailure('AAaaAA', position: 2, message: 'end of input expected');
    });
    test('possible fix', () {
      final parser = [uppercase.end(), anycase.end()].toChoiceParser();
      check(parser).parseSuccess('AAAA', result: 'success');
      check(parser).parseSuccess('aaaAAaaa', result: 'fallback');
      check(parser).parseSuccess('AAaaAA', result: 'fallback');
    });
    test('more general', () {
      final parser = [
        uppercase.skip(after: anycase.not()),
        anycase,
      ].toChoiceParser().end();
      check(parser).parseSuccess('AAAA', result: 'success');
      check(parser).parseSuccess('aaaAAaaa', result: 'fallback');
      check(parser).parseSuccess('AAaaAA', result: 'fallback');
    });
  });
  group('https://stackoverflow.com/questions/78078779', () {
    test('How to consume only as long as another parser accepts?', () {
      final parser = digit().plusLazy(digit().repeat(3).not());
      check(parser).parseSuccess('123', result: ['1'], position: 1);
      check(parser).parseSuccess('1234', result: ['1', '2'], position: 2);
    });
    test('How to recognize a list of items with optional delimiters?', () {
      final parser = digit().plusSeparated(char(',').optional());
      check(parser).parseSuccess(
        '1,2,3',
        result: isSeparatedList<String, String?>(
          elements: ['1', '2', '3'],
          separators: [',', ','],
        ),
      );
      check(parser).parseSuccess(
        '12,3',
        result: isSeparatedList<String, String?>(
          elements: ['1', '2', '3'],
          separators: [null, ','],
        ),
      );
    });
  });
  group('https://stackoverflow.com/questions/78701485', () {
    final wholeNumber = digit().plus().trim();
    final number = wholeNumber.plus() & char('.').optional() & wholeNumber;
    test('original', () {
      final parser = char('(') & number & char(')');
      check(parser).parseSuccess('(0.53)');
      check(parser)
          .parseFailure('(0.53,00)', position: 5, message: '")" expected');
    });
    test('modified', () {
      final parser =
          char('(') &
          number &
          char(',').not(message: 'remove comma') &
          char(')');
      check(parser).parseSuccess('(0.53)');
      check(parser)
          .parseFailure('(0.53,00)', position: 5, message: 'remove comma');
    });
  });
  group('github.com/petitparser/dart-petitparser/discussions/177', () {
    test('continuation', () {
      final variables = ['first', 'second'];
      final parser = failure<String>().callCC(
        (continuation, context) => variables
            .map((each) => each.toParser())
            .toChoiceParser()
            .parseOn(context),
      );
      check(parser).parseSuccess('first');
      check(parser).parseSuccess('second');
      check(parser).parseFailure('third');
      variables.add('third');
      check(parser).parseSuccess('third');
    });
  });
  group('github.com/petitparser/dart-petitparser/issues/80', () {
    final surrogatePair = seq2(
      pattern('\uD800-\uDBFF'),
      pattern('\uDC00-\uDFFF'),
    );
    final decodedSurrogatePair = surrogatePair.map2(
      (hi, lo) =>
          0x400 * (hi.codeUnitAt(0) - 0xD800) +
          (lo.codeUnitAt(0) - 0xDC00) +
          0x10000,
    );
    test('en.wikipedia.org/wiki/UTF-16#Examples', () {
      check(decodedSurrogatePair).parseSuccess('\u{10437}', result: 0x10437);
      check(decodedSurrogatePair).parseSuccess('\u{24B62}', result: 0x24B62);
    });
    test('#issuecomment-2510905396', () {
      final parser = decodedSurrogatePair.where(
        (value) => 0x20000 <= value && value <= 0x2FFFF,
      );
      check(parser).parseSuccess('\u{20000}', result: 0x20000);
      check(parser).parseSuccess('\u{2abcd}', result: 0x2abcd);
      check(parser).parseSuccess('\u{2FFFF}', result: 0x2FFFF);
    });
  });
  group('github.com/petitparser/dart-petitparser/issues/184', () {
    final parser = ProtobufGrammar().build();
    test('valid', () {
      check(parser.parse(' ')).isSuccess();
      check(parser.parse('message foo {} ')).isSuccess();
      check(parser.parse('message foo {} message bar {} ')).isSuccess();
    });
    test('invalid', () {
      check(parser.parse('message '))
          .isFailure(message: 'identifier expected', position: 8);
      check(parser.parse('message 123'))
          .isFailure(message: 'identifier expected', position: 8);
      check(parser.parse('message Empty'))
          .isFailure(message: '"{" expected', position: 13);
      check(parser.parse('message Empty {'))
          .isFailure(message: '"}" expected', position: 15);
    });
  });
  group('github.com/petitparser/dart-petitparser/issues/191', () {
    test('simple', () {
      final zero = '0'.toParser();
      final one = '1'.toParser();
      final parser = [seq2(zero, one), one].toChoiceParser().star().flatten();
      check(parser).parseSuccess('1', result: '1');
      check(parser).parseSuccess('01', result: '01');
      check(parser).parseSuccess('11', result: '11');
      check(parser).parseSuccess('011', result: '011');
      check(parser).parseSuccess('0101', result: '0101');
    });
    test('general', () {
      final zero = '0'.toParser();
      final one = '1'.toParser();
      final parser = [zero, one]
          .toChoiceParser()
          .callCC<String>((continuation, context) {
            // Parse the original choice parser (zero or one).
            final result = continuation(context);
            // If this is a success and the result is '0', create a new parser
            // and follow up with it after the original choice parser.
            if (result case Success(value: '0')) {
              return '1'.toParser().parseOn(result);
            }
            // Otherwise return the result of the original choice parser.
            return result;
          })
          .star()
          .flatten();
      check(parser).parseSuccess('1', result: '1');
      check(parser).parseSuccess('01', result: '01');
      check(parser).parseSuccess('11', result: '11');
      check(parser).parseSuccess('011', result: '011');
      check(parser).parseSuccess('0101', result: '0101');
    });
  });
  group('github.com/petitparser/dart-petitparser/issues/193', () {
    final parser = AssignmentGrammar().build();
    test('number', () {
      check(parser).parseSuccess('1');
    });
    test('variable', () {
      check(parser).parseSuccess('a');
      check(parser).parseSuccess('a[1]');
      check(parser).parseSuccess('a[1+2]');
      check(parser).parseSuccess('a[1][2]');
    });
    test('array', () {
      check(parser).parseSuccess('[]');
      check(parser).parseSuccess('[1]');
      check(parser).parseSuccess('[1,2]');
    });
    test('addition', () {
      check(parser).parseSuccess('1+2');
      check(parser).parseSuccess('1+2+3');
    });
    test('assignment', () {
      check(parser).parseSuccess('a=1');
      check(parser).parseSuccess('a=2+3');
      check(parser).parseSuccess('a[1]=2');
      check(parser).parseSuccess('a[1][2+3]=4');
      check(parser).parseSuccess('a[1]=[2+3][4]');
    });
    test('examples', () {
      check(parser).parseSuccess('a[0]');
      check(parser).parseSuccess('a[0][0]');
      check(parser).parseSuccess('[1,2,3][0]+[[1,2],1][0][0]');
    });
  });
}
