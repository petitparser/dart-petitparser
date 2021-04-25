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
    [Parser Function()? parserProduction, Matcher? parseMatcher]) {
  group(name, () {
    test('grammar', () => parse(source, grammarProduction));
    if (parserProduction != null && parseMatcher != null) {
      test('parser',
          () => expect(parse(source, parserProduction), parseMatcher));
    }
  });
}

// Node matchers

TypeMatcher<LiteralNode> isLiteralNode(dynamic value) =>
    isA<LiteralNode>().having((node) => node.value, 'value', value);

TypeMatcher<VariableNode> isVariableNode(String name) =>
    isA<VariableNode>().having((node) => node.name, 'name', name);

TypeMatcher<MessageNode> isMessageNode(Matcher receiver, String selector,
        [List<Matcher> arguments = const []]) =>
    isA<MessageNode>()
        .having((node) => node.receiver, 'receiver', receiver)
        .having((node) => node.selector, 'selector', selector)
        .having((node) => node.arguments, 'arguments', arguments);

TypeMatcher<CascadeNode> isCascadeNode(List<Matcher> messages) =>
    isA<CascadeNode>().having((node) => node.messages, 'messages', messages);

TypeMatcher<AssignmentNode> isAssignmentNode(String name, Matcher value) =>
    isA<AssignmentNode>()
        .having((node) => node.variable, 'variable', isVariableNode(name))
        .having((node) => node.value, 'value', value);

TypeMatcher<ArrayNode> isArrayNode(List<Matcher> statements) => isA<ArrayNode>()
    .having((node) => node.statements, 'statements', statements);

TypeMatcher<SequenceNode> isSequenceNode(
        List<Matcher> temporaries, List<Matcher> statements) =>
    isA<SequenceNode>()
        .having((node) => node.temporaries, 'temporaries', temporaries)
        .having((node) => node.statements, 'statements', statements);

TypeMatcher<ReturnNode> isReturnNode(Matcher value) =>
    isA<ReturnNode>().having((node) => node.value, 'value', value);

TypeMatcher<BlockNode> isBlockNode(List<Matcher> arguments,
        List<Matcher> temporaries, List<Matcher> statements) =>
    isA<BlockNode>()
        .having((node) => node.arguments, 'arguments', arguments)
        .having((node) => node.body, 'body',
            isSequenceNode(temporaries, statements));

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
    verify('Array1', '{}', grammar.array, parser.array, isArrayNode([]));
    verify('Array2', '{1}', grammar.array, parser.array,
        isArrayNode([isLiteralNode(1)]));
    verify('Array3', '{1. 2}', grammar.array, parser.array,
        isArrayNode([isLiteralNode(1), isLiteralNode(2)]));
    verify('Array4', '{1. 2. }', grammar.array, parser.array,
        isArrayNode([isLiteralNode(1), isLiteralNode(2)]));
    verify('Assignment1', '1', grammar.expression, parser.expression,
        isLiteralNode(1));
    verify('Assignment2', 'a := 1', grammar.expression, parser.expression,
        isAssignmentNode('a', isLiteralNode(1)));
    verify('Assignment3', 'a := b := 1', grammar.expression, parser.expression,
        isAssignmentNode('a', isAssignmentNode('b', isLiteralNode(1))));
    verify(
        'Assignment4',
        'a := (b := c)',
        grammar.expression,
        parser.expression,
        isAssignmentNode('a', isAssignmentNode('b', isVariableNode('c'))));
    verify('Comment1', '1"one"+2', grammar.expression);
    verify('Comment2', '1 "one" +2', grammar.expression);
    verify('Comment3', '1"one"+"two"2', grammar.expression);
    verify('Comment4', '1"one""two"+2', grammar.expression);
    verify('Comment5', '1"one" "two"+2', grammar.expression);
    verify('Method1', 'negated ^ 0 - self', grammar.method);
    verify('Method2', '   negated ^ 0 - self', grammar.method);
    verify('Method3', ' negated ^ 0 - self  ', grammar.method);
    verify('Sequence1', '| a | 1', grammar.sequence, parser.sequence,
        isSequenceNode([isVariableNode('a')], [isLiteralNode(1)]));
    verify(
        'Sequence2',
        '| a | ^ 1',
        grammar.sequence,
        parser.sequence,
        isSequenceNode(
            [isVariableNode('a')], [isReturnNode(isLiteralNode(1))]));
    verify(
        'Sequence3',
        '| a | 1. ^ 2',
        grammar.sequence,
        parser.sequence,
        isSequenceNode([isVariableNode('a')],
            [isLiteralNode(1), isReturnNode(isLiteralNode(2))]));
    verify('Statements1', '1', grammar.sequence, parser.sequence,
        isSequenceNode([], [isLiteralNode(1)]));
    verify('Statements2', '1 . 2', grammar.sequence, parser.sequence,
        isSequenceNode([], [isLiteralNode(1), isLiteralNode(2)]));
    verify(
        'Statements3',
        '1 . 2 . 3',
        grammar.sequence,
        parser.sequence,
        isSequenceNode(
            [], [isLiteralNode(1), isLiteralNode(2), isLiteralNode(3)]));
    verify(
        'Statements4',
        '1 . 2 . 3 .',
        grammar.sequence,
        parser.sequence,
        isSequenceNode(
            [], [isLiteralNode(1), isLiteralNode(2), isLiteralNode(3)]));
    verify('Statements5', '1 . . 2', grammar.sequence, parser.sequence,
        isSequenceNode([], [isLiteralNode(1), isLiteralNode(2)]));
    verify('Statements6', '1. 2', grammar.sequence, parser.sequence,
        isSequenceNode([], [isLiteralNode(1), isLiteralNode(2)]));
    verify('Statements7', '. 1', grammar.sequence, parser.sequence,
        isSequenceNode([], [isLiteralNode(1)]));
    verify('Statements8', '.1', grammar.sequence, parser.sequence,
        isSequenceNode([], [isLiteralNode(1)]));
    verify(
        'Statements9',
        'a := 1. b := 2',
        grammar.sequence,
        parser.sequence,
        isSequenceNode([], [
          isAssignmentNode('a', isLiteralNode(1)),
          isAssignmentNode('b', isLiteralNode(2))
        ]));
    verify('Sequence10', '^ 1', grammar.sequence, parser.sequence,
        isSequenceNode([], [isReturnNode(isLiteralNode(1))]));
    verify('Sequence11', '1. ^ 2', grammar.sequence, parser.sequence,
        isSequenceNode([], [isLiteralNode(1), isReturnNode(isLiteralNode(2))]));
    verify('Temporaries1', '| a |', grammar.sequence, parser.sequence,
        isSequenceNode([isVariableNode('a')], []));
    verify('Temporaries2', '| a b |', grammar.sequence, parser.sequence,
        isSequenceNode([isVariableNode('a'), isVariableNode('b')], []));
    verify(
        'Temporaries3',
        '| a b c |',
        grammar.sequence,
        parser.sequence,
        isSequenceNode(
            [isVariableNode('a'), isVariableNode('b'), isVariableNode('c')],
            []));
    verify('Variable1', 'trueBinding', grammar.primary, parser.primary,
        isVariableNode('trueBinding'));
    verify('Variable2', 'falseBinding', grammar.primary, parser.primary,
        isVariableNode('falseBinding'));
    verify('Variable3', 'nilly', grammar.primary, parser.primary,
        isVariableNode('nilly'));
    verify('Variable4', 'selfish', grammar.primary, parser.primary,
        isVariableNode('selfish'));
    verify('Variable5', 'superman', grammar.primary, parser.primary,
        isVariableNode('superman'));
    verify('Variable6', 'super_nanny', grammar.primary, parser.primary,
        isVariableNode('super_nanny'));
    verify('Variable7', '__gen_var_123__', grammar.primary, parser.primary,
        isVariableNode('__gen_var_123__'));
    verify('ArgumentsBlock1', '[ :a | ]', grammar.block, parser.block,
        isBlockNode([isVariableNode('a')], [], []));
    verify('ArgumentsBlock2', '[ :a :b | ]', grammar.block, parser.block,
        isBlockNode([isVariableNode('a'), isVariableNode('b')], [], []));
    verify(
        'ArgumentsBlock3',
        '[ :a :b :c | ]',
        grammar.block,
        parser.block,
        isBlockNode(
            [isVariableNode('a'), isVariableNode('b'), isVariableNode('c')],
            [],
            []));
    verify(
        'ComplexBlock1',
        '[ :a | | b | c ]',
        grammar.block,
        parser.block,
        isBlockNode([isVariableNode('a')], [isVariableNode('b')],
            [isVariableNode('c')]));
    verify(
        'ComplexBlock2',
        '[:a||b|c]',
        grammar.block,
        parser.block,
        isBlockNode([isVariableNode('a')], [isVariableNode('b')],
            [isVariableNode('c')]));
    verify('SimpleBlock1', '[ ]', grammar.block, parser.block,
        isBlockNode([], [], []));
    verify('SimpleBlock2', '[ a ]', grammar.block, parser.block,
        isBlockNode([], [], [isVariableNode('a')]));
    verify('SimpleBlock3', '[ :a ]', grammar.block, parser.block,
        isBlockNode([isVariableNode('a')], [], []));
    verify('StatementBlock1', '[ 1 ]', grammar.block, parser.block,
        isBlockNode([], [], [isLiteralNode(1)]));
    verify('StatementBlock2', '[ | a | 1 ]', grammar.block, parser.block,
        isBlockNode([], [isVariableNode('a')], [isLiteralNode(1)]));
    verify(
        'StatementBlock3',
        '[ | a b | 1 ]',
        grammar.block,
        parser.block,
        isBlockNode([], [isVariableNode('a'), isVariableNode('b')],
            [isLiteralNode(1)]));
    verify('ArrayLiteral1', '#()', grammar.arrayLiteral, parser.arrayLiteral,
        isLiteralNode([]));
    verify('ArrayLiteral2', '#(1)', grammar.arrayLiteral, parser.arrayLiteral,
        isLiteralNode([1]));
    verify('ArrayLiteral3', '#(1 2)', grammar.arrayLiteral, parser.arrayLiteral,
        isLiteralNode([1, 2]));
    verify('ArrayLiteral4', '#(true false nil)', grammar.arrayLiteral,
        parser.arrayLiteral, isLiteralNode([true, false, null]));
    verify('ArrayLiteral5', '#(\$a)', grammar.arrayLiteral, parser.arrayLiteral,
        isLiteralNode(['a']));
    verify('ArrayLiteral6', '#(1.2)', grammar.arrayLiteral, parser.arrayLiteral,
        isLiteralNode([1.2]));
    verify('ArrayLiteral7', "#(size #at: at:put: #'==')", grammar.arrayLiteral,
        parser.arrayLiteral, isLiteralNode(['size', 'at:', 'at:put:', '==']));
    verify('ArrayLiteral8', "#('baz')", grammar.arrayLiteral,
        parser.arrayLiteral, isLiteralNode(['baz']));
    verify(
        'ArrayLiteral9',
        '#((1) 2)',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        isLiteralNode([
          [1],
          2
        ]));
    verify(
        'ArrayLiteral10',
        '#((1 2) #(1 2 3))',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        isLiteralNode([
          [1, 2],
          [1, 2, 3]
        ]));
    verify(
        'ArrayLiteral11',
        '#([1 2] #[1 2 3])',
        grammar.arrayLiteral,
        parser.arrayLiteral,
        isLiteralNode([
          [1, 2],
          [1, 2, 3]
        ]));
    verify('ByteLiteral1', '#[]', grammar.byteLiteral, parser.byteLiteral,
        isLiteralNode([]));
    verify('ByteLiteral2', '#[0]', grammar.byteLiteral, parser.byteLiteral,
        isLiteralNode([0]));
    verify('ByteLiteral3', '#[255]', grammar.byteLiteral, parser.byteLiteral,
        isLiteralNode([255]));
    verify('ByteLiteral4', '#[ 1 2 ]', grammar.byteLiteral, parser.byteLiteral,
        isLiteralNode([1, 2]));
    verify('ByteLiteral5', '#[ 2r1010 8r77 16rFF ]', grammar.byteLiteral,
        parser.byteLiteral, isLiteralNode([10, 63, 255]));
    verify('CharLiteral1', '\$a', grammar.characterLiteral,
        parser.characterLiteral, isLiteralNode('a'));
    verify('CharLiteral2', '\$ ', grammar.characterLiteral,
        parser.characterLiteral, isLiteralNode(' '));
    verify('CharLiteral3', '\$\$', grammar.characterLiteral,
        parser.characterLiteral, isLiteralNode('\$'));
    verify('NumberLiteral1', '0', grammar.numberLiteral, parser.numberLiteral,
        isLiteralNode(0));
    verify('NumberLiteral2', '0.1', grammar.numberLiteral, parser.numberLiteral,
        isLiteralNode(0.1));
    verify('NumberLiteral3', '123', grammar.numberLiteral, parser.numberLiteral,
        isLiteralNode(123));
    verify('NumberLiteral4', '123.456', grammar.numberLiteral,
        parser.numberLiteral, isLiteralNode(123.456));
    verify('NumberLiteral5', '-0', grammar.numberLiteral, parser.numberLiteral,
        isLiteralNode(0));
    verify('NumberLiteral6', '-0.1', grammar.numberLiteral,
        parser.numberLiteral, isLiteralNode(-0.1));
    verify('NumberLiteral7', '-123', grammar.numberLiteral,
        parser.numberLiteral, isLiteralNode(-123));
    verify('NumberLiteral9', '-123.456', grammar.numberLiteral,
        parser.numberLiteral, isLiteralNode(-123.456));
    verify('NumberLiteral10', '10r10', grammar.numberLiteral,
        parser.numberLiteral, isLiteralNode(10));
    verify('NumberLiteral11', '8r777', grammar.numberLiteral,
        parser.numberLiteral, isLiteralNode(511));
    verify('NumberLiteral12', '16rAF', grammar.numberLiteral,
        parser.numberLiteral, isLiteralNode(175));
    verify('SpecialLiteral1', 'true', grammar.trueLiteral, parser.trueLiteral,
        isLiteralNode(true));
    verify('SpecialLiteral2', 'false', grammar.falseLiteral,
        parser.falseLiteral, isLiteralNode(false));
    verify('SpecialLiteral3', 'nil', grammar.nilLiteral, parser.nilLiteral,
        isLiteralNode(null));
    verify('StringLiteral1', "''", grammar.stringLiteral, parser.stringLiteral,
        isLiteralNode(''));
    verify('StringLiteral2', '\'ab\'', grammar.stringLiteral,
        parser.stringLiteral, isLiteralNode('ab'));
    verify('StringLiteral3', '\'ab\'\'cd\'', grammar.stringLiteral,
        parser.stringLiteral, isLiteralNode('ab\'cd'));
    verify('SymbolLiteral1', '#foo', grammar.symbolLiteral,
        parser.symbolLiteral, isLiteralNode('foo'));
    verify('SymbolLiteral2', '#+', grammar.symbolLiteral, parser.symbolLiteral,
        isLiteralNode('+'));
    verify('SymbolLiteral3', '#key:', grammar.symbolLiteral,
        parser.symbolLiteral, isLiteralNode('key:'));
    verify('SymbolLiteral4', '#key:value:', grammar.symbolLiteral,
        parser.symbolLiteral, isLiteralNode('key:value:'));
    verify('SymbolLiteral5', '#\'ing-result\'', grammar.symbolLiteral,
        parser.symbolLiteral, isLiteralNode('ing-result'));
    verify('SymbolLiteral6', '#__gen__binding', grammar.symbolLiteral,
        parser.symbolLiteral, isLiteralNode('__gen__binding'));
    verify('SymbolLiteral7', '# foo', grammar.symbolLiteral,
        parser.symbolLiteral, isLiteralNode('foo'));
    verify('SymbolLiteral8', '##foo', grammar.symbolLiteral,
        parser.symbolLiteral, isLiteralNode('foo'));
    verify('SymbolLiteral9', '## foo', grammar.symbolLiteral,
        parser.symbolLiteral, isLiteralNode('foo'));
    verify('BinaryExpression1', '1 + 2', grammar.expression, parser.expression,
        isMessageNode(isLiteralNode(1), '+', [isLiteralNode(2)]));
    verify(
        'BinaryExpression2',
        '1 + 2 + 3',
        grammar.expression,
        parser.expression,
        isMessageNode(isMessageNode(isLiteralNode(1), '+', [isLiteralNode(2)]),
            '+', [isLiteralNode(3)]));
    verify('BinaryExpression3', '1 // 2', grammar.expression, parser.expression,
        isMessageNode(isLiteralNode(1), '//', [isLiteralNode(2)]));
    verify('BinaryExpression4', '1 -- 2', grammar.expression, parser.expression,
        isMessageNode(isLiteralNode(1), '--', [isLiteralNode(2)]));
    verify(
        'BinaryExpression5',
        '1 ==> 2',
        grammar.expression,
        parser.expression,
        isMessageNode(isLiteralNode(1), '==>', [isLiteralNode(2)]));
    verify('BinaryMethod1', '+ a', grammar.method);
    verify('BinaryMethod2', '+ a | b |', grammar.method);
    verify('BinaryMethod3', '+ a b', grammar.method);
    verify('BinaryMethod4', '+ a | b | c', grammar.method);
    verify('BinaryMethod5', '-- a', grammar.method);
    verify(
        'CascadeExpression1',
        '1 abs; negated',
        grammar.expression,
        parser.expression,
        isCascadeNode([
          isMessageNode(isLiteralNode(1), 'abs'),
          isMessageNode(isLiteralNode(1), 'negated'),
        ]));
    verify(
        'CascadeExpression2',
        '1 abs negated; raisedTo: 12; negated',
        grammar.expression,
        parser.expression,
        isCascadeNode([
          isMessageNode(isMessageNode(isLiteralNode(1), 'abs'), 'negated'),
          isMessageNode(isMessageNode(isLiteralNode(1), 'abs'), 'raisedTo:',
              [isLiteralNode(12)]),
          isMessageNode(isMessageNode(isLiteralNode(1), 'abs'), 'negated'),
        ]));
    verify(
        'CascadeExpression3',
        '1 + 2; - 3',
        grammar.expression,
        parser.expression,
        isCascadeNode([
          isMessageNode(isLiteralNode(1), '+', [isLiteralNode(2)]),
          isMessageNode(isLiteralNode(1), '-', [isLiteralNode(3)]),
        ]));
    verify(
        'KeywordExpression1',
        '1 to: 2',
        grammar.expression,
        parser.expression,
        isMessageNode(isLiteralNode(1), 'to:', [isLiteralNode(2)]));
    verify(
        'KeywordExpression2',
        '1 to: 2 by: 3',
        grammar.expression,
        parser.expression,
        isMessageNode(
            isLiteralNode(1), 'to:by:', [isLiteralNode(2), isLiteralNode(3)]));
    verify(
        'KeywordExpression3',
        '1 to: 2 by: 3 do: 4',
        grammar.expression,
        parser.expression,
        isMessageNode(isLiteralNode(1), 'to:by:do:',
            [isLiteralNode(2), isLiteralNode(3), isLiteralNode(4)]));
    verify('KeywordMethod1', 'to: a', grammar.method);
    verify('KeywordMethod2', 'to: a do: b | c |', grammar.method);
    verify('KeywordMethod3', 'to: a do: b by: c d', grammar.method);
    verify('KeywordMethod4', 'to: a do: b by: c | d | e', grammar.method);
    verify('UnaryExpression1', '1 abs', grammar.expression, parser.expression,
        isMessageNode(isLiteralNode(1), 'abs'));
    verify(
        'UnaryExpression2',
        '1 abs negated',
        grammar.expression,
        parser.expression,
        isMessageNode(isMessageNode(isLiteralNode(1), 'abs'), 'negated'));
    verify('UnaryMethod1', 'abs', grammar.method);
    verify('UnaryMethod2', 'abs | a |', grammar.method);
    verify('UnaryMethod3', 'abs a', grammar.method);
    verify('UnaryMethod4', 'abs | a | b', grammar.method);
    verify('UnaryMethod5', 'abs | a |', grammar.method);
    verify('Pragma1', 'method <foo>', grammar.method);
    verify('Pragma2', 'method <foo> <bar>', grammar.method);
    verify('Pragma3', 'method | a | <foo>', grammar.method);
    verify('Pragma4', 'method <foo> | a |', grammar.method);
    verify('Pragma5', 'method <foo> | a | <bar>', grammar.method);
    verify('Pragma6', 'method <foo: 1>', grammar.method);
    verify('Pragma7', 'method <foo: 1.2>', grammar.method);
    verify('Pragma8', 'method <foo: ' 'bar' '>', grammar.method);
    verify('Pragma9', 'method <foo: #' 'bar' '>', grammar.method);
    verify('Pragma10', 'method <foo: bar>', grammar.method);
    verify('Pragma11', 'method <foo: true>', grammar.method);
    verify('Pragma12', 'method <foo: false>', grammar.method);
    verify('Pragma13', 'method <foo: nil>', grammar.method);
    verify('Pragma14', 'method <foo: ()>', grammar.method);
    verify('Pragma15', 'method <foo: #()>', grammar.method);
    verify('Pragma16', 'method < + 1 >', grammar.method);
  });
}
