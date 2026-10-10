import 'package:checks/checks.dart';
import 'package:petitparser/core.dart';
import 'package:petitparser/definition.dart';
import 'package:petitparser/indent.dart';
import 'package:petitparser/matcher.dart';
import 'package:petitparser/parser.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/scaffolding.dart';

import 'utils/checks.dart';

class IndentList extends GrammarDefinition {
  final indent = Indent();

  @override
  Parser<List<dynamic>> start() => seq4(
    ref0(newlines).optional(),
    ref0(things).optional(),
    ref0(newlines).optional(),
    endOfInput(),
  ).map4((_, things, _, _) => things ?? const []);

  Parser<List<dynamic>> things() => seq2(
    indent.same,
    ref0(object) | ref0(line),
  ).map2((_, value) => value).plus();

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
      check(definition.indent.stack).isEmpty();
      check(definition.indent.current).equals('');
    });
    test('linter', () {
      check(linter(parser)).isEmpty();
    });
    test('empty', () {
      check(parser).parseSuccess('', result: []);

      check(parser).parseSuccess('\n', result: []);
      check(parser).parseSuccess('\n\r', result: []);
      check(parser).parseSuccess('\r', result: []);

      check(parser).parseSuccess('\n\n', result: []);
      check(parser).parseSuccess('\n\r\n\r', result: []);
      check(parser).parseSuccess('\r\r', result: []);
    });
    test('newline before', () {
      check(parser).parseSuccess('\na', result: ['a']);
      check(parser).parseSuccess('\n\ra', result: ['a']);
      check(parser).parseSuccess('\ra', result: ['a']);

      check(parser).parseSuccess('\n\na', result: ['a']);
      check(parser).parseSuccess('\n\r\n\ra', result: ['a']);
      check(parser).parseSuccess('\r\ra', result: ['a']);
    });
    test('newline after', () {
      check(parser).parseSuccess('a\n', result: ['a']);
      check(parser).parseSuccess('a\n\r', result: ['a']);
      check(parser).parseSuccess('a\r', result: ['a']);

      check(parser).parseSuccess('a\n\n', result: ['a']);
      check(parser).parseSuccess('a\n\r\n\r', result: ['a']);
      check(parser).parseSuccess('a\r\r', result: ['a']);
    });
    test('single indent', () {
      check(parser).parseSuccess(
        'a:\n b',
        result: [
          {
            'a': ['b'],
          },
        ],
      );
      check(parser).parseSuccess(
        'a:\n\tb',
        result: [
          {
            'a': ['b'],
          },
        ],
      );
      check(parser).parseSuccess(
        'a:\n \tb',
        result: [
          {
            'a': ['b'],
          },
        ],
      );
      check(parser).parseSuccess(
        'a:\n\t b',
        result: [
          {
            'a': ['b'],
          },
        ],
      );
    });
    test('same indent', () {
      check(parser).parseSuccess(
        'a:\n b\n c',
        result: [
          {
            'a': ['b', 'c'],
          },
        ],
      );
      check(parser).parseSuccess(
        'a:\n\tb\n\tc',
        result: [
          {
            'a': ['b', 'c'],
          },
        ],
      );
      check(parser).parseSuccess(
        'a:\n \tb\n \tc',
        result: [
          {
            'a': ['b', 'c'],
          },
        ],
      );
      check(parser).parseSuccess(
        'a:\n\t b\n\t c',
        result: [
          {
            'a': ['b', 'c'],
          },
        ],
      );
    });
    test('different indent', () {
      check(parser).parseFailure('a:\n b\n\tc', position: 6);
      check(parser).parseFailure('a:\n\tb\n c', position: 6);
    });
    test('missing indent', () {
      check(parser).parseSuccess('a:\nb', result: ['a:', 'b']);
    });
    test('unexpected indent', () {
      check(parser).parseFailure('a\n b', position: 2);
    });
    test('same level', () {
      check(parser).parseSuccess('a\nb\nc', result: ['a', 'b', 'c']);
    });
    test('inlined values', () {
      check(parser).parseSuccess(
        'a:1\nb: 2\nc :3',
        result: [
          {'a': '1'},
          {'b': '2'},
          {'c': '3'},
        ],
      );
    });
    test('increasing', () {
      check(parser).parseSuccess(
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
      );
    });
    test('decreasing', () {
      check(parser).parseSuccess(
        'a:\n\tb\nc',
        result: [
          {
            'a': ['b'],
          },
          'c',
        ],
      );
    });
  });
  group('during', () {
    late Indent indent;

    setUp(() {
      indent = Indent();
    });

    test('success restores indentation', () {
      final inner = seq2(
        indent.same,
        char('a'),
      ).map2((indent, ch) => '$indent$ch');
      final parser = indent.during(inner);

      check(parser).parseSuccess(' a', result: ' a');
      check(indent.current).equals('');
      check(indent.stack).isEmpty();
    });

    test('failure rolls back indentation', () {
      final inner = seq2(indent.same, char('a'));
      final parser = indent.during(inner);

      check(parser).parseFailure(' b', position: 1, message: '"a" expected');
      check(indent.current).equals('');
      check(indent.stack).isEmpty();
    });

    test('nested failure rolls back each level', () {
      final inner = indent.during(seq2(indent.same, char('b')));
      final outer = indent.during(seq2(indent.same, char('\n') & inner));

      check(outer).parseFailure(' \n  c', position: 4, message: '"b" expected');
      check(indent.current).equals('');
      check(indent.stack).isEmpty();
    });

    test('choice rollback allows alternate path', () {
      final inner1 = seq2(indent.same, char('a'));
      final inner2 = seq2(indent.same, char('b'));
      final parser = [
        indent.during(inner1),
        indent.during(inner2),
      ].toChoiceParser();

      check(parser).parseSuccess(' b', result: (' ', 'b'));
      check(indent.current).equals('');
      check(indent.stack).isEmpty();
    });

    test('linter', () {
      final parser = indent.during(seq2(indent.same, char('a')));
      check(linter(parser)).isEmpty();
    });

    test('increase failure leaves state unchanged', () {
      final inner = seq2(indent.same, char('a'));
      final parser = indent.during(inner);

      check(parser)
          .parseFailure('a', position: 0, message: 'indented expected');
      check(indent.current).equals('');
      check(indent.stack).isEmpty();
    });

    test('restores non-empty parent indentation on success', () {
      final block = indent.during(seq2(indent.same, char('b')));
      final parser = indent.during(seq2(indent.same, char('a') & block));

      check(parser).parseSuccess('  a   b');
      check(indent.current).equals('');
      check(indent.stack).isEmpty();
    });

    test('consecutive during blocks at the same level', () {
      final block1 = indent.during(seq2(indent.same, char('a')));
      final block2 = indent.during(seq2(indent.same, char('b')));
      final parser = seq2(block1, block2);

      check(parser).parseSuccess(' a b');
      check(indent.current).equals('');
      check(indent.stack).isEmpty();
    });

    test('accept (fastParseOn) on success and failure', () {
      final inner = seq2(indent.same, char('a'));
      final parser = indent.during(inner);

      check(parser.accept(' a')).isTrue();
      check(indent.current).equals('');
      check(indent.stack).isEmpty();

      check(parser.accept(' b')).isFalse();
      check(indent.current).equals('');
      check(indent.stack).isEmpty();
    });
  });
}
