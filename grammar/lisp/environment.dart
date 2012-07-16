// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

abstract class Environment {

  /** The internal environment bindings. */
  final Map<Symbol, Dynamic> _bindings;

  /** Constructor for the environment. */
  Environment() : _bindings = new Map();

  /** Constructor for a nested environment. */
  Environment create() => new NestedEnvironment(this);

  /** Returns the cell defined by a [key]. */
  Dynamic operator [](Symbol key) {
    var value = _bindings[key];
    return value != null ? value : _notFound(key);
  }

  /** Defines or redefines the cell with [value] of a [key]. */
  void operator []=(Symbol key, Dynamic value) {
    _bindings[key] = value;
  }

  /** Abstract behavior called when an non-existing binding is accessed. */
  abstract Dynamic _notFound(Symbol key);

}

class RootEnvironment extends Environment {

  /** Return null if the value does not exist. */
  _notFound(Symbol key) => null;

  /** Register the minimal functions needed for bootstrap. */
  RootEnvironment() {

    /** Defines a value in the root environment. */
    _define('define', (Environment env, Dynamic args) {
      return this[args.head] = eval(env, args.tail.head);
    });

    /** Looks up a native function. */
    _define('native', (Environment env, Dynamic args) {
      return Natives.find(args.head);
    });

  }

  /** Private function to define primitives. */
  _define(String key, Dynamic cell) {
    this[new Symbol(key)] = cell;
  }

}

class NestedEnvironment extends Environment {

  /** The owning environemnt. */
  final Environment _owner;

  /** Constructs a nested environment. */
  NestedEnvironment(this._owner);

  /** Lookup values in the parent environment. */
  _notFound(Symbol key) => _owner[key];

}