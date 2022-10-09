// AUTO-GENERATED CODE: DO NOT EDIT

import '../../core/parser.dart';
import 'generated/sequence_map_2.dart';
import 'generated/sequence_map_3.dart';
import 'generated/sequence_map_4.dart';
import 'generated/sequence_map_5.dart';
import 'generated/sequence_map_6.dart';
import 'generated/sequence_map_7.dart';
import 'generated/sequence_map_8.dart';
import 'generated/sequence_map_9.dart';

/// Creates a parser that consumes a sequence of 2 typed parsers and combines
/// the successful parse with a [callback] to a result of type [R].
Parser<R> seqMap2<R1, R2, R>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  R Function(R1, R2) callback,
) =>
    SequenceMapParser2<R1, R2, R>(parser1, parser2, callback);

/// Creates a parser that consumes a sequence of 3 typed parsers and combines
/// the successful parse with a [callback] to a result of type [R].
Parser<R> seqMap3<R1, R2, R3, R>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  R Function(R1, R2, R3) callback,
) =>
    SequenceMapParser3<R1, R2, R3, R>(parser1, parser2, parser3, callback);

/// Creates a parser that consumes a sequence of 4 typed parsers and combines
/// the successful parse with a [callback] to a result of type [R].
Parser<R> seqMap4<R1, R2, R3, R4, R>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  Parser<R4> parser4,
  R Function(R1, R2, R3, R4) callback,
) =>
    SequenceMapParser4<R1, R2, R3, R4, R>(
        parser1, parser2, parser3, parser4, callback);

/// Creates a parser that consumes a sequence of 5 typed parsers and combines
/// the successful parse with a [callback] to a result of type [R].
Parser<R> seqMap5<R1, R2, R3, R4, R5, R>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  Parser<R4> parser4,
  Parser<R5> parser5,
  R Function(R1, R2, R3, R4, R5) callback,
) =>
    SequenceMapParser5<R1, R2, R3, R4, R5, R>(
        parser1, parser2, parser3, parser4, parser5, callback);

/// Creates a parser that consumes a sequence of 6 typed parsers and combines
/// the successful parse with a [callback] to a result of type [R].
Parser<R> seqMap6<R1, R2, R3, R4, R5, R6, R>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  Parser<R4> parser4,
  Parser<R5> parser5,
  Parser<R6> parser6,
  R Function(R1, R2, R3, R4, R5, R6) callback,
) =>
    SequenceMapParser6<R1, R2, R3, R4, R5, R6, R>(
        parser1, parser2, parser3, parser4, parser5, parser6, callback);

/// Creates a parser that consumes a sequence of 7 typed parsers and combines
/// the successful parse with a [callback] to a result of type [R].
Parser<R> seqMap7<R1, R2, R3, R4, R5, R6, R7, R>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  Parser<R4> parser4,
  Parser<R5> parser5,
  Parser<R6> parser6,
  Parser<R7> parser7,
  R Function(R1, R2, R3, R4, R5, R6, R7) callback,
) =>
    SequenceMapParser7<R1, R2, R3, R4, R5, R6, R7, R>(parser1, parser2, parser3,
        parser4, parser5, parser6, parser7, callback);

/// Creates a parser that consumes a sequence of 8 typed parsers and combines
/// the successful parse with a [callback] to a result of type [R].
Parser<R> seqMap8<R1, R2, R3, R4, R5, R6, R7, R8, R>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  Parser<R4> parser4,
  Parser<R5> parser5,
  Parser<R6> parser6,
  Parser<R7> parser7,
  Parser<R8> parser8,
  R Function(R1, R2, R3, R4, R5, R6, R7, R8) callback,
) =>
    SequenceMapParser8<R1, R2, R3, R4, R5, R6, R7, R8, R>(parser1, parser2,
        parser3, parser4, parser5, parser6, parser7, parser8, callback);

/// Creates a parser that consumes a sequence of 9 typed parsers and combines
/// the successful parse with a [callback] to a result of type [R].
Parser<R> seqMap9<R1, R2, R3, R4, R5, R6, R7, R8, R9, R>(
  Parser<R1> parser1,
  Parser<R2> parser2,
  Parser<R3> parser3,
  Parser<R4> parser4,
  Parser<R5> parser5,
  Parser<R6> parser6,
  Parser<R7> parser7,
  Parser<R8> parser8,
  Parser<R9> parser9,
  R Function(R1, R2, R3, R4, R5, R6, R7, R8, R9) callback,
) =>
    SequenceMapParser9<R1, R2, R3, R4, R5, R6, R7, R8, R9, R>(
        parser1,
        parser2,
        parser3,
        parser4,
        parser5,
        parser6,
        parser7,
        parser8,
        parser9,
        callback);
