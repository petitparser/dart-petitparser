// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * JSON grammar definition.
 */
class JsonGrammar extends CompositeParser {

  void initialize() {
    define('start', ref('value').end());

    define('array',
      char('[').trim()
        .seq(ref('elements').optional())
        .seq(char(']').trim()));
    define('elements',
      ref('value').separatedBy(char(',').trim()));
    define('members',
      ref('pair').separatedBy(char(',').trim()));
    define('object',
      char('{').trim()
        .seq(ref('members').optional())
        .seq(char('}').trim()));
    define('pair',
      ref('stringToken')
        .seq(char(':').trim())
        .seq(ref('value')));
    define('value',
      ref('stringToken')
        .or(ref('numberToken'))
        .or(ref('object'))
        .or(ref('array'))
        .or(ref('trueToken'))
        .or(ref('falseToken'))
        .or(ref('nullToken')));

    define('trueToken', string('true').flatten().trim());
    define('falseToken', string('false').flatten().trim());
    define('nullToken', string('null').flatten().trim());
    define('stringToken', ref('stringPrimitive').flatten().trim());
    define('numberToken', ref('numberPrimitive').flatten().trim());

    define('characterPrimitive',
      ref('characterEscape')
        .or(ref('characterOctal'))
        .or(ref('characterNormal')));
    define('characterEscape',
      char('\\').seq(anyOf(new List.from(ESCAPE_TABLE.getKeys()))));
    define('characterNormal',
      anyOf('"\\').neg());
    define('characterOctal',
      string('\\u').seq(pattern("0-9A-Fa-f").times(4).flatten()));
    define('numberPrimitive',
      char('-').optional()
        .seq(char('0').or(digit().plus()))
        .seq(char('.').seq(digit().plus()).optional())
        .seq(anyOf('eE').seq(anyOf('-+').optional()).seq(digit().plus()).optional()));
    define('stringPrimitive',
      char('"')
        .seq(ref('characterPrimitive').star())
        .seq(char('"')));
  }

}