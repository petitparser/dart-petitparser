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
  Parser token(Object source, [String name]) {
    Parser parser;
    String expected;
    if (source is String) {
      if (source.length == 1) {
        parser = char(source);
      } else {
        parser = string(source);
      }
      expected = name ?? source;
    } else if (source is Parser) {
      parser = source;
      expected = name;
    } else {
      throw ArgumentError('Unknow token type: $source.');
    }
    if (expected == null) {
      throw ArgumentError('Missing token name: $source');
    }
    return parser.flatten(expected).trim();
  }

  Parser array() =>
      ref(token, '[') & ref(elements).optional() & ref(token, ']');
  Parser elements() =>
      ref(value).separatedBy(ref(token, ','), includeSeparators: false);
  Parser members() =>
      ref(pair).separatedBy(ref(token, ','), includeSeparators: false);
  Parser object() =>
      ref(token, '{') & ref(members).optional() & ref(token, '}');
  Parser pair() => ref(stringToken) & ref(token, ':') & ref(value);
  Parser value() =>
      ref(stringToken) |
      ref(numberToken) |
      ref(object) |
      ref(array) |
      ref(trueToken) |
      ref(falseToken) |
      ref(nullToken);

  Parser trueToken() => ref(token, 'true');
  Parser falseToken() => ref(token, 'false');
  Parser nullToken() => ref(token, 'null');
  Parser stringToken() => ref(token, ref(stringPrimitive), 'string');
  Parser numberToken() => ref(token, ref(numberPrimitive), 'number');

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

const Map<String, String> jsonEscapeChars = {
  '\\': '\\',
  '/': '/',
  '"': '"',
  'b': '\b',
  'f': '\f',
  'n': '\n',
  'r': '\r',
  't': '\t'
};
