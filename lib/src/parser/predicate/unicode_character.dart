import '../../core/context.dart';
import '../../core/result.dart';
import 'character.dart';
import 'single_character.dart';

/// Parser class for individual Unicode code-points.
///
/// This class parses Unicode code-points, similar to those that [String.runes]
/// returns. Decoding surrogate pairs (characters that cannot be expressed in a
/// single 16-bit value) comes at a significant cost, to avoid this consider
/// using [SingleCharacterParser] instead.
class UnicodeCharacterParser extends CharacterParser {
  UnicodeCharacterParser(super.predicate, super.message);

  @override
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    // Code adapted from https://github.com/dart-lang/sdk/blob/1207250b0d5687f9016cf115068addf6593dba58/sdk/lib/core/string.dart#L932-L955
    if (position < buffer.length) {
      var codeUnit = buffer.codeUnitAt(position);
      var nextPosition = position + 1;
      if (_isLeadSurrogate(codeUnit) && nextPosition < buffer.length) {
        final nextCodeUnit = buffer.codeUnitAt(nextPosition);
        if (_isTrailSurrogate(nextCodeUnit)) {
          codeUnit = _combineSurrogatePair(codeUnit, nextCodeUnit);
          nextPosition++;
        }
      }
      if (predicate.test(codeUnit)) {
        return context.success(
            buffer.substring(position, nextPosition), nextPosition);
      }
    }
    return context.failure(message);
  }

  @override
  int fastParseOn(String buffer, int position) {
    if (position < buffer.length) {
      var codeUnit = buffer.codeUnitAt(position++);
      if (_isLeadSurrogate(codeUnit) && position < buffer.length) {
        final nextCodeUnit = buffer.codeUnitAt(position);
        if (_isTrailSurrogate(nextCodeUnit)) {
          codeUnit = _combineSurrogatePair(codeUnit, nextCodeUnit);
          position++;
        }
      }
      if (predicate.test(codeUnit)) {
        return position;
      }
    }
    return -1;
  }

  @override
  UnicodeCharacterParser copy() => UnicodeCharacterParser(predicate, message);
}

// Tests if the code is a UTF-16 lead surrogate.
bool _isLeadSurrogate(int code) => (code & 0xFC00) == 0xD800;

// Tests if the code is a UTF-16 trail surrogate.
bool _isTrailSurrogate(int code) => (code & 0xFC00) == 0xDC00;

// Combines a lead and a trail surrogate value into a single code point.
int _combineSurrogatePair(int start, int end) =>
    0x10000 + ((start & 0x3FF) << 10) + (end & 0x3FF);
