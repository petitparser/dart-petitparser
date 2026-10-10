import 'dart:async';
import 'dart:convert';

import 'package:checks/checks.dart';
import 'package:petitparser/core.dart';
import 'package:petitparser/parser.dart';
import 'package:petitparser/stream.dart';
import 'package:test/scaffolding.dart';

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
          check(position).equals(6);
          check(buffer).equals('foobar');
        },
      );

      // 'foobar' as single word
      check(iterable.toList()).deepEquals(['foobar']);
      check(matches).deepEquals(['foobar']);
      check(starts).deepEquals([0]);
      check(stops).deepEquals([6]);
      check(closed).isTrue();
    });

    test('contiguous multiple tokens', () {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final iterable = token.parseIterable('<foo><bar><baz>');
      check(iterable.toList()).deepEquals(['<foo>', '<bar>', '<baz>']);
    });

    test('contiguous empty input', () {
      final parser = word;
      var closed = false;
      final iterable = parser.parseIterable(
        '',
        onClose: ({required position, required buffer}) {
          closed = true;
          check(position).equals(0);
          check(buffer).equals('');
        },
      );
      check(iterable.toList()).isEmpty();
      check(closed).isTrue();
    });

    test('contiguous error without onError throws ParserException', () {
      final parser = char('a');
      final iterator = parser.parseIterable('ab').iterator;
      check(iterator.moveNext()).isTrue();
      check(iterator.current).equals('a');
      check(iterator.moveNext).throws<ParserException>();
    });

    test('contiguous error resumption with try-catch', () {
      final parser = char('a');
      final iterator = parser.parseIterable('a!a?a').iterator;
      final results = <String>[];

      // 1st: 'a'
      check(iterator.moveNext()).isTrue();
      results.add(iterator.current);

      // 2nd: '!' fails, throws ParserException
      check(iterator.moveNext).throws<ParserException>();

      // 3rd: 'a' resumes at index 2
      check(iterator.moveNext()).isTrue();
      results.add(iterator.current);

      // 4th: '?' fails, throws ParserException
      check(iterator.moveNext).throws<ParserException>();

      // 5th: 'a' resumes at index 4
      check(iterator.moveNext()).isTrue();
      results.add(iterator.current);

      // End
      check(iterator.moveNext()).isFalse();
      check(results).deepEquals(['a', 'a', 'a']);
    });

    test('contiguous error resumption with onError callback', () {
      final parser = char('a');
      final errors = <Failure>[];
      final iterable = parser.parseIterable('a!a?a', onError: errors.add);
      check(iterable.toList()).deepEquals(['a', 'a', 'a']);
      check(errors.length).equals(2);
      check(errors[0].position).equals(1);
      check(errors[1].position).equals(3);
    });

    test('zero-width match does not infinite loop', () {
      final parser = char('a').optional();
      final iterable = parser.parseIterable('a');
      // pos 0: 'a', pos 1: EOF matches null with zero width
      check(iterable.toList()).deepEquals(['a', null]);
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
      check(closePos).equals(1);
    });

    test('zero-width epsilon match', () {
      final parser = epsilon();
      final iterable = parser.parseIterable('ab');
      // Matches at 0, 1, 2
      check(iterable.toList()).deepEquals([null, null, null]);
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
      check(iterable.toList()).deepEquals(['@foo{1}', '@bar{2}']);
    });

    test('false-alarm recovery', () {
      // @invalid (missing braces), @user@email.com, then valid @valid{123}
      const input = 'contact @user@domain.com or @invalid or @valid{123}';
      final iterable = entry.parseIterable(input, delimiter: char('@'));
      check(iterable.toList()).deepEquals(['@valid{123}']);
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
      check(iterable.toList()).deepEquals(['---a:1---', '---b:2---']);
    });

    test('arbitrary composite parser delimiter', () {
      final numEntry = (char('#') | char('\$')).seq(digit().plus()).flatten();
      const input = 'ignore #123 skip \$456 tail';
      final iterable = numEntry.parseIterable(
        input,
        delimiter: char('#') | char('\$'),
      );
      check(iterable.toList()).deepEquals(['#123', '\$456']);
    });

    test('scanned mode (contiguous: false, delimiter: null)', () {
      final parser = digit().plus().flatten();
      const input = 'abc 123 def 456 ghi';
      final iterable = parser.parseIterable(input, contiguous: false);
      check(iterable.toList()).deepEquals(['123', '456']);
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
      check(results)
          .deepEquals(['@article{key, title = "Value"}', '@book{key2}']);
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
      check(results).deepEquals(['###secOne###', '###secTwo###']);
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
      check(results).deepEquals(['@entry{val}']);
    });

    test(
      'candidate truncated at chunk boundary is carried and completed',
      () async {
        final chunks = Stream.fromIterable(['@entry{part1, ', 'part2}']);
        final results = await entry
            .parseStreamChunks(chunks, delimiter: char('@'))
            .toList();
        check(results).deepEquals(['@entry{part1, part2}']);
      },
    );

    test('contiguous chunked stream with split tokens', () async {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final chunks = Stream.fromIterable(['<fo', 'o><ba', 'r><baz>']);
      final results = await token
          .parseStreamChunks(chunks, contiguous: true)
          .toList();
      check(results).deepEquals(['<foo>', '<bar>', '<baz>']);
    });

    test('contiguous chunked stream throws on invalid syntax at EOF', () async {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final chunks = Stream.fromIterable(['<foo>', '<broken']);
      await check(token.parseStreamChunks(chunks, contiguous: true).toList())
          .throws<ParserException>(
            (it) => it.has((e) => e.offset, 'offset').equals(12),
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

      check(results).deepEquals(['<first>', '<second>', '<third>']);
      check(starts).deepEquals([0, 7, 15]);
      check(stops).deepEquals([7, 15, 22]);
    });

    test('scanned chunked stream', () async {
      final token = char('[').seq(digit().plus()).seq(char(']')).flatten();
      final chunks = Stream.fromIterable(['a[1', '2]b', '[34', '5]c']);
      final results = await token
          .parseStreamChunks(chunks, contiguous: false)
          .toList();
      check(results).deepEquals(['[12]', '[345]']);
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
        check(results).deepEquals(['@article{key}']);
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
      check(items).deepEquals(['<foo>']);
      sink.close();
      check(items).deepEquals(['<foo>']);
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
        check(items).isEmpty();
        check(sink.close).throws<ParserException>();
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
        check(results).deepEquals(['##foo##', r'$$bar$$']);
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
      check(results).deepEquals(['<-foo->']);
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
      check(results).deepEquals(['@entry{valid}']);
      check(starts).deepEquals([79]);
    });

    test('empty chunked streams', () async {
      check(
        await entry
            .parseStreamChunks(const Stream.empty(), delimiter: char('@'))
            .toList(),
      ).isEmpty();
      check(
        await entry
            .parseStreamChunks(const Stream.empty(), contiguous: false)
            .toList(),
      ).isEmpty();
      check(
        await entry
            .parseStreamChunks(const Stream.empty(), contiguous: true)
            .toList(),
      ).isEmpty();
    });

    test('only false alarms in stream ends cleanly', () async {
      final chunks = Stream.fromIterable(['@junk1 @junk2', ' @junk3']);
      final results = await entry
          .parseStreamChunks(chunks, delimiter: char('@'))
          .toList();
      check(results).isEmpty();
    });

    test('contiguous chunked stream with onError callback', () async {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final chunks = Stream.fromIterable(['<foo>', '!broken!', '<bar>']);
      final errors = <Failure>[];
      final results = await token
          .parseStreamChunks(chunks, contiguous: true, onError: errors.add)
          .toList();
      check(results).deepEquals(['<foo>', '<bar>']);
      check(errors).isNotEmpty();
    });

    test('contiguous chunked stream with failure within chunk preserves subsequent tokens', () async {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final chunks = Stream.fromIterable(['<foo>!<bar>', '<baz>']);
      final errors = <Failure>[];
      final results = await token
          .parseStreamChunks(chunks, contiguous: true, onError: errors.add)
          .toList();
      check(results).deepEquals(['<foo>', '<bar>', '<baz>']);
      check(errors.length).equals(1);
      check(errors.first.position).equals(5);
    });

    test('contiguous chunked stream with failure within chunk throws ParserException', () async {
      final token = char('<').seq(letter().plus()).seq(char('>')).flatten();
      final chunks = Stream.fromIterable(['<foo>!<bar>', '<baz>']);
      await check(token.parseStreamChunks(chunks, contiguous: true).toList())
          .throws<ParserException>();
    });

    test('delimited chunked stream false alarm without next delimiter in chunk does not leak carry', () async {
      final chunks = Stream.fromIterable([
        '@falseAlarm! but no other at symbol in this chunk',
        'another chunk with completely normal text and no delimiter',
        '@entry{valid}',
      ]);
      final results = await entry
          .parseStreamChunks(chunks, delimiter: char('@'))
          .toList();
      check(results).deepEquals(['@entry{valid}']);
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
      check(closePos).equals(11);
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
        check(results).deepEquals(expectedEntries);
      });
    }
  });

  group('stream extensions and converter', () {
    final parser = letter().plus().flatten();

    test('parseStream', () async {
      final stream = parser.parseStream('hello world', contiguous: false);
      check(await stream.toList()).deepEquals(['hello', 'world']);
    });

    test('toConverter and StringConversionSink', () {
      final converter = parser.toConverter(contiguous: false);
      final list = converter.convert('one two three');
      check(list).deepEquals(['one', 'two', 'three']);
    });

    test('parseWith extension on Stream<String>', () async {
      final stream = Stream.fromIterable(['alpha ', 'beta ', 'gamma']);
      final results = await stream
          .parseWith(parser, contiguous: false)
          .toList();
      check(results).deepEquals(['alpha', 'beta', 'gamma']);
    });

    test('parseStream with empty input and onClose', () async {
      var closed = false;
      final stream = parser.parseStream(
        '',
        onClose: ({required position, required buffer}) {
          closed = true;
          check(position).equals(0);
        },
      );
      check(await stream.toList()).isEmpty();
      check(closed).isTrue();
    });

    test('parseWith in contiguous and delimited modes', () async {
      final stream1 = Stream.fromIterable(['<foo>', '<bar>']);
      final r1 = await stream1
          .parseWith(
            char('<').seq(letter().plus()).seq(char('>')).flatten(),
            contiguous: true,
          )
          .toList();
      check(r1).deepEquals(['<foo>', '<bar>']);

      final stream2 = Stream.fromIterable(['ignore @val{1} ignore @val{2}']);
      final entry = char('@')
          .seq(letter().plus())
          .seq(char('{'))
          .seq(digit())
          .seq(char('}'))
          .flatten();
      final r2 = await stream2.parseWith(entry, delimiter: char('@')).toList();
      check(r2).deepEquals(['@val{1}', '@val{2}']);
    });
  });

  group('ParseDecoder', () {
    final parser = letter().plus().flatten();

    test('convert with slice start and end', () {
      final decoder = ParseDecoder(parser, contiguous: false);
      check(decoder.convert('foo 123 bar 456', 8, 11)).deepEquals(['bar']);
    });

    test('convert with slice start only', () {
      final decoder = ParseDecoder(parser, contiguous: false);
      check(decoder.convert('foo 123 bar', 8)).deepEquals(['bar']);
    });

    test('convert with start == end returns empty list', () {
      final decoder = ParseDecoder(parser, contiguous: false);
      check(decoder.convert('foo 123 bar', 5, 5)).isEmpty();
    });

    test('convert with invalid range throws RangeError', () {
      final decoder = ParseDecoder(parser, contiguous: false);
      check(() => decoder.convert('foo', 3, 1)).throws<RangeError>();
    });

    test('convert invokes callbacks', () {
      final matches = <String>[];
      var closed = false;
      final decoder = ParseDecoder(
        parser,
        contiguous: false,
        onMatch: (value, {required start, required stop, required buffer}) {
          matches.add(value);
        },
        onClose: ({required position, required buffer}) {
          closed = true;
        },
      );
      final list = decoder.convert('foo bar');
      check(list).deepEquals(['foo', 'bar']);
      check(matches).deepEquals(['foo', 'bar']);
      check(closed).isTrue();
    });

    test(
      'convert contiguous failure without onError throws ParserException',
      () {
        final decoder = ParseDecoder(char('a'), contiguous: true);
        check(() => decoder.convert('ab')).throws<ParserException>();
      },
    );

    test('convert contiguous failure with onError callback', () {
      final errors = <Failure>[];
      final decoder = ParseDecoder(
        char('a'),
        contiguous: true,
        onError: errors.add,
      );
      final list = decoder.convert('a!a');
      check(list).deepEquals(['a', 'a']);
      check(errors.length).equals(1);
      check(errors.single.position).equals(1);
    });
  });

  group('ParseDecoderSink edge cases', () {
    final word = letter().plus().flatten();

    test('addSlice and close on already closed sink does nothing', () {
      final items = <String>[];
      final sink = ParseDecoderSink<String>(
        word,
        _TestSink(items.addAll),
        contiguous: false,
      );
      sink.close();
      check(items).isEmpty();

      // Subsequent addSlice and close should be no-ops
      sink.addSlice('hello', 0, 5, false);
      sink.close();
      check(items).isEmpty();
    });

    test('addSlice with start == end and isLast == false is no-op', () {
      final items = <String>[];
      final sink = ParseDecoderSink<String>(
        word,
        _TestSink(items.addAll),
        contiguous: false,
      );
      sink.addSlice('abc', 1, 1, false);
      check(items).isEmpty();
      sink.addSlice('foo', 0, 3, true);
      check(items).deepEquals(['foo']);
    });

    test('addSlice with start == end and isLast == true closes sink', () {
      final items = <String>[];
      var closed = false;
      final sink = ParseDecoderSink<String>(
        word,
        _TestSink(items.addAll),
        contiguous: false,
        onClose: ({required position, required buffer}) {
          closed = true;
        },
      );
      sink.addSlice('abc', 1, 1, true);
      check(closed).isTrue();
    });

    test(
      'scanned chunked stream carries partial match at chunk boundary',
      () async {
        // 4-letter word across boundary
        final fourLetter = letter().repeat(4).flatten();
        final chunks = Stream.fromIterable(['123 ab', 'cd 456']);
        final results = await fourLetter
            .parseStreamChunks(chunks, contiguous: false)
            .toList();
        check(results).deepEquals(['abcd']);
      },
    );

    test('zero-width match in chunked stream advances position', () async {
      final opt = char('a').optional();
      final chunks = Stream.fromIterable(['a', 'b']);
      final results = await opt
          .parseStreamChunks(chunks, contiguous: true)
          .toList();
      check(results).deepEquals(['a', null]);
    });

    test('onMatch callback called in scanned chunked mode', () async {
      final numToken = digit().plus().flatten();
      final starts = <int>[];
      final stops = <int>[];
      final chunks = Stream.fromIterable(['x 12 ', 'y 34']);
      final results = await numToken
          .parseStreamChunks(
            chunks,
            contiguous: false,
            onMatch: (value, {required start, required stop, required buffer}) {
              starts.add(start);
              stops.add(stop);
            },
          )
          .toList();
      check(results).deepEquals(['12', '34']);
      check(starts).deepEquals([2, 7]);
      check(stops).deepEquals([4, 9]);
    });
  });

  group('ParseIterator edge cases', () {
    test('moveNext after iteration is finished returns false', () {
      final parser = char('a');
      final iterator = parser.parseIterable('a').iterator;
      check(iterator.moveNext()).isTrue();
      check(iterator.current).equals('a');
      check(iterator.moveNext()).isFalse();
      check(iterator.moveNext()).isFalse();
    });

    test('moveNext on empty string in scanned mode returns false', () {
      final parser = letter();
      var closed = false;
      final iterator = parser
          .parseIterable(
            '',
            contiguous: false,
            onClose: ({required position, required buffer}) {
              closed = true;
              check(position).equals(0);
            },
          )
          .iterator;
      check(iterator.moveNext()).isFalse();
      check(closed).isTrue();
      check(iterator.moveNext()).isFalse();
    });

    test('moveNext on empty string in delimited mode returns false', () {
      final parser = char('@').seq(letter()).flatten();
      var closed = false;
      final iterator = parser
          .parseIterable(
            '',
            delimiter: char('@'),
            onClose: ({required position, required buffer}) {
              closed = true;
              check(position).equals(0);
            },
          )
          .iterator;
      check(iterator.moveNext()).isFalse();
      check(closed).isTrue();
    });

    test('delimited mode with false alarm at end of string', () {
      final parser = char('@').seq(letter()).flatten();
      final iterator = parser.parseIterable('@', delimiter: char('@')).iterator;
      check(iterator.moveNext()).isFalse();
    });

    test('scanned mode with onMatch and onClose callbacks', () {
      final parser = digit().plus().flatten();
      final matches = <String>[];
      final starts = <int>[];
      var closedPos = 0;
      final iterable = parser.parseIterable(
        'a 12 b 34 c',
        contiguous: false,
        onMatch: (value, {required start, required stop, required buffer}) {
          matches.add(value);
          starts.add(start);
        },
        onClose: ({required position, required buffer}) {
          closedPos = position;
        },
      );
      check(iterable.toList()).deepEquals(['12', '34']);
      check(matches).deepEquals(['12', '34']);
      check(starts).deepEquals([2, 7]);
      check(closedPos).equals(11);
    });

    test('zero-width match in scanned mode does not infinite loop', () {
      final parser = char('a').optional();
      final iterable = parser.parseIterable('a', contiguous: false);
      check(iterable.toList()).deepEquals(['a', null]);
    });
  });

  group('DelimiterSearcher and overlap calculations', () {
    final entry = char('@')
        .seq(letter().plus())
        .seq(char('{'))
        .seq(noneOf('}').star())
        .seq(char('}'))
        .flatten();

    test('case-insensitive string delimiter fallback to fastParseOn', () {
      final delim = string('END', ignoreCase: true);
      final parser = delim.seq(digit().plus()).flatten();
      final iterable = parser.parseIterable(
        'junk end123 noise EnD456 tail',
        delimiter: delim,
      );
      check(iterable.toList()).deepEquals(['end123', 'EnD456']);
    });

    test('general predicate delimiter fallback to fastParseOn', () {
      final delim = digit();
      final parser = delim.seq(letter().plus()).flatten();
      final iterable = parser.parseIterable(
        'noise 1abc noise 2def tail',
        delimiter: delim,
      );
      check(iterable.toList()).deepEquals(['1abc', '2def']);
    });

    test('wrapped delimiter with flatten()', () async {
      final delim = string('---').flatten();
      final parser = delim.seq(word()).seq(delim).flatten();
      final chunks = Stream.fromIterable(['noise --', '-a--- tail']);
      final results = await parser
          .parseStreamChunks(chunks, delimiter: delim)
          .toList();
      check(results).deepEquals(['---a---']);
    });

    test('wrapped delimiter with trim()', () async {
      final delim = string('===');
      final parser = delim.seq(word()).seq(delim).flatten();
      final chunks = Stream.fromIterable(['noise ==', '=b=== tail']);
      final results = await parser
          .parseStreamChunks(chunks, delimiter: delim.trim())
          .toList();
      check(results).deepEquals(['===b===']);
    });

    test('sequence delimiter with wrapped children', () async {
      final delim = string('<!--').flatten() & string('->').flatten();
      final parser = delim.seq(word()).seq(delim).flatten();
      final chunks = Stream.fromIterable(['pre <!--', '->x<!---> post']);
      final results = await parser
          .parseStreamChunks(chunks, delimiter: delim)
          .toList();
      check(results).deepEquals(['<!--->x<!--->']);
    });

    test('nested sequence delimiter', () async {
      final delim = (char('<') & char('-')) & (char('-') & char('>'));
      final parser = delim.seq(word()).seq(delim).flatten();
      final chunks = Stream.fromIterable(['pre <--', '>z<--> post']);
      final results = await parser
          .parseStreamChunks(chunks, delimiter: delim)
          .toList();
      check(results).deepEquals(['<-->z<-->']);
    });

    test(
      'sequence delimiter with variable-length child reports 0 overlap',
      () async {
        final delim = char('<') & letter().star() & char('>');
        final parser = delim.seq(digit()).flatten();
        final iterable = parser.parseIterable(
          'noise <tag>1 noise <x>2',
          delimiter: delim,
        );
        check(iterable.toList()).deepEquals(['<tag>1', '<x>2']);
      },
    );

    test('choice delimiter with wrapped children', () async {
      final delim = string('##').flatten() | string(r'$$').trim();
      final parser = delim.seq(word()).flatten();
      final chunks = Stream.fromIterable([
        'noise #',
        '#a noise \$',
        '\$b tail',
      ]);
      final results = await parser
          .parseStreamChunks(chunks, delimiter: delim)
          .toList();
      check(results).deepEquals(['##a', r'$$b']);
    });

    test('character parser delimiter in chunked stream', () async {
      final chunks = Stream.fromIterable(['noise @', 'foo{1} tail']);
      final results = await entry
          .parseStreamChunks(chunks, delimiter: char('@'))
          .toList();
      check(results).deepEquals(['@foo{1}']);
    });

    test(
      'arbitrary non-literal non-character parser delimiter in chunked stream',
      () async {
        final delim = letter();
        final p = delim.seq(digit().plus()).flatten();
        final chunks = Stream.fromIterable(['... a', '1 ... b', '2 ...']);
        final results = await p
            .parseStreamChunks(chunks, delimiter: delim)
            .toList();
        check(results).deepEquals(['a1', 'b2']);
      },
    );
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
