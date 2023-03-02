import '../core/parser.dart';
import '../parser/combinator/choice.dart';

// Internal helper to build an optimal choice parser.
Parser<R> buildChoice<R>(List<Parser<R>> parsers) =>
    parsers.length == 1 ? parsers.first : parsers.toChoiceParser();
