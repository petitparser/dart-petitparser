/// Converts an object to a character code.
int toCharCode(String char) {
  assert(char.length == 1, '"$char" is not a valid character');
  return char.codeUnitAt(0);
}

/// Converts a character to a readable string.
String toReadableString(String element) =>
    element.codeUnits.map(_toFormattedChar).join();

String _toFormattedChar(int code) {
  switch (code) {
    case 0x08:
      return r'\b'; // backspace
    case 0x09:
      return r'\t'; // horizontal tab
    case 0x0A:
      return r'\n'; // new line
    case 0x0B:
      return r'\v'; // vertical tab
    case 0x0C:
      return r'\f'; // form feed
    case 0x0D:
      return r'\r'; // carriage return
    case 0x22:
      return r'\"'; // double quote
    case 0x27:
      return r"\'"; // single quote
    case 0x5C:
      return r'\\'; // backslash
  }
  if (code < 0x20) {
    return '\\x${code.toRadixString(16).padLeft(2, '0')}';
  }
  return String.fromCharCode(code);
}
