// ignore_for_file: unnecessary_overrides
import 'package:petitparser/petitparser.dart';

import 'ast.dart';
import 'grammar.dart';

/// Smalltalk parser definition.
class SmalltalkParserDefinition extends SmalltalkGrammarDefinition {
  Parser array() => super
      .array()
      .map((input) => buildArray(input[1])..surroundWith(input[0], input[2]));

  Parser arrayLiteral() => super.arrayLiteral().map((input) =>
      LiteralArrayNode(input[1].cast<LiteralNode>().toList())
        ..surroundWith(input[0], input[2]));

  Parser arrayLiteralArray() => super.arrayLiteralArray().map((input) =>
      LiteralArrayNode(input[1].cast<LiteralNode>().toList())
        ..surroundWith(input[0], input[2]));

  Parser binaryExpression() =>
      super.binaryExpression().map((input) => buildMessage(input[0], input[1]));

  Parser block() =>
      super.block().map((input) => input[1]..surroundWith(input[0], input[2]));

  Parser blockArgument() => super.blockArgument();

  Parser blockBody() =>
      super.blockBody().map((input) => buildBlock(input[0], input[1]));

  Parser byteLiteral() => super.byteLiteral().map((input) =>
      LiteralArrayNode<num>(input[1].cast<LiteralNode<num>>().toList())
        ..surroundWith(input[0], input[2]));

  Parser byteLiteralArray() => super.byteLiteralArray().map((input) =>
      LiteralArrayNode<num>(input[1].cast<LiteralNode<num>>().toList())
        ..surroundWith(input[0], input[2]));

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

  Parser method() => super.method().map((input) => buildMethod(input));

  Parser nilLiteral() =>
      super.nilLiteral().map((input) => LiteralValueNode<void>(input, null));

  Parser numberLiteral() => super
      .numberLiteral()
      .map((input) => LiteralValueNode<num>(input, buildNumber(input.value)));

  Parser parens() =>
      super.parens().map((input) => input[1]..surroundWith(input[0], input[2]));

  Parser pragma() => super
      .pragma()
      .map((input) => buildPragma(input[1])..surroundWith(input[0], input[2]));

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

// Build different node types

ArrayNode buildArray(List statements) {
  final result = ArrayNode();
  addTo<IsStatement>(result.statements, statements);
  addTo<Token>(result.periods, statements);
  return result;
}

ValueNode buildAssignment(ValueNode node, List parts) {
  return parts.reversed.fold(
      node,
      (result, variableAndToken) =>
          AssignmentNode(variableAndToken[0], variableAndToken[1], result));
}

ValueNode buildBlock(List arguments, SequenceNode body) {
  final result = BlockNode(body);
  addTo<VariableNode>(result.arguments, arguments);
  addTo<Token>(result.separators, arguments);
  return result;
}

ValueNode buildCascade(ValueNode value, List parts) {
  if (parts.isNotEmpty) {
    final result = CascadeNode();
    result.messages.add(value as MessageNode);
    for (final part in parts) {
      final message = buildMessage(result.receiver, [part[1]]);
      result.messages.add(message as MessageNode);
      result.semicolons.add(part[0]);
    }
    return result;
  }
  return value;
}

ValueNode buildMessage(ValueNode receiver, List parts) {
  return parts
      .where((selectorAndArguments) => selectorAndArguments.isNotEmpty)
      .fold(receiver, (receiver, selectorAndArguments) {
    final message = MessageNode(receiver);
    addTo<Token>(message.selectorToken, selectorAndArguments);
    addTo<ValueNode>(message.arguments, selectorAndArguments);
    return message;
  });
}

MethodNode buildMethod(List parts) {
  final result = MethodNode();
  addTo<Token>(result.selectorToken, parts[0]);
  addTo<VariableNode>(result.arguments, parts[0]);
  addTo<PragmaNode>(result.pragmas, parts[1]);
  addTo<VariableNode>(result.body.temporaries, parts[1][3]);
  addTo<IsStatement>(result.body.statements, parts[1][7]);
  addTo<Token>(result.body.periods, parts[1][7]);
  return result;
}

PragmaNode buildPragma(List parts) {
  final result = PragmaNode();
  addTo<Token>(result.selectorToken, parts);
  addTo<LiteralNode>(result.arguments, parts);
  return result;
}

SequenceNode buildSequence(List temporaries, List statements) {
  final result = SequenceNode();
  addTo<VariableNode>(result.temporaries, temporaries);
  addTo<IsStatement>(result.statements, statements);
  addTo<Token>(result.periods, statements);
  return result;
}

// Various other helpers.

void addTo<T>(List<T> target, List parts) {
  for (final part in parts) {
    if (part is T) {
      target.add(part);
    } else if (part is List) {
      addTo<T>(target, part);
    }
  }
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
