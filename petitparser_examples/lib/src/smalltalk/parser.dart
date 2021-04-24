import 'package:petitparser/petitparser.dart';

import 'ast.dart';
import 'grammar.dart';

// ignore_for_file: unnecessary_overrides

/// Smalltalk parser definition.
class SmalltalkParserDefinition extends SmalltalkGrammarDefinition {
  Parser token(Object source, [String? message]) =>
      super.token(source, message).token();

  Parser array() =>
      super.array().map((input) => ArrayNode(input[0], input[1], input[2]));

  Parser arrayLiteral() => super.arrayLiteral().map((input) =>
      LiteralArrayNode(input[0], input[1].cast<LiteralNode>(), input[2]));

  Parser arrayLiteralArray() => super.arrayLiteralArray().map((input) =>
      LiteralArrayNode(input[0], input[1].cast<LiteralNode>(), input[2]));

  Parser binaryExpression() =>
      super.binaryExpression().map((input) => input[1].fold(input[0],
          (selector, receiver) => MessageNode(receiver, selector, [])));

  Parser block() => super.block();

  Parser blockArgument() => super.blockArgument();

  Parser blockBody() => super.blockBody();

  Parser byteLiteral() =>
      super.byteLiteral().map((input) => LiteralArrayNode<num>(
          input[0], input[1].cast<LiteralNode<num>>(), input[2]));

  Parser byteLiteralArray() =>
      super.byteLiteralArray().map((input) => LiteralArrayNode<num>(
          input[0], input[1].cast<LiteralNode<num>>(), input[2]));

  Parser characterLiteral() => super.characterLiteral().map(
      (input) => LiteralValueNode<String>(input, input.value.substring(1)));

  Parser expression() => super.expression();

  Parser falseLiteral() =>
      super.falseLiteral().map((input) => LiteralValueNode<bool>(input, false));

  Parser keywordExpression() =>
      super.keywordExpression().map((input) => input[1].fold(input[0],
          (selector, receiver) => MessageNode(receiver, selector, [])));

  Parser method() => super.method();

  Parser methodDeclaration() => super.methodDeclaration();

  Parser methodSequence() => super.methodSequence();

  Parser nilLiteral() =>
      super.nilLiteral().map((input) => LiteralValueNode<void>(input, null));

  Parser numberLiteral() => super
      .numberLiteral()
      .map((input) => LiteralValueNode<num>(input, buildNumber(input.value)));

  Parser parens() =>
      super.parens().map((input) => input[1].addParens(input[0], input[1]));

  Parser pragma() => super.pragma();

  Parser answer() => super.answer();

  Parser sequence() => super.sequence();

  Parser stringLiteral() => super.stringLiteral().map(
      (input) => LiteralValueNode<String>(input, buildString(input.value)));

  Parser symbolLiteral() =>
      super.symbolLiteral().map((input) => LiteralValueNode<String>(
          Token.join<dynamic>([...input[0], input[1]]),
          buildString(input[1].value)));

  Parser symbolLiteralArray() => super.symbolLiteralArray().map(
      (input) => LiteralValueNode<String>(input, buildString(input.value)));

  Parser unaryExpression() =>
      super.unaryExpression().map((input) => input[1].fold(input[0],
          (selector, receiver) => MessageNode(receiver, selector, [])));

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
