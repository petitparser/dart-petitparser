// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

abstract class Environment {

  /** The internal environment bindings. */
  final Map<SymbolCell, Cell> _bindings;

  /** Constructor for the environment. */
  Environment() : _bindings = new Map();

  /** Constructor for a nested environment. */
  Environment create() => new NestedEnvironment(this);

  /** Returns the cell defined by a [key]. */
  Cell operator [](SymbolCell key) {
    var value = _bindings[key];
    return value != null ? value : _notFound(key);
  }

  /** Defines or redefines the cell with [value] of a [key]. */
  void operator []=(SymbolCell key, Cell value) {
    _bindings[key] = value;
  }

  /** Abstract behavior called when an non-existing binding is accessed. */
  abstract Cell _notFound(SymbolCell key);

}

class RootEnvironment extends Environment {

  /** Return [NULL] if the value does not exist. */
  _notFound(SymbolCell key) => NULL;

}

class NestedEnvironment extends Environment {

  /** The owning environemnt. */
  final Environment _owner;

  /** Constructs a nested environment. */
  NestedEnvironment(this._owner);

  /** Lookup values in the parent environment. */
  _notFound(SymbolCell key) => _owner[key];

}