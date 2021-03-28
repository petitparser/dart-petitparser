import 'package:petitparser/petitparser.dart';
import 'package:petitparser_examples/smalltalk.dart';
import 'package:test/test.dart';

final grammar = SmalltalkGrammarDefinition();

dynamic validate(String source, Function production) {
  final parser = grammar.build(start: production).end();
  final result = parser.parse(source);
  return result.value;
}

void main() {
  test('start', () {
    return validate(r'''
exampleWithNumber: x

  "A method that illustrates every part of Smalltalk method syntax
  except primitives. It has unary, binary, and keyword messages,
  declares arguments and temporaries, accesses a global variable
  (but not and instance variable), uses literals (array, character,
  symbol, string, integer, float), uses the pseudo variables
  true false, nil, self, and super, and has sequence, assignment,
  return and cascade. It has both zero argument and one argument blocks."

  |y|
  y := true & false not & (nil isNil) ifFalse: [self halt].
  self size + super size.
  #($a #a "a" 1 1.0)
      do: [:each | Transcript show: (each class name);
                               show: ' '].
  ^ x < y''', grammar.start);
  });
  test('token', () {
    expect(() => grammar.token(123), throwsArgumentError);
  });
  test('testArray1', () {
    return validate('{}', grammar.array);
  });
  test('testArray2', () {
    return validate('{self foo}', grammar.array);
  });
  test('testArray3', () {
    return validate('{self foo. self bar}', grammar.array);
  });
  test('testArray4', () {
    return validate('{self foo. self bar.}', grammar.array);
  });
  test('testAssignment1', () {
    return validate('1', grammar.expression);
  });
  test('testAssignment2', () {
    return validate('a := 1', grammar.expression);
  });
  test('testAssignment3', () {
    return validate('a := b := 1', grammar.expression);
  });
  test('testAssignment6', () {
    return validate('a := (b := c)', grammar.expression);
  });
  test('testComment1', () {
    return validate('1"one"+2', grammar.expression);
  });
  test('testComment2', () {
    return validate('1 "one" +2', grammar.expression);
  });
  test('testComment3', () {
    return validate('1"one"+"two"2', grammar.expression);
  });
  test('testComment4', () {
    return validate('1"one""two"+2', grammar.expression);
  });
  test('testComment5', () {
    return validate('1"one" "two"+2', grammar.expression);
  });
  test('testMethod1', () {
    return validate('negated ^ 0 - self', grammar.method);
  });
  test('testMethod2', () {
    return validate('   negated ^ 0 - self', grammar.method);
  });
  test('testMethod3', () {
    return validate(' negated ^ 0 - self  ', grammar.method);
  });
  test('testSequence1', () {
    return validate('| a | 1 . 2', grammar.sequence);
  });
  test('testStatements1', () {
    return validate('1', grammar.sequence);
  });
  test('testStatements2', () {
    return validate('1 . 2', grammar.sequence);
  });
  test('testStatements3', () {
    return validate('1 . 2 . 3', grammar.sequence);
  });
  test('testStatements4', () {
    return validate('1 . 2 . 3 .', grammar.sequence);
  });
  test('testStatements5', () {
    return validate('1 . . 2', grammar.sequence);
  });
  test('testStatements6', () {
    return validate('1. 2', grammar.sequence);
  });
  test('testStatements7', () {
    return validate('. 1', grammar.sequence);
  });
  test('testStatements8', () {
    return validate('.1', grammar.sequence);
  });
  test('testStatements9', () {
    return validate('a := 1. b := 2', grammar.sequence);
  });
  test('testTemporaries1', () {
    return validate('| a |', grammar.sequence);
  });
  test('testTemporaries2', () {
    return validate('| a b |', grammar.sequence);
  });
  test('testTemporaries3', () {
    return validate('| a b c |', grammar.sequence);
  });
  test('testVariable1', () {
    return validate('trueBinding', grammar.primary);
  });
  test('testVariable2', () {
    return validate('falseBinding', grammar.primary);
  });
  test('testVariable3', () {
    return validate('nilly', grammar.primary);
  });
  test('testVariable4', () {
    return validate('selfish', grammar.primary);
  });
  test('testVariable5', () {
    return validate('supernanny', grammar.primary);
  });
  test('testVariable6', () {
    return validate('super_nanny', grammar.primary);
  });
  test('testVariable7', () {
    return validate('__gen_var_123__', grammar.primary);
  });
  test('testArgumentsBlock1', () {
    return validate('[ :a | ]', grammar.block);
  });
  test('testArgumentsBlock2', () {
    return validate('[ :a :b | ]', grammar.block);
  });
  test('testArgumentsBlock3', () {
    return validate('[ :a :b :c | ]', grammar.block);
  });
  test('testComplexBlock1', () {
    return validate('[ :a | | b | c ]', grammar.block);
  });
  test('testComplexBlock2', () {
    return validate('[:a||b|c]', grammar.block);
  });
  test('testSimpleBlock1', () {
    return validate('[ ]', grammar.block);
  });
  test('testSimpleBlock2', () {
    return validate('[ nil ]', grammar.block);
  });
  test('testSimpleBlock3', () {
    return validate('[ :a ]', grammar.block);
  });
  test('testStatementBlock1', () {
    return validate('[ nil ]', grammar.block);
  });
  test('testStatementBlock2', () {
    return validate('[ | a | nil ]', grammar.block);
  });
  test('testStatementBlock3', () {
    return validate('[ | a b | nil ]', grammar.block);
  });
  test('testArrayLiteral1', () {
    return validate('#()', grammar.arrayLiteral);
  });
  test('testArrayLiteral10', () {
    return validate('#((1 2) #(1 2 3))', grammar.arrayLiteral);
  });
  test('testArrayLiteral11', () {
    return validate('#([1 2] #[1 2 3])', grammar.arrayLiteral);
  });
  test('testArrayLiteral2', () {
    return validate('#(1)', grammar.arrayLiteral);
  });
  test('testArrayLiteral3', () {
    return validate('#(1 2)', grammar.arrayLiteral);
  });
  test('testArrayLiteral4', () {
    return validate('#(true false nil)', grammar.arrayLiteral);
  });
  test('testArrayLiteral5', () {
    return validate('#(\$a)', grammar.arrayLiteral);
  });
  test('testArrayLiteral6', () {
    return validate('#(1.2)', grammar.arrayLiteral);
  });
  test('testArrayLiteral7', () {
    return validate('#(size #at: at:put: #' '==' ')', grammar.arrayLiteral);
  });
  test('testArrayLiteral8', () {
    return validate('#(' 'baz' ')', grammar.arrayLiteral);
  });
  test('testArrayLiteral9', () {
    return validate('#((1) 2)', grammar.arrayLiteral);
  });
  test('testByteLiteral1', () {
    return validate('#[]', grammar.byteLiteral);
  });
  test('testByteLiteral2', () {
    return validate('#[0]', grammar.byteLiteral);
  });
  test('testByteLiteral3', () {
    return validate('#[255]', grammar.byteLiteral);
  });
  test('testByteLiteral4', () {
    return validate('#[ 1 2 ]', grammar.byteLiteral);
  });
  test('testByteLiteral5', () {
    return validate('#[ 2r1010 8r77 16rFF ]', grammar.byteLiteral);
  });
  test('testCharLiteral1', () {
    return validate('\$a', grammar.characterLiteral);
  });
  test('testCharLiteral2', () {
    return validate('\$ ', grammar.characterLiteral);
  });
  test('testCharLiteral3', () {
    return validate('\$\$', grammar.characterLiteral);
  });
  test('testNumberLiteral1', () {
    return validate('0', grammar.numberLiteral);
  });
  test('testNumberLiteral10', () {
    return validate('10r10', grammar.numberLiteral);
  });
  test('testNumberLiteral11', () {
    return validate('8r777', grammar.numberLiteral);
  });
  test('testNumberLiteral12', () {
    return validate('16rAF', grammar.numberLiteral);
  });
  test('testNumberLiteral2', () {
    return validate('0.1', grammar.numberLiteral);
  });
  test('testNumberLiteral3', () {
    return validate('123', grammar.numberLiteral);
  });
  test('testNumberLiteral4', () {
    return validate('123.456', grammar.numberLiteral);
  });
  test('testNumberLiteral5', () {
    return validate('-0', grammar.numberLiteral);
  });
  test('testNumberLiteral6', () {
    return validate('-0.1', grammar.numberLiteral);
  });
  test('testNumberLiteral7', () {
    return validate('-123', grammar.numberLiteral);
  });
  test('testNumberLiteral8', () {
    return validate('-123', grammar.numberLiteral);
  });
  test('testNumberLiteral9', () {
    return validate('-123.456', grammar.numberLiteral);
  });
  test('testSpecialLiteral1', () {
    return validate('true', grammar.trueLiteral);
  });
  test('testSpecialLiteral2', () {
    return validate('false', grammar.falseLiteral);
  });
  test('testSpecialLiteral3', () {
    return validate('nil', grammar.nilLiteral);
  });
  test('testStringLiteral1', () {
    return validate('\'\'', grammar.stringLiteral);
  });
  test('testStringLiteral2', () {
    return validate('\'ab\'', grammar.stringLiteral);
  });
  test('testStringLiteral3', () {
    return validate('\'ab\'\'cd\'', grammar.stringLiteral);
  });
  test('testSymbolLiteral1', () {
    return validate('#foo', grammar.symbolLiteral);
  });
  test('testSymbolLiteral2', () {
    return validate('#+', grammar.symbolLiteral);
  });
  test('testSymbolLiteral3', () {
    return validate('#key:', grammar.symbolLiteral);
  });
  test('testSymbolLiteral4', () {
    return validate('#key:value:', grammar.symbolLiteral);
  });
  test('testSymbolLiteral5', () {
    return validate('#\'testing-result\'', grammar.symbolLiteral);
  });
  test('testSymbolLiteral6', () {
    return validate('#__gen__binding', grammar.symbolLiteral);
  });
  test('testSymbolLiteral7', () {
    return validate('# fucker', grammar.symbolLiteral);
  });
  test('testSymbolLiteral8', () {
    return validate('##fucker', grammar.symbolLiteral);
  });
  test('testSymbolLiteral9', () {
    return validate('## fucker', grammar.symbolLiteral);
  });
  test('testBinaryExpression1', () {
    return validate('1 + 2', grammar.expression);
  });
  test('testBinaryExpression2', () {
    return validate('1 + 2 + 3', grammar.expression);
  });
  test('testBinaryExpression3', () {
    return validate('1 // 2', grammar.expression);
  });
  test('testBinaryExpression4', () {
    return validate('1 -- 2', grammar.expression);
  });
  test('testBinaryExpression5', () {
    return validate('1 ==> 2', grammar.expression);
  });
  test('testBinaryMethod1', () {
    return validate('+ a', grammar.method);
  });
  test('testBinaryMethod2', () {
    return validate('+ a | b |', grammar.method);
  });
  test('testBinaryMethod3', () {
    return validate('+ a b', grammar.method);
  });
  test('testBinaryMethod4', () {
    return validate('+ a | b | c', grammar.method);
  });
  test('testBinaryMethod5', () {
    return validate('-- a', grammar.method);
  });
  test('testCascadeExpression1', () {
    return validate('1 abs; negated', grammar.expression);
  });
  test('testCascadeExpression2', () {
    return validate('1 abs negated; raisedTo: 12; negated', grammar.expression);
  });
  test('testCascadeExpression3', () {
    return validate('1 + 2; - 3', grammar.expression);
  });
  test('testKeywordExpression1', () {
    return validate('1 to: 2', grammar.expression);
  });
  test('testKeywordExpression2', () {
    return validate('1 to: 2 by: 3', grammar.expression);
  });
  test('testKeywordExpression3', () {
    return validate('1 to: 2 by: 3 do: 4', grammar.expression);
  });
  test('testKeywordMethod1', () {
    return validate('to: a', grammar.method);
  });
  test('testKeywordMethod2', () {
    return validate('to: a do: b | c |', grammar.method);
  });
  test('testKeywordMethod3', () {
    return validate('to: a do: b by: c d', grammar.method);
  });
  test('testKeywordMethod4', () {
    return validate('to: a do: b by: c | d | e', grammar.method);
  });
  test('testUnaryExpression1', () {
    return validate('1 abs', grammar.expression);
  });
  test('testUnaryExpression2', () {
    return validate('1 abs negated', grammar.expression);
  });
  test('testUnaryMethod1', () {
    return validate('abs', grammar.method);
  });
  test('testUnaryMethod2', () {
    return validate('abs | a |', grammar.method);
  });
  test('testUnaryMethod3', () {
    return validate('abs a', grammar.method);
  });
  test('testUnaryMethod4', () {
    return validate('abs | a | b', grammar.method);
  });
  test('testUnaryMethod5', () {
    return validate('abs | a |', grammar.method);
  });
  test('testPragma1', () {
    return validate('method <foo>', grammar.method);
  });
  test('testPragma10', () {
    return validate('method <foo: bar>', grammar.method);
  });
  test('testPragma11', () {
    return validate('method <foo: true>', grammar.method);
  });
  test('testPragma12', () {
    return validate('method <foo: false>', grammar.method);
  });
  test('testPragma13', () {
    return validate('method <foo: nil>', grammar.method);
  });
  test('testPragma14', () {
    return validate('method <foo: ()>', grammar.method);
  });
  test('testPragma15', () {
    return validate('method <foo: #()>', grammar.method);
  });
  test('testPragma16', () {
    return validate('method < + 1 >', grammar.method);
  });
  test('testPragma2', () {
    return validate('method <foo> <bar>', grammar.method);
  });
  test('testPragma3', () {
    return validate('method | a | <foo>', grammar.method);
  });
  test('testPragma4', () {
    return validate('method <foo> | a |', grammar.method);
  });
  test('testPragma5', () {
    return validate('method <foo> | a | <bar>', grammar.method);
  });
  test('testPragma6', () {
    return validate('method <foo: 1>', grammar.method);
  });
  test('testPragma7', () {
    return validate('method <foo: 1.2>', grammar.method);
  });
  test('testPragma8', () {
    return validate('method <foo: ' 'bar' '>', grammar.method);
  });
  test('testPragma9', () {
    return validate('method <foo: #' 'bar' '>', grammar.method);
  });
}
