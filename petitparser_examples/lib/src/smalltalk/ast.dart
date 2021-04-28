import 'package:petitparser/petitparser.dart';

import 'visitor.dart';

abstract class Node {
  void accept(Visitor visitor);
}

abstract class HasStatements implements Node {
  List<IsStatement> get statements;

  List<Token> get periods;
}

abstract class IsStatement implements Node {}

mixin HasSelector {
  List<Token> get selectorToken;

  String get selector => selectorToken.map((token) => token.input).join('');
}

class MethodNode extends Node with HasSelector {
  final List<Token> selectorToken = [];
  final List<VariableNode> arguments = [];
  final List<PragmaNode> pragmas = [];
  final SequenceNode body = SequenceNode();

  MethodNode();

  void accept(Visitor visitor) => visitor.visitMethodNode(this);
}

class PragmaNode extends Node with HasSelector {
  final List<Token> selectorToken = [];
  final List<LiteralNode> arguments = [];

  PragmaNode();

  void accept(Visitor visitor) => visitor.visitPragmaNode(this);
}

class SequenceNode extends Node implements HasStatements {
  final List<VariableNode> temporaries = [];
  final List<IsStatement> statements = [];
  final List<Token> periods = [];

  SequenceNode();

  void accept(Visitor visitor) => visitor.visitSequenceNode(this);
}

class ReturnNode extends Node implements IsStatement {
  final Token caret;
  final ValueNode value;

  ReturnNode(this.caret, this.value);

  void accept(Visitor visitor) => visitor.visitReturnNode(this);
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

  void accept(Visitor visitor) => visitor.visitArrayNode(this);
}

class AssignmentNode extends ValueNode {
  final VariableNode variable;
  final Token assignment;
  final ValueNode value;

  AssignmentNode(this.variable, this.assignment, this.value);

  void accept(Visitor visitor) => visitor.visitAssignmentNode(this);
}

class BlockNode extends ValueNode {
  final List<VariableNode> arguments;
  final SequenceNode body;

  BlockNode(this.arguments, this.body);

  void accept(Visitor visitor) => visitor.visitBlockNode(this);
}

class CascadeNode extends ValueNode {
  final List<MessageNode> messages = [];
  final List<Token> semicolons = [];

  CascadeNode();

  ValueNode get receiver => messages[0].receiver;

  void accept(Visitor visitor) => visitor.visitCascadeNode(this);
}

abstract class LiteralNode<T> extends ValueNode {
  final T value;

  LiteralNode(this.value);
}

class LiteralArrayNode<T> extends LiteralNode<List<T>> {
  final List<LiteralNode<T>> values;

  LiteralArrayNode(this.values)
      : super(values.map((value) => value.value).toList());

  void accept(Visitor visitor) => visitor.visitLiteralArrayNode(this);
}

class LiteralValueNode<T> extends LiteralNode<T> {
  final Token token;

  LiteralValueNode(this.token, T value) : super(value);

  void accept(Visitor visitor) => visitor.visitLiteralValueNode(this);
}

class MessageNode extends ValueNode with HasSelector {
  final ValueNode receiver;
  final List<Token> selectorToken;
  final List<ValueNode> arguments;

  MessageNode(this.receiver, this.selectorToken, this.arguments);

  void accept(Visitor visitor) => visitor.visitMessageNode(this);
}

class VariableNode extends ValueNode {
  final Token token;

  VariableNode(this.token);

  String get name => token.input;

  void accept(Visitor visitor) => visitor.visitVariableNode(this);
}
