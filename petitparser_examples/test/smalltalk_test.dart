import 'package:petitparser/petitparser.dart';
import 'package:petitparser_examples/smalltalk.dart';
import 'package:petitparser_examples/src/smalltalk/ast.dart';
import 'package:test/test.dart';

final grammar = SmalltalkGrammarDefinition();
final parser = SmalltalkParserDefinition();

dynamic parse(String source, Parser Function() production) {
  final parser = resolve(production()).end();
  final result = parser.parse(source);
  return result.value;
}

void verify(String name, String source, Parser Function() grammarProduction,
    [Parser Function()? parserProduction,
    void Function(Node)? parserAssertion]) {
  group(name, () {
    test('grammar', () => parse(source, grammarProduction));
    if (parserProduction != null && parserAssertion != null) {
      test('parser', () => parserAssertion(parse(source, parserProduction)));
    }
  });
}

void main() {
  group('grammar', () {
    test('start', () {
      parse(r'''
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
    // All the productions and production actions of the grammar and parser.
    verify('Array1', '{}', grammar.array);
    verify('Array2', '{self foo}', grammar.array);
    verify('Array3', '{self foo. self bar}', grammar.array);
    verify('Array4', '{self foo. self bar.}', grammar.array);
    verify('Assignment1', '1', grammar.expression);
    verify('Assignment2', 'a := 1', grammar.expression);
    verify('Assignment3', 'a := b := 1', grammar.expression);
    verify('Assignment6', 'a := (b := c)', grammar.expression);
    verify('Comment1', '1"one"+2', grammar.expression);
    verify('Comment2', '1 "one" +2', grammar.expression);
    verify('Comment3', '1"one"+"two"2', grammar.expression);
    verify('Comment4', '1"one""two"+2', grammar.expression);
    verify('Comment5', '1"one" "two"+2', grammar.expression);
    verify('Method1', 'negated ^ 0 - self', grammar.method);
    verify('Method2', '   negated ^ 0 - self', grammar.method);
    verify('Method3', ' negated ^ 0 - self  ', grammar.method);
    verify('Sequence1', '| a | 1 . 2', grammar.sequence);
    verify('Statements1', '1', grammar.sequence);
    verify('Statements2', '1 . 2', grammar.sequence);
    verify('Statements3', '1 . 2 . 3', grammar.sequence);
    verify('Statements4', '1 . 2 . 3 .', grammar.sequence);
    verify('Statements5', '1 . . 2', grammar.sequence);
    verify('Statements6', '1. 2', grammar.sequence);
    verify('Statements7', '. 1', grammar.sequence);
    verify('Statements8', '.1', grammar.sequence);
    verify('Statements9', 'a := 1. b := 2', grammar.sequence);
    verify('Temporaries1', '| a |', grammar.sequence);
    verify('Temporaries2', '| a b |', grammar.sequence);
    verify('Temporaries3', '| a b c |', grammar.sequence);
    verify(
        'Variable1',
        'trueBinding',
        grammar.primary,
        parser.primary,
        (node) => expect(
            node,
            isA<VariableNode>()
                .having((node) => node.name, 'name', 'trueBinding')));
    verify(
        'Variable2',
        'falseBinding',
        grammar.primary,
        parser.primary,
        (node) => expect(
            node,
            isA<VariableNode>()
                .having((node) => node.name, 'name', 'falseBinding')));
    verify(
        'Variable3',
        'nilly',
        grammar.primary,
        parser.primary,
        (node) => expect(node,
            isA<VariableNode>().having((node) => node.name, 'name', 'nilly')));
    verify(
        'Variable4',
        'selfish',
        grammar.primary,
        parser.primary,
        (node) => expect(
            node,
            isA<VariableNode>()
                .having((node) => node.name, 'name', 'selfish')));
    verify(
        'Variable5',
        'supernanny',
        grammar.primary,
        parser.primary,
        (node) => expect(
            node,
            isA<VariableNode>()
                .having((node) => node.name, 'name', 'supernanny')));
    verify(
        'Variable6',
        'super_nanny',
        grammar.primary,
        parser.primary,
        (node) => expect(
            node,
            isA<VariableNode>()
                .having((node) => node.name, 'name', 'super_nanny')));
    verify(
        'Variable7',
        '__gen_var_123__',
        grammar.primary,
        parser.primary,
        (node) => expect(
            node,
            isA<VariableNode>()
                .having((node) => node.name, 'name', '__gen_var_123__')));
    verify('ArgumentsBlock1', '[ :a | ]', grammar.block);
    verify('ArgumentsBlock2', '[ :a :b | ]', grammar.block);
    verify('ArgumentsBlock3', '[ :a :b :c | ]', grammar.block);
    verify('ComplexBlock1', '[ :a | | b | c ]', grammar.block);
    verify('ComplexBlock2', '[:a||b|c]', grammar.block);
    verify('SimpleBlock1', '[ ]', grammar.block);
    verify('SimpleBlock2', '[ nil ]', grammar.block);
    verify('SimpleBlock3', '[ :a ]', grammar.block);
    verify('StatementBlock1', '[ nil ]', grammar.block);
    verify('StatementBlock2', '[ | a | nil ]', grammar.block);
    verify('StatementBlock3', '[ | a b | nil ]', grammar.block);
    verify(
        'ArrayLiteral1',
        '#()',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        (node) => expect(node,
            isA<LiteralArrayNode>().having((node) => node.value, 'value', [])));
    verify(
        'ArrayLiteral2',
        '#(1)',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode>()
                .having((node) => node.value, 'value', [1])));
    verify(
        'ArrayLiteral3',
        '#(1 2)',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode>()
                .having((node) => node.value, 'value', [1, 2])));
    verify(
        'ArrayLiteral4',
        '#(true false nil)',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode>()
                .having((node) => node.value, 'value', [true, false, null])));
    verify(
        'ArrayLiteral5',
        '#(\$a)',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode>()
                .having((node) => node.value, 'value', ['a'])));
    verify(
        'ArrayLiteral6',
        '#(1.2)',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode>()
                .having((node) => node.value, 'value', [1.2])));
    verify(
        'ArrayLiteral7',
        "#(size #at: at:put: #'==')",
        grammar.arrayLiteral,
        parser.arrayLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode>().having((node) => node.value, 'value',
                ['size', 'at:', 'at:put:', '=='])));
    verify(
        'ArrayLiteral8',
        "#('baz')",
        grammar.arrayLiteral,
        parser.arrayLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode>()
                .having((node) => node.value, 'value', ['baz'])));
    verify(
        'ArrayLiteral9',
        '#((1) 2)',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode>().having((node) => node.value, 'value', [
              [1],
              2
            ])));
    verify(
        'ArrayLiteral10',
        '#((1 2) #(1 2 3))',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode>().having((node) => node.value, 'value', [
              [1, 2],
              [1, 2, 3]
            ])));
    verify(
        'ArrayLiteral11',
        '#([1 2] #[1 2 3])',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode>().having((node) => node.value, 'value', [
              [1, 2],
              [1, 2, 3]
            ])));
    verify(
        'ByteLiteral1',
        '#[]',
        grammar.byteLiteral,
        parser.byteLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode<num>>()
                .having((node) => node.value, 'value', [])));
    verify(
        'ByteLiteral2',
        '#[0]',
        grammar.byteLiteral,
        parser.byteLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode<num>>()
                .having((node) => node.value, 'value', [0])));
    verify(
        'ByteLiteral3',
        '#[255]',
        grammar.byteLiteral,
        parser.byteLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode<num>>()
                .having((node) => node.value, 'value', [255])));
    verify(
        'ByteLiteral4',
        '#[ 1 2 ]',
        grammar.byteLiteral,
        parser.byteLiteral,
        (node) => expect(
            node,
            isA<LiteralArrayNode<num>>()
                .having((node) => node.value, 'value', [1, 2])));
    verify('ByteLiteral5', '#[ 2r1010 8r77 16rFF ]', grammar.byteLiteral);
    verify(
        'CharLiteral1',
        '\$a',
        grammar.characterLiteral,
        parser.characterLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', 'a')));
    verify(
        'CharLiteral2',
        '\$ ',
        grammar.characterLiteral,
        parser.characterLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', ' ')));
    verify(
        'CharLiteral3',
        '\$\$',
        grammar.characterLiteral,
        parser.characterLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', '\$')));
    verify(
        'NumberLiteral1',
        '0',
        grammar.numberLiteral,
        parser.numberLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<num>>()
                .having((node) => node.value, 'value', 0)));
    verify('NumberLiteral10', '10r10', grammar.numberLiteral);
    verify('NumberLiteral11', '8r777', grammar.numberLiteral);
    verify('NumberLiteral12', '16rAF', grammar.numberLiteral);
    verify(
        'NumberLiteral2',
        '0.1',
        grammar.numberLiteral,
        parser.numberLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<num>>()
                .having((node) => node.value, 'value', 0.1)));
    verify(
        'NumberLiteral3',
        '123',
        grammar.numberLiteral,
        parser.numberLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<num>>()
                .having((node) => node.value, 'value', 123)));
    verify(
        'NumberLiteral4',
        '123.456',
        grammar.numberLiteral,
        parser.numberLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<num>>()
                .having((node) => node.value, 'value', 123.456)));
    verify(
        'NumberLiteral5',
        '-0',
        grammar.numberLiteral,
        parser.numberLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<num>>()
                .having((node) => node.value, 'value', 0)));
    verify(
        'NumberLiteral6',
        '-0.1',
        grammar.numberLiteral,
        parser.numberLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<num>>()
                .having((node) => node.value, 'value', -0.1)));
    verify(
        'NumberLiteral7',
        '-123',
        grammar.numberLiteral,
        parser.numberLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<num>>()
                .having((node) => node.value, 'value', -123)));
    verify(
        'NumberLiteral9',
        '-123.456',
        grammar.numberLiteral,
        parser.numberLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<num>>()
                .having((node) => node.value, 'value', -123.456)));
    verify(
        'SpecialLiteral1',
        'true',
        grammar.trueLiteral,
        parser.trueLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<bool>>()
                .having((node) => node.value, 'value', true)));
    verify(
        'SpecialLiteral2',
        'false',
        grammar.falseLiteral,
        parser.falseLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<bool>>()
                .having((node) => node.value, 'value', false)));
    verify(
        'SpecialLiteral3',
        'nil',
        grammar.nilLiteral,
        parser.nilLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<void>>()
                .having((node) => node.value, 'value', null)));
    verify(
        'StringLiteral1',
        '\'\'',
        grammar.stringLiteral,
        parser.stringLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', '')));
    verify(
        'StringLiteral2',
        '\'ab\'',
        grammar.stringLiteral,
        parser.stringLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', 'ab')));
    verify(
        'StringLiteral3',
        '\'ab\'\'cd\'',
        grammar.stringLiteral,
        parser.stringLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', 'ab\'cd')));
    verify(
        'SymbolLiteral1',
        '#foo',
        grammar.symbolLiteral,
        parser.symbolLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', 'foo')));
    verify(
        'SymbolLiteral2',
        '#+',
        grammar.symbolLiteral,
        parser.symbolLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', '+')));
    verify(
        'SymbolLiteral3',
        '#key:',
        grammar.symbolLiteral,
        parser.symbolLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', 'key:')));
    verify(
        'SymbolLiteral4',
        '#key:value:',
        grammar.symbolLiteral,
        parser.symbolLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', 'key:value:')));
    verify(
        'SymbolLiteral5',
        '#\'ing-result\'',
        grammar.symbolLiteral,
        parser.symbolLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', 'ing-result')));
    verify(
        'SymbolLiteral6',
        '#__gen__binding',
        grammar.symbolLiteral,
        parser.symbolLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', '__gen__binding')));
    verify(
        'SymbolLiteral7',
        '# foo',
        grammar.symbolLiteral,
        parser.symbolLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', 'foo')));
    verify(
        'SymbolLiteral8',
        '##foo',
        grammar.symbolLiteral,
        parser.symbolLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', 'foo')));
    verify(
        'SymbolLiteral9',
        '## foo',
        grammar.symbolLiteral,
        parser.symbolLiteral,
        (node) => expect(
            node,
            isA<LiteralValueNode<String>>()
                .having((node) => node.value, 'value', 'foo')));
    verify('BinaryExpression1', '1 + 2', grammar.expression);
    verify('BinaryExpression2', '1 + 2 + 3', grammar.expression);
    verify('BinaryExpression3', '1 // 2', grammar.expression);
    verify('BinaryExpression4', '1 -- 2', grammar.expression);
    verify('BinaryExpression5', '1 ==> 2', grammar.expression);
    verify('BinaryMethod1', '+ a', grammar.method);
    verify('BinaryMethod2', '+ a | b |', grammar.method);
    verify('BinaryMethod3', '+ a b', grammar.method);
    verify('BinaryMethod4', '+ a | b | c', grammar.method);
    verify('BinaryMethod5', '-- a', grammar.method);
    verify('CascadeExpression1', '1 abs; negated', grammar.expression);
    verify('CascadeExpression2', '1 abs negated; raisedTo: 12; negated',
        grammar.expression);
    verify('CascadeExpression3', '1 + 2; - 3', grammar.expression);
    verify('KeywordExpression1', '1 to: 2', grammar.expression);
    verify('KeywordExpression2', '1 to: 2 by: 3', grammar.expression);
    verify('KeywordExpression3', '1 to: 2 by: 3 do: 4', grammar.expression);
    verify('KeywordMethod1', 'to: a', grammar.method);
    verify('KeywordMethod2', 'to: a do: b | c |', grammar.method);
    verify('KeywordMethod3', 'to: a do: b by: c d', grammar.method);
    verify('KeywordMethod4', 'to: a do: b by: c | d | e', grammar.method);
    verify('UnaryExpression1', '1 abs', grammar.expression);
    verify('UnaryExpression2', '1 abs negated', grammar.expression);
    verify('UnaryMethod1', 'abs', grammar.method);
    verify('UnaryMethod2', 'abs | a |', grammar.method);
    verify('UnaryMethod3', 'abs a', grammar.method);
    verify('UnaryMethod4', 'abs | a | b', grammar.method);
    verify('UnaryMethod5', 'abs | a |', grammar.method);
    verify('Pragma1', 'method <foo>', grammar.method);
    verify('Pragma10', 'method <foo: bar>', grammar.method);
    verify('Pragma11', 'method <foo: true>', grammar.method);
    verify('Pragma12', 'method <foo: false>', grammar.method);
    verify('Pragma13', 'method <foo: nil>', grammar.method);
    verify('Pragma14', 'method <foo: ()>', grammar.method);
    verify('Pragma15', 'method <foo: #()>', grammar.method);
    verify('Pragma16', 'method < + 1 >', grammar.method);
    verify('Pragma2', 'method <foo> <bar>', grammar.method);
    verify('Pragma3', 'method | a | <foo>', grammar.method);
    verify('Pragma4', 'method <foo> | a |', grammar.method);
    verify('Pragma5', 'method <foo> | a | <bar>', grammar.method);
    verify('Pragma6', 'method <foo: 1>', grammar.method);
    verify('Pragma7', 'method <foo: 1.2>', grammar.method);
    verify('Pragma8', 'method <foo: ' 'bar' '>', grammar.method);
    verify('Pragma9', 'method <foo: #' 'bar' '>', grammar.method);
  });
}
