import 'dart:math';

import 'package:meta/meta.dart';
import 'package:petitparser/petitparser.dart';
import 'package:petitparser/src/parser/character/predicates/char.dart';
import 'package:petitparser/src/parser/character/predicates/constant.dart';
import 'package:petitparser/src/parser/character/predicates/digit.dart';
import 'package:petitparser/src/parser/character/predicates/letter.dart';
import 'package:petitparser/src/parser/character/predicates/lookup.dart';
import 'package:petitparser/src/parser/character/predicates/lowercase.dart';
import 'package:petitparser/src/parser/character/predicates/not.dart';
import 'package:petitparser/src/parser/character/predicates/range.dart';
import 'package:petitparser/src/parser/character/predicates/ranges.dart';
import 'package:petitparser/src/parser/character/predicates/uppercase.dart';
import 'package:petitparser/src/parser/character/predicates/whitespace.dart';
import 'package:petitparser/src/parser/character/predicates/word.dart';
import 'package:test/test.dart' hide anyOf;

import 'utils/assertions.dart';
import 'utils/matchers.dart';

@isTestGroup
void variation(
  String label,
  Parser<String> parser, {
  Iterable<String> accept = const [],
  Iterable<String> reject = const [],
  dynamic message = anything,
  dynamic predicate = anything,
}) {
  group(label, () {
    expectParserInvariants(parser);
    if (accept.isNotEmpty) {
      test('accept', () {
        for (final char in accept) {
          expect(parser, isParseSuccess(char, result: char));
        }
      });
    }
    if (reject.isNotEmpty) {
      test('reject', () {
        for (final char in reject) {
          expect(parser, isParseFailure(char, message: message));
        }
      });
    }
    test('empty', () {
      expect(parser, isParseFailure('', message: message));
    });
    test('state', () {
      final characterParser = parser as CharacterParser;
      expect(characterParser.message, message);
      expect(characterParser.predicate, predicate);
      expect(characterParser.predicate.toString(),
          isNot(startsWith('Instance of')));
      expect(
          characterParser.predicate.toString(),
          stringContainsInOrder(
              [characterParser.predicate.runtimeType.toString()]));
      expect(characterParser.predicate.hashCode, isA<int>());
    });
  });
}

void main() {
  group('any', () {
    variation(
      'default',
      any(),
      accept: ['a', 'z', '9', '\u3211'],
      message: 'input expected',
      predicate: const ConstantCharPredicate(true),
    );
    variation(
      'message',
      any(message: 'something expected'),
      accept: ['a', 'z', '9', '\u3211'],
      message: 'something expected',
      predicate: const ConstantCharPredicate(true),
    );
    variation(
      'unicode',
      any(unicode: true),
      accept: ['a', 'b', 'c', '🤔', '🤐'],
      message: 'input expected',
      predicate: const ConstantCharPredicate(true),
    );
  });
  group('anyOf', () {
    variation(
      'default',
      anyOf('uncopyrightable'),
      accept: ['c', 'g', 'h', 'i', 'o', 'p', 'r', 't', 'y'],
      reject: ['x', 'z', 'C'],
      message: 'any of "uncopyrightable" expected',
      predicate: const LookupCharPredicate(97, 121, [18541015]),
    );
    variation(
      'message',
      anyOf('02468', message: 'even digit'),
      accept: ['0', '2', '4', '6', '8'],
      reject: ['1', '3', '5', '7', '9'],
      message: 'even digit',
      predicate: const LookupCharPredicate(48, 56, [341]),
    );
    variation(
      'ignore-case',
      anyOf('aB0', ignoreCase: true),
      accept: ['a', 'A', 'b', 'B', '0'],
      reject: ['c', '1'],
      message: 'any of "aB0" (case-insensitive) expected',
      predicate: const LookupCharPredicate(48, 98, [393217, 393216]),
    );
    variation(
      'unicode',
      anyOf('abc🤔🤐', unicode: true),
      accept: ['a', 'b', 'c', '🤔', '🤐'],
      reject: ['0', 'd', '🙄'],
      message: 'any of "abc🤔🤐" expected',
      predicate: isA<LookupCharPredicate>(),
    );
  });
  group('char', () {
    variation(
      'default',
      char('y'),
      accept: ['y'],
      reject: ['x', '%', '\r', 'Y'],
      message: '"y" expected',
      predicate: const SingleCharPredicate(121),
    );
    variation(
      'message',
      char('y', message: 'lowercase y'),
      accept: ['y'],
      reject: ['x', '5', '\x00'],
      message: 'lowercase y',
      predicate: const SingleCharPredicate(121),
    );
    variation(
      'ignore-case',
      char('y', ignoreCase: true),
      accept: ['y', 'Y'],
      reject: ['x', 'z', 'X', 'Z'],
      message: '"y" (case-insensitive) expected',
      predicate: const LookupCharPredicate(89, 121, [1, 1]),
    );
    variation(
      'unicode',
      char('🙄', unicode: true),
      accept: ['🙄'],
      reject: ['🤐', '🤔', 'a', '0'],
      message: '"🙄" expected',
      predicate: const SingleCharPredicate(128580),
    );
    test('invalid character', () {
      expect(() => char('ab'), throwsA(isAssertionError));
      expect(() => char('🙄'), throwsA(isAssertionError));
    }, skip: !hasAssertionsEnabled());
  });
  group('digit', () {
    variation(
      'default',
      digit(),
      accept: ['0', '8', '9'],
      reject: ['a', 'X', '\b'],
      message: 'digit expected',
      predicate: const DigitCharPredicate(),
    );
    variation(
      'message',
      digit(message: 'number expected'),
      accept: ['1', '2', '3'],
      reject: ['e', '#', '*'],
      message: 'number expected',
      predicate: const DigitCharPredicate(),
    );
  });
  group('letter', () {
    variation(
      'default',
      letter(),
      accept: ['a', 'X', 'n'],
      reject: ['6', '#', '\n'],
      message: 'letter expected',
      predicate: const LetterCharPredicate(),
    );
    variation(
      'message',
      letter(message: 'word constituent'),
      accept: ['y', 'Z', 'R'],
      reject: ['0', '&', '^'],
      message: 'word constituent',
      predicate: const LetterCharPredicate(),
    );
  });
  group('lowercase', () {
    variation(
      'default',
      lowercase(),
      accept: ['a', 'l', 'r'],
      reject: ['3', 'Z', '\t'],
      message: 'lowercase letter expected',
      predicate: const LowercaseCharPredicate(),
    );
    variation(
      'message',
      lowercase(message: 'lowercase only'),
      accept: ['x', 'y', 'z'],
      reject: ['0', '&', '\x00'],
      message: 'lowercase only',
      predicate: const LowercaseCharPredicate(),
    );
  });
  group('noneOf', () {
    variation(
      'default',
      noneOf('uncopyrightable'),
      accept: ['x', 'z'],
      reject: ['c', 'g', 'h', 'i', 'o', 'p', 'r', 't', 'y'],
      message: 'none of "uncopyrightable" expected',
      predicate:
          const NotCharPredicate(LookupCharPredicate(97, 121, [18541015])),
    );
    variation(
      'message',
      noneOf('02468', message: 'no even digit'),
      accept: ['1', '3', '5', '7', '9'],
      reject: ['0', '2', '4', '6', '8'],
      message: 'no even digit',
      predicate: const NotCharPredicate(LookupCharPredicate(48, 56, [341])),
    );
    variation(
      'ignore-case',
      noneOf('aB0', ignoreCase: true),
      accept: ['c', 'C', 'x', '1'],
      reject: ['a', 'A', 'b', 'B', '0'],
      message: 'none of "aB0" (case-insensitive) expected',
      predicate:
          const NotCharPredicate(LookupCharPredicate(48, 98, [393217, 393216])),
    );
    variation(
      'unicode',
      noneOf('abc🤔🤐', unicode: true),
      accept: ['0', 'd', '🙄'],
      reject: ['a', 'b', 'c', '🤔', '🤐'],
      message: 'none of "abc🤔🤐" expected',
    );
  });
  group('pattern', () {
    group('single', () {
      variation(
        'default',
        pattern('y'),
        accept: ['y'],
        reject: ['x', 'z', '5', 'Y', '\x00', '😮'],
        message: '[y] expected',
        predicate: const SingleCharPredicate(121),
      );
      variation(
        'ignore-case',
        pattern('a', ignoreCase: true),
        accept: ['a', 'A'],
        reject: ['b', 'B', '\x00', '&'],
        predicate: const LookupCharPredicate(65, 97, [1, 1]),
      );
      variation(
        'unicode',
        pattern('😮', unicode: true),
        accept: ['😮'],
        reject: ['x', 'z', '5', '\x00', '😃'],
        message: '[😮] expected',
        predicate: const SingleCharPredicate(128558),
      );
      variation(
        'negated',
        pattern('^y'),
        accept: ['x', 'z', '5', '\x00'],
        reject: ['y'],
        message: '[^y] expected',
        predicate: const NotCharPredicate(SingleCharPredicate(121)),
      );
    });
    group('multiple', () {
      variation(
        'default',
        pattern('ab-'),
        accept: ['a', 'b', '-'],
        reject: ['d', 'e', 'A', 'B', 'f'],
        message: '[ab-] expected',
        predicate: const LookupCharPredicate(45, 98, [1, 3145728]),
      );
      variation(
        'ignore-case',
        pattern('ab-', ignoreCase: true),
        accept: ['a', 'A', 'b', 'B', '-'],
        reject: ['c', 'C', '\x00', '&'],
        predicate: const LookupCharPredicate(45, 98, [3145729, 3145728]),
      );
      variation(
        'unicode',
        pattern('y😃💕', unicode: true),
        accept: ['y', '😃', '💕'],
        reject: ['x', 'z', '💞'],
        message: '[y😃💕] expected',
        predicate: isA<LookupCharPredicate>(),
      );
      variation(
        'negated',
        pattern('^ab-'),
        accept: ['d', 'e', 'f'],
        reject: ['a', 'b', '-'],
        message: '[^ab-] expected',
        predicate:
            const NotCharPredicate(LookupCharPredicate(45, 98, [1, 3145728])),
      );
    });
    group('range', () {
      variation(
        'default',
        pattern('a-c'),
        accept: ['a', 'b', 'c'],
        reject: ['d', 'e', 'f'],
        message: '[a-c] expected',
        predicate: const RangeCharPredicate(97, 99),
      );
      variation(
        'negated',
        pattern('^a-c'),
        accept: ['d', 'e', 'f'],
        reject: ['a', 'b', 'c'],
        message: '[^a-c] expected',
        predicate: const NotCharPredicate(RangeCharPredicate(97, 99)),
      );
      variation(
        'overlapping',
        pattern('b-da-c'),
        accept: ['a', 'b', 'c', 'd'],
        reject: ['e', 'f', 'g'],
        message: '[b-da-c] expected',
        predicate: const RangeCharPredicate(97, 100),
      );
      variation(
        'adjacent',
        pattern('c-ea-c'),
        accept: ['a', 'b', 'c', 'd', 'e'],
        reject: ['f'],
        message: '[c-ea-c] expected',
        predicate: const RangeCharPredicate(97, 101),
      );
      variation(
        'prefix',
        pattern('a-ea-c'),
        accept: ['a', 'b', 'c', 'd', 'e'],
        reject: ['f'],
        message: '[a-ea-c] expected',
        predicate: const RangeCharPredicate(97, 101),
      );
      variation(
        'postfix',
        pattern('a-ec-e'),
        accept: ['a', 'b', 'c', 'd', 'e'],
        reject: ['f'],
        message: '[a-ec-e] expected',
        predicate: const RangeCharPredicate(97, 101),
      );
      variation(
        'repeated',
        pattern('a-ea-e'),
        accept: ['a', 'b', 'c', 'd', 'e'],
        reject: ['f'],
        message: '[a-ea-e] expected',
        predicate: const RangeCharPredicate(97, 101),
      );
      variation(
        'composed',
        pattern('ac-df-'),
        accept: ['a', 'c', 'd', 'f', '-'],
        reject: ['b', 'e', 'g'],
        message: '[ac-df-] expected',
        predicate: const LookupCharPredicate(45, 102, [1, 47185920]),
      );
    });
    group('everything', () {
      variation(
        'default',
        pattern('\u{0000}-\u{ffff}'),
        accept: ['\u{0000}', '\u{ffff}'],
        reject: [],
        message: '[\\x00-\u{ffff}] expected',
        predicate: const ConstantCharPredicate(true),
      );
      variation(
        'ignore-case',
        pattern('\u{0000}-\u{ffff}', ignoreCase: true),
        accept: ['\u{0000}', '\u{ffff}'],
        reject: [],
        message: '[\\x00-￿] (case-insensitive) expected',
        predicate: const ConstantCharPredicate(true),
      );
      variation(
        'unicode',
        pattern('\u{0000}-\u{10ffff}', unicode: true),
        accept: ['\u{0000}', '\u{ffff}', '\u{10ffff}'],
        reject: [],
        message: '[\\x00-\u{10ffff}] expected',
        predicate: const ConstantCharPredicate(true),
      );
      variation(
        'negated',
        pattern('^\u{0000}-\u{ffff}'),
        accept: [],
        reject: ['\u{0000}', '\u{ffff}'],
        message: '[^\\x00-\u{ffff}] expected',
        predicate: const ConstantCharPredicate(false),
      );
      variation(
        'negated, unicode',
        pattern('^\u{0000}-\u{10ffff}', unicode: true),
        accept: [],
        reject: ['\u{0000}', '\u{ffff}', '\u{10ffff}'],
        message: '[^\\x00-\u{10ffff}] expected',
        predicate: const ConstantCharPredicate(false),
      );
    });
    group('nothing', () {
      variation(
        'default',
        pattern(''),
        accept: [],
        reject: ['\u{0000}', '\u{ffff}'],
        message: '[] expected',
        predicate: const ConstantCharPredicate(false),
      );
      variation(
        'unicode',
        pattern('', unicode: true),
        accept: [],
        reject: ['\u{0000}', '\u{ffff}'],
        message: '[] expected',
        predicate: const ConstantCharPredicate(false),
      );
      variation(
        'negated',
        pattern('^'),
        accept: ['\u{0000}', '\u{ffff}'],
        reject: [],
        message: '[^] expected',
        predicate: const ConstantCharPredicate(true),
      );
      variation(
        'negated, unicode',
        pattern('^', unicode: true),
        accept: ['\u{0000}', '\u{10ffff}'],
        reject: [],
        message: '[^] expected',
        predicate: const ConstantCharPredicate(true),
      );
    });
    // special
    variation(
      'large range',
      pattern('\u2200-\u22ff\u27c0-\u27ef\u2980-\u29ff'),
      accept: ['∉', '⟃', '⦻'],
      reject: ['a', '9', '*'],
      message: '[\u2200-\u22ff\u27c0-\u27ef\u2980-\u29ff] expected',
      predicate: isA<LookupCharPredicate>(),
    );
    // errors
    test('invalid range', () {
      expect(() => pattern('c-a'), throwsA(isAssertionError));
    }, skip: !hasAssertionsEnabled());
  });
  group('range', () {
    variation(
      'default',
      range('e', 'o'),
      accept: ['e', 'i', 'o'],
      reject: ['p', 'd', '9'],
      message: '[e-o] expected',
      predicate: const RangeCharPredicate(101, 111),
    );
    variation(
      'message',
      range('x', 'z', message: 'variable expected'),
      accept: ['x', 'y', 'z'],
      reject: ['p', 'd', '9'],
      message: 'variable expected',
      predicate: const RangeCharPredicate(120, 122),
    );
    variation(
      'unicode',
      range('😁', '😄', unicode: true),
      accept: ['😁', '😃', '😄'],
      reject: ['😀', '😅', '9'],
      message: '[😁-😄] expected',
      predicate: const RangeCharPredicate(128513, 128516),
    );
    test('invalid range', () {
      expect(() => range('o', 'e'), throwsA(isAssertionError));
    }, skip: !hasAssertionsEnabled());
    test('invalid character', () {
      expect(() => range('😃', '😍'), throwsA(isAssertionError));
    }, skip: !hasAssertionsEnabled());
  });
  group('uppercase', () {
    variation(
      'default',
      uppercase(),
      accept: ['A', 'L', 'R'],
      reject: ['3', 'z', '\t'],
      message: 'uppercase letter expected',
      predicate: const UppercaseCharPredicate(),
    );
    variation(
      'message',
      uppercase(message: 'only uppercase'),
      accept: ['X', 'Y', 'Z'],
      reject: ['0', '&', '\x00'],
      message: 'only uppercase',
      predicate: const UppercaseCharPredicate(),
    );
  });
  group('whitespace', () {
    const whitespaceCharCodes = {
      9, 10, 11, 12, 13, 32, 133, 160, 5760, 8192, 8193, 8194, 8195, 8196,
      8197, 8198, 8199, 8200, 8201, 8202, 8232, 8233, 8239, 8287, 12288,
      65279 //
    };
    final accept = [
      for (var c = 0; c <= 0x10000; c++)
        if (whitespaceCharCodes.contains(c)) String.fromCharCode(c)
    ];
    final reject = [
      for (var c = 0; c <= 0x10000; c++)
        if (!whitespaceCharCodes.contains(c)) String.fromCharCode(c)
    ];
    variation(
      'default',
      whitespace(),
      accept: accept,
      reject: reject,
      message: 'whitespace expected',
      predicate: const WhitespaceCharPredicate(),
    );
    variation(
      'message',
      whitespace(message: 'only blanks'),
      accept: [' ', '\t', '\r', '\f', '\r', '\n'],
      reject: ['3', 'z', '#', '0', '&', '\x00'],
      message: 'only blanks',
      predicate: const WhitespaceCharPredicate(),
    );
  });
  group('word', () {
    variation(
      'default',
      word(),
      accept: ['a', 'z', 'A', 'Z', '0', '9', '_'],
      reject: ['-', '#', '('],
      message: 'letter or digit expected',
      predicate: const WordCharPredicate(),
    );
    variation(
      'message',
      word(message: 'only word'),
      accept: ['L', 'F', 'R', '7'],
      reject: ['@', ':', '\x00'],
      message: 'only word',
      predicate: const WordCharPredicate(),
    );
  });
  group('stress', () {
    void stress(
      CharacterPredicate Function(List<RangeCharPredicate>) factory, {
      int repeat = 1000,
      int size = 1000,
      int maxGap = 100,
      int maxRange = 100,
      int seed = 81728392,
    }) {
      final random = Random(seed);
      for (var i = 0; i < repeat; i++) {
        var start = random.nextInt(maxGap);
        final ranges = <RangeCharPredicate>[];
        final included = List<bool>.filled(size + 1, false);
        while (true) {
          final end = start + random.nextInt(maxRange);
          if (end > size) break;
          ranges.add(RangeCharPredicate(start, end));
          included.fillRange(start, end + 1, true);
          start = random.nextInt(maxGap) + end + 1;
        }
        final lookup = factory(ranges);
        for (var i = 0; i <= size; i++) {
          expect(lookup.test(i), included[i]);
        }
      }
    }

    test('lookup', () => stress(LookupCharPredicate.fromRanges));
    test('ranges', () => stress(RangesCharPredicate.fromRanges));
  });
}
