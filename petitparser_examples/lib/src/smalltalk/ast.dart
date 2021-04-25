import 'package:petitparser/petitparser.dart';

abstract class Node {}

abstract class HasStatements {
  List<IsStatement> get statements;
  List<Token> get periods;
}

abstract class IsStatement {}

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

class SequenceNode extends Node implements HasStatements {
  final List<VariableNode> temporaries = [];
  final List<IsStatement> statements = [];
  final List<Token> periods = [];

  SequenceNode();
}

class ReturnNode extends Node implements IsStatement {
  final Token caret;
  final ValueNode value;

  ReturnNode(this.caret, this.value);
}

abstract class ValueNode extends Node implements IsStatement {
  final List<Token> beforeToken = [];
  final List<Token> afterToken = [];

  void surroundWith(Token before, Token after) {
    beforeToken.add(before);
    afterToken.add(after);
  }
}

class ArrayNode extends ValueNode implements HasStatements {
  final List<ValueNode> statements = [];
  final List<Token> periods = [];

  ArrayNode();
}

class AssignmentNode extends ValueNode {
  final VariableNode variable;
  final Token assignment;
  final ValueNode value;

  AssignmentNode(this.variable, this.assignment, this.value);
}

class BlockNode extends ValueNode {
  final List<VariableNode> arguments;
  final SequenceNode body;

  BlockNode(this.arguments, this.body);
}

class CascadeNode extends ValueNode {
  final List<MessageNode> messages = [];
  final List<Token> semicolons = [];

  CascadeNode();

  ValueNode get receiver => messages[0].receiver;
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
  final List<LiteralNode<T>> values;

  LiteralArrayNode(this.values)
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

  VariableNode(this.token);

  String get name => token.input;
}
