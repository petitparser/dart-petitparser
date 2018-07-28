library petitparser.example.lisp.cons;

/// The basic data structure of LISP.
class Cons {
  /// The first object.
  Object car;

  /// The second object.
  Object cdr;

  /// Constructs a cons.
  Cons(this.car, [this.cdr]);

  /// The head of the cons.
  Object get head => car;

  /// The tail of the cons, if applicable.
  Cons get tail {
    if (cdr is Cons) {
      return cdr;
    } else if (cdr == null) {
      return null;
    } else {
      throw StateError('${toString()} does not have a tail.');
    }
  }

  @override
  bool operator ==(other) {
    return other is Cons && car == other.car && cdr == other.cdr;
  }

  @override
  int get hashCode => 31 * car.hashCode + cdr.hashCode;

  @override
  String toString() {
    var buffer = StringBuffer();
    buffer.write('(');
    var current = this;
    while (true) {
      buffer.write(current.car);
      if (current.cdr is Cons) {
        current = current.cdr;
        buffer.write(' ');
      } else if (current.cdr == null) {
        buffer.write(')');
        return buffer.toString();
      } else {
        buffer.write(' . ');
        buffer.write(current.cdr);
        buffer.write(')');
        return buffer.toString();
      }
    }
  }
}
