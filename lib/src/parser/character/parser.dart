import '../../context/context.dart';
import '../../core/parser.dart';
import 'predicate.dart';

/// Parser class for individual character classes.
class CharacterParser extends Parser<String> {
  CharacterParser(this.predicate, this.message);

  /// Predicate indicating whether a character can be consumed.
  final CharacterPredicate predicate;

  /// Error message to annotate parse failures with.
  final String message;

  @override
  void parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    if (position < buffer.length &&
        predicate.test(buffer.codeUnitAt(position))) {
      context.isSuccess = true;
      context.value = buffer[position];
      context.position = position + 1;
    } else {
      context.isSuccess = false;
      context.message = message;
    }
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
