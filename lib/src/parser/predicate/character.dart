import '../../core/context.dart';
import '../../core/parser.dart';
import '../../core/result.dart';
import '../character/predicate.dart';

/// Alias for deprecated class name.
@Deprecated('Instead use `SingleCharacterParser`')
typedef CharacterParser = SingleCharacterParser;

/// Parser class for individual character classes.
class SingleCharacterParser extends Parser<String> {
  SingleCharacterParser(this.predicate, this.message);

  /// Predicate indicating whether a character can be consumed.
  final CharacterPredicate predicate;

  /// Error message to annotate parse failures with.
  final String message;

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
  SingleCharacterParser copy() => SingleCharacterParser(predicate, message);

  @override
  bool hasEqualProperties(SingleCharacterParser other) =>
      super.hasEqualProperties(other) &&
      predicate.isEqualTo(other.predicate) &&
      message == other.message;
}
