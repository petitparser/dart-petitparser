// Helper class to associate operators and actions.
class ExpressionResult {
  final dynamic operator;
  final Function callback;

  ExpressionResult(this.operator, this.callback);
}
