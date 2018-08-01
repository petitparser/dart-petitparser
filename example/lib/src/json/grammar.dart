library petitparser.example.json.grammar;

import 'package:petitparser/petitparser.dart';

/// JSON grammar.
class JsonGrammar extends GrammarParser {
  JsonGrammar() : super(const JsonGrammarDefinition());
}

/// JSON grammar definition.
class JsonGrammarDefinition extends GrammarDefinition {
  const JsonGrammarDefinition();

  Parser start() => ref(value).end();
  Parser token(Parser parser) => parser.flatten().trim();

  Parser array() =>
      ref(token, char('[')) & ref(elements).optional() & ref(token, char(']'));
  Parser elements() =>
      ref(value).separatedBy(ref(token, char(',')), includeSeparators: false);
  Parser members() =>
      ref(pair).separatedBy(ref(token, char(',')), includeSeparators: false);
  Parser object() =>
      ref(token, char('{')) & ref(members).optional() & ref(token, char('}'));
  Parser pair() => ref(stringToken) & ref(token, char(':')) & ref(value);
  Parser value() =>
      ref(stringToken) |
      ref(numberToken) |
      ref(object) |
      ref(array) |
      ref(trueToken) |
      ref(falseToken) |
      ref(nullToken);

  Parser trueToken() => ref(token, string('true'));
  Parser falseToken() => ref(token, string('false'));
  Parser nullToken() => ref(token, string('null'));
  Parser stringToken() => ref(token, ref(stringPrimitive));
  Parser numberToken() => ref(token, ref(numberPrimitive));

  Parser characterPrimitive() =>
      ref(characterNormal) | ref(characterEscape) | ref(characterUnicode);
  Parser characterNormal() => pattern('^"\\');
  Parser characterEscape() => char('\\') & pattern(jsonEscapeChars.keys.join());
  Parser characterUnicode() => string('\\u') & pattern('0-9A-Fa-f').times(4);
  Parser numberPrimitive() =>
      char('-').optional() &
      char('0').or(digit().plus()) &
      char('.').seq(digit().plus()).optional() &
      pattern('eE')
          .seq(pattern('-+').optional())
          .seq(digit().plus())
          .optional();
  Parser stringPrimitive() =>
      char('"') & ref(characterPrimitive).star() & char('"');
}

const jsonEscapeChars = {
  '\\': '\\',
  '/': '/',
  '"': '"',
  'b': '\b',
  'f': '\f',
  'n': '\n',
  'r': '\r',
  't': '\t'
};
