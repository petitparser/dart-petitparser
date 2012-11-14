// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of lisplib;

/** Abstract enviornment of bindings. */
abstract class Environment {

  /** The internal environment bindings. */
  final Map<Symbol, dynamic> _bindings;

  /** Constructor for the environment. */
  Environment() : _bindings = new Map();

  /** Constructor for a nested environment. */
  Environment create() => new NestedEnvironment(this);

  /** Return the binding for [key]. */
  dynamic operator [](Symbol key) {
    if (_bindings.containsKey(key)) {
      return _bindings[key];
    } else if (parent != null) {
      return parent[key];
    } else {
      return _invalidBinding(key);
    }
  }

  /** Updates the binding for [key] with a [value]. */
  dynamic operator []=(Symbol key, dynamic value) {
    if (_bindings.containsKey(key)) {
      return _bindings[key] = value;
    } else if (parent != null) {
      return parent[key] = value;
    } else {
      return _invalidBinding(key);
    }
  }

  /** Defines a new binding from [key] to [value]. */
  dynamic define(Symbol key, dynamic value) {
    return _bindings[key] = value;
  }

  /** Returns the keys of the bindings. */
  Collection<Symbol> get keys => _bindings.keys;

  /** Returns the parent of the bindings. */
  Environment get parent => null;

  /** Called when a missing binding is accessed. */
  dynamic _invalidBinding(Symbol key) {
    throw new IllegalArgumentException('Unknown binding for $key');
  }

}

/** The root environment of the execution. */
class RootEnvironment extends Environment {

  /** Register the minimal functions needed for bootstrap. */
  RootEnvironment() {

    /** Defines a value in the root environment. */
    define(new Symbol('define'), (Environment env, dynamic args) {
      if (args.head is Symbol) {
        return env.define(args.head, args.tail.head);
      } else if (args.head.head is Symbol) {
        return env.define(args.head.head, Natives.find('lambda')(env,
            new Cons(args.head.tail, args.tail)));
      } else {
        throw new ArgumentError('Invalid define: $args');
      }
    });

    /** Lookup a native function. */
    define(new Symbol('native'), (Environment env, dynamic args) {
      return Natives.find(args.head);
    });

    /** Defines all native functions. */
    define(new Symbol('native-import-all'), (Environment env, dynamic args) {
      return Natives.importNatives(this);
    });

  }

}

/** The default execution environment with a parent. */
class NestedEnvironment extends Environment {

  /** The owning environemnt. */
  final Environment _owner;

  /** Constructs a nested environment. */
  NestedEnvironment(this._owner);

  /** Returns the parent of the bindings. */
  Environment get parent => _owner;

}