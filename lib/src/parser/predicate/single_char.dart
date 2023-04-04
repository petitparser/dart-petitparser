import '../../context/context.dart';
import '../../core/parser.dart';
import '../character/predicate.dart';

/// Alias for the [SingleCharacterParser].
@Deprecated('Replace with SingleCharacterParser')
typedef CharacterParser = SingleCharacterParser;

/// Parser class for individual character classes.
class SingleCharacterParser extends Parser<String> {
  SingleCharacterParser(this.predicate, this.message);

  /// Predicate indicating whether a character can be consumed.
  final CharacterPredicate predicate;

  /// Error message to annotate parse failures with.
  final String message;

  @override
  void parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    if (position < context.end && predicate.test(buffer.codeUnitAt(position))) {
      context.isSuccess = true;
      context.position = position + 1;
      context.value = buffer[position];
    } else {
      context.isSuccess = false;
      context.message = message;
    }
  }

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  SingleCharacterParser copy() => SingleCharacterParser(predicate, message);

  @override
  bool hasEqualProperties(SingleCharacterParser other) =>
      super.hasEqualProperties(other) &&
      predicate.isEqualTo(other.predicate) &&
      message == other.message;
}
