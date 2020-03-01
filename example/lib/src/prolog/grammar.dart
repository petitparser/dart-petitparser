library petitparser.example.prolog.grammar;

import 'package:petitparser/petitparser.dart';

/// Prolog grammar.
class PrologGrammar extends GrammarParser {
  PrologGrammar() : super(PrologGrammarDefinition());
}

/// Prolog grammar definition.
class PrologGrammarDefinition extends GrammarDefinition {
  Parser start() => throw UnsupportedError('Either parse rules or terms.');

  Parser rules() => ref(rule).star();
  Parser rule() =>
      ref(term) &
      (ref(DEFINITION) &
              ref(term).separatedBy(ref(COMMA), includeSeparators: false))
          .optional() &
      ref(TERMINATOR);
  Parser term() =>
      ref(atom) &
      (ref(OPEN_PAREN) &
              ref(parameter).separatedBy(ref(COMMA), includeSeparators: false) &
              ref(CLOSE_PAREN))
          .optional();
  Parser parameter() =>
      ref(atom) &
      (ref(OPEN_PAREN) &
              ref(parameter).separatedBy(ref(COMMA), includeSeparators: false) &
              ref(CLOSE_PAREN))
          .optional();
  Parser atom() => ref(variable) | ref(value);

  Parser variable() => ref(VARIABLE);
  Parser value() => ref(VALUE);

  Parser space() => whitespace() | ref(commentSingle) | ref(commentMulti);
  Parser commentSingle() => char('%') & Token.newlineParser().neg().star();
  Parser commentMulti() => string('/*').starLazy(string('*/')) & string('*/');

  Parser token(Object parser, [String message]) {
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

  Parser VARIABLE() => ref(
        token,
        pattern('A-Z_') & pattern('A-Za-z0-9_').star(),
        'Variable expected',
      );
  Parser VALUE() => ref(
        token,
        pattern('a-z') & pattern('A-Za-z0-9_').star(),
        'Value expected',
      );
  Parser OPEN_PAREN() => ref(token, '(');
  Parser CLOSE_PAREN() => ref(token, ')');
  Parser COMMA() => ref(token, ',');
  Parser TERMINATOR() => ref(token, '.');
  Parser DEFINITION() => ref(token, ':-');
}
