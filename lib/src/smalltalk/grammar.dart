part of smalltalk;

/**
 * Smalltalk grammar definition.
 */
class SmalltalkGrammar extends CompositeParser {

  @override
  void initialize() {
    _whitespace();
    _number();
    _smalltalk();
  }

  void _whitespace() {
    // the original implementation uses a handwritten parser to
    // efficiently consume whitespace and comments
    def('whitespace', whitespace()
      .or(ref('comment')));
    def('comment', char('"')
      .seq(char('"').neg().star())
      .seq(char('"')));
  }

  void _number() {
    // the original implementation uses the hand written number
    // parser of the system, this is the spec of the ANSI standard
    def('number', char('-').optional()
        .seq(ref('positiveNumber')));
    def('positiveNumber', ref('scaledDecimal')
        .or(ref('float'))
        .or(ref('integer')));

    def('integer', ref('radixInteger')
        .or(ref('decimalInteger')));
    def('decimalInteger', ref('digits'));
    def('digits', digit().plus());
    def('radixInteger', ref('radixSpecifier')
        .seq(char('r'))
        .seq(ref('radixDigits')));
    def('radixSpecifier', ref('digits'));
    def('radixDigits', pattern('0-9A-Z').plus());

    def('float', ref('mantissa')
        .seq(ref('exponentLetter')
            .seq(ref('exponent'))
            .optional()));
    def('mantissa', ref('digits')
        .seq(char('.'))
        .seq(ref('digits')));
    def('exponent', char('-')
        .seq(ref('decimalInteger')));
    def('exponentLetter', pattern('edq'));

    def('scaledDecimal', ref('scaledMantissa')
        .seq(char('s'))
        .seq(ref('fractionalDigits').optional()));
    def('scaledMantissa', ref('decimalInteger')
        .or(ref('mantissa')));
    def('fractionalDigits', ref('decimalInteger'));
  }

  Parser _token(input) {
    var parser = input;
    if (parser is String) {
      parser = parser.length == 1 ? char(parser) : string(parser);
    }
    return parser.token().trim(ref('whitespace'));
  }

  void _smalltalk() {
    def('array', _token('{')
        .seq(ref('expression').separatedBy(ref('periodToken'))
          .seq(ref('periodToken').optional()).optional())
        .seq(_token('}')));
    def('arrayItem', ref('literal')
        .or(ref('symbolLiteralArray'))
        .or(ref('arrayLiteralArray'))
        .or(ref('byteLiteralArray')));
    def('arrayLiteral', _token('#(')
        .seq(ref('arrayItem').star())
        .seq(_token(')')));
    def('arrayLiteralArray', _token('(')
        .seq(ref('arrayItem').star())
        .seq(_token(')')));
    def('assignment', ref('variable')
        .seq(ref('assignmentToken')));
    def('assignmentToken', _token(':='));
    def('binary', pattern('!%&*+,-/<=>?@\\|~').plus());
    def('binaryExpression', ref('unaryExpression')
        .seq(ref('binaryMessage').star()));
    def('binaryMessage', ref('binaryToken')
        .seq(ref('unaryExpression')));
    def('binaryMethod', ref('binaryToken')
        .seq(ref('variable')));
    def('binaryPragma', ref('binaryToken')
        .seq(ref('arrayItem')));
    def('binaryToken', _token(ref('binary')));
    def('block', _token('[')
        .seq(ref('blockBody'))
        .seq(_token(']')));
    def('blockArgument', _token(':')
        .seq(ref('variable')));
    def('blockArguments', ref('blockArgumentsWith')
        .or(ref('blockArgumentsWithout')));
    def('blockArgumentsWith', ref('blockArgument').plus()
        .seq(_token('|').or(_token(']').and())));
    def('blockArgumentsWithout', epsilon());
    def('blockBody', ref('blockArguments')
        .seq(ref('sequence')));
    def('byteLiteral', _token('#[')
        .seq(ref('numberLiteral').star())
        .seq(_token(']')));
    def('byteLiteralArray', _token('[')
        .seq(ref('numberLiteral').star())
        .seq(_token(']')));
    def('cascadeExpression', ref('keywordExpression')
        .seq(ref('cascadeMessage').star()));
    def('cascadeMessage', _token(';')
        .seq(ref('message')));
    def('char', char('\$').seq(any()));
    def('charLiteral', ref('charToken'));
    def('charToken', _token(ref('char')));
    def('expression', ref('assignment').star()
        .seq(ref('cascadeExpression')));
    def('falseLiteral', ref('falseToken'));
    def('falseToken', _token('false')
        .seq(word().not()));
    def('identifier', pattern('a-zA-Z_')
        .seq(word().star()));
    def('identifierToken', _token(ref('identifier')));
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
    def('keywordToken', _token(ref('keyword')));
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
    def('nilToken', _token('nil')
        .seq(word().not()));
    def('numberLiteral', ref('numberToken'));
    def('numberToken', _token(ref('number')));
    def('parens', _token('(')
        .seq(ref('expression'))
        .seq(_token(')')));
    def('period', char('.'));
    def('periodToken', _token(ref('period')));
    def('pragma', _token('<')
        .seq(ref('pragmaMessage'))
        .seq(_token('>')));
    def('pragmaMessage', ref('keywordPragma')
        .or(ref('unaryPragma'))
        .or(ref('binaryPragma')));
    def('pragmas', ref('pragma').star());
    def('primary', ref('literal')
        .or(ref('variable'))
        .or(ref('block'))
        .or(ref('parens'))
        .or(ref('array')));
    def('return', _token('^')
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
    def('stringToken', _token(ref('string')));
    def('symbol', ref('unary')
        .or(ref('binary'))
        .or(ref('multiword'))
        .or(ref('string')));
    def('symbolLiteral', _token('#').plus()
        .seq(_token(ref('symbol'))));
    def('symbolLiteralArray', _token(ref('symbol')));
    def('temporaries', _token('|')
        .seq(ref('variable').star())
        .seq(_token('|'))
            .optional());
    def('trueLiteral', ref('trueToken'));
    def('trueToken', _token('true')
        .seq(word().not()));
    def('unary', ref('identifier')
        .seq(char(':').not()));
    def('unaryExpression', ref('primary')
        .seq(ref('unaryMessage').star()));
    def('unaryMessage', ref('unaryToken'));
    def('unaryMethod', ref('identifierToken'));
    def('unaryPragma', ref('identifierToken'));
    def('unaryToken', _token(ref('unary')));
    def('variable', ref('identifierToken'));
  }

}
