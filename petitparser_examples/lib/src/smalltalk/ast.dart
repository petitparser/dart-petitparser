import 'package:petitparser/petitparser.dart';

abstract class Node {}

class MethodNode extends Node {
  final String selector;
  final List<VariableNode> arguments;
  final SequenceNode body;

  MethodNode(this.selector, this.arguments, this.body);
}

class PragmaNode extends Node {
  final String selector;
  final List<LiteralNode> arguments;

  PragmaNode(this.selector, this.arguments);
}

class ReturnNode extends Node {
  final ValueNode value;

  ReturnNode(this.value);
}

class SequenceNode extends Node {
  final List<VariableNode> arguments;
  final List<ValueNode> statements;

  SequenceNode(this.arguments, this.statements);
}

abstract class ValueNode extends Node {
  final List<Token> openParens = [];
  final List<Token> closeParens = [];

  void addParens(Token open, Token close) {
    openParens.add(open);
    closeParens.add(close);
  }
}

class ArrayNode extends ValueNode {
  final Token openToken;
  final List<ValueNode> statements;
  final Token closeToken;

  ArrayNode(this.openToken, this.statements, this.closeToken);
}

class AssignmentNode extends ValueNode {
  final VariableNode variable;
  final ValueNode value;

  AssignmentNode(this.variable, this.value);
}

class BlockNode extends ValueNode {
  final List<VariableNode> arguments;
  final SequenceNode body;

  BlockNode(this.arguments, this.body);
}

class CascadeNode extends ValueNode {
  final List<MessageNode> messages;

  CascadeNode(this.messages);
}

abstract class LiteralNode<T> extends ValueNode {
  final T value;

  LiteralNode(this.value);
}

class LiteralValueNode<T> extends LiteralNode<T> {
  final Token token;

  LiteralValueNode(this.token, T value) : super(value);
}

class LiteralArrayNode<T> extends LiteralNode<List<T>> {
  final Token openToken;
  final List<LiteralNode<T>> values;
  final Token closeToken;

  LiteralArrayNode(this.openToken, this.values, this.closeToken)
      : super(values.map((value) => value.value).toList());
}

class MessageNode extends ValueNode {
  final ValueNode receiver;
  final List<Token> selectorToken;
  final List<ValueNode> arguments;

  MessageNode(this.receiver, this.selectorToken, this.arguments);

  String get selector => selectorToken.map((token) => token.input).join('');
}

class VariableNode extends ValueNode {
  final Token token;
  final String name;

  VariableNode(this.token) : name = token.input;
}
