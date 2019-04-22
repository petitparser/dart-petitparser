library petitparser.example.lisp.grammar;

import 'package:petitparser/petitparser.dart';

/// LISP grammar.
class LispGrammar extends GrammarParser {
  LispGrammar() : super(LispGrammarDefinition());
}

/// LISP grammar definition.
class LispGrammarDefinition extends GrammarDefinition {
  Parser start() => ref(atom).star().end();

  Parser atom() => ref(atom_).trim(ref(space));
  Parser atom_() =>
      ref(list) |
      ref(number) |
      ref(string) |
      ref(symbol) |
      ref(quote) |
      ref(quasiquote) |
      ref(unquote) |
      ref(splice);

  Parser list() =>
      ref(bracket, '()', ref(cells)) |
      ref(bracket, '[]', ref(cells)) |
      ref(bracket, '{}', ref(cells));
  Parser cells() => ref(cell) | ref(empty);
  Parser cell() => ref(atom) & ref(cells);
  Parser empty() => ref(space).star();

  Parser number() => ref(number_).flatten('Number expected');
  Parser number_() =>
      anyIn('-+').optional() &
      char('0').or(digit().plus()) &
      char('.').seq(digit().plus()).optional() &
      anyIn('eE').seq(anyIn('-+').optional()).seq(digit().plus()).optional();

  Parser string() => ref(bracket, '""', ref(character).star());
  Parser character() => ref(characterEscape) | ref(characterRaw);
  Parser characterEscape() => char('\\') & any();
  Parser characterRaw() => pattern('^"');

  Parser symbol() => ref(symbol_).flatten('Symbol expected');
  Parser symbol_() =>
      pattern('a-zA-Z!#\$%&*/:<=>?@\\^_|~+-') &
      pattern('a-zA-Z0-9!#\$%&*/:<=>?@\\^_|~+-').star();

  Parser quote() => char('\'') & ref(list);
  Parser quasiquote() => char('`') & ref(list);
  Parser unquote() => char(',') & ref(list);
  Parser splice() => char('@') & ref(list);

  Parser space() => whitespace() | ref(comment);
  Parser comment() => char(';') & Token.newlineParser().neg().star();
  Parser bracket(String brackets, Parser parser) =>
      char(brackets[0]) & parser & char(brackets[1]);
}
