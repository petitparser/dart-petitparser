// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of json;

/**
 * JSON grammar definition.
 */
class JsonGrammar extends CompositeParser {

  void initialize() {
    def('start', ref('value').end());

    def('array',
      char('[').trim()
        .seq(ref('elements').optional())
        .seq(char(']').trim()));
    def('elements',
      ref('value').separatedBy(char(',').trim()));
    def('members',
      ref('pair').separatedBy(char(',').trim()));
    def('object',
      char('{').trim()
        .seq(ref('members').optional())
        .seq(char('}').trim()));
    def('pair',
      ref('stringToken')
        .seq(char(':').trim())
        .seq(ref('value')));
    def('value',
      ref('stringToken')
        .or(ref('numberToken'))
        .or(ref('object'))
        .or(ref('array'))
        .or(ref('trueToken'))
        .or(ref('falseToken'))
        .or(ref('nullToken')));

    def('trueToken', string('true').flatten().trim());
    def('falseToken', string('false').flatten().trim());
    def('nullToken', string('null').flatten().trim());
    def('stringToken', ref('stringPrimitive').flatten().trim());
    def('numberToken', ref('numberPrimitive').flatten().trim());

    def('characterPrimitive',
      ref('characterEscape')
        .or(ref('characterOctal'))
        .or(ref('characterNormal')));
    def('characterEscape',
      char('\\').seq(anyIn(new List.from(ESCAPE_TABLE.keys))));
    def('characterNormal',
      anyIn('"\\').neg());
    def('characterOctal',
      string('\\u').seq(pattern("0-9A-Fa-f").times(4).flatten()));
    def('numberPrimitive',
      char('-').optional()
        .seq(char('0').or(digit().plus()))
        .seq(char('.').seq(digit().plus()).optional())
        .seq(anyIn('eE').seq(anyIn('-+').optional()).seq(digit().plus()).optional()));
    def('stringPrimitive',
      char('"')
        .seq(ref('characterPrimitive').star())
        .seq(char('"')));
  }

}