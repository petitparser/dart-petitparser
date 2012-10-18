// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of lisplib;

/**
 * An unique symbol.
 */
class Symbol implements Hashable {

  /** The interned symbols. */
  static Map<String, Symbol> _interned;

  /** Factory for new symbol cells. */
  factory Symbol(String name) {
    if (_interned == null) _interned = new HashMap();
    return _interned.putIfAbsent(name, () => new Symbol._internal(name, name.hashCode()));
  }

  /** The name of the symbol. */
  final String _name;

  /** The hash code of the symbol. */
  final int _hash;

  /** Returns the name of the symbol. */
  String get name => _name;

  /** Internal constructor for symbol. */
  Symbol._internal(this._name, this._hash);

  /** Returns the string representation of the symbol. */
  String toString() => _name;

  /** Returns the hash code of the receiver. */
  int hashCode() => _hash;

}