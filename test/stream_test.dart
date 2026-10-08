import 'dart:async';
import 'dart:convert';

import 'package:petitparser/core.dart';
import 'package:petitparser/parser.dart';
import 'package:petitparser/stream.dart';
import 'package:test/test.dart';

void main() {
  group('parseIterable', () {
    final word = letter().plus().flatten();

    test('contiguous tokens', () {
      final parser = word;
      final matches = <String>[];
      final starts = <int>[];
      final stops = <int>[];
      var closed = false;

      final iterable = parser.parseIterable(
        'foobar',
        onMatch: (value, {required start, required stop, required buffer}) {
          matches.add(value);
          starts.add(start);
          stops.add(stop);
        },
        onClose: ({required position, required buffer}) {
          closed = true;
          expect(position, 6);
          expect(buffer, 'foobar');
        },
      );

      // 'foobar' as single word
      expect(iterable.toList(), ['foobar']);
      expect(matches, ['foobar']);
      expect(starts, [0]);
      expect(stops, [6]);
      expect(closed, isTrue);
    });

    test('contiguous multiple tokens', () {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final iterable = token.parseIterable('<foo><bar><baz>');
      expect(iterable.toList(), ['<foo>', '<bar>', '<baz>']);
    });

    test('contiguous empty input', () {
      final parser = word;
      var closed = false;
      final iterable = parser.parseIterable(
        '',
        onClose: ({required position, required buffer}) {
          closed = true;
          expect(position, 0);
          expect(buffer, '');
        },
      );
      expect(iterable.toList(), isEmpty);
      expect(closed, isTrue);
    });

    test('contiguous error without onError throws ParserException', () {
      final parser = char('a');
      final iterator = parser.parseIterable('ab').iterator;
      expect(iterator.moveNext(), isTrue);
      expect(iterator.current, 'a');
      expect(iterator.moveNext, throwsA(isA<ParserException>()));
    });

    test('contiguous error resumption with try-catch', () {
      final parser = char('a');
      final iterator = parser.parseIterable('a!a?a').iterator;
      final results = <String>[];

      // 1st: 'a'
      expect(iterator.moveNext(), isTrue);
      results.add(iterator.current);

      // 2nd: '!' fails, throws ParserException
      expect(iterator.moveNext, throwsA(isA<ParserException>()));

      // 3rd: 'a' resumes at index 2
      expect(iterator.moveNext(), isTrue);
      results.add(iterator.current);

      // 4th: '?' fails, throws ParserException
      expect(iterator.moveNext, throwsA(isA<ParserException>()));

      // 5th: 'a' resumes at index 4
      expect(iterator.moveNext(), isTrue);
      results.add(iterator.current);

      // End
      expect(iterator.moveNext(), isFalse);
      expect(results, ['a', 'a', 'a']);
    });

    test('contiguous error resumption with onError callback', () {
      final parser = char('a');
      final errors = <Failure>[];
      final iterable = parser.parseIterable('a!a?a', onError: errors.add);
      expect(iterable.toList(), ['a', 'a', 'a']);
      expect(errors.length, 2);
      expect(errors[0].position, 1);
      expect(errors[1].position, 3);
    });

    test('zero-width match does not infinite loop', () {
      final parser = char('a').optional();
      final iterable = parser.parseIterable('a');
      // pos 0: 'a', pos 1: EOF matches null with zero width
      expect(iterable.toList(), ['a', null]);
    });

    test('zero-width match at EOF reports position <= input.length', () {
      final parser = char('a').optional();
      int? closePos;
      final iterable = parser.parseIterable(
        'a',
        onClose: ({required position, required buffer}) {
          closePos = position;
        },
      );
      iterable.toList();
      expect(closePos, 1);
    });

    test('zero-width epsilon match', () {
      final parser = epsilon();
      final iterable = parser.parseIterable('ab');
      // Matches at 0, 1, 2
      expect(iterable.toList(), [null, null, null]);
    });
  });

  group('delimited parsing', () {
    // Delimited entry: @name{content}
    final entry = char('@')
        .seq(letter().plus())
        .seq(char('{'))
        .seq(noneOf('}').star())
        .seq(char('}'))
        .flatten();

    test('accelerated skipping of non-entry content', () {
      const input = 'some junk @foo{1} random text @bar{2} trailing';
      final iterable = entry.parseIterable(input, delimiter: char('@'));
      expect(iterable.toList(), ['@foo{1}', '@bar{2}']);
    });

    test('false-alarm recovery', () {
      // @invalid (missing braces), @user@email.com, then valid @valid{123}
      const input = 'contact @user@domain.com or @invalid or @valid{123}';
      final iterable = entry.parseIterable(input, delimiter: char('@'));
      expect(iterable.toList(), ['@valid{123}']);
    });

    test('multi-character delimiter', () {
      // Delimiter '---', entry: ---title:content---
      final entryParser = string('---')
          .seq(word())
          .seq(char(':'))
          .seq(word())
          .seq(string('---'))
          .flatten();
      const input = 'ignore this ---a:1--- ignore ---b:2--- tail';
      final iterable = entryParser.parseIterable(
        input,
        delimiter: string('---'),
      );
      expect(iterable.toList(), ['---a:1---', '---b:2---']);
    });

    test('arbitrary composite parser delimiter', () {
      final numEntry = (char('#') | char('\$')).seq(digit().plus()).flatten();
      const input = 'ignore #123 skip \$456 tail';
      final iterable = numEntry.parseIterable(
        input,
        delimiter: char('#') | char('\$'),
      );
      expect(iterable.toList(), ['#123', '\$456']);
    });

    test('scanned mode (contiguous: false, delimiter: null)', () {
      final parser = digit().plus().flatten();
      const input = 'abc 123 def 456 ghi';
      final iterable = parser.parseIterable(input, contiguous: false);
      expect(iterable.toList(), ['123', '456']);
    });
  });

  group('chunked stream parsing', () {
    final entry = char('@')
        .seq(letter().plus())
        .seq(char('{'))
        .seq(noneOf('}').star())
        .seq(char('}'))
        .flatten();

    test('tokens split across chunk boundaries', () async {
      final chunks = Stream.fromIterable([
        'some text @ar',
        'ticle{key, ti',
        'tle = "Value"} mo',
        're text @book{key2',
        '} end',
      ]);
      final results = await entry
          .parseStreamChunks(chunks, delimiter: char('@'))
          .toList();
      expect(results, ['@article{key, title = "Value"}', '@book{key2}']);
    });

    test('multi-character delimiter split across chunk boundaries', () async {
      final sectionParser = string('###')
          .seq(letter().plus())
          .seq(string('###'))
          .flatten();
      // '###' split into '##' and '#'
      final chunks = Stream.fromIterable([
        'intro text ##',
        '#secOne### middle text #',
        '##secTwo### end',
      ]);
      final results = await sectionParser
          .parseStreamChunks(chunks, delimiter: string('###'))
          .toList();
      expect(results, ['###secOne###', '###secTwo###']);
    });

    test('false alarm disambiguation at chunk boundary', () async {
      // Chunk 1 has a false alarm: '@incomplete' that fails before chunk end
      // Chunk 2 has valid '@entry{val}'
      final chunks = Stream.fromIterable([
        'text @falseAlarm! more text ',
        '@entry{val} and @anotherFalse',
      ]);
      final results = await entry
          .parseStreamChunks(chunks, delimiter: char('@'))
          .toList();
      expect(results, ['@entry{val}']);
    });

    test(
      'candidate truncated at chunk boundary is carried and completed',
      () async {
        final chunks = Stream.fromIterable(['@entry{part1, ', 'part2}']);
        final results = await entry
            .parseStreamChunks(chunks, delimiter: char('@'))
            .toList();
        expect(results, ['@entry{part1, part2}']);
      },
    );

    test('contiguous chunked stream with split tokens', () async {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final chunks = Stream.fromIterable(['<fo', 'o><ba', 'r><baz>']);
      final results = await token
          .parseStreamChunks(chunks, contiguous: true)
          .toList();
      expect(results, ['<foo>', '<bar>', '<baz>']);
    });

    test('contiguous chunked stream throws on invalid syntax at EOF', () async {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final chunks = Stream.fromIterable(['<foo>', '<broken']);
      expect(
        () => token.parseStreamChunks(chunks, contiguous: true).toList(),
        throwsA(isA<ParserException>().having((e) => e.offset, 'offset', 12)),
      );
    });

    test('global offset tracking', () async {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final starts = <int>[];
      final stops = <int>[];

      final chunks = Stream.fromIterable([
        '<first>',
        '<sec',
        'ond>',
        '<third>',
      ]);
      final results = await token
          .parseStreamChunks(
            chunks,
            contiguous: true,
            onMatch: (value, {required start, required stop, required buffer}) {
              starts.add(start);
              stops.add(stop);
            },
          )
          .toList();

      expect(results, ['<first>', '<second>', '<third>']);
      expect(starts, [0, 7, 15]);
      expect(stops, [7, 15, 22]);
    });

    test('scanned chunked stream', () async {
      final token = char('[').seq(digit().plus()).seq(char(']')).flatten();
      final chunks = Stream.fromIterable(['a[1', '2]b', '[34', '5]c']);
      final results = await token
          .parseStreamChunks(chunks, contiguous: false)
          .toList();
      expect(results, ['[12]', '[345]']);
    });

    test(
      'choice parser split across chunk boundaries in delimited mode',
      () async {
        final p1 = (string('@article{') & letter().plus() & char('}'))
            .flatten();
        final p2 = (string('@a') & char('!')).flatten();
        final parser = (p1 | p2).flatten();

        final chunks = Stream.fromIterable(['@article{key', '}']);
        final results = await parser
            .parseStreamChunks(chunks, delimiter: char('@'))
            .toList();
        expect(results, ['@article{key}']);
      },
    );

    test('explicit sink.close() drains carried data in contiguous mode', () {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final items = <String>[];
      final sink =
          token
                  .toConverter(contiguous: true)
                  .startChunkedConversion(_TestSink(items.addAll))
              as StringConversionSink;
      sink.addSlice('<foo', 0, 4, false);
      sink.addSlice('>junk', 0, 1, false);
      expect(items, ['<foo>']);
      sink.close();
      expect(items, ['<foo>']);
    });

    test(
      'explicit sink.close() throws on incomplete token in contiguous mode',
      () {
        final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
        final items = <String>[];
        final sink =
            token
                    .toConverter(contiguous: true)
                    .startChunkedConversion(_TestSink(items.addAll))
                as StringConversionSink;
        sink.addSlice('<foo', 0, 4, false);
        expect(items, isEmpty);
        expect(sink.close, throwsA(isA<ParserException>()));
      },
    );

    test(
      'multi-character choice delimiter split across chunk boundaries',
      () async {
        final parser = (string('##') | string(r'$$'))
            .seq(letter().plus())
            .seq(string('##') | string(r'$$'))
            .flatten();
        final chunks = Stream.fromIterable([
          'pre #',
          '#foo## mid \$',
          r'$bar$$ post',
        ]);
        final results = await parser
            .parseStreamChunks(chunks, delimiter: string('##') | string(r'$$'))
            .toList();
        expect(results, ['##foo##', r'$$bar$$']);
      },
    );

    test('sequence delimiter split across chunk boundaries', () async {
      final delim = char('<').seq(char('-'));
      final parser = delim
          .seq(letter().plus())
          .seq(char('-').seq(char('>')))
          .flatten();
      final chunks = Stream.fromIterable(['pre <', '-foo-> post']);
      final results = await parser
          .parseStreamChunks(chunks, delimiter: delim)
          .toList();
      expect(results, ['<-foo->']);
    });

    test('false alarm across chunk boundary before next valid entry', () async {
      final chunks = Stream.fromIterable([
        'some @invalid token that is not an entry ',
        'and even more noise without delimiter ',
        '@entry{valid}',
      ]);
      final starts = <int>[];
      final results = await entry
          .parseStreamChunks(
            chunks,
            delimiter: char('@'),
            onMatch: (value, {required start, required stop, required buffer}) {
              starts.add(start);
            },
          )
          .toList();
      expect(results, ['@entry{valid}']);
      expect(starts, [79]);
    });

    test('empty chunked streams', () async {
      expect(
        await entry
            .parseStreamChunks(const Stream.empty(), delimiter: char('@'))
            .toList(),
        isEmpty,
      );
      expect(
        await entry
            .parseStreamChunks(const Stream.empty(), contiguous: false)
            .toList(),
        isEmpty,
      );
      expect(
        await entry
            .parseStreamChunks(const Stream.empty(), contiguous: true)
            .toList(),
        isEmpty,
      );
    });

    test('only false alarms in stream ends cleanly', () async {
      final chunks = Stream.fromIterable(['@junk1 @junk2', ' @junk3']);
      final results = await entry
          .parseStreamChunks(chunks, delimiter: char('@'))
          .toList();
      expect(results, isEmpty);
    });

    test('contiguous chunked stream with onError callback', () async {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final chunks = Stream.fromIterable(['<foo>', '!broken!', '<bar>']);
      final errors = <Failure>[];
      final results = await token
          .parseStreamChunks(chunks, contiguous: true, onError: errors.add)
          .toList();
      expect(results, ['<foo>', '<bar>']);
      expect(errors, isNotEmpty);
    });

    test('onClose callback on chunked stream', () async {
      int? closePos;
      final chunks = Stream.fromIterable(['@entry{foo}']);
      await entry
          .parseStreamChunks(
            chunks,
            delimiter: char('@'),
            onClose: ({required position, required buffer}) {
              closePos = position;
            },
          )
          .toList();
      expect(closePos, 11);
    });
  });

  group('power-of-two chunk splits', () {
    final entry = char('@')
        .seq(letter().plus())
        .seq(char('{'))
        .seq(noneOf('}').star())
        .seq(char('}'))
        .flatten();

    final fullInput = StringBuffer();
    for (var i = 0; i < 50; i++) {
      fullInput.write('noise $i email@domain$i.com text ');
      fullInput.write('@entry$i{key$i, data = "val$i"} ');
      fullInput.write('more noise $i\n');
    }
    final content = fullInput.toString();
    final expectedEntries = entry
        .parseIterable(content, delimiter: char('@'))
        .toList();

    for (var power = 0; power <= 9; power++) {
      final chunkSize = 1 << power; // 1, 2, 4, 8, ..., 512
      test('chunk size $chunkSize ($power-of-two)', () async {
        final chunks = <String>[];
        for (var i = 0; i < content.length; i += chunkSize) {
          final end = (i + chunkSize < content.length)
              ? i + chunkSize
              : content.length;
          chunks.add(content.substring(i, end));
        }

        final stream = Stream.fromIterable(chunks);
        final results = await entry
            .parseStreamChunks(stream, delimiter: char('@'))
            .toList();
        expect(results, expectedEntries);
      });
    }
  });

  group('stream extensions and converter', () {
    final parser = letter().plus().flatten();

    test('parseStream', () async {
      final stream = parser.parseStream('hello world', contiguous: false);
      expect(await stream.toList(), ['hello', 'world']);
    });

    test('toConverter and StringConversionSink', () {
      final converter = parser.toConverter(contiguous: false);
      final list = converter.convert('one two three');
      expect(list, ['one', 'two', 'three']);
    });

    test('parseWith extension on Stream<String>', () async {
      final stream = Stream.fromIterable(['alpha ', 'beta ', 'gamma']);
      final results = await stream
          .parseWith(parser, contiguous: false)
          .toList();
      expect(results, ['alpha', 'beta', 'gamma']);
    });
  });
}

class _TestSink<T> implements Sink<T> {
  const new(this.callback);

  final void Function(T) callback;

  @override
  void add(T data) => callback(data);

  @override
  void close() {}
}
