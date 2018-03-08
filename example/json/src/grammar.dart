library petitparser.example.json.grammar;

import 'package:petitparser/petitparser.dart';

/// JSON grammar.
class JsonGrammar extends GrammarParser {
  JsonGrammar() : super(const JsonGrammarDefinition());
}

/// JSON grammar definition.
class JsonGrammarDefinition extends GrammarDefinition {
  const JsonGrammarDefinition();

  start() => ref(value).end();
  token(Parser p) => p.flatten().trim();

  array() =>
      ref(token, char('[')) & ref(elements).optional() & ref(token, char(']'));
  elements() =>
      ref(value).separatedBy(ref(token, char(',')), includeSeparators: false);
  members() =>
      ref(pair).separatedBy(ref(token, char(',')), includeSeparators: false);
  object() =>
      ref(token, char('{')) & ref(members).optional() & ref(token, char('}'));
  pair() => ref(stringToken) & ref(token, char(':')) & ref(value);
  value() =>
      ref(stringToken) |
      ref(numberToken) |
      ref(object) |
      ref(array) |
      ref(trueToken) |
      ref(falseToken) |
      ref(nullToken);

  trueToken() => ref(token, string('true'));
  falseToken() => ref(token, string('false'));
  nullToken() => ref(token, string('null'));
  stringToken() => ref(token, ref(stringPrimitive));
  numberToken() => ref(token, ref(numberPrimitive));

  characterPrimitive() =>
      ref(characterNormal) | ref(characterEscape) | ref(characterUnicode);
  characterNormal() => pattern('^"\\');
  characterEscape() => char('\\') & pattern(jsonEscapeChars.keys.join());
  characterUnicode() => string('\\u') & pattern('0-9A-Fa-f').times(4);
  numberPrimitive() =>
      char('-').optional() &
      char('0').or(digit().plus()) &
      char('.').seq(digit().plus()).optional() &
      pattern('eE')
          .seq(pattern('-+').optional())
          .seq(digit().plus())
          .optional();
  stringPrimitive() => char('"') & ref(characterPrimitive).star() & char('"');
}

const jsonEscapeChars = const {
  '\\': '\\',
  '/': '/',
  '"': '"',
  'b': '\b',
  'f': '\f',
  'n': '\n',
  'r': '\r',
  't': '\t'
};
