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
      (ref(DEFINITION) & ref(term).separatedBy(ref(COMMA))).optional() &
      char(TERMINATOR);
  Parser term() =>
      ref(name) &
      (ref(OPEN_PAREN) & ref(term).separatedBy(ref(COMMA)) & ref(CLOSE_PAREN))
          .optional();
  Parser atom() => ref(name) | ref(number);

  Parser name() => ref(NAME);
  Parser number() => ref(NUMBER);

  Parser space() => whitespace() | ref(commentSingle) | ref(commentMulti);
  Parser commentSingle() => char('%') & Token.newlineParser().neg().star();
  Parser commentMulti() => string('/*').starLazy(string('*/')) & string('*/');

  Parser token(Object parser, [String message]) {
    if (parser is Parser) {
      return parser.flatten(message).trim(ref(space));
    } else if (parser is String) {
      return token(
        parser.length == 1 ? char(parser) : string(parser),
        message ?? '$parser expected',
      );
    } else {
      throw ArgumentError.value(parser, 'parser', 'Invalid parser type');
    }
  }

  Parser NAME() => ref(token, pattern('A-Za-z_') & pattern('A-Za-z0-9_').star(),
      'Name expected');
  Parser NUMBER() =>
      ref(token, pattern('+-').optional() & pattern('0-9').plus());
  Parser OPEN_PAREN() => ref(token, '(');
  Parser CLOSE_PAREN() => ref(token, ')');
  Parser COMMA() => ref(token, ',');
  Parser TERMINATOR() => ref(token, '.');
  Parser DEFINITION() => ref(token, ':-');
}
