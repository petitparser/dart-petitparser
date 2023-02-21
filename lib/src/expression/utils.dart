import '../core/parser.dart';
import '../parser/combinator/choice.dart';

// Internal helper to build an optimal choice parser.
Parser<T> buildChoice<T>(List<Parser<T>> parsers) =>
    parsers.length == 1 ? parsers.first : parsers.toChoiceParser();
