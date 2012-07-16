// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/** Cell reqpresenting a symbol. */
class Symbol implements Hashable {

  /** The interned symbol cells. */
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
  String get name() => _name;

  /** Internal constructor for symbol. */
  Symbol._internal(this._name, this._hash);

  /** Returns the string representation of the symbol. */
  String toString() => _name;

  /** Returns the hash code of the receiver. */
  int hashCode() => _hash;

}

/** Cell representing a cons. */
class Cons {

  /** The head of the cons. */
  Dynamic _head;

  /** The tail of the cons. */
  Dynamic _tail;

  /** Constructs a cons. */
  Cons(this._head, this._tail);

  /** Accessors for the head of this cons. */
  Dynamic get head()             => _head;
          set head(Dynamic head) => _head = head;

  /** Accessors for the tail of this cons. */
  Dynamic get tail()             => _tail;
          set tail(Dynamic tail) => _tail = tail;

  /** Returns the string representation of the cell. */
  String toString() {
    StringBuffer buffer = new StringBuffer();
    buffer.add('(');
    var current = this;
    while (current != null) {
      buffer.add(current.head.toString());
      if ((current = current.tail) != null) {
        buffer.add(' ');
      }
    }
    buffer.add(')');
    return buffer.toString();
  }

}