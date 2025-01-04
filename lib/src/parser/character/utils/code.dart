/// Converts an string to a character code.
int toCharCode(String value, {required bool unicode}) {
  final codes = unicode ? value.runes : value.codeUnits;
  assert(codes.length == 1, '"$value" is not a valid character');
  return codes.single;
}

/// Converts a character to a readable string.
String toReadableString(String value, {required bool unicode}) {
  final codePoints = unicode ? value.runes : value.codeUnits;
  return codePoints.map(_toFormattedChar).join();
}

String _toFormattedChar(int code) {
  if (_escapes[code] case final value?) return value;
  if (code < 0x20) return '\\x${code.toRadixString(16).padLeft(2, '0')}';
  return String.fromCharCode(code);
}

const _escapes = {
  0x0a: r'\n', // new line
  0x0d: r'\r', // carriage return
  0x0c: r'\f', // form feed
  0x08: r'\b', // backspace
  0x09: r'\t', // horizontal tab
  0x0b: r'\v', // vertical tab
};
