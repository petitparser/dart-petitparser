/// Streaming and iteration infrastructure for PetitParser.
///
/// This library provides tools for incremental, lazy, and chunked parsing
/// over in-memory [String] data and asynchronous [Stream] sources:
///
/// - [ParseIterable]: Lazily parses matches from an in-memory string as an [Iterable].
/// - [StreamParserExtension.parseIterable]: Extension to construct a [ParseIterable] directly from a parser.
/// - [StreamParserExtension.parseStream]: Parses an in-memory string as an asynchronous [Stream].
/// - [StreamParserExtension.parseStreamChunks]: Transforms a chunked [Stream] of [String] into
///   a stream of parsed elements across chunk boundaries.
/// - [ParseDecoder]: A [Converter] decoding string chunks into batches of parsed results.
/// - [ParseDecoderSink]: A [StringConversionSinkBase] accumulating chunk data and carrying
///   partial tokens across boundaries.
///
/// ### Parsing Modes
///
/// 1. **Contiguous matching** (default, `contiguous: true`, `delimiter: null`):
///    Matches must appear immediately adjacent without unparsed input in between.
/// 2. **Scanned matching** (`contiguous: false`, `delimiter: null`):
///    Unmatched characters between matches are skipped by sequentially scanning the input.
/// 3. **Delimiter-accelerated matching** (`delimiter: ...`):
///    Candidate positions are located using an optimized delimiter parser (such as
///    `char('@')` or `string('---')`), skipping irrelevant noise quickly and
///    resuming search on false alarms.
library;

import 'dart:convert';

import 'src/stream/parse_decoder.dart';
import 'src/stream/parse_decoder_sink.dart';
import 'src/stream/parse_iterable.dart';
import 'src/stream/stream_extensions.dart';

export 'src/stream/parse_decoder.dart';
export 'src/stream/parse_decoder_sink.dart';
export 'src/stream/parse_iterable.dart';
export 'src/stream/stream_extensions.dart';
