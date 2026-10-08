import 'package:meta/meta.dart';

import '../core/context.dart';
import '../core/exception.dart';
import '../core/parser.dart';
import '../core/result.dart';
import 'delimiter.dart';

/// An [Iterable] that parses results of type [R] from an input [String].
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
/// final iterable = ParseIterable(parser, 'foo bar baz', contiguous: false);
/// print(iterable.toList()); // ['foo', 'bar', 'baz']
/// ```
@immutable
class ParseIterable<R> extends Iterable<R> {
  /// Creates a [ParseIterable] on [input] using [parser].
  ///
  /// If [delimiter] is provided, candidate match positions are located by
  /// searching for matches of [delimiter], skipping unparsed content in
  /// between.
  ///
  /// If [contiguous] is `true` (default) and [delimiter] is `null`, matches
  /// must be adjacent with no unparsed characters between them. If
  /// [contiguous] is `false`, unparsed characters between matches are skipped.
  const new(
    this.parser,
    this.input, {
    this.delimiter,
    this.contiguous = true,
    this.onMatch,
    this.onError,
    this.onClose,
  });

  /// The parser used to produce elements of type [R].
  final Parser<R> parser;

  /// The input string to parse.
  final String input;

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

  /// Callback invoked when iteration finishes or closes.
  final void Function({required int position, required String buffer})? onClose;

  @override
  Iterator<R> get iterator => ParseIterator<R>(
    parser,
    input,
    delimiter: delimiter,
    contiguous: contiguous,
    onMatch: onMatch,
    onError: onError,
    onClose: onClose,
  );
}

/// An [Iterator] that parses results of type [R] from an input [String].
class ParseIterator<R> implements Iterator<R> {
  /// Creates a [ParseIterator] on [input] using [parser].
  new(
    this.parser,
    this.input, {
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

  /// The input string to parse.
  final String input;

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

  /// Callback invoked when iteration finishes or closes.
  final void Function({required int position, required String buffer})? onClose;

  int _position = 0;
  bool _closed = false;
  late R _current;

  @override
  R get current => _current;

  @override
  bool moveNext() {
    if (_closed) return false;
    if (_delimiterSearcher != null) return _moveNextDelimited();
    if (contiguous) return _moveNextContiguous();
    return _moveNextScanned();
  }

  bool _moveNextDelimited() {
    final searcher = _delimiterSearcher!;
    while (_position <= input.length) {
      final candidate = searcher.find(input, _position);
      if (candidate == -1) break;
      if (parser.fastParseOn(input, candidate) >= 0) {
        final result = parser.parseOn(Context(input, candidate));
        if (result is Success<R>) {
          return _handleSuccess(result, candidate);
        }
      }
      _position = candidate + 1;
    }
    return _close(input.length);
  }

  bool _moveNextContiguous() {
    while (_position <= input.length) {
      final result = parser.parseOn(Context(input, _position));
      if (result is Success<R>) {
        return _handleSuccess(result, _position);
      }
      if (_position < input.length) {
        _handleFailure(result as Failure);
      } else {
        break;
      }
    }
    return _close(_position);
  }

  bool _moveNextScanned() {
    while (_position <= input.length) {
      if (parser.fastParseOn(input, _position) >= 0) {
        final result = parser.parseOn(Context(input, _position));
        if (result is Success<R>) {
          return _handleSuccess(result, _position);
        }
      }
      _position++;
    }
    return _close(input.length);
  }

  bool _handleSuccess(Success<R> success, int start) {
    final stop = success.position;
    _current = success.value;
    _position = stop > start ? stop : start + 1;
    onMatch?.call(success.value, start: start, stop: stop, buffer: input);
    return true;
  }

  void _handleFailure(Failure failure) {
    _position++;
    final onError = this.onError;
    if (onError != null) {
      onError(failure);
    } else {
      throw ParserException(failure);
    }
  }

  bool _close(int position) {
    _closed = true;
    onClose?.call(
      position: position > input.length ? input.length : position,
      buffer: input,
    );
    return false;
  }
}
