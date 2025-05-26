import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/result.dart';
import '../../shared/pragma.dart';
import '../character/predicate.dart';
import '../character/predicate/constant.dart';
import 'character.dart';

/// Parser class for an individual Unicode code-point (including possible
/// surrogate pairs) satisfying a specified [CharacterPredicate].
class UnicodeCharacterParser extends CharacterParser {
  factory UnicodeCharacterParser(
    CharacterPredicate predicate,
    String message,
  ) => ConstantCharPredicate.any.isEqualTo(predicate)
      ? AnyUnicodeCharacterParser.internal(predicate, message)
      : UnicodeCharacterParser.internal(predicate, message);

  @internal
  UnicodeCharacterParser.internal(super.predicate, super.message)
    : super.internal();

  @override
  @noBoundsChecks
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
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
          buffer.substring(position, nextPosition),
          nextPosition,
        );
      }
    }
    return context.failure(message);
  }

  @override
  @noBoundsChecks
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

/// Optimized version of [UnicodeCharacterParser] that parses any Unicode
/// character (including possible surrogate pairs).
class AnyUnicodeCharacterParser extends UnicodeCharacterParser {
  AnyUnicodeCharacterParser.internal(super.predicate, super.message)
    : assert(ConstantCharPredicate.any.isEqualTo(predicate)),
      super.internal();

  @override
  @noBoundsChecks
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    if (position < buffer.length) {
      var nextPosition = position + 1;
      if (_isLeadSurrogate(buffer.codeUnitAt(position)) &&
          nextPosition < buffer.length &&
          _isTrailSurrogate(buffer.codeUnitAt(nextPosition))) {
        nextPosition++;
      }
      return context.success(
        buffer.substring(position, nextPosition),
        nextPosition,
      );
    }
    return context.failure(message);
  }

  @override
  @noBoundsChecks
  int fastParseOn(String buffer, int position) {
    if (position < buffer.length) {
      if (_isLeadSurrogate(buffer.codeUnitAt(position++)) &&
          position < buffer.length &&
          _isTrailSurrogate(buffer.codeUnitAt(position))) {
        position++;
      }
      return position;
    }
    return -1;
  }
}

// The following tests are adapted from the Dart SDK:
// https://github.com/dart-lang/sdk/blob/1207250b0d5687f9016cf115068addf6593dba58/sdk/lib/core/string.dart#L932-L955

// Tests if the code is a UTF-16 lead surrogate.
@preferInline
bool _isLeadSurrogate(int code) => (code & 0xFC00) == 0xD800;

// Tests if the code is a UTF-16 trail surrogate.
@preferInline
bool _isTrailSurrogate(int code) => (code & 0xFC00) == 0xDC00;

// Combines a lead and a trail surrogate value into a single code point.
@preferInline
int _combineSurrogatePair(int start, int end) =>
    0x10000 + ((start & 0x3FF) << 10) + (end & 0x3FF);
