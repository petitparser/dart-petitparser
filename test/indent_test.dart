import 'package:petitparser/core.dart';
import 'package:petitparser/definition.dart';
import 'package:petitparser/indent.dart';
import 'package:petitparser/parser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

import 'utils/matchers.dart';

class IndentList extends GrammarDefinition {
  final indent = Indent();

  @override
  Parser<List<dynamic>> start() => seq4(
    ref0(newlines).optional(),
    ref0(things),
    ref0(newlines).optional(),
    endOfInput(),
  ).map4((_, things, _, _) => things);

  Parser<List<dynamic>> things() => seq2(
    indent.same,
    ref0(object) | ref0(line),
  ).map2((_, value) => value).star();

  Parser<Map<String, dynamic>> object() => seq2(
    ref0(key),
    ref0(block) | ref0(inline),
  ).map2((key, values) => {key: values});

  Parser<String> key() => seq4(
    pattern('^ \t\r\n:').plusString(),
    indent.parser.star(),
    char(':'),
    indent.parser.star(),
  ).map4((key, _, _, _) => key);

  Parser<List<dynamic>> block() => seq2(
    ref0(newlines),
    indent.during(ref0(things)),
  ).map2((_, things) => things);

  Parser<String> inline() => ref0(line);

  Parser<String> line() => seq2(
    ref0(newline).neg().plus().flatten(),
    ref0(newlines).optional(),
  ).map2((line, _) => line);

  Parser<void> whitespaces() => indent.parser.star();

  Parser<void> newline() => Token.newlineParser();

  Parser<void> newlines() => seq2(ref0(whitespaces), ref0(newline)).plus();
}

void main() {
  group('definition', () {
    final definition = IndentList();
    final parser = definition.build();

    tearDown(() {
      expect(definition.indent.stack, isEmpty);
      expect(definition.indent.current, '');
    });
    test('linter', () {
      expect(linter(parser), isEmpty);
    });
    test('empty', () {
      expect(parser, isParseSuccess('', result: isEmpty));

      expect(parser, isParseSuccess('\n', result: isEmpty));
      expect(parser, isParseSuccess('\n\r', result: isEmpty));
      expect(parser, isParseSuccess('\r', result: isEmpty));

      expect(parser, isParseSuccess('\n\n', result: isEmpty));
      expect(parser, isParseSuccess('\n\r\n\r', result: isEmpty));
      expect(parser, isParseSuccess('\r\r', result: isEmpty));
    });
    test('newline before', () {
      expect(parser, isParseSuccess('\na', result: ['a']));
      expect(parser, isParseSuccess('\n\ra', result: ['a']));
      expect(parser, isParseSuccess('\ra', result: ['a']));

      expect(parser, isParseSuccess('\n\na', result: ['a']));
      expect(parser, isParseSuccess('\n\r\n\ra', result: ['a']));
      expect(parser, isParseSuccess('\r\ra', result: ['a']));
    });
    test('newline after', () {
      expect(parser, isParseSuccess('a\n', result: ['a']));
      expect(parser, isParseSuccess('a\n\r', result: ['a']));
      expect(parser, isParseSuccess('a\r', result: ['a']));

      expect(parser, isParseSuccess('a\n\n', result: ['a']));
      expect(parser, isParseSuccess('a\n\r\n\r', result: ['a']));
      expect(parser, isParseSuccess('a\r\r', result: ['a']));
    });
    test('single indent', () {
      expect(
        parser,
        isParseSuccess(
          'a:\n b',
          result: [
            {
              'a': ['b'],
            },
          ],
        ),
      );
      expect(
        parser,
        isParseSuccess(
          'a:\n\tb',
          result: [
            {
              'a': ['b'],
            },
          ],
        ),
      );
      expect(
        parser,
        isParseSuccess(
          'a:\n \tb',
          result: [
            {
              'a': ['b'],
            },
          ],
        ),
      );
      expect(
        parser,
        isParseSuccess(
          'a:\n\t b',
          result: [
            {
              'a': ['b'],
            },
          ],
        ),
      );
    });
    test('same indent', () {
      expect(
        parser,
        isParseSuccess(
          'a:\n b\n c',
          result: [
            {
              'a': ['b', 'c'],
            },
          ],
        ),
      );
      expect(
        parser,
        isParseSuccess(
          'a:\n\tb\n\tc',
          result: [
            {
              'a': ['b', 'c'],
            },
          ],
        ),
      );
      expect(
        parser,
        isParseSuccess(
          'a:\n \tb\n \tc',
          result: [
            {
              'a': ['b', 'c'],
            },
          ],
        ),
      );
      expect(
        parser,
        isParseSuccess(
          'a:\n\t b\n\t c',
          result: [
            {
              'a': ['b', 'c'],
            },
          ],
        ),
      );
    });
    test('different indent', () {
      expect(parser, isParseFailure('a:\n b\n\tc', position: 6));
      expect(parser, isParseFailure('a:\n\tb\n c', position: 6));
    });
    test('missing indent', () {
      expect(parser, isParseSuccess('a:\nb', result: ['a:', 'b']));
    });
    test('unexpected indent', () {
      expect(parser, isParseFailure('a\n b', position: 2));
    });
    test('same level', () {
      expect(parser, isParseSuccess('a\nb\nc', result: ['a', 'b', 'c']));
    });
    test('inlined values', () {
      expect(
        parser,
        isParseSuccess(
          'a:1\nb: 2\nc :3',
          result: [
            {'a': '1'},
            {'b': '2'},
            {'c': '3'},
          ],
        ),
      );
    });
    test('increasing', () {
      expect(
        parser,
        isParseSuccess(
          'a:\n  b:\n    c',
          result: [
            {
              'a': [
                {
                  'b': ['c'],
                },
              ],
            },
          ],
        ),
      );
    });
    test('decreasing', () {
      expect(
        parser,
        isParseSuccess(
          'a:\n\tb\nc',
          result: [
            {
              'a': ['b'],
            },
            'c',
          ],
        ),
      );
    });
  });
}
