part of lisp;

/**
 * Environment of bindings.
 */
class Environment {

  /** The owning environemnt. */
  final Environment _owner;

  /** The internal environment bindings. */
  final Map<Name, dynamic> _bindings;

  /** Constructor for the nested environment. */
  Environment([this._owner]): _bindings = new Map();

  /** Constructor for a nested environment. */
  Environment create() => new Environment(this);

  /** Return the binding for [key]. */
  operator [](Name key) {
    if (_bindings.containsKey(key)) {
      return _bindings[key];
    } else if (_owner != null) {
      return _owner[key];
    } else {
      return _invalidBinding(key);
    }
  }

  /** Updates the binding for [key] with a [value]. */
  void operator []=(Name key, value) {
    if (_bindings.containsKey(key)) {
      _bindings[key] = value;
    } else if (_owner != null) {
      _owner[key] = value;
    } else {
      _invalidBinding(key);
    }
  }

  /** Defines a new binding from [key] to [value]. */
  define(Name key, value) {
    return _bindings[key] = value;
  }

  /** Returns the keys of the bindings. */
  Iterable<Name> get keys => _bindings.keys;

  /** Returns the parent of the bindings. */
  Environment get owner => _owner;

  /** Called when a missing binding is accessed. */
  _invalidBinding(Name key) {
    throw new ArgumentError('Unknown binding for $key');
  }

}
