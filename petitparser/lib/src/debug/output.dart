library petitparser.debug.output;

typedef void OutputHandler(Object object);

String repeat(int count, String value) {
  final result = StringBuffer();
  for (var i = 0; i < count; i++) {
    result.write(value);
  }
  return result.toString();
}
