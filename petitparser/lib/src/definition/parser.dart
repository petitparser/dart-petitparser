import '../parser/combinator/delegate.dart';
import 'grammar.dart';

/// A helper to build a parser from a {@link GrammarDefinition}.
class GrammarParser extends DelegateParser {
  GrammarParser(GrammarDefinition definition) : super(definition.build());

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);
}
