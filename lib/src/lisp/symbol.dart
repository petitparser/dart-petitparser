// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of lisp;

/**
 * An unique symbol.
 */
class Symbol {

  /** The name of the symbol. */
  final String _name;

  /** The interned symbols. */
  static Map<String, Symbol> _interned;

  /** Factory for new symbol cells. */
  factory Symbol(String name) {
    if (_interned == null) _interned = new HashMap();
    return _interned.putIfAbsent(name, () => new Symbol._internal(name));
  }

  /** Internal constructor for symbol. */
  Symbol._internal(this._name);

  /** Returns the string representation of the symbol. */
  String toString() => _name;

}
