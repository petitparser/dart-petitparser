/// Generates a human readable list of strings.
String formatIterable<T>(Iterable<T> objects, {int? offset}) {
  final buffer = StringBuffer();
  for (var i = 0, it = objects.iterator; it.moveNext(); i++) {
    if (0 < i) buffer.write('\n');
    if (offset != null) {
      buffer.write(' ${offset + i}: ');
    } else {
      buffer.write(' - ');
    }
    buffer.write(it.current);
  }
  return buffer.toString();
}
