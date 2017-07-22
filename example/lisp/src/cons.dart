library petitparser.example.lisp.cons;

/// The basic data structure of LISP.
class Cons {
  /// The first object.
  Object car;

  /// The head of the cons.
  Object get head => this.car;

  /// The second object.
  Object cdr;

  /// The tail of the cons, if applicable.
  Cons get tail {
    if (cdr is Cons) {
      return cdr as Cons;
    } else if (cdr == null) {
      return null;
    } else {
      throw new StateError('${toString()} does not have a tail.');
    }
  }

  /// Constructs a cons.
  Cons(this.car, [this.cdr]);

  @override
  bool operator ==(other) {
    return other is Cons && car == other.car && cdr == other.cdr;
  }

  @override
  int get hashCode => 31 * car.hashCode + cdr.hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();
    buffer.write('(');
    var current = this;
    while (current is Cons) {
      buffer.write(current.car);
      current = current.cdr;
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
