/// This package contains the parse input buffers.
import 'package:characters/characters.dart';

import 'src/buffer/character_buffer.dart';
import 'src/buffer/string_buffer.dart';

abstract class Buffer {
  /// Create a buffer from the most appropriate internal implementation.
  factory Buffer(/*Buffer|String|Characters*/ dynamic input) {
    if (input is Buffer) {
      return input;
    } else if (input is String) {
      return Buffer.fromString(input);
    } else if (input is Characters) {
      return Buffer.fromCharacters(input);
    } else {
      throw ArgumentError.value(input, 'input', 'Invalid input buffer');
    }
  }

  /// Create a buffer from an input [String] (UTF-16).
  factory Buffer.fromString(String input) => StringBuffer(input);

  /// Create a buffer from input [Characters] (Unicode Grapheme).
  factory Buffer.fromCharacters(Characters input) => CharactersBuffer(input);

  /// Return the length of the buffer.
  int get length;

  /// Return the character at [position].
  String charAt(int position);

  /// Return the character code at [position].
  int codeUnitAt(int position);

  /// Return the substring between [start] and [stop] (exclusive).
  String substring(int start, int stop);
}
