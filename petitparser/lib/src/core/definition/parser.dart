library petitparser.core.definition.parser;

import 'package:petitparser/src/core/combinators/delegate.dart';
import 'package:petitparser/src/core/definition/grammar.dart';

/// A helper to build a parser from a {@link GrammarDefinition}.
class GrammarParser extends DelegateParser {
  GrammarParser(GrammarDefinition definition) : super(definition.build());

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);
}
