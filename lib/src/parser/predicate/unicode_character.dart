import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/result.dart';
import '../../shared/annotations.dart';
import '../character/predicate.dart';
import '../character/predicates/constant.dart';
import 'character.dart';
import 'single_character.dart';

/// Parser class for an individual Unicode code-point satisfying a [predicate].
///
/// This class parses Unicode code-points, similar to those that [String.runes]
/// returns. Decoding surrogate pairs (characters that cannot be expressed in a
/// single 16-bit value) comes at an extra cost, to avoid this consider using
/// [SingleCharacterParser] instead.
class UnicodeCharacterParser extends CharacterParser {
  factory UnicodeCharacterParser(
          CharacterPredicate predicate, String message) =>
      const ConstantCharPredicate(true) == predicate
          ? AnyUnicodeCharacterParser.internal(predicate, message)
          : UnicodeCharacterParser.internal(predicate, message);

  @internal
  UnicodeCharacterParser.internal(super.predicate, super.message)
      : super.internal();

  @override
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    var position = context.position;
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
        return context.success(String.fromCharCode(codeUnit), position);
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

/// Internal parser specialization of the [UnicodeCharacterParser] that assumes
/// its `predicate` always returns `true`.
class AnyUnicodeCharacterParser extends UnicodeCharacterParser {
  @internal
  AnyUnicodeCharacterParser.internal(super.predicate, super.message)
      : assert(const ConstantCharPredicate(true) == predicate),
        super.internal();

  @override
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    var position = context.position;
    if (position < buffer.length) {
      var codeUnit = buffer.codeUnitAt(position++);
      if (_isLeadSurrogate(codeUnit) && position < buffer.length) {
        final nextCodeUnit = buffer.codeUnitAt(position);
        if (_isTrailSurrogate(nextCodeUnit)) {
          codeUnit = _combineSurrogatePair(codeUnit, nextCodeUnit);
          position++;
        }
      }
      return context.success(String.fromCharCode(codeUnit), position);
    }
    return context.failure(message);
  }

  @override
  int fastParseOn(String buffer, int position) {
    if (position < buffer.length) {
      final codeUnit = buffer.codeUnitAt(position++);
      if (_isLeadSurrogate(codeUnit) && position < buffer.length) {
        final nextCodeUnit = buffer.codeUnitAt(position);
        if (_isTrailSurrogate(nextCodeUnit)) {
          position++;
        }
      }
      return position;
    }
    return -1;
  }
}

// The following tests are adapted from the Dart SDK:
// https://github.com/dart-lang/sdk/blob/1207250b0d5687f9016cf115068addf6593dba58/sdk/lib/core/string.dart#L932-L955

// Tests if the code is a UTF-16 lead surrogate.
@inlineVm
@inlineJs
bool _isLeadSurrogate(int code) => (code & 0xFC00) == 0xD800;

// Tests if the code is a UTF-16 trail surrogate.
@inlineVm
@inlineJs
bool _isTrailSurrogate(int code) => (code & 0xFC00) == 0xDC00;

// Combines a lead and a trail surrogate value into a single code point.
@inlineVm
@inlineJs
int _combineSurrogatePair(int start, int end) =>
    0x10000 + ((start & 0x3FF) << 10) + (end & 0x3FF);
