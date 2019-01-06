library petitparser.core.characters.parser;

import 'package:petitparser/src/core/characters/predicate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// Parser class for individual character classes.
class CharacterParser extends Parser<String> {
  final CharacterPredicate predicate;

  final String message;

  CharacterParser(this.predicate, this.message)
      : assert(predicate != null),
        assert(message != null);

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
  String toString() => '${super.toString()}[$message]';

  @override
  CharacterParser copy() => CharacterParser(predicate, message);

  @override
  bool hasEqualProperties(CharacterParser other) =>
      super.hasEqualProperties(other) &&
      predicate.isEqualTo(other.predicate) &&
      message == other.message;
}
