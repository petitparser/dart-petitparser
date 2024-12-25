import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/result.dart';
import 'character.dart';
import 'unicode_character.dart';

/// Parser class an individual UTF-16 code unit satisfying a [predicate].
///
/// This class parses characters equivalent to those that [String.codeUnitAt]
/// or [String.codeUnits] returns. To decode surrogate pairs (characters that
/// cannot be expressed as a single 16-bit value), [UnicodeCharacterParser]
/// should be used instead.
class SingleCharacterParser extends CharacterParser {
  SingleCharacterParser(super.predicate, super.message) : super.internal();

  @override
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    if (position < buffer.length &&
        predicate.test(buffer.codeUnitAt(position))) {
      return context.success(buffer[position], position + 1);
    }
    return context.failure(message);
  }

  @override
  int fastParseOn(String buffer, int position) =>
      position < buffer.length && predicate.test(buffer.codeUnitAt(position))
          ? position + 1
          : -1;

  @override
  SingleCharacterParser copy() => SingleCharacterParser(predicate, message);
}
