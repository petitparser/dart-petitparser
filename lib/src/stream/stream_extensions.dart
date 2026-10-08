import 'dart:convert';

import '../core/parser.dart';
import '../core/result.dart';
import 'parse_decoder.dart';
import 'parse_iterable.dart';

/// Extension on [Parser] providing streaming and iteration capabilities.
extension StreamParserExtension<R> on Parser<R> {
  /// Returns a lazy [Iterable] of parse results of type [R] from [input].
  ///
  /// If [delimiter] is provided, candidate match positions are located by
  /// searching for matches of [delimiter], skipping unparsed content in
  /// between. If matching fails at a candidate position, it is treated as a
  /// false alarm and search resumes at the next candidate.
  ///
  /// If [contiguous] is `true` (default) and [delimiter] is `null`, matches
  /// must be adjacent with no unparsed characters between them. If
  /// [contiguous] is `false`, unparsed characters between matches are skipped.
  ///
  /// For example:
  ///
  /// ```dart
  /// final parser = letter().plus().flatten();
  /// final tokens = parser.parseIterable('foo bar baz', contiguous: false);
  /// print(tokens.toList()); // ['foo', 'bar', 'baz']
  /// ```
  Iterable<R> parseIterable(
    String input, {
    Parser<dynamic>? delimiter,
    bool contiguous = true,
    void Function(
      R value, {
      required int start,
      required int stop,
      required String buffer,
    })?
    onMatch,
    void Function(Failure failure)? onError,
    void Function({required int position, required String buffer})? onClose,
  }) => ParseIterable<R>(
    this,
    input,
    delimiter: delimiter,
    contiguous: contiguous,
    onMatch: onMatch,
    onError: onError,
    onClose: onClose,
  );

  /// Returns a progressive asynchronous [Stream] of [R] from [input].
  ///
  /// If [delimiter] is provided, candidate match positions are located by
  /// searching for matches of [delimiter], skipping unparsed content in
  /// between. If matching fails at a candidate position, it is treated as a
  /// false alarm and search resumes at the next candidate.
  ///
  /// If [contiguous] is `true` (default) and [delimiter] is `null`, matches
  /// must be adjacent with no unparsed characters between them. If
  /// [contiguous] is `false`, unparsed characters between matches are skipped.
  ///
  /// For example:
  ///
  /// ```dart
  /// final parser = letter().plus().flatten();
  /// final stream = parser.parseStream('hello world', contiguous: false);
  /// await for (final word in stream) {
  ///   print(word);
  /// }
  /// ```
  Stream<R> parseStream(
    String input, {
    Parser<dynamic>? delimiter,
    bool contiguous = true,
    void Function(
      R value, {
      required int start,
      required int stop,
      required String buffer,
    })?
    onMatch,
    void Function(Failure failure)? onError,
    void Function({required int position, required String buffer})? onClose,
  }) => Stream<R>.fromIterable(
    parseIterable(
      input,
      delimiter: delimiter,
      contiguous: contiguous,
      onMatch: onMatch,
      onError: onError,
      onClose: onClose,
    ),
  );

  /// Parses chunks of text from [stream] into a progressive [Stream] of [R].
  ///
  /// If [delimiter] is provided, candidate match positions are located by
  /// searching for matches of [delimiter], skipping unparsed content in
  /// between. If matching fails at a candidate position, it is treated as a
  /// false alarm and search resumes at the next candidate.
  ///
  /// If [contiguous] is `true` (default) and [delimiter] is `null`, matches
  /// must be adjacent with no unparsed characters between them. If
  /// [contiguous] is `false`, unparsed characters between matches are skipped.
  ///
  /// For example:
  ///
  /// ```dart
  /// final parser = char('@').seq(word()).flatten();
  /// final chunks = Stream.fromIterable(['@al', 'pha @be', 'ta']);
  /// final results = await parser
  ///     .parseStreamChunks(chunks, delimiter: char('@'))
  ///     .toList();
  /// print(results); // ['@alpha', '@beta']
  /// ```
  Stream<R> parseStreamChunks(
    Stream<String> stream, {
    Parser<dynamic>? delimiter,
    bool contiguous = true,
    void Function(
      R value, {
      required int start,
      required int stop,
      required String buffer,
    })?
    onMatch,
    void Function(Failure failure)? onError,
    void Function({required int position, required String buffer})? onClose,
  }) => stream
      .transform(
        toConverter(
          delimiter: delimiter,
          contiguous: contiguous,
          onMatch: onMatch,
          onError: onError,
          onClose: onClose,
        ),
      )
      .expand((elements) => elements);

  /// Returns a [Converter] that decodes a [String] stream into batches of [R].
  ///
  /// If [delimiter] is provided, candidate match positions are located by
  /// searching for matches of [delimiter], skipping unparsed content in
  /// between. If matching fails at a candidate position, it is treated as a
  /// false alarm and search resumes at the next candidate.
  ///
  /// If [contiguous] is `true` (default) and [delimiter] is `null`, matches
  /// must be adjacent with no unparsed characters between them. If
  /// [contiguous] is `false`, unparsed characters between matches are skipped.
  ///
  /// For example:
  ///
  /// ```dart
  /// final parser = letter().plus().flatten();
  /// final converter = parser.toConverter(contiguous: false);
  /// print(converter.convert('foo bar')); // ['foo', 'bar']
  /// ```
  Converter<String, List<R>> toConverter({
    Parser<dynamic>? delimiter,
    bool contiguous = true,
    void Function(
      R value, {
      required int start,
      required int stop,
      required String buffer,
    })?
    onMatch,
    void Function(Failure failure)? onError,
    void Function({required int position, required String buffer})? onClose,
  }) => ParseDecoder<R>(
    this,
    delimiter: delimiter,
    contiguous: contiguous,
    onMatch: onMatch,
    onError: onError,
    onClose: onClose,
  );
}

/// Extension on [Stream<String>] for fluent parser streaming.
extension ParseStreamStringExtension on Stream<String> {
  /// Parses this stream of strings using [parser].
  ///
  /// If [delimiter] is provided, candidate match positions are located by
  /// searching for matches of [delimiter], skipping unparsed content in
  /// between. If matching fails at a candidate position, it is treated as a
  /// false alarm and search resumes at the next candidate.
  ///
  /// If [contiguous] is `true` (default) and [delimiter] is `null`, matches
  /// must be adjacent with no unparsed characters between them. If
  /// [contiguous] is `false`, unparsed characters between matches are skipped.
  ///
  /// For example:
  ///
  /// ```dart
  /// final parser = letter().plus().flatten();
  /// final stream = Stream.fromIterable(['foo ', 'bar']);
  /// final results = await stream.parseWith(parser, contiguous: false).toList();
  /// print(results); // ['foo', 'bar']
  /// ```
  Stream<R> parseWith<R>(
    Parser<R> parser, {
    Parser<dynamic>? delimiter,
    bool contiguous = true,
    void Function(
      R value, {
      required int start,
      required int stop,
      required String buffer,
    })?
    onMatch,
    void Function(Failure failure)? onError,
    void Function({required int position, required String buffer})? onClose,
  }) => parser.parseStreamChunks(
    this,
    delimiter: delimiter,
    contiguous: contiguous,
    onMatch: onMatch,
    onError: onError,
    onClose: onClose,
  );
}
