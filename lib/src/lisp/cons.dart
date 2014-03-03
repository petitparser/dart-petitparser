part of lisp;

/**
 * The basic data structure of LISP.
 */
class Cons {

  /** The head of the cons. */
  dynamic head;

  /** The tail of the cons. */
  dynamic tail;

  /** Constructs a cons. */
  Cons(this.head, this.tail);

  @override
  bool operator ==(other) {
    return other is Cons && head == other.head && tail == other.tail;
  }

  @override
  int get hashCode => 31 * head.hashCode + tail.hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();
    buffer.write('(');
    var current = this;
    while (current is Cons) {
      buffer.write(current.head.toString());
      current = current.tail;
      if (current != null) {
        buffer.write(' ');
      }
    }
    if (current != null) {
      buffer.write('. ');
      buffer.write(current);
    }
    buffer.write(')');
    return buffer.toString();
  }

}
