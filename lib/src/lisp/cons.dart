// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of lisplib;

/**
 * The basic data structure of LISP.
 */
class Cons {

  /** The head of the cons. */
  dynamic _head;

  /** The tail of the cons. */
  dynamic _tail;

  /** Constructs a cons. */
  Cons(this._head, this._tail);

  /** Accessors for the head of this cons. */
  dynamic get head => _head;
  set head(dynamic head) => _head = head;

  /** Accessors for the tail of this cons. */
  dynamic get tail => _tail;
  set tail(dynamic tail) => _tail = tail;

  /** Compare the cells. */
  bool operator ==(Cons cons) {
    return cons is Cons && head == cons.head && tail == cons.tail;
  }

  /** Returns the string representation of the cons. */
  String toString() {
    var buffer = new StringBuffer();
    buffer.add('(');
    var current = this;
    while (current is Cons) {
      buffer.add(current.head.toString());
      current = current.tail;
      if (current != null) {
        buffer.add(' ');
      }
    }
    if (current != null) {
      buffer.add('. ');
      buffer.add(current);
    }
    buffer.add(')');
    return buffer.toString();
  }

}