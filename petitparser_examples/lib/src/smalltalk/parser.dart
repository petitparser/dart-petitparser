import 'package:petitparser/petitparser.dart';

import 'ast.dart';
import 'grammar.dart';

/// Smalltalk parser definition.
class SmalltalkParserDefinition extends SmalltalkGrammarDefinition {
  Parser array() => super.array().map(buildArrayNode);

  Parser arrayLiteral() => super.arrayLiteral().map(buildLiteralArrayNode);

  Parser arrayLiteralArray() =>
      super.arrayLiteralArray().map(buildLiteralArrayNode);

  Parser binaryExpression() => super
      .binaryExpression()
      .map((input) => buildMessageNodes(input[0], input[1]));

  Parser block() =>
      super.block().map((input) => input[1]..surroundWith(input[0], input[2]));

  Parser blockBody() => super.blockBody().map(buildBlockNode);

  Parser byteLiteral() => super.byteLiteral().map(buildLiteralArrayNode);

  Parser byteLiteralArray() =>
      super.byteLiteralArray().map(buildLiteralArrayNode);

  Parser characterLiteral() => super.characterLiteral().map(
      (input) => LiteralValueNode<String>(input, input.value.substring(1)));

  Parser cascadeExpression() => super.cascadeExpression().map(buildCascadeNode);

  Parser expression() => super.expression().map(buildAssignmentNode);

  Parser expressionReturn() =>
      super.expressionReturn().map((input) => ReturnNode(input[0], input[1]));

  Parser falseLiteral() =>
      super.falseLiteral().map((input) => LiteralValueNode<bool>(input, false));

  Parser keywordExpression() => super
      .keywordExpression()
      .map((input) => buildMessageNodes(input[0], [input[1]]));

  Parser method() => super.method().map(buildMethodNode);

  Parser nilLiteral() =>
      super.nilLiteral().map((input) => LiteralValueNode<void>(input, null));

  Parser numberLiteral() => super.numberLiteral().map(buildLiteralNumber);

  Parser parens() =>
      super.parens().map((input) => input[1]..surroundWith(input[0], input[2]));

  Parser pragma() => super.pragma().map(buildPragmaNode);

  Parser sequence() => super.sequence().map(buildSequenceNode);

  Parser stringLiteral() => super.stringLiteral().map(
      (input) => LiteralValueNode<String>(input, buildString(input.value)));

  Parser symbolLiteral() =>
      super.symbolLiteral().map((input) => LiteralValueNode<String>(
          Token.join<dynamic>([...input[0], input[1]]),
          buildString(input[1].value)));

  Parser symbolLiteralArray() => super.symbolLiteralArray().map(
      (input) => LiteralValueNode<String>(input, buildString(input.value)));

  Parser unaryExpression() => super
      .unaryExpression()
      .map((input) => buildMessageNodes(input[0], input[1]));

  Parser trueLiteral() =>
      super.trueLiteral().map((input) => LiteralValueNode<bool>(input, true));

  Parser variable() => super.variable().map((input) => VariableNode(input));
}

String buildString(String input) =>
    input.isNotEmpty && input.startsWith("'") && input.startsWith("'")
        ? input.substring(1, input.length - 1).replaceAll("''", "'")
        : input;

Node buildArrayNode(dynamic parts) {
  final result = ArrayNode();
  addTo<IsStatement>(result.statements, parts[1]);
  addTo<Token>(result.periods, parts[1]);
  result.surroundWith(parts[0], parts[2]);
  return result;
}

Node buildAssignmentNode(dynamic input) {
  final parts = input[0] as List;
  if (parts.isEmpty) {
    return input[1];
  }
  return parts.reversed.fold<ValueNode>(
      input[1],
      (result, variableAndToken) =>
          AssignmentNode(variableAndToken[0], variableAndToken[1], result));
}

Node buildBlockNode(dynamic input) {
  final arguments = <VariableNode>[];
  addTo<VariableNode>(arguments, input[0]);
  return BlockNode(arguments, input[1]);
}

Node buildCascadeNode(dynamic input) {
  final parts = input[1] as List;
  if (parts.isEmpty) {
    return input[0];
  }
  final result = CascadeNode();
  result.messages.add(input[0]);
  for (final part in parts) {
    result.messages
        .add(buildMessageNodes(result.receiver, [part[1]]) as MessageNode);
    result.semicolons.add(part[0]);
  }
  return result;
}

Node buildLiteralArrayNode<T>(dynamic input) =>
    LiteralArrayNode<T>(input[1].cast<LiteralNode<T>>().toList())
      ..surroundWith(input[0], input[2]);

Node buildLiteralNumber(dynamic input) {
  final token = input as Token;
  if (token.input.contains('.')) {
    return LiteralValueNode<double>(token, double.parse(token.input));
  }
  final values = token.input.split('r');
  final value = values.length == 1
      ? int.parse(token.input)
      : int.parse(values[1], radix: int.parse(values[0]));
  return LiteralValueNode<int>(token, value);
}

Node buildMessageNodes(ValueNode receiver, dynamic messages) => messages.fold(
    receiver,
    (receiver, parts) => parts == null || parts.isEmpty
        ? receiver
        : MessageNode(receiver, parts[0].cast<Token>().toList(),
            parts[1].cast<ValueNode>().toList()));

Node buildMethodNode(dynamic input) {
  final result = MethodNode();
  addTo<Token>(result.selectorToken, input[0][0]);
  addTo<VariableNode>(result.arguments, input[0][1]);
  addTo<Token>(result.body.periods, input[1][0]);
  addTo<PragmaNode>(result.pragmas, input[1][1]);
  addTo<Token>(result.body.periods, input[1][2]);
  addTo<VariableNode>(result.body.temporaries, input[1][3]);
  addTo<Token>(result.body.periods, input[1][4]);
  addTo<PragmaNode>(result.pragmas, input[1][5]);
  addTo<Token>(result.body.periods, input[1][6]);
  addTo<IsStatement>(result.body.statements, input[1][7]);
  return result;
}

Node buildPragmaNode(dynamic input) {
  final result = PragmaNode();
  addTo<Token>(result.selectorToken, input[1][0]);
  addTo<LiteralNode>(result.arguments, input[1][1]);
  return result;
}

Node buildSequenceNode(dynamic input) {
  final result = SequenceNode();
  addTo<VariableNode>(result.temporaries, input[0]);
  addTo<Token>(result.periods, input[1]);
  addTo<IsStatement>(result.statements, input[2]);
  addTo<Token>(result.periods, input[2]);
  return result;
}

void addTo<T>(List<T> result, List parts) {
  for (final part in parts) {
    if (part is T) {
      result.add(part);
    } else if (part is List) {
      addTo<T>(result, part);
    }
  }
}
