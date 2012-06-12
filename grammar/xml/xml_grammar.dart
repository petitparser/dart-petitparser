// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * XML grammar definition.
 */
class XmlGrammar extends CompositeParser {

  static final String NAME_START_CHARS = ':A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF'
      '\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001\uD7FF'
      '\uF900-\uFDCF\uFDF0-\uFFFD';
  static final String NAME_CHARS = '-.0-9\u00B7\u0300-\u036F\u203F-\u2040$NAME_START_CHARS';

  void initialize() {
    define('start', ref('document').end());

    define('attribute', ref('qualified')
      .seq(ref('whitespace').optional())
      .seq(char('='))
      .seq(ref('whitespace').optional())
      .seq(ref('attributeValue'))
      .map((list) => [list[0], list[4]]));
    define('attributeValue', ref('attributeValueDouble')
      .or(ref('attributeValueSingle'))
      .map((list) => list[1]));
    define('attributeValueDouble', char('"')
      .seq(char('"').neg().star().flatten())
      .seq(char('"')));
    define('attributeValueSingle', char("'")
      .seq(char("'").neg().star().flatten())
      .seq(char("'")));
    define('attributes', ref('whitespace')
      .seq(ref('attribute'))
      .map((list) => list[1])
      .star());
    define('comment', string('<!--')
      .seq(string('-->').neg().star().flatten())
      .seq(string('-->'))
      .map((list) => list[1]));
    define('content', ref('characterData')
      .or(ref('element'))
      .or(ref('processing'))
      .or(ref('comment'))
      .star());
    define('doctype', string('<!DOCTYPE')
      .seq(ref('whitespace').optional())
      .seq(char('[').neg().star()
        .seq(char('['))
        .seq(char(']').neg().star())
        .seq(char(']'))
        .flatten())
      .seq(ref('whitespace').optional())
      .seq(char('>'))
      .map((list) => list[2]));
    define('document', ref('processing').optional()
      .seq(ref('misc'))
      .seq(ref('doctype').optional())
      .seq(ref('misc'))
      .seq(ref('element'))
      .seq(ref('misc'))
      .map((list) => [list[0], list[2], list[4]].filter((each) => each != null)));
    define('element', char('<')
      .seq(ref('qualified'))
      .seq(ref('attributes'))
      .seq(ref('whitespace').optional())
      .seq(string('/>')
        .or(char('>')
          .seq(ref('content'))
          .seq(string('</'))
          .seq(ref('qualified'))
          .seq(ref('whitespace').optional())
          .seq(char('>'))))
      .map((list) {
        if (list[4] == '/>') {
          return [list[1], list[2], []];
        } else {
          if (list[1] == list[4][3]) {
            return [list[1], list[2], list[4][1]];
          } else {
            throw new IllegalArgumentException('Expected </${list[1]}>');
          }
        }
      }));
    define('processing', string('<?')
      .seq(ref('nameToken'))
      .seq(ref('whitespace')
        .seq(string('?>').neg().star())
        .optional()
        .flatten())
      .seq(string('?>'))
      .map((list) => [list[1], list[2]]));
    define('qualified', ref('nameToken'));

    define('characterData', char('<').neg().plus().flatten());
    define('misc', ref('whitespace')
      .or(ref('comment'))
      .or(ref('processing'))
      .star());
    define('whitespace', whitespace().plus());

    define('nameToken', ref('nameStartChar')
      .seq(ref('nameStartChar').star())
      .flatten());
    define('nameStartChar', pattern(NAME_START_CHARS));
    define('nameChar', pattern(NAME_CHARS));
  }

}