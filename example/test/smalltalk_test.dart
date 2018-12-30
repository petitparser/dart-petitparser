library petitparser.example.test.smalltalk_test;

import 'package:example/smalltalk.dart';
import 'package:test/test.dart';

final SmalltalkGrammarDefinition definition = SmalltalkGrammarDefinition();
final SmalltalkGrammar grammar = SmalltalkGrammar();

dynamic validate(String source, Function production) {
  final parser = definition.build(start: production).end();
  final result = parser.parse(source);
  return result.value;
}

void main() {
  test('start', () {
    return validate(r'''exampleWithNumber: x

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
  ^ x < y''', definition.start);
  });
  test('token', () {
    expect(() => definition.token(123), throwsArgumentError);
  });
  test('testArray1', () {
    return validate('{}', definition.array);
  });
  test('testArray2', () {
    return validate('{self foo}', definition.array);
  });
  test('testArray3', () {
    return validate('{self foo. self bar}', definition.array);
  });
  test('testArray4', () {
    return validate('{self foo. self bar.}', definition.array);
  });
  test('testAssignment1', () {
    return validate('1', definition.expression);
  });
  test('testAssignment2', () {
    return validate('a := 1', definition.expression);
  });
  test('testAssignment3', () {
    return validate('a := b := 1', definition.expression);
  });
  test('testAssignment6', () {
    return validate('a := (b := c)', definition.expression);
  });
  test('testComment1', () {
    return validate('1"one"+2', definition.expression);
  });
  test('testComment2', () {
    return validate('1 "one" +2', definition.expression);
  });
  test('testComment3', () {
    return validate('1"one"+"two"2', definition.expression);
  });
  test('testComment4', () {
    return validate('1"one""two"+2', definition.expression);
  });
  test('testComment5', () {
    return validate('1"one" "two"+2', definition.expression);
  });
  test('testMethod1', () {
    return validate('negated ^ 0 - self', definition.method);
  });
  test('testMethod2', () {
    return validate('   negated ^ 0 - self', definition.method);
  });
  test('testMethod3', () {
    return validate(' negated ^ 0 - self  ', definition.method);
  });
  test('testSequence1', () {
    return validate('| a | 1 . 2', definition.sequence);
  });
  test('testStatements1', () {
    return validate('1', definition.sequence);
  });
  test('testStatements2', () {
    return validate('1 . 2', definition.sequence);
  });
  test('testStatements3', () {
    return validate('1 . 2 . 3', definition.sequence);
  });
  test('testStatements4', () {
    return validate('1 . 2 . 3 .', definition.sequence);
  });
  test('testStatements5', () {
    return validate('1 . . 2', definition.sequence);
  });
  test('testStatements6', () {
    return validate('1. 2', definition.sequence);
  });
  test('testStatements7', () {
    return validate('. 1', definition.sequence);
  });
  test('testStatements8', () {
    return validate('.1', definition.sequence);
  });
  test('testTemporaries1', () {
    return validate('| a |', definition.sequence);
  });
  test('testTemporaries2', () {
    return validate('| a b |', definition.sequence);
  });
  test('testTemporaries3', () {
    return validate('| a b c |', definition.sequence);
  });
  test('testVariable1', () {
    return validate('trueBinding', definition.primary);
  });
  test('testVariable2', () {
    return validate('falseBinding', definition.primary);
  });
  test('testVariable3', () {
    return validate('nilly', definition.primary);
  });
  test('testVariable4', () {
    return validate('selfish', definition.primary);
  });
  test('testVariable5', () {
    return validate('supernanny', definition.primary);
  });
  test('testVariable6', () {
    return validate('super_nanny', definition.primary);
  });
  test('testVariable7', () {
    return validate('__gen_var_123__', definition.primary);
  });
  test('testArgumentsBlock1', () {
    return validate('[ :a | ]', definition.block);
  });
  test('testArgumentsBlock2', () {
    return validate('[ :a :b | ]', definition.block);
  });
  test('testArgumentsBlock3', () {
    return validate('[ :a :b :c | ]', definition.block);
  });
  test('testComplexBlock1', () {
    return validate('[ :a | | b | c ]', definition.block);
  });
  test('testComplexBlock2', () {
    return validate('[:a||b|c]', definition.block);
  });
  test('testSimpleBlock1', () {
    return validate('[ ]', definition.block);
  });
  test('testSimpleBlock2', () {
    return validate('[ nil ]', definition.block);
  });
  test('testSimpleBlock3', () {
    return validate('[ :a ]', definition.block);
  });
  test('testStatementBlock1', () {
    return validate('[ nil ]', definition.block);
  });
  test('testStatementBlock2', () {
    return validate('[ | a | nil ]', definition.block);
  });
  test('testStatementBlock3', () {
    return validate('[ | a b | nil ]', definition.block);
  });
  test('testArrayLiteral1', () {
    return validate('#()', definition.arrayLiteral);
  });
  test('testArrayLiteral10', () {
    return validate('#((1 2) #(1 2 3))', definition.arrayLiteral);
  });
  test('testArrayLiteral11', () {
    return validate('#([1 2] #[1 2 3])', definition.arrayLiteral);
  });
  test('testArrayLiteral2', () {
    return validate('#(1)', definition.arrayLiteral);
  });
  test('testArrayLiteral3', () {
    return validate('#(1 2)', definition.arrayLiteral);
  });
  test('testArrayLiteral4', () {
    return validate('#(true false nil)', definition.arrayLiteral);
  });
  test('testArrayLiteral5', () {
    return validate('#(\$a)', definition.arrayLiteral);
  });
  test('testArrayLiteral6', () {
    return validate('#(1.2)', definition.arrayLiteral);
  });
  test('testArrayLiteral7', () {
    return validate('#(size #at: at:put: #' '==' ')', definition.arrayLiteral);
  });
  test('testArrayLiteral8', () {
    return validate('#(' 'baz' ')', definition.arrayLiteral);
  });
  test('testArrayLiteral9', () {
    return validate('#((1) 2)', definition.arrayLiteral);
  });
  test('testByteLiteral1', () {
    return validate('#[]', definition.byteLiteral);
  });
  test('testByteLiteral2', () {
    return validate('#[0]', definition.byteLiteral);
  });
  test('testByteLiteral3', () {
    return validate('#[255]', definition.byteLiteral);
  });
  test('testByteLiteral4', () {
    return validate('#[ 1 2 ]', definition.byteLiteral);
  });
  test('testByteLiteral5', () {
    return validate('#[ 2r1010 8r77 16rFF ]', definition.byteLiteral);
  });
  test('testCharLiteral1', () {
    return validate('\$a', definition.characterLiteral);
  });
  test('testCharLiteral2', () {
    return validate('\$ ', definition.characterLiteral);
  });
  test('testCharLiteral3', () {
    return validate('\$\$', definition.characterLiteral);
  });
  test('testNumberLiteral1', () {
    return validate('0', definition.numberLiteral);
  });
  test('testNumberLiteral10', () {
    return validate('10r10', definition.numberLiteral);
  });
  test('testNumberLiteral11', () {
    return validate('8r777', definition.numberLiteral);
  });
  test('testNumberLiteral12', () {
    return validate('16rAF', definition.numberLiteral);
  });
  test('testNumberLiteral2', () {
    return validate('0.1', definition.numberLiteral);
  });
  test('testNumberLiteral3', () {
    return validate('123', definition.numberLiteral);
  });
  test('testNumberLiteral4', () {
    return validate('123.456', definition.numberLiteral);
  });
  test('testNumberLiteral5', () {
    return validate('-0', definition.numberLiteral);
  });
  test('testNumberLiteral6', () {
    return validate('-0.1', definition.numberLiteral);
  });
  test('testNumberLiteral7', () {
    return validate('-123', definition.numberLiteral);
  });
  test('testNumberLiteral8', () {
    return validate('-123', definition.numberLiteral);
  });
  test('testNumberLiteral9', () {
    return validate('-123.456', definition.numberLiteral);
  });
  test('testSpecialLiteral1', () {
    return validate('true', definition.trueLiteral);
  });
  test('testSpecialLiteral2', () {
    return validate('false', definition.falseLiteral);
  });
  test('testSpecialLiteral3', () {
    return validate('nil', definition.nilLiteral);
  });
  test('testStringLiteral1', () {
    return validate('\'\'', definition.stringLiteral);
  });
  test('testStringLiteral2', () {
    return validate('\'ab\'', definition.stringLiteral);
  });
  test('testStringLiteral3', () {
    return validate('\'ab\'\'cd\'', definition.stringLiteral);
  });
  test('testSymbolLiteral1', () {
    return validate('#foo', definition.symbolLiteral);
  });
  test('testSymbolLiteral2', () {
    return validate('#+', definition.symbolLiteral);
  });
  test('testSymbolLiteral3', () {
    return validate('#key:', definition.symbolLiteral);
  });
  test('testSymbolLiteral4', () {
    return validate('#key:value:', definition.symbolLiteral);
  });
  test('testSymbolLiteral5', () {
    return validate('#\'testing-result\'', definition.symbolLiteral);
  });
  test('testSymbolLiteral6', () {
    return validate('#__gen__binding', definition.symbolLiteral);
  });
  test('testSymbolLiteral7', () {
    return validate('# fucker', definition.symbolLiteral);
  });
  test('testSymbolLiteral8', () {
    return validate('##fucker', definition.symbolLiteral);
  });
  test('testSymbolLiteral9', () {
    return validate('## fucker', definition.symbolLiteral);
  });
  test('testBinaryExpression1', () {
    return validate('1 + 2', definition.expression);
  });
  test('testBinaryExpression2', () {
    return validate('1 + 2 + 3', definition.expression);
  });
  test('testBinaryExpression3', () {
    return validate('1 // 2', definition.expression);
  });
  test('testBinaryExpression4', () {
    return validate('1 -- 2', definition.expression);
  });
  test('testBinaryExpression5', () {
    return validate('1 ==> 2', definition.expression);
  });
  test('testBinaryMethod1', () {
    return validate('+ a', definition.method);
  });
  test('testBinaryMethod2', () {
    return validate('+ a | b |', definition.method);
  });
  test('testBinaryMethod3', () {
    return validate('+ a b', definition.method);
  });
  test('testBinaryMethod4', () {
    return validate('+ a | b | c', definition.method);
  });
  test('testBinaryMethod5', () {
    return validate('-- a', definition.method);
  });
  test('testCascadeExpression1', () {
    return validate('1 abs; negated', definition.expression);
  });
  test('testCascadeExpression2', () {
    return validate(
        '1 abs negated; raisedTo: 12; negated', definition.expression);
  });
  test('testCascadeExpression3', () {
    return validate('1 + 2; - 3', definition.expression);
  });
  test('testKeywordExpression1', () {
    return validate('1 to: 2', definition.expression);
  });
  test('testKeywordExpression2', () {
    return validate('1 to: 2 by: 3', definition.expression);
  });
  test('testKeywordExpression3', () {
    return validate('1 to: 2 by: 3 do: 4', definition.expression);
  });
  test('testKeywordMethod1', () {
    return validate('to: a', definition.method);
  });
  test('testKeywordMethod2', () {
    return validate('to: a do: b | c |', definition.method);
  });
  test('testKeywordMethod3', () {
    return validate('to: a do: b by: c d', definition.method);
  });
  test('testKeywordMethod4', () {
    return validate('to: a do: b by: c | d | e', definition.method);
  });
  test('testUnaryExpression1', () {
    return validate('1 abs', definition.expression);
  });
  test('testUnaryExpression2', () {
    return validate('1 abs negated', definition.expression);
  });
  test('testUnaryMethod1', () {
    return validate('abs', definition.method);
  });
  test('testUnaryMethod2', () {
    return validate('abs | a |', definition.method);
  });
  test('testUnaryMethod3', () {
    return validate('abs a', definition.method);
  });
  test('testUnaryMethod4', () {
    return validate('abs | a | b', definition.method);
  });
  test('testUnaryMethod5', () {
    return validate('abs | a |', definition.method);
  });
  test('testPragma1', () {
    return validate('method <foo>', definition.method);
  });
  test('testPragma10', () {
    return validate('method <foo: bar>', definition.method);
  });
  test('testPragma11', () {
    return validate('method <foo: true>', definition.method);
  });
  test('testPragma12', () {
    return validate('method <foo: false>', definition.method);
  });
  test('testPragma13', () {
    return validate('method <foo: nil>', definition.method);
  });
  test('testPragma14', () {
    return validate('method <foo: ()>', definition.method);
  });
  test('testPragma15', () {
    return validate('method <foo: #()>', definition.method);
  });
  test('testPragma16', () {
    return validate('method < + 1 >', definition.method);
  });
  test('testPragma2', () {
    return validate('method <foo> <bar>', definition.method);
  });
  test('testPragma3', () {
    return validate('method | a | <foo>', definition.method);
  });
  test('testPragma4', () {
    return validate('method <foo> | a |', definition.method);
  });
  test('testPragma5', () {
    return validate('method <foo> | a | <bar>', definition.method);
  });
  test('testPragma6', () {
    return validate('method <foo: 1>', definition.method);
  });
  test('testPragma7', () {
    return validate('method <foo: 1.2>', definition.method);
  });
  test('testPragma8', () {
    return validate('method <foo: ' 'bar' '>', definition.method);
  });
  test('testPragma9', () {
    return validate('method <foo: #' 'bar' '>', definition.method);
  });
}
