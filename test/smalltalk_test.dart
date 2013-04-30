// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

library smalltalk_test;

import 'package:petitparser/smalltalk.dart';
import 'package:unittest/unittest.dart';

var smalltalk = new SmalltalkGrammar();

dynamic validate(String source, String production) {
  var parser = smalltalk[production].end();
  var result = parser.parse(source);
  return result.value;
}

void main() {
  test('testArray1', () {
    return validate('{}', 'array');
  });
  test('testArray2', () {
    return validate('{self foo}', 'array');
  });
  test('testArray3', () {
    return validate('{self foo. self bar}', 'array');
  });
  test('testArray4', () {
    return validate('{self foo. self bar.}', 'array');
  });
  test('testAssignment1', () {
    return validate('1', 'expression');
  });
  test('testAssignment2', () {
    return validate('a := 1', 'expression');
  });
  test('testAssignment3', () {
    return validate('a := b := 1', 'expression');
  });
  test('testAssignment6', () {
    return validate('a := (b := c)', 'expression');
  });
  test('testComment1', () {
    return validate('1"one"+2', 'expression');
  });
  test('testComment2', () {
    return validate('1 "one" +2', 'expression');
  });
  test('testComment3', () {
    return validate('1"one"+"two"2', 'expression');
  });
  test('testComment4', () {
    return validate('1"one""two"+2', 'expression');
  });
  test('testComment5', () {
    return validate('1"one" "two"+2', 'expression');
  });
  test('testMethod1', () {
    return validate('negated ^ 0 - self', 'method');
  });
  test('testMethod2', () {
    return validate('   negated ^ 0 - self', 'method');
  });
  test('testMethod3', () {
    return validate(' negated ^ 0 - self  ', 'method');
  });
  test('testSequence1', () {
    return validate('| a | 1 . 2', 'sequence');
  });
  test('testStatements1', () {
    return validate('1', 'sequence');
  });
  test('testStatements2', () {
    return validate('1 . 2', 'sequence');
  });
  test('testStatements3', () {
    return validate('1 . 2 . 3', 'sequence');
  });
  test('testStatements4', () {
    return validate('1 . 2 . 3 .', 'sequence');
  });
  test('testStatements5', () {
    return validate('1 . . 2', 'sequence');
  });
  test('testStatements6', () {
    return validate('1. 2', 'sequence');
  });
  test('testStatements7', () {
    return validate('. 1', 'sequence');
  });
  test('testStatements8', () {
    return validate('.1', 'sequence');
  });
  test('testTemporaries1', () {
    return validate('| a |', 'sequence');
  });
  test('testTemporaries2', () {
    return validate('| a b |', 'sequence');
  });
  test('testTemporaries3', () {
    return validate('| a b c |', 'sequence');
  });
  test('testVariable1', () {
    return validate('trueBinding', 'primary');
  });
  test('testVariable2', () {
    return validate('falseBinding', 'primary');
  });
  test('testVariable3', () {
    return validate('nilly', 'primary');
  });
  test('testVariable4', () {
    return validate('selfish', 'primary');
  });
  test('testVariable5', () {
    return validate('supernanny', 'primary');
  });
  test('testVariable6', () {
    return validate('super_nanny', 'primary');
  });
  test('testVariable7', () {
    return validate('__gen_var_123__', 'primary');
  });
  test('testArgumentsBlock1', () {
    return validate('[ :a | ]', 'block');
  });
  test('testArgumentsBlock2', () {
    return validate('[ :a :b | ]', 'block');
  });
  test('testArgumentsBlock3', () {
    return validate('[ :a :b :c | ]', 'block');
  });
  test('testComplexBlock1', () {
    return validate('[ :a | | b | c ]', 'block');
  });
  test('testComplexBlock2', () {
    return validate('[:a||b|c]', 'block');
  });
  test('testSimpleBlock1', () {
    return validate('[ ]', 'block');
  });
  test('testSimpleBlock2', () {
    return validate('[ nil ]', 'block');
  });
  test('testSimpleBlock3', () {
    return validate('[ :a ]', 'block');
  });
  test('testStatementBlock1', () {
    return validate('[ nil ]', 'block');
  });
  test('testStatementBlock2', () {
    return validate('[ | a | nil ]', 'block');
  });
  test('testStatementBlock3', () {
    return validate('[ | a b | nil ]', 'block');
  });
  test('testArrayLiteral1', () {
    return validate('#()', 'arrayLiteral');
  });
  test('testArrayLiteral10', () {
    return validate('#((1 2) #(1 2 3))', 'arrayLiteral');
  });
  test('testArrayLiteral11', () {
    return validate('#([1 2] #[1 2 3])', 'arrayLiteral');
  });
  test('testArrayLiteral2', () {
    return validate('#(1)', 'arrayLiteral');
  });
  test('testArrayLiteral3', () {
    return validate('#(1 2)', 'arrayLiteral');
  });
  test('testArrayLiteral4', () {
    return validate('#(true false nil)', 'arrayLiteral');
  });
  test('testArrayLiteral5', () {
    return validate('#(\$a)', 'arrayLiteral');
  });
  test('testArrayLiteral6', () {
    return validate('#(1.2)', 'arrayLiteral');
  });
  test('testArrayLiteral7', () {
    return validate('#(size #at: at:put: #''=='')', 'arrayLiteral');
  });
  test('testArrayLiteral8', () {
    return validate('#(''baz'')', 'arrayLiteral');
  });
  test('testArrayLiteral9', () {
    return validate('#((1) 2)', 'arrayLiteral');
  });
  test('testByteLiteral1', () {
    return validate('#[]', 'byteLiteral');
  });
  test('testByteLiteral2', () {
    return validate('#[0]', 'byteLiteral');
  });
  test('testByteLiteral3', () {
    return validate('#[255]', 'byteLiteral');
  });
  test('testByteLiteral4', () {
    return validate('#[ 1 2 ]', 'byteLiteral');
  });
  test('testByteLiteral5', () {
    return validate('#[ 2r1010 8r77 16rFF ]', 'byteLiteral');
  });
  test('testCharLiteral1', () {
    return validate('\$a', 'charLiteral');
  });
  test('testCharLiteral2', () {
    return validate('\$ ', 'charLiteral');
  });
  test('testCharLiteral3', () {
    return validate('\$\$', 'charLiteral');
  });
  test('testNumberLiteral1', () {
    return validate('0', 'numberLiteral');
  });
  test('testNumberLiteral10', () {
    return validate('10r10', 'numberLiteral');
  });
  test('testNumberLiteral11', () {
    return validate('8r777', 'numberLiteral');
  });
  test('testNumberLiteral12', () {
    return validate('16rAF', 'numberLiteral');
  });
  test('testNumberLiteral13', () {
    return validate('16rCA.FE', 'numberLiteral');
  });
  test('testNumberLiteral14', () {
    return validate('3r-22.2', 'numberLiteral');
  });
  test('testNumberLiteral15', () {
    return validate('0.50s2', 'numberLiteral');
  });
  test('testNumberLiteral2', () {
    return validate('0.1', 'numberLiteral');
  });
  test('testNumberLiteral3', () {
    return validate('123', 'numberLiteral');
  });
  test('testNumberLiteral4', () {
    return validate('123.456', 'numberLiteral');
  });
  test('testNumberLiteral5', () {
    return validate('-0', 'numberLiteral');
  });
  test('testNumberLiteral6', () {
    return validate('-0.1', 'numberLiteral');
  });
  test('testNumberLiteral7', () {
    return validate('-123', 'numberLiteral');
  });
  test('testNumberLiteral8', () {
    return validate('-123', 'numberLiteral');
  });
  test('testNumberLiteral9', () {
    return validate('-123.456', 'numberLiteral');
  });
  test('testSpecialLiteral1', () {
    return validate('true', 'trueLiteral');
  });
  test('testSpecialLiteral2', () {
    return validate('false', 'falseLiteral');
  });
  test('testSpecialLiteral3', () {
    return validate('nil', 'nilLiteral');
  });
  test('testStringLiteral1', () {
    return validate('\'\'', 'stringLiteral');
  });
  test('testStringLiteral2', () {
    return validate('\'ab\'', 'stringLiteral');
  });
  test('testStringLiteral3', () {
    return validate('\'ab\'\'cd\'', 'stringLiteral');
  });
  test('testSymbolLiteral1', () {
    return validate('#foo', 'symbolLiteral');
  });
  test('testSymbolLiteral2', () {
    return validate('#+', 'symbolLiteral');
  });
  test('testSymbolLiteral3', () {
    return validate('#key:', 'symbolLiteral');
  });
  test('testSymbolLiteral4', () {
    return validate('#key:value:', 'symbolLiteral');
  });
  test('testSymbolLiteral5', () {
    return validate('#\'testing-result\'', 'symbolLiteral');
  });
  test('testSymbolLiteral6', () {
    return validate('#__gen__binding', 'symbolLiteral');
  });
  test('testSymbolLiteral7', () {
    return validate('# fucker', 'symbolLiteral');
  });
  test('testSymbolLiteral8', () {
    return validate('##fucker', 'symbolLiteral');
  });
  test('testSymbolLiteral9', () {
    return validate('## fucker', 'symbolLiteral');
  });
  test('testBinaryExpression1', () {
    return validate('1 + 2', 'expression');
  });
  test('testBinaryExpression2', () {
    return validate('1 + 2 + 3', 'expression');
  });
  test('testBinaryExpression3', () {
    return validate('1 // 2', 'expression');
  });
  test('testBinaryExpression4', () {
    return validate('1 -- 2', 'expression');
  });
  test('testBinaryExpression5', () {
    return validate('1 ==> 2', 'expression');
  });
  test('testBinaryMethod1', () {
    return validate('+ a', 'method');
  });
  test('testBinaryMethod2', () {
    return validate('+ a | b |', 'method');
  });
  test('testBinaryMethod3', () {
    return validate('+ a b', 'method');
  });
  test('testBinaryMethod4', () {
    return validate('+ a | b | c', 'method');
  });
  test('testBinaryMethod5', () {
    return validate('-- a', 'method');
  });
  test('testCascadeExpression1', () {
    return validate('1 abs; negated', 'expression');
  });
  test('testCascadeExpression2', () {
    return validate('1 abs negated; raisedTo: 12; negated', 'expression');
  });
  test('testCascadeExpression3', () {
    return validate('1 + 2; - 3', 'expression');
  });
  test('testKeywordExpression1', () {
    return validate('1 to: 2', 'expression');
  });
  test('testKeywordExpression2', () {
    return validate('1 to: 2 by: 3', 'expression');
  });
  test('testKeywordExpression3', () {
    return validate('1 to: 2 by: 3 do: 4', 'expression');
  });
  test('testKeywordMethod1', () {
    return validate('to: a', 'method');
  });
  test('testKeywordMethod2', () {
    return validate('to: a do: b | c |', 'method');
  });
  test('testKeywordMethod3', () {
    return validate('to: a do: b by: c d', 'method');
  });
  test('testKeywordMethod4', () {
    return validate('to: a do: b by: c | d | e', 'method');
  });
  test('testUnaryExpression1', () {
    return validate('1 abs', 'expression');
  });
  test('testUnaryExpression2', () {
    return validate('1 abs negated', 'expression');
  });
  test('testUnaryMethod1', () {
    return validate('abs', 'method');
  });
  test('testUnaryMethod2', () {
    return validate('abs | a |', 'method');
  });
  test('testUnaryMethod3', () {
    return validate('abs a', 'method');
  });
  test('testUnaryMethod4', () {
    return validate('abs | a | b', 'method');
  });
  test('testUnaryMethod5', () {
    return validate('abs | a |', 'method');
  });
  test('testPragma1', () {
    return validate('method <foo>', 'method');
  });
  test('testPragma10', () {
    return validate('method <foo: bar>', 'method');
  });
  test('testPragma11', () {
    return validate('method <foo: true>', 'method');
  });
  test('testPragma12', () {
    return validate('method <foo: false>', 'method');
  });
  test('testPragma13', () {
    return validate('method <foo: nil>', 'method');
  });
  test('testPragma14', () {
    return validate('method <foo: ()>', 'method');
  });
  test('testPragma15', () {
    return validate('method <foo: #()>', 'method');
  });
  test('testPragma16', () {
    return validate('method < + 1 >', 'method');
  });
  test('testPragma2', () {
    return validate('method <foo> <bar>', 'method');
  });
  test('testPragma3', () {
    return validate('method | a | <foo>', 'method');
  });
  test('testPragma4', () {
    return validate('method <foo> | a |', 'method');
  });
  test('testPragma5', () {
    return validate('method <foo> | a | <bar>', 'method');
  });
  test('testPragma6', () {
    return validate('method <foo: 1>', 'method');
  });
  test('testPragma7', () {
    return validate('method <foo: 1.2>', 'method');
  });
  test('testPragma8', () {
    return validate('method <foo: ''bar''>', 'method');
  });
  test('testPragma9', () {
    return validate('method <foo: #''bar''>', 'method');
  });
}
