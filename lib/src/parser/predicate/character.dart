import '../../core/parser.dart';
import '../character/predicate.dart';

/// Abstract parser for character classes.
abstract class CharacterParser extends Parser<String> {
  CharacterParser(this.predicate, this.message);

  /// Predicate indicating whether a character can be consumed.
  final CharacterPredicate predicate;

  /// Error message to annotate parse failures with.
  final String message;

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  bool hasEqualProperties(CharacterParser other) =>
      super.hasEqualProperties(other) &&
      predicate.isEqualTo(other.predicate) &&
      message == other.message;
}
