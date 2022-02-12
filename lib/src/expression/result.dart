class ExpressionResultPrefix<V, O> {
  ExpressionResultPrefix(this.operator, this.callback);

  final O operator;
  final V Function(O operator, V value) callback;

  V call(V value) => callback(operator, value);
}

class ExpressionResultPostfix<V, O> {
  ExpressionResultPostfix(this.operator, this.callback);

  final O operator;
  final V Function(V value, O operator) callback;

  V call(V value) => callback(value, operator);
}

class ExpressionResultInfix<V, O> {
  ExpressionResultInfix(this.operator, this.callback);

  final O operator;
  final V Function(V left, O operator, V right) callback;

  V call(V left, V right) => callback(left, operator, right);
}
