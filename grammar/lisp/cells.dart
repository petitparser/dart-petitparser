// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

class Cell {

  const Cell();

  /** Returns the print string of the receiver. */
  String toString() {
    StringBuffer buffer = new StringBuffer();
    writeTo(buffer);
    return buffer.toString();
  }

  /** Evaluates the receving cell. */
  Cell evaluate(Environment environment) => this;

  /** Writes the print string of the receiver. */
  abstract void writeTo(StringBuffer buffer);
}

/** The interned null cell. */
final Cell NULL = const _NullCell();

/** Cell representing a null value. */
class _NullCell extends Cell {
  const _NullCell();
  void writeTo(StringBuffer buffer) {
    buffer.add('null');
  }
}

/** Cell representing a number. */
class NumberCell extends Cell {
  final num _value;
  NumberCell(this._value);
  bool operator == (NumberCell cell) {
    return cell is NumberCell && _value == cell._value;
  }
  void writeTo(StringBuffer buffer) {
    buffer.add(_value);
  }
}

/** Cell representing a string. */
class StringCell extends Cell {
  final String _value;
  StringCell(this._value);
  bool operator == (StringCell cell) {
    return cell is StringCell && _value == cell._value;
  }
  void writeTo(StringBuffer buffer) {
    buffer.add('"');
    for (int i = 0; i < _value.length; i++) {
      if (_value[i] == '"') {
        buffer.add('\"');
      } else {
        buffer.add(_value[i]);
      }
    }
    buffer.add('"');
  }
}

/** Cell reqpresenting a symbol. */
class SymbolCell extends Cell {

  /** The interned symbol cells. */
  static Map<String, Cell> _interned;

  /** Factory for new symbol cells. */
  factory SymbolCell(String name) {
    if (_interned == null) _interned = new HashMap();
    return _interned.putIfAbsent(name, () => new SymbolCell._internal(name));
  }

  final String _name;
  SymbolCell._internal(this._name);
  void writeTo(StringBuffer buffer) {
    buffer.add(_name);
  }
}

/** Cell representing a cons. */
class ConsCell extends Cell {
  Cell _head;
  Cell _tail;

  /** Constructs a cons cell. */
  ConsCell(this._head, this._tail);

  /** Accessors for the head of this cell. */
  Cell get head()          => _head;
       set head(Cell head) => _head = head;

  /** Accessors for the tail of this cell. */
  Cell get tail()          => _tail;
       set tail(Cell tail) => _tail = tail;

  void writeTo(StringBuffer buffer) {
    buffer.add('(');
    var self = this;
    while (self != NULL) {
      self.head.writeTo(buffer);
      self = self.tail;
      if (self != NULL) {
        buffer.add(' ');
      }
    }
    buffer.add(')');
  }
}