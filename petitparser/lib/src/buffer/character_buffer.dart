import 'package:characters/characters.dart';

import '../../buffer.dart';

class CharactersBuffer implements Buffer {
  final List<String> characters;

  CharactersBuffer(Characters characters)
      : characters = characters.toList(growable: false);

  @override
  int get length => characters.length;

  @override
  String charAt(int position) => characters[position];

  @override
  int codeUnitAt(int position) {
    final chars = characters[position];
    final charsLength = chars.length;
    if (charsLength == 1) {
      return chars.codeUnitAt(0);
    } else {
      var value = 0;
      for (var i = 0; i < charsLength; i++) {
        value = (value << 16) | chars.codeUnitAt(i);
      }
      return value;
    }
  }

  @override
  String substring(int start, int end) =>
      characters.getRange(start, end).join();
}
