library petitparser.core.characters.code;

/// Converts an object to a character code.
int toCharCode(Object element) {
  if (element is num) {
    return element.round();
  }
  var value = element.toString();
  if (value.length != 1) {
    throw new ArgumentError('"$value" is not a character');
  }
  return value.codeUnitAt(0);
}

/// Converts a character to a readable string.
String toReadableString(Object element) {
  if (element is String && element.length > 1) {
    StringBuffer buffer = new StringBuffer();
    for (var i = 0; i < element.length; i++) {
      buffer.write(toReadableString(element[i]));
    }
    return buffer.toString();
  }
  var code = toCharCode(element);
  switch (code) {
    case 0x08:
      return '\\b'; // backspace
    case 0x09:
      return '\\t'; // horizontal tab
    case 0x0A:
      return '\\n'; // new line
    case 0x0B:
      return '\\v'; // vertical tab
    case 0x0C:
      return '\\f'; // form feed
    case 0x0D:
      return '\\r'; // carriage return
    case 0x22:
      return '\\"'; // double quote
    case 0x27:
      return "\\'"; // single quote
    case 0x5C:
      return '\\\\'; // backslash
  }
  if (code < 0x20) {
    return '\\x${code.toRadixString(16).padLeft(2, '0')}';
  }
  return new String.fromCharCode(code);
}
