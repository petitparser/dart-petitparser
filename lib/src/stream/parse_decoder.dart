import 'dart:convert';

import 'package:meta/meta.dart';

import '../core/exception.dart';
import '../core/parser.dart';
import '../core/result.dart';
import 'parse_decoder_sink.dart';
import 'parse_iterable.dart';

/// A [Converter] that decodes a [String] stream into batches of [List] of [R].
///
/// Parsing can operate in three modes depending on [delimiter] and [contiguous]:
/// 1. **Contiguous matching** (default, [contiguous] is `true`, [delimiter] is `null`):
///    Matches must be immediately adjacent without any unparsed characters between them.
///    Any unmatched input triggers an error (calling [onError] or throwing a [ParserException]).
/// 2. **Scanned matching** ([contiguous] is `false`, [delimiter] is `null`):
///    Unparsed input between matches is skipped. The input is scanned sequentially
///    for matches of [parser].
/// 3. **Delimiter-accelerated matching** ([delimiter] is provided):
///    Searches for occurrences of [delimiter] to locate candidate start positions
///    for [parser]. Input between matches is skipped up to each delimiter. If [parser]
///    fails at a candidate position, it is treated as a false alarm and search
///    resumes at the next delimiter candidate.
///
/// For example:
///
/// ```dart
/// final parser = letter().plus().flatten();
/// final decoder = ParseDecoder(parser, contiguous: false);
/// print(decoder.convert('foo bar baz')); // ['foo', 'bar', 'baz']
/// ```
@immutable
class ParseDecoder<R> extends Converter<String, List<R>> {
  /// Creates a [ParseDecoder] using [parser].
  ///
  /// If [delimiter] is provided, candidate match positions are located by
  /// searching for matches of [delimiter], skipping unparsed content in
  /// between.
  ///
  /// If [contiguous] is `true` (default) and [delimiter] is `null`, matches
  /// must be adjacent with no unparsed characters between them. If
  /// [contiguous] is `false`, unparsed characters between matches are skipped.
  const new(
    this.parser, {
    this.delimiter,
    this.contiguous = true,
    this.onMatch,
    this.onError,
    this.onClose,
  });

  /// The parser used to produce elements of type [R].
  final Parser<R> parser;

  /// Optional delimiter parser to accelerate candidate selection.
  ///
  /// When provided, candidate match positions are located by searching for
  /// matches of [delimiter] (such as `char('@')` or `string('---')`).
  /// Input before each delimiter is skipped. If [parser] fails to match at
  /// a candidate delimiter position, it is treated as a false alarm and search
  /// continues for the next candidate.
  ///
  /// When omitted (`null`), candidate matching behavior is controlled by [contiguous]:
  /// - If [contiguous] is `true`, matching starts immediately at the current
  ///   position; any unmatched character triggers an error.
  /// - If [contiguous] is `false`, matching scans sequentially through the
  ///   input, advancing one character at a time until [parser] succeeds.
  final Parser<dynamic>? delimiter;

  /// Whether matches must be adjacent without unparsed input between them.
  ///
  /// When `true` (default), every input position between matches must be
  /// matched by [parser]. If the parser fails at any position, a parse error
  /// is reported (by calling [onError] or throwing a [ParserException]).
  ///
  /// When `false`, arbitrary unparsed input between matches is skipped
  /// (scanned mode).
  final bool contiguous;

  /// Callback invoked when a match is produced.
  final void Function(
    R value, {
    required int start,
    required int stop,
    required String buffer,
  })?
  onMatch;

  /// Callback invoked when a parse failure occurs.
  final void Function(Failure failure)? onError;

  /// Callback invoked when conversion finishes or closes.
  final void Function({required int position, required String buffer})? onClose;

  @override
  List<R> convert(String input, [int start = 0, int? end]) {
    end = RangeError.checkValidRange(start, end, input.length);
    final target = (start == 0 && end == input.length)
        ? input
        : input.substring(start, end);
    return ParseIterable<R>(
      parser,
      target,
      delimiter: delimiter,
      contiguous: contiguous,
      onMatch: onMatch,
      onError: onError,
      onClose: onClose,
    ).toList();
  }

  @override
  StringConversionSink startChunkedConversion(Sink<List<R>> sink) =>
      ParseDecoderSink<R>(
        parser,
        sink,
        delimiter: delimiter,
        contiguous: contiguous,
        onMatch: onMatch,
        onError: onError,
        onClose: onClose,
      );
}
