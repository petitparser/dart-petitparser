/// Internal helper to cleanup to default output of [Object.toString].
String sanitizeToString(String value) {
  final start = value.indexOf("'");
  if (0 <= start) {
    final end = value.indexOf("'", start + 1);
    if (start < end) {
      return value.substring(start + 1, end);
    }
  }
  return value;
}
