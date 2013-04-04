// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of json;

/**
 * JSON grammar definition.
 */
class JsonGrammar extends CompositeParser {

  static final ESCAPE_TABLE = const {
    '\\': '\\',
    '/': '/',
    '"': '"',
    'b': '\b',
    'f': '\f',
    'n': '\n',
    'r': '\r',
    't': '\t'
  };

  void initialize() {
    start = value.end();

    elements = value.separatedBy(char(',').trim(), includeSeparators: false);
    members = pair.separatedBy(char(',').trim(), includeSeparators: false);

    array = char('[').trim()
        & elements.optional()
        & char(']').trim();
    object = char('{').trim()
        & members.optional()
        & char('}').trim();
    pair = stringToken
        & char(':').trim()
        & value;
    value = stringToken
        | numberToken
        | object
        | array
        | trueToken
        | falseToken
        | nullToken;

    trueToken = string('true').flatten().trim();
    falseToken = string('false').flatten().trim();
    nullToken = string('null').flatten().trim();
    stringToken = stringPrimitive.flatten().trim();
    numberToken = numberPrimitive.flatten().trim();

    characterPrimitive = characterEscape
        | characterOctal
        | characterNormal;
    characterEscape = char('\\')
        & anyIn(new List.from(ESCAPE_TABLE.keys));
    characterNormal = anyIn('"\\').neg();
    characterOctal = string('\\u')
        & pattern("0-9A-Fa-f").times(4).flatten();

    numberPrimitive = char('-').optional()
        & (char('0') | digit().plus())
        & (char('.') & digit().plus()).optional()
        & (anyIn('eE') & anyIn('-+').optional() & digit().plus()).optional();
    stringPrimitive = char('"')
        & characterPrimitive.star()
        & char('"');
  }

}