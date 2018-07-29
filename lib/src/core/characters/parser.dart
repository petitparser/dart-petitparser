library petitparser.core.characters.parser;

import 'package:petitparser/src/core/characters/predicate.dart';
import 'package:petitparser/src/core/contexts/context.dart';
import 'package:petitparser/src/core/contexts/result.dart';
import 'package:petitparser/src/core/parser.dart';

/// Parser class for individual character classes.
class CharacterParser extends Parser<String> {
  final CharacterPredicate _predicate;

  final String _message;

  CharacterParser(this._predicate, this._message);

  @override
  Result<String> parseOn(Context context) {
    var buffer = context.buffer;
    var position = context.position;
    if (position < buffer.length &&
        _predicate.test(buffer.codeUnitAt(position))) {
      return context.success(buffer[position], position + 1);
    }
    return context.failure(_message);
  }

  @override
  String toString() => '${super.toString()}[$_message]';

  @override
  Parser<String> copy() => CharacterParser(_predicate, _message);

  @override
  bool hasEqualProperties(Parser other) {
    return other is CharacterParser &&
        super.hasEqualProperties(other) &&
        _predicate == other._predicate &&
        _message == other._message;
  }
}
