import 'package:petitparser/petitparser.dart';

import 'ast.dart';
import 'grammar.dart';

// ignore_for_file: unnecessary_overrides

/// Smalltalk parser definition.
class SmalltalkParserDefinition extends SmalltalkGrammarDefinition {
  Parser array() => super
      .array()
      .map((input) => addStatements(ArrayNode(input[0], input[2]), input[1]));

  Parser arrayLiteral() => super.arrayLiteral().map((input) => LiteralArrayNode(
      input[0], input[1].cast<LiteralNode>().toList(), input[2]));

  Parser arrayLiteralArray() =>
      super.arrayLiteralArray().map((input) => LiteralArrayNode(
          input[0], input[1].cast<LiteralNode>().toList(), input[2]));

  Parser binaryExpression() =>
      super.binaryExpression().map((input) => buildMessage(input[0], input[1]));

  Parser block() => super.block();

  Parser blockArgument() => super.blockArgument();

  Parser blockBody() => super.blockBody();

  Parser byteLiteral() =>
      super.byteLiteral().map((input) => LiteralArrayNode<num>(
          input[0], input[1].cast<LiteralNode<num>>().toList(), input[2]));

  Parser byteLiteralArray() =>
      super.byteLiteralArray().map((input) => LiteralArrayNode<num>(
          input[0], input[1].cast<LiteralNode<num>>().toList(), input[2]));

  Parser characterLiteral() => super.characterLiteral().map(
      (input) => LiteralValueNode<String>(input, input.value.substring(1)));

  Parser cascadeExpression() => super
      .cascadeExpression()
      .map((input) => buildCascade(input[0], input[1]));

  Parser expression() =>
      super.expression().map((input) => buildAssignment(input[1], input[0]));

  Parser expressionReturn() =>
      super.expressionReturn().map((input) => ReturnNode(input[0], input[1]));

  Parser falseLiteral() =>
      super.falseLiteral().map((input) => LiteralValueNode<bool>(input, false));

  Parser keywordExpression() => super
      .keywordExpression()
      .map((input) => buildMessage(input[0], [input[1]]));

  Parser method() => super.method();

  Parser methodDeclaration() => super.methodDeclaration();

  Parser methodSequence() => super.methodSequence();

  Parser nilLiteral() =>
      super.nilLiteral().map((input) => LiteralValueNode<void>(input, null));

  Parser numberLiteral() => super
      .numberLiteral()
      .map((input) => LiteralValueNode<num>(input, buildNumber(input.value)));

  Parser parens() =>
      super.parens().map((input) => input[1]..addParens(input[0], input[2]));

  Parser pragma() => super.pragma();

  Parser sequence() => super
      .sequence()
      .map((input) => buildSequence(input[0], [input[1], input[2]]));

  Parser stringLiteral() => super.stringLiteral().map(
      (input) => LiteralValueNode<String>(input, buildString(input.value)));

  Parser symbolLiteral() =>
      super.symbolLiteral().map((input) => LiteralValueNode<String>(
          Token.join<dynamic>([...input[0], input[1]]),
          buildString(input[1].value)));

  Parser symbolLiteralArray() => super.symbolLiteralArray().map(
      (input) => LiteralValueNode<String>(input, buildString(input.value)));

  Parser unaryExpression() =>
      super.unaryExpression().map((input) => buildMessage(input[0], input[1]));

  Parser trueLiteral() =>
      super.trueLiteral().map((input) => LiteralValueNode<bool>(input, true));

  Parser variable() => super.variable().map((input) => VariableNode(input));
}

num buildNumber(String input) {
  final values = input.split('r');
  return values.length == 1
      ? num.parse(values[0])
      : values.length == 2
          ? int.parse(values[1], radix: int.parse(values[0]))
          : throw ArgumentError.value(input, 'number', 'Unable to parse');
}

String buildString(String input) =>
    input.isNotEmpty && input.startsWith("'") && input.startsWith("'")
        ? input.substring(1, input.length - 1).replaceAll("''", "'")
        : input;

ValueNode buildAssignment(ValueNode node, List parts) {
  if (parts.isEmpty) {
    return node;
  }
  return parts.reversed.fold(
      node,
      (result, variableAndToken) =>
          AssignmentNode(variableAndToken[0], variableAndToken[1], result));
}

ValueNode buildCascade(ValueNode node, List parts) {
  if (parts.isEmpty) {
    return node;
  }
  final messages = [node as MessageNode];
  final semicolons = <Token>[];
  for (final part in parts) {
    messages.add(buildMessage(messages[0].receiver, [part[1]]) as MessageNode);
    semicolons.add(part[0]);
  }
  return CascadeNode(messages, semicolons);
}

ValueNode buildMessage(ValueNode receiver, List? parts) => (parts ?? []).fold(
    receiver,
    (receiver, selectorsAndArguments) => selectorsAndArguments == null
        ? receiver
        : MessageNode(receiver, selectorsAndArguments[0].cast<Token>().toList(),
            selectorsAndArguments[1].cast<ValueNode>().toList()));

SequenceNode buildSequence(List temporaries, List statements) {
  final result = SequenceNode();
  if (temporaries.isNotEmpty) {
    result.temporaries.addAll(temporaries[1].cast<VariableNode>());
  }
  addStatements(result, statements);
  return result;
}

HasStatements addStatements(HasStatements node, List? parts) {
  for (final part in parts ?? []) {
    if (part is List) {
      addStatements(node, part);
    } else if (part is Token) {
      node.periods.add(part);
    } else if (part is IsStatement) {
      node.statements.add(part);
    }
  }
  return node;
}
