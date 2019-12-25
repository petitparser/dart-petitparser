library petitparser.parsers.characters.parser;

import '../../core/contexts/context.dart';
import '../../core/contexts/result.dart';
import '../../core/parser.dart';
import 'predicate.dart';

/// Parser class for individual character classes.
class CharacterParser extends Parser<String> {
  final CharacterPredicate predicate;

  final String message;

  CharacterParser(this.predicate, this.message)
      : assert(predicate != null, 'predicate must not be null'),
        assert(message != null, 'message must not be null');

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
  String toString() => '${super.toString()}[$message]';

  @override
  CharacterParser copy() => CharacterParser(predicate, message);

  @override
  bool hasEqualProperties(CharacterParser other) =>
      super.hasEqualProperties(other) &&
      predicate.isEqualTo(other.predicate) &&
      message == other.message;
}
