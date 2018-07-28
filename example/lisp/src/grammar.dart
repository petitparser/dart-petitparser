library petitparser.example.lisp.grammar;

import 'package:petitparser/petitparser.dart';

/// LISP grammar.
class LispGrammar extends GrammarParser {
  LispGrammar() : super(LispGrammarDefinition());
}

/// LISP grammar definition.
class LispGrammarDefinition extends GrammarDefinition {
  start() => ref(atom).star().end();

  atom() => ref(atom_).trim(ref(space));
  atom_() =>
      ref(list) |
      ref(number) |
      ref(string) |
      ref(symbol) |
      ref(quote) |
      ref(quasiquote) |
      ref(unquote) |
      ref(splice);

  list() =>
      ref(bracket, '()', ref(cells)) |
      ref(bracket, '[]', ref(cells)) |
      ref(bracket, '{}', ref(cells));
  cells() => ref(cell) | ref(empty);
  cell() => ref(atom) & ref(cells);
  empty() => ref(space).star();

  number() => ref(number_).flatten();
  number_() =>
      anyIn('-+').optional() &
      char('0').or(digit().plus()) &
      char('.').seq(digit().plus()).optional() &
      anyIn('eE').seq(anyIn('-+').optional()).seq(digit().plus()).optional();

  string() => ref(bracket, '""', ref(character).star());
  character() => ref(characterEscape) | ref(characterRaw);
  characterEscape() => char('\\') & any();
  characterRaw() => pattern('^"');

  symbol() => ref(symbol_).flatten();
  symbol_() =>
      pattern('a-zA-Z!#\$%&*/:<=>?@\\^_|~+-') &
      pattern('a-zA-Z0-9!#\$%&*/:<=>?@\\^_|~+-').star();

  quote() => char('\'') & ref(list);
  quasiquote() => char('`') & ref(list);
  unquote() => char(',') & ref(list);
  splice() => char('@') & ref(list);

  space() => whitespace() | ref(comment);
  comment() => char(';') & Token.newlineParser().neg().star();
  bracket(String brackets, Parser parser) =>
      char(brackets[0]) & parser & char(brackets[1]);
}
