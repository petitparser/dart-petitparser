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

  /** Returns the value defined by a [key]. */
  dynamic operator [](Symbol key) {
    return _bindings.containsKey(key)
        ? _bindings[key]
        : _notFound(key);
  }

  /** Defines or redefines the cell with [value] of a [key]. */
  void operator []=(Symbol key, dynamic value) {
    _bindings[key] = value;
  }

  /** Returns the keys of the bindings. */
  Collection<Symbol> get keys => _bindings.keys;

  /** Returns the parent of the bindings. */
  Environment get parent => null;

  /** Called when a missing binding is accessed. */
  dynamic _notFound(Symbol key);

}

/** The root environment of the execution. */
class RootEnvironment extends Environment {

  /** Return null if the value does not exist. */
  _notFound(Symbol key) => null;

  /** Register the minimal functions needed for bootstrap. */
  RootEnvironment() {

    /** Defines a value in the root environment. */
    _define('define', (Environment env, dynamic args) {
      if (args.head is Cons) {
        var definition = new Cons(args.head.tail, args.tail);
        return this[args.head.head] = Natives.find('lambda')(env, definition);
      } else {
        return this[args.head] = eval(env, args.tail.head);
      }
    });

    /** Lookup a native function. */
    _define('native', (Environment env, dynamic args) {
      return Natives.find(args.head);
    });

    /** Defines all native functions. */
    _define('native-import-all', (Environment env, dynamic args) {
      return Natives.importNatives(this);
    });

  }

  /** Private function to define primitives. */
  _define(String key, dynamic cell) {
    this[new Symbol(key)] = cell;
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

  /** Lookup values in the parent environment. */
  _notFound(Symbol key) => _owner[key];

}