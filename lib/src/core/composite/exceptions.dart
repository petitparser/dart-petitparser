library petitparser.core.composite.exceptions;

/// Error raised when somebody tries to modify a CompositeParser outside
/// the CompositeParser.initialize method.
@deprecated
class CompletedParserError extends Error {
  CompletedParserError();

  @override
  String toString() => 'Completed parser';
}

/// Error raised when an undefined production is accessed.
@deprecated
class UndefinedProductionError extends Error {
  final String name;

  UndefinedProductionError(this.name);

  @override
  String toString() => 'Undefined production: $name';
}

/// Error raised when a production is accidentally redefined.
@deprecated
class RedefinedProductionError extends Error {
  final String name;

  RedefinedProductionError(this.name);

  @override
  String toString() => 'Redefined production: $name';
}
