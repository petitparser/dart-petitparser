import 'package:meta/meta.dart';

import '../../core/context.dart';
import '../../core/result.dart';
import '../character/predicate.dart';
import '../character/predicates/constant.dart';
import 'character.dart';
import 'unicode_character.dart';

/// Parser class an individual UTF-16 code unit satisfying a [predicate].
///
/// This class parses characters equivalent to those that [String.codeUnitAt]
/// or [String.codeUnits] returns. To decode surrogate pairs (characters that
/// cannot be expressed as a single 16-bit value), [UnicodeCharacterParser]
/// should be used instead.
class SingleCharacterParser extends CharacterParser {
  factory SingleCharacterParser(CharacterPredicate predicate, String message) =>
      const ConstantCharPredicate(true) == predicate
          ? AnySingleCharacterParser.internal(predicate, message)
          : SingleCharacterParser.internal(predicate, message);

  @internal
  SingleCharacterParser.internal(super.predicate, super.message)
      : super.internal();

  @override
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    return position < buffer.length &&
            predicate.test(buffer.codeUnitAt(position))
        ? context.success(buffer[position], position + 1)
        : context.failure(message);
  }

  @override
  int fastParseOn(String buffer, int position) =>
      position < buffer.length && predicate.test(buffer.codeUnitAt(position))
          ? position + 1
          : -1;

  @override
  SingleCharacterParser copy() => SingleCharacterParser(predicate, message);
}

/// Internal parser specialization of the [SingleCharacterParser] that assumes
/// its `predicate` always returns `true`.
class AnySingleCharacterParser extends SingleCharacterParser {
  @internal
  AnySingleCharacterParser.internal(super.predicate, super.message)
      : super.internal();

  @override
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    return position < buffer.length
        ? context.success(buffer[position], position + 1)
        : context.failure(message);
  }

  @override
  int fastParseOn(String buffer, int position) =>
      position < buffer.length ? position + 1 : -1;
}
