import '../context/context.dart';
import '../context/result.dart';
import '../core/parser.dart';
import '../parser/combinator/delegate.dart';
import 'grammar.dart';

/// A helper to build a parser from a {@link GrammarDefinition}.
class GrammarParser<T> extends DelegateParser<T> {
  GrammarParser(GrammarDefinition<T> definition) : super(definition.build());

  GrammarParser._(Parser definition) : super(definition);

  @override
  Result<T> parseOn(Context context) => delegate.parseOn(context) as Result<T>;

  @override
  int fastParseOn(String buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  GrammarParser<T> copy() => GrammarParser<T>._(delegate);
}
