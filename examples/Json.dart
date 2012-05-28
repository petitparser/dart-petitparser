// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('Json');

#import('../lib/PetitParser.dart');

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

/**
 * JSON parser definition.
 */
class JsonParser extends JsonGrammar {

  void initialize() {
    super.initialize();

    attach('array', (each) => each[1] != null ? each[1] : new List());
    redefine('elements', (parser) => parser.withoutSeparators());
    redefine('members', (parser) => parser.withoutSeparators());
    attach('object', (each) {
      Map result = new LinkedHashMap();
      if (each[1] != null) {
        for (List element in each[1]) {
          result[element[0]] = element[2];
        }
      }
      return result;
    });

    attach('trueToken', (each) => true);
    attach('falseToken', (each) => false);
    attach('nullToken', (each) => null);
    redefine('stringToken', (parser) => ref('stringPrimitive').trim());
    attach('numberToken', (each) {
      double floating = Math.parseDouble(each);
      int integral = floating.toInt();
      if (floating == integral && each.indexOf('.') == -1) {
        return integral;
      } else {
        return floating;
      }
    });

    attach('stringPrimitive', (each) => Strings.join(each[1], ''));
    attach('characterEscape', (each) => ESCAPE_TABLE[each[1]]);
    attach('characterOctal', (each) {
      throw new UnsupportedOperationException('Octal characters not supported yet');
    });

  }

}

final ESCAPE_TABLE = const {
  '\\': '\\',
  '/': '/',
  '"': '"',
  'b': '\b',
  'f': '\f',
  'n': '\n',
  'r': '\r',
  't': '\t'
};