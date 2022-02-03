// Helper class to associate operators and actions.
class ExpressionResult {
  ExpressionResult(this.operator, this.action);

  final dynamic operator;
  final Function action;
}
