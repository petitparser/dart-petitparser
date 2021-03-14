import 'package:petitparser/petitparser.dart';

/// Prolog grammar.
class PrologGrammar extends GrammarParser {
  PrologGrammar() : super(PrologGrammarDefinition());
}

/// Prolog grammar definition.
class PrologGrammarDefinition extends GrammarDefinition {
  Parser start() => throw UnsupportedError('Either parse rules or terms.');

  Parser<List> rules() => ref(rule).star();
  Parser rule() =>
      ref(term) &
      (ref(definitionToken) &
              ref(term).separatedBy(ref(commaToken), includeSeparators: false))
          .optional() &
      ref(terminatorToken);
  Parser term() =>
      ref(atom) &
      (ref(openParenToken) &
              ref(parameter)
                  .separatedBy(ref(commaToken), includeSeparators: false) &
              ref(closeParentToken))
          .optional();
  Parser parameter() =>
      ref(atom) &
      (ref(openParenToken) &
              ref(parameter)
                  .separatedBy(ref(commaToken), includeSeparators: false) &
              ref(closeParentToken))
          .optional();
  Parser atom() => ref(variable) | ref(value);

  Parser variable() => ref(variableToken);
  Parser value() => ref(valueToken);

  Parser space() => whitespace() | ref(commentSingle) | ref(commentMulti);
  Parser commentSingle() => char('%') & Token.newlineParser().neg().star();
  Parser commentMulti() => string('/*').starLazy(string('*/')) & string('*/');

  Parser token(Object parser, [String? message]) {
    if (parser is Parser) {
      return parser.flatten(message).trim(ref(space));
    } else if (parser is String) {
      return parser
          .toParser(message: message ?? '$parser expected')
          .trim(ref(space));
    } else {
      throw ArgumentError.value(parser, 'parser', 'Invalid parser type');
    }
  }

  Parser variableToken() => ref(
        token,
        pattern('A-Z_') & pattern('A-Za-z0-9_').star(),
        'Variable expected',
      );
  Parser valueToken() => ref(
        token,
        pattern('a-z') & pattern('A-Za-z0-9_').star(),
        'Value expected',
      );
  Parser openParenToken() => ref(token, '(');
  Parser closeParentToken() => ref(token, ')');
  Parser commaToken() => ref(token, ',');
  Parser terminatorToken() => ref(token, '.');
  Parser definitionToken() => ref(token, ':-');
}
