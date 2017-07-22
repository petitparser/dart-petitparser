library petitparser.core.expression.result;

// Helper class to associate operators and actions.
class ExpressionResult {
  final operator;
  final Function action;
  ExpressionResult(this.operator, this.action);
}
