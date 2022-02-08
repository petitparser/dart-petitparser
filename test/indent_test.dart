import 'package:petitparser/core.dart';
import 'package:petitparser/definition.dart';
import 'package:petitparser/indent.dart';
import 'package:petitparser/parser.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

class IndentList extends GrammarDefinition {
  final indent = Indent();

  @override
  Parser start() => <Parser>[
        ref0(newlines).optional(),
        ref0(things),
        ref0(newlines).optional(),
        endOfInput(),
      ].toSequenceParser().pick(1);

  Parser things() => <Parser>[
        indent.same,
        ref0(object) | ref0(line),
      ].toSequenceParser().pick(1).star();

  Parser object() => <Parser>[
        ref0(key),
        ref0(block) | ref0(inline),
      ].toSequenceParser().map((values) => {values[0]: values[1]});

  Parser key() => <Parser>[
        pattern('^ \t\r\n:').plus().flatten(),
        indent.parser.star(),
        char(':'),
        indent.parser.star(),
      ].toSequenceParser().pick(0);

  Parser block() => <Parser>[
        ref0(newlines),
        indent.increase,
        ref0(things),
        indent.decrease,
      ].toSequenceParser().pick(2);

  Parser inline() => ref0(line).map((value) => [value]);

  Parser line() => <Parser>[
        ref0(newline).neg().plus().flatten(),
        ref0(newlines).optional(),
      ].toSequenceParser().pick(0);

  Parser newline() => Token.newlineParser();

  Parser newlines() => [
        indent.parser.star(),
        ref0(newline),
      ].toSequenceParser().plus();
}

void main() {
  group('definition', () {
    final definition = IndentList();
    final parser = definition.build();

    tearDown(() {
      expect(definition.indent.stack, isEmpty);
      expect(definition.indent.current, '');
    });
    test('same', () {
      expect(parser, isParseSuccess('''
a
b
c
''', ['a', 'b', 'c']));
    });
    test('increasing', () {
      expect(
          parser,
          isParseSuccess('''
a:
  b:
    c
''', [
            {
              'a': [
                {
                  'b': ['c']
                }
              ]
            }
          ]));
    });
    test('decreasing', () {
      expect(
          parser,
          isParseSuccess('''
a:
  b
c
''', [
            {
              'a': ['b']
            },
            'c'
          ]));
    });
  });
}
