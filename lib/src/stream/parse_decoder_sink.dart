import 'dart:convert';
import 'dart:math' as math;

import '../core/context.dart';
import '../core/exception.dart';
import '../core/parser.dart';
import '../core/result.dart';
import 'delimiter.dart';

/// A [StringConversionSinkBase] that converts chunks of [String] into [List] of [R].
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
/// final items = <String>[];
/// final parser = letter().plus().flatten();
/// final sink = ParseDecoderSink(parser, Sink.of(items.addAll), contiguous: false);
/// sink.add('foo bar');
/// sink.close();
/// ```
class ParseDecoderSink<R> extends StringConversionSinkBase {
  /// Creates a [ParseDecoderSink] that outputs to [sink].
  ///
  /// If [delimiter] is provided, candidate match positions are located by
  /// searching for matches of [delimiter], skipping unparsed content in
  /// between.
  ///
  /// If [contiguous] is `true` (default) and [delimiter] is `null`, matches
  /// must be adjacent with no unparsed characters between them. If
  /// [contiguous] is `false`, unparsed characters between matches are skipped.
  new(
    this.parser,
    this.sink, {
    this.delimiter,
    this.contiguous = true,
    this.onMatch,
    this.onError,
    this.onClose,
  }) : _delimiterSearcher = delimiter != null
           ? DelimiterSearcher(delimiter)
           : null;

  /// The parser used to produce elements of type [R].
  final Parser<R> parser;

  /// The destination sink for batches of parsed items.
  final Sink<List<R>> sink;

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

  final DelimiterSearcher? _delimiterSearcher;

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

  String _carry = '';
  int _offset = 0;
  bool _closed = false;

  @override
  void addSlice(String str, int start, int end, bool isLast) {
    if (_closed) return;
    end = RangeError.checkValidRange(start, end, str.length);
    if (start == end) {
      if (isLast) close();
      return;
    }

    final buffer = _carry + str.substring(start, end);
    _carry = '';
    final items = <R>[];

    final carryStart = _delimiterSearcher != null
        ? _processDelimited(buffer, items, isLast)
        : contiguous
        ? _processContiguous(buffer, items, isLast)
        : _processScanned(buffer, items, isLast);

    _carry = buffer.substring(carryStart);
    _offset += carryStart;

    if (items.isNotEmpty) {
      sink.add(items);
    }
    if (isLast) {
      close();
    }
  }

  int _processDelimited(String buffer, List<R> items, bool isLast) {
    final searcher = _delimiterSearcher!;
    var pos = 0;
    var carryStart = buffer.length;
    while (pos < buffer.length) {
      final candidate = searcher.find(buffer, pos);
      if (candidate == -1) {
        carryStart = _carryDelimiterBoundary(buffer, pos, isLast);
        break;
      }
      final result = parser.parseOn(Context(buffer, candidate));
      if (result is Success<R>) {
        pos = _recordMatch(buffer, candidate, result, items);
      } else if (_isFalseAlarm(
        searcher,
        buffer,
        candidate,
        result as Failure,
        isLast,
      )) {
        pos = candidate + 1;
      } else {
        carryStart = candidate;
        break;
      }
    }
    return carryStart;
  }

  bool _isFalseAlarm(
    DelimiterSearcher searcher,
    String buffer,
    int candidate,
    Failure failure,
    bool isLast,
  ) {
    if (isLast) return true;
    final nextCandidate = searcher.find(buffer, candidate + 1);
    return nextCandidate != -1 && failure.position <= nextCandidate;
  }

  int _carryDelimiterBoundary(String buffer, int pos, bool isLast) {
    if (isLast) return buffer.length;
    final overlap = math.min(buffer.length - pos, _delimiterSearcher!.overlap);
    return buffer.length - overlap;
  }

  int _processContiguous(String buffer, List<R> items, bool isLast) {
    var pos = 0;
    var carryStart = buffer.length;
    while (pos < buffer.length) {
      final result = parser.parseOn(Context(buffer, pos));
      if (result is Success<R>) {
        pos = _recordMatch(buffer, pos, result, items);
      } else if (isLast) {
        _handleFailure(buffer, result as Failure);
        pos++;
      } else {
        carryStart = pos;
        break;
      }
    }
    return carryStart;
  }

  int _processScanned(String buffer, List<R> items, bool isLast) {
    var pos = 0;
    var carryStart = buffer.length;
    while (pos < buffer.length) {
      final result = parser.parseOn(Context(buffer, pos));
      if (result is Success<R>) {
        pos = _recordMatch(buffer, pos, result, items);
      } else if (isLast || result.position < buffer.length) {
        pos++;
      } else {
        carryStart = pos;
        break;
      }
    }
    return carryStart;
  }

  int _recordMatch(
    String buffer,
    int start,
    Success<R> success,
    List<R> items,
  ) {
    final stop = success.position;
    items.add(success.value);
    onMatch?.call(
      success.value,
      start: _offset + start,
      stop: _offset + stop,
      buffer: buffer,
    );
    return stop > start ? stop : start + 1;
  }

  void _handleFailure(String buffer, Failure failure) {
    final globalFailure = Failure(
      buffer,
      _offset + failure.position,
      failure.message,
    );
    final onError = this.onError;
    if (onError != null) {
      onError(globalFailure);
    } else {
      throw ParserException(globalFailure);
    }
  }

  @override
  void close() {
    if (_closed) return;
    if (_carry.isNotEmpty) {
      final carry = _carry;
      _carry = '';
      addSlice(carry, 0, carry.length, true);
      return;
    }
    _closed = true;
    onClose?.call(position: _offset, buffer: '');
    sink.close();
  }
}
