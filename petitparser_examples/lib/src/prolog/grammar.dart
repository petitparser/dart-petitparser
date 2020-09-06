import 'package:petitparser/petitparser.dart';

/// Prolog grammar.
class PrologGrammar extends GrammarParser {
  PrologGrammar() : super(PrologGrammarDefinition());
}

/// Prolog grammar definition.
class PrologGrammarDefinition extends GrammarDefinition {
  Parser start() => throw UnsupportedError('Either parse rules or terms.');

  Parser<List> rules() => ref0(rule).star();
  Parser rule() =>
      ref0(term) &
      (ref0(DEFINITION) &
              ref0(term).separatedBy(ref0(COMMA), includeSeparators: false))
          .optional() &
      ref0(TERMINATOR);
  Parser term() =>
      ref0(atom) &
      (ref0(OPEN_PAREN) &
              ref0(parameter)
                  .separatedBy(ref0(COMMA), includeSeparators: false) &
              ref0(CLOSE_PAREN))
          .optional();
  Parser parameter() =>
      ref0(atom) &
      (ref0(OPEN_PAREN) &
              ref0(parameter)
                  .separatedBy(ref0(COMMA), includeSeparators: false) &
              ref0(CLOSE_PAREN))
          .optional();
  Parser atom() => ref0(variable) | ref0(value);

  Parser variable() => ref0(VARIABLE);
  Parser value() => ref0(VALUE);

  Parser space() => whitespace() | ref0(commentSingle) | ref0(commentMulti);
  Parser commentSingle() => char('%') & Token.newlineParser().neg().star();
  Parser commentMulti() => string('/*').starLazy(string('*/')) & string('*/');

  Parser token(Object parser, [String message]) {
    if (parser is Parser) {
      return parser.flatten(message).trim(ref0(space));
    } else if (parser is String) {
      return parser
          .toParser(message: message ?? '$parser expected')
          .trim(ref0(space));
    } else {
      throw ArgumentError.value(parser, 'parser', 'Invalid parser type');
    }
  }

  Parser VARIABLE() => ref2(
        token,
        pattern('A-Z_') & pattern('A-Za-z0-9_').star(),
        'Variable expected',
      );
  Parser VALUE() => ref2(
        token,
        pattern('a-z') & pattern('A-Za-z0-9_').star(),
        'Value expected',
      );
  Parser OPEN_PAREN() => ref1(token, '(');
  Parser CLOSE_PAREN() => ref1(token, ')');
  Parser COMMA() => ref1(token, ',');
  Parser TERMINATOR() => ref1(token, '.');
  Parser DEFINITION() => ref1(token, ':-');
}
