// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * Lisp grammar definition.
 */
class LispGrammar extends CompositeParser {

  void initialize() {
    def('start', ref('atom').end());

    def('atom',
      ref('list')
        .or(ref('number'))
        .or(ref('string'))
        .or(ref('symbol'))
        .or(ref('quote'))
        .or(ref('quasiquote'))
        .or(ref('unquote'))
        .or(ref('splice'))
        .trim());

    def('list',
      bracket('()', 'atoms')
        .or(bracket('[]', 'atoms'))
        .or(bracket('{}', 'atoms')));
    def('atoms',
      ref('cell')
        .or(ref('null')));
    def('cell',
      ref('atom')
        .seq(ref('atoms')));
    def('null',
      whitespace().star());

    def('string',
      char('"')
        .seq(ref('character').star())
        .seq(char('"')));
    def('character',
      ref('character escape')
        .or(ref('character raw')));
    def('character escape',
      char('\\').seq(any()));
    def('character raw',
      pattern('^"'));

    def('symbol',
      pattern('a-zA-Z!#\$%&*/:<=>?@\\^_|~+-')
        .seq(pattern('a-zA-Z0-9!#\$%&*/:<=>?@\\^_|~+-').star())
        .flatten());

    def('number',
      anyIn('-+').optional()
        .seq(char('0').or(digit().plus()))
        .seq(char('.').seq(digit().plus()).optional())
        .seq(anyIn('eE').seq(anyIn('-+').optional()).seq(digit().plus()).optional())
        .flatten());

    def('quote', char('\'').seq(ref('atom')));
    def('quasiquote', char('`').seq(ref('atom')));
    def('unquote', char(',').seq(ref('atom')));
    def('splice', char('@').seq(ref('atom')));
  }

  Parser bracket(String brackets, String reference) {
    return char(brackets[0])
        .seq(ref(reference))
        .seq(char(brackets[1]).trim());
  }

}