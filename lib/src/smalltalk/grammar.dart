// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of smalltalk;

/**
 * Smalltalk grammar definition.
 */
class SmalltalkGrammar extends CompositeParser {

  void initialize() {
    _whitespace();
    _smalltalk();
  }

  void _whitespace() {
    def('whitespace', whitespace()
      .or(ref('comment')));
    def('comment', char('"')
      .seq(string('"').neg().star())
      .seq(char('"')));
  }

  Parser _token(String name) {
    var parser = name.length == 1 ? char(name) : string(name);
    return parser.token().trim(ref('whitespace'));
  }

  void _smalltalk() {
    def('array', char('{').token().trim()
        .seq(ref('expression').separatedBy(ref('periodToken'))
          .seq(ref('periodToken').optional()).optional())
        .seq(char('}').token().trim()));
    def('arrayItem', ref('literal')
        .or(ref('symbolLiteralArray'))
        .or(ref('arrayLiteralArray'))
        .or(ref('byteLiteralArray')));
    def('arrayLiteral', string('#(').token().trim()
        .seq(ref('arrayItem').star())
        .seq(char(')').token().trim()));
    def('arrayLiteralArray', char('(').token().trim()
        .seq(ref('arrayItem').star())
        .seq(char(')').token().trim()));
    def('assignment', ref('variable')
        .seq(ref('assignmentToken')));
    def('assignmentToken', string(':=').token().trim());
    def('binary', pattern('!%&*+,-/<=>?@\\\u007c\u007e').plus());
    def('binaryExpression', ref('unaryExpression')
        .seq(ref('binaryMessage').star()));
    def('binaryMessage', ref('binaryToken')
        .seq(ref('unaryExpression')));
    def('binaryMethod', ref('binaryToken')
        .seq(ref('variable')));
    def('binaryPragma', ref('binaryToken')
        .seq(ref('arrayItem')));
    def('binaryToken', ref('binary').token().trim());
    def('block', char('[').token().trim()
        .seq(ref('blockBody'))
        .seq(char(']').token().trim()));
    def('blockArgument', char(':').token().trim()
        .seq(ref('variable')));
    def('blockArguments', ref('blockArgumentsWith')
        .or(ref('blockArgumentsWithout')));
    def('blockArgumentsWith', ref('blockArgument').plus()
        .seq(char('|').token().trim().or(char(']').token().trim().and())));
    def('blockArgumentsWithout', epsilon());
    def('blockBody', ref('blockArguments')
        .seq(ref('sequence')));
    def('byteLiteral', string('#[').token().trim()
        .seq(ref('numberLiteral').star())
        .seq(char(']').token().trim()));
    def('byteLiteralArray', char('[').token().trim()
        .seq(ref('numberLiteral').star())
        .seq(char(']').token().trim()));
    def('cascadeExpression', ref('keywordExpression')
        .seq(ref('cascadeMessage').star()));
    def('cascadeMessage', char(';').token().trim()
        .seq(ref('message')));
    def('char', char('\$').seq(any()));
    def('charLiteral', ref('charToken'));
    def('charToken', ref('char').token().trim());
    def('expression', ref('assignment').star()
        .seq(ref('cascadeExpression')));
    def('falseLiteral', ref('falseToken'));
    def('falseToken', string('false')
        .seq(word().not()).token().trim());
    def('identifier', letter()
        .seq(word().star()));
    def('identifierToken', ref('identifier').token().trim());
    def('keyword', ref('identifier')
        .seq(char(':')));
    def('keywordExpression', ref('binaryExpression')
        .seq(ref('keywordMessage').optional()));
    def('keywordMessage', ref('keywordToken')
        .seq(ref('binaryExpression')).plus());
    def('keywordMethod', ref('keywordToken')
        .seq(ref('variable')).plus());
    def('keywordPragma', ref('keywordToken')
        .seq(ref('arrayItem')).plus());
    def('keywordToken', ref('keyword').token().trim());
    def('literal', ref('numberLiteral')
        .or(ref('stringLiteral'))
        .or(ref('charLiteral'))
        .or(ref('arrayLiteral'))
        .or(ref('byteLiteral'))
        .or(ref('symbolLiteral'))
        .or(ref('nilLiteral'))
        .or(ref('trueLiteral'))
        .or(ref('falseLiteral')));
    def('message', ref('keywordMessage')
        .or(ref('binaryMessage'))
        .or(ref('unaryMessage')));
    def('method', ref('methodDeclaration')
        .seq(ref('methodSequence')));
    def('methodDeclaration', ref('keywordMethod')
        .or(ref('unaryMethod'))
        .or(ref('binaryMethod')));
    def('methodSequence', ref('periodToken').star()
        .seq(ref('pragmas'))
        .seq(ref('periodToken').star())
        .seq(ref('temporaries'))
        .seq(ref('periodToken').star())
        .seq(ref('pragmas'))
        .seq(ref('periodToken').star())
        .seq(ref('statements')));
    def('multiword', ref('keyword').plus());
    def('nilLiteral', ref('nilToken'));
    def('nilToken', string('nil')
        .seq(word().not()).token().trim());
    def('number', char('-').optional()
        .seq(digit().plus()));
    def('numberLiteral', ref('numberToken'));
    def('numberToken', ref('number').token().trim());
    def('parens', char('(').token().trim()
        .seq(ref('expression'))
        .seq(char(')').token().trim()));
    def('period', char('.'));
    def('periodToken', ref('period').token().trim());
    def('pragma', char('<').token().trim()
        .seq(ref('pragmaMessage'))
        .seq(char('>').token().trim()));
    def('pragmaMessage', ref('keywordPragma')
        .or(ref('unaryPragma'))
        .or(ref('binaryPragma')));
    def('pragmas', ref('pragma').star());
    def('primary', ref('literal')
        .or(ref('variable'))
        .or(ref('block'))
        .or(ref('parens'))
        .or(ref('array')));
    def('return', char('^').token().trim()
        .seq(ref('expression')));
    def('sequence', ref('temporaries')
        .seq(ref('periodToken').star())
        .seq(ref('statements')));
    def('start', ref('startMethod'));
    def('startMethod', ref('method').end());
    def('statements', ref('expression')
        .seq(ref('periodToken').plus().seq(ref('statements'))
            .or(ref('periodToken').star()))
            .or(ref('return').seq(ref('periodToken').star()))
            .or(ref('periodToken').star()));
    def('string', char('\'')
        .seq(string('\'\'').or(pattern('^\'')).star())
        .seq(char('\'')));
    def('stringLiteral', ref('stringToken'));
    def('stringToken', ref('string').token().trim());
    def('symbol', ref('unary')
        .or(ref('binary'))
        .or(ref('multiword'))
        .or(ref('string')));
    def('symbolLiteral', char('#').token().trim().plus()
        .seq(ref('symbol').token().trim()));
    def('symbolLiteralArray', ref('symbol').token().trim());
    def('temporaries', char('|').token().trim()
        .seq(ref('variable').star())
        .seq(char('|').token().trim())
            .optional());
    def('trueLiteral', ref('trueToken'));
    def('trueToken', string('true')
        .seq(word().not()).token().trim());
    def('unary', ref('identifier')
        .seq(char(':').not()));
    def('unaryExpression', ref('primary')
        .seq(ref('unaryMessage').star()));
    def('unaryMessage', ref('unaryToken'));
    def('unaryMethod', ref('identifierToken'));
    def('unaryPragma', ref('identifierToken'));
    def('unaryToken', ref('unary').token().trim());
    def('variable', ref('identifierToken'));
  }

}
