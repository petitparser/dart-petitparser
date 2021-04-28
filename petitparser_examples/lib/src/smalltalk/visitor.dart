import 'ast.dart';

abstract class Visitor {
  void visit(Node node) => node.accept(this);

  void visitMethodNode(MethodNode node) {
    node.arguments.forEach(visit);
    node.pragmas.forEach(visit);
    visit(node.body);
  }

  void visitPragmaNode(PragmaNode node) {
    node.arguments.forEach(visit);
  }

  void visitReturnNode(ReturnNode node) {
    visit(node.value);
  }

  void visitSequenceNode(SequenceNode node) {
    node.temporaries.forEach(visit);
    node.statements.forEach(visit);
  }

  void visitArrayNode(ArrayNode node) {
    node.statements.forEach(visit);
  }

  void visitAssignmentNode(AssignmentNode node) {
    visit(node.variable);
    visit(node.value);
  }

  void visitBlockNode(BlockNode node) {
    node.arguments.forEach(visit);
    visit(node.body);
  }

  void visitCascadeNode(CascadeNode node) {
    node.messages.forEach(visit);
  }

  void visitLiteralArrayNode(LiteralArrayNode node) {
    node.values.forEach(visit);
  }

  void visitLiteralValueNode(LiteralValueNode node) {}

  void visitMessageNode(MessageNode node) {
    visit(node.receiver);
    node.arguments.forEach(visit);
  }

  void visitVariableNode(VariableNode node) {}
}
