// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of smalltalk;

/**
 * Smalltalk grammar definition.
 */
class SmalltalkGrammar extends CompositeParser {
  void initialize() {
    def('array', char('{', '\${ expected').token().trim().seq(ref('expression').separatedBy(ref('periodToken')).seq(ref('periodToken').optional()).optional()).seq(char('}', '\$} expected').token().trim()));
    def('arrayItem', ref('literal').or(ref('symbolLiteralArray')).or(ref('arrayLiteralArray')).or(ref('byteLiteralArray')));
    def('arrayLiteral', string('#(', '\'#(\' expected').token().trim().seq(ref('arrayItem').star()).seq(char(')', '\$) expected').token().trim()));
    def('arrayLiteralArray', char('(', '\$( expected').token().trim().seq(ref('arrayItem').star()).seq(char(')', '\$) expected').token().trim()));
    def('assignment', ref('variable').seq(ref('assignmentToken')));
    def('assignmentToken', string('\u003a=', '\'\u003a=\' expected').token().trim());
    def('binary', pattern('!%&*+,-/<=>?@\\\u007c\u007e', 'any of \'!%&*+,-/<=>?@\\\u007c\u007e\' expected').plus());
    def('binaryExpression', ref('unaryExpression').seq(ref('binaryMessage').star()));
    def('binaryMessage', ref('binaryToken').seq(ref('unaryExpression')));
    def('binaryMethod', ref('binaryToken').seq(ref('variable')));
    def('binaryPragma', ref('binaryToken').seq(ref('arrayItem')));
    def('binaryToken', ref('binary').token().trim());
    def('block', char('[', '\$[ expected').token().trim().seq(ref('blockBody')).seq(char(']', '\$] expected').token().trim()));
    def('blockArgument', char('\u003a', '\$\u003a expected').token().trim().seq(ref('variable')));
    def('blockArguments', ref('blockArgumentsWith').or(ref('blockArgumentsWithout')));
    def('blockArgumentsWith', ref('blockArgument').plus().seq(char('\u007c', '\$\u007c expected').token().trim().or(char(']', '\$] expected').token().trim().and())));
    def('blockArgumentsWithout', epsilon());
    def('blockBody', ref('blockArguments').seq(ref('sequence')));
    def('byteLiteral', string('#[', '\'#[\' expected').token().trim().seq(ref('numberLiteral').star()).seq(char(']', '\$] expected').token().trim()));
    def('byteLiteralArray', char('[', '\$[ expected').token().trim().seq(ref('numberLiteral').star()).seq(char(']', '\$] expected').token().trim()));
    def('cascadeExpression', ref('keywordExpression').seq(ref('cascadeMessage').star()));
    def('cascadeMessage', char(';', '\$; expected').token().trim().seq(ref('message')));
    def('char', char('\$', '\$\$ expected').seq(any('input expected')));
    def('charLiteral', ref('charToken'));
    def('charToken', ref('char').token().trim());
    def('expression', ref('assignment').star().seq(ref('cascadeExpression')));
    def('falseLiteral', ref('falseToken'));
    def('falseToken', string('false', '\'false\' expected').seq(word('letter or digit expected').not()).token().trim());
    def('identifier', letter('letter expected').seq(word('letter or digit expected').star()));
    def('identifierToken', ref('identifier').token().trim());
    def('keyword', ref('identifier').seq(char('\u003a', '\$\u003a expected')));
    def('keywordExpression', ref('binaryExpression').seq(ref('keywordMessage').optional()));
    def('keywordMessage', ref('keywordToken').seq(ref('binaryExpression')).plus());
    def('keywordMethod', ref('keywordToken').seq(ref('variable')).plus());
    def('keywordPragma', ref('keywordToken').seq(ref('arrayItem')).plus());
    def('keywordToken', ref('keyword').token().trim());
    def('literal', ref('numberLiteral').or(ref('stringLiteral')).or(ref('charLiteral')).or(ref('arrayLiteral')).or(ref('byteLiteral')).or(ref('symbolLiteral')).or(ref('nilLiteral')).or(ref('trueLiteral')).or(ref('falseLiteral')));
    def('message', ref('keywordMessage').or(ref('binaryMessage')).or(ref('unaryMessage')));
    def('method', ref('methodDeclaration').seq(ref('methodSequence')));
    def('methodDeclaration', ref('keywordMethod').or(ref('unaryMethod')).or(ref('binaryMethod')));
    def('methodSequence', ref('periodToken').star().seq(ref('pragmas')).seq(ref('periodToken').star()).seq(ref('temporaries')).seq(ref('periodToken').star()).seq(ref('pragmas')).seq(ref('periodToken').star()).seq(ref('statements')));
    def('multiword', ref('keyword').plus());
    def('nilLiteral', ref('nilToken'));
    def('nilToken', string('nil', '\'nil\' expected').seq(word('letter or digit expected').not()).token().trim());
    def('number', char('-', '\$- expected').optional().seq(digit('digit expected').plus()));
    def('numberLiteral', ref('numberToken'));
    def('numberToken', ref('number').token().trim());
    def('parens', char('(', '\$( expected').token().trim().seq(ref('expression')).seq(char(')', '\$) expected').token().trim()));
    def('period', char('.', '\$. expected'));
    def('periodToken', ref('period').token().trim());
    def('pragma', char('<', '\$< expected').token().trim().seq(ref('pragmaMessage')).seq(char('>', '\$> expected').token().trim()));
    def('pragmaMessage', ref('keywordPragma').or(ref('unaryPragma')).or(ref('binaryPragma')));
    def('pragmas', ref('pragma').star());
    def('primary', ref('literal').or(ref('variable')).or(ref('block')).or(ref('parens')).or(ref('array')));
    def('return', char('^', '\$^ expected').token().trim().seq(ref('expression')));
    def('sequence', ref('temporaries').seq(ref('periodToken').star()).seq(ref('statements')));
    def('start', ref('startMethod'));
    def('startMethod', ref('method').end());
    def('statements', ref('expression').seq(ref('periodToken').plus().seq(ref('statements')).or(ref('periodToken').star())).or(ref('return').seq(ref('periodToken').star())).or(ref('periodToken').star()));
    def('string', char('\'', '\$\' expected').seq(string('\'\'', '\'\'\'\'\'\' expected').or(pattern('\u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007\u0008\u0009\u000a\u000b\u000c\u000d\u000e\u000f\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001a\u001b\u001c\u001d\u001e\u001f !"#\$%&()*+,-./0123456789\u003a;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{\u007c}\u007e\u007f\u0080\u0081\u0082\u0083\u0084\u0085\u0086\u0087\u0088\u0089\u008a\u008b\u008c\u008d\u008e\u008f\u0090\u0091\u0092\u0093\u0094\u0095\u0096\u0097\u0098\u0099\u009a\u009b\u009c\u009d\u009e\u009f\u00a0\u00a1\u00a2\u00a3\u00a4\u00a5\u00a6\u00a7\u00a8\u00a9ª\u00ab\u00ac\u00ad\u00ae\u00af\u00b0\u00b1\u00b2\u00b3\u00b4µ\u00b6\u00b7\u00b8\u00b9º\u00bb\u00bc\u00bd\u00be\u00bfÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ\u00d7ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö\u00f7øùúûüýþÿ', 'no \$\' expected')).star()).seq(char('\'', '\$\' expected')));
    def('stringLiteral', ref('stringToken'));
    def('stringToken', ref('string').token().trim());
    def('symbol', ref('unary').or(ref('binary')).or(ref('multiword')).or(ref('string')));
    def('symbolLiteral', char('#', '\$# expected').token().trim().plus().seq(ref('symbol').token().trim()));
    def('symbolLiteralArray', ref('symbol').token().trim());
    def('temporaries', char('\u007c', '\$\u007c expected').token().trim().seq(ref('variable').star()).seq(char('\u007c', '\$\u007c expected').token().trim()).optional());
    def('trueLiteral', ref('trueToken'));
    def('trueToken', string('true', '\'true\' expected').seq(word('letter or digit expected').not()).token().trim());
    def('unary', ref('identifier').seq(char('\u003a', '\$\u003a expected').not()));
    def('unaryExpression', ref('primary').seq(ref('unaryMessage').star()));
    def('unaryMessage', ref('unaryToken'));
    def('unaryMethod', ref('identifierToken'));
    def('unaryPragma', ref('identifierToken'));
    def('unaryToken', ref('unary').token().trim());
    def('variable', ref('identifierToken'));
  }
}
