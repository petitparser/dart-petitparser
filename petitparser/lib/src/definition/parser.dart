import '../../buffer.dart';
import '../context/context.dart';
import '../context/result.dart';
import '../core/parser.dart';
import '../parser/combinator/delegate.dart';
import 'grammar.dart';

/// A helper to build a parser from a {@link GrammarDefinition}.
class GrammarParser extends DelegateParser {
  GrammarParser(GrammarDefinition definition) : this._(definition.build());

  GrammarParser._(Parser parser) : super(parser);

  @override
  Result parseOn(Context context) => delegate.parseOn(context);

  @override
  int fastParseOn(Buffer buffer, int position) =>
      delegate.fastParseOn(buffer, position);

  @override
  GrammarParser copy() => GrammarParser._(delegate);
}
