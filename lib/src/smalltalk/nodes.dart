// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of smalltalk;

abstract class ProgramNode {

}

class MethodNode extends ProgramNode {

  List<Token> selectorParts;
  List<VariableNode> arguments;
  List<PragmaNode> pragmas;
  SequenceNode body;

}

class PragmaNode extends ProgramNode {

  Token left;
  List<Token> selectorParts;
  List<LiteralNode> arguments;
  Token right;

}

class ReturnNode extends ProgramNode {

  Token caret;
  ValueNode value;

}

class SequenceNode extends ProgramNode {

  Token leftBar;
  List<VariableNode> temporaries;
  Token rightBar;
  List<ValueNode> statements;
  List<Token> periods;

}

abstract class ValueNode extends ProgramNode {

  List<Token> open;
  List<Token> close;

}

class ArrayNode extends ValueNode {

  Token left;
  List<ValueNode> statements;
  List<Token> periods;
  Token right;

}

class AssignmentNode extends ValueNode {

  VariableNode variable;
  Token assignment;
  ValueNode value;

}

class BlockNode extends ValueNode {

  Token left;
  List<Token> colons;
  List<VariableNode> arguments;
  Token bar;
  ProgramNode body;
  Token right;

}

class CascadeNode extends ValueNode {

  List<MessageNode> messages;
  List<Token> colons;

}

abstract class LiteralNode extends ValueNode {

  final dynamic value;

  LiteralNode(this.value);

}

class LiteralArrayNode extends LiteralNode {

  final Token left;
  final Token right;

  LiteralArrayNode(this.left, value, this.right) : super(value);

}

class LiteralValueNode extends LiteralNode {

  final Token token;

  LiteralValueNode(this.token, value) : super(value);

}

class MessageNode extends ValueNode {

  ValueNode receiver;
  List<Token> selectorParts;
  List<ValueNode> arguments;

}

class VariableNode extends ValueNode {

  final Token variable;

  VariableNode(this.variable);

}