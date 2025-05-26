import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/result.dart';
import '../../shared/pragma.dart';
import '../character/predicate.dart';
import '../character/predicate/constant.dart';
import 'character.dart';

/// Parser class for an individual 16-bit UTF-16 code units satisfying a
/// specified [CharacterPredicate].
class SingleCharacterParser extends CharacterParser {
  factory SingleCharacterParser(CharacterPredicate predicate, String message) =>
      ConstantCharPredicate.any.isEqualTo(predicate)
      ? AnySingleCharacterParser.internal(predicate, message)
      : SingleCharacterParser.internal(predicate, message);

  @internal
  SingleCharacterParser.internal(super.predicate, super.message)
    : super.internal();

  @override
  @noBoundsChecks
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
  @noBoundsChecks
  int fastParseOn(String buffer, int position) =>
      position < buffer.length && predicate.test(buffer.codeUnitAt(position))
      ? position + 1
      : -1;

  @override
  SingleCharacterParser copy() => SingleCharacterParser(predicate, message);
}

/// Optimized version of [SingleCharacterParser] that parses any 16-bit UTF-16
/// character (including possible surrogate pairs).
class AnySingleCharacterParser extends SingleCharacterParser {
  AnySingleCharacterParser.internal(super.predicate, super.message)
    : assert(ConstantCharPredicate.any.isEqualTo(predicate)),
      super.internal();

  @override
  @noBoundsChecks
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    if (position < buffer.length) {
      return context.success(buffer[position], position + 1);
    }
    return context.failure(message);
  }

  @override
  int fastParseOn(String buffer, int position) =>
      position < buffer.length ? position + 1 : -1;
}
