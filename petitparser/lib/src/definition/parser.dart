import '../context/context.dart';
import '../context/result.dart';
import '../core/parser.dart';
import '../parser/combinator/delegate.dart';
import 'grammar.dart';

/// A helper to build a parser from a {@link GrammarDefinition}.
@Deprecated('Directly use the GrammarDefinition to build parsers.')
class GrammarParser<T> extends DelegateParser<T, T> {
  GrammarParser(GrammarDefinition definition) : this._(definition.build());

  GrammarParser._(Parser<T> parser) : super(parser);

  @override
  Result<T> parseOn(Context context) => delegate.parseOn(context);

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  GrammarParser<T> copy() => GrammarParser<T>._(delegate);
}
