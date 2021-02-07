import '../../../buffer.dart';
import '../../context/context.dart';
import '../../context/result.dart';
import '../../core/parser.dart';
import 'predicate.dart';

/// Parser class for individual character classes.
class CharacterParser extends Parser<String> {
  final CharacterPredicate predicate;

  final String message;

  CharacterParser(this.predicate, this.message);

  @override
  Result<String> parseOn(Context context) {
    final buffer = context.buffer;
    final position = context.position;
    return position < buffer.length &&
            predicate.test(buffer.codeUnitAt(position))
        ? context.success(buffer.charAt(position), position + 1)
        : context.failure(message);
  }

  @override
  int fastParseOn(Buffer buffer, int position) =>
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
