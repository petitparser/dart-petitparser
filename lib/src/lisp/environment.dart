// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of lisp;

/** Environment of bindings. */
class Environment {

  /** The owning environemnt. */
  final Environment _owner;

  /** The internal environment bindings. */
  final Map<Symbol, dynamic> _bindings;

  /** Constructor for the nested environment. */
  Environment([this._owner]) : _bindings = new Map();

  /** Constructor for a nested environment. */
  Environment create() => new Environment(this);

  /** Return the binding for [key]. */
  dynamic operator [](Symbol key) {
    if (_bindings.containsKey(key)) {
      return _bindings[key];
    } else if (_owner != null) {
      return _owner[key];
    } else {
      return _invalidBinding(key);
    }
  }

  /** Updates the binding for [key] with a [value]. */
  void operator []=(Symbol key, dynamic value) {
    if (_bindings.containsKey(key)) {
      _bindings[key] = value;
    } else if (_owner != null) {
      _owner[key] = value;
    } else {
      _invalidBinding(key);
    }
  }

  /** Defines a new binding from [key] to [value]. */
  dynamic define(Symbol key, dynamic value) {
    return _bindings[key] = value;
  }

  /** Returns the keys of the bindings. */
  Collection<Symbol> get keys => _bindings.keys;

  /** Returns the parent of the bindings. */
  Environment get owner => _owner;

  /** Called when a missing binding is accessed. */
  dynamic _invalidBinding(Symbol key) {
    throw new ArgumentError('Unknown binding for $key');
  }

}