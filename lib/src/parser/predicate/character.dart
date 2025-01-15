import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../character/predicate.dart';
import 'single_character.dart';
import 'unicode_character.dart';

/// Parser class for an individual character satisfying a [CharacterPredicate].
abstract class CharacterParser extends Parser<String> {
  /// Constructs a new character parser.
  ///
  /// The [predicate] defines the character class to be detected.
  ///
  /// The [message] is the error text generated in case the predicate does not
  /// satisfy the input.
  ///
  /// By default, the parsers works on UTF-16 code units. If [unicode] is set
  /// to `true` unicode surrogate pairs are extracted from the input and matched
  /// against the predicate.
  factory CharacterParser(CharacterPredicate predicate, String message,
          {bool unicode = false}) =>
      switch (unicode) {
        false => SingleCharacterParser(predicate, message),
        true => UnicodeCharacterParser(predicate, message),
      };

  /// Internal constructor.
  @internal
  CharacterParser.internal(this.predicate, this.message);

  /// Predicate indicating whether a character can be consumed.
  final CharacterPredicate predicate;

  /// Error message to annotate parse failures with.
  final String message;

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  bool hasEqualProperties(SingleCharacterParser other) =>
      super.hasEqualProperties(other) &&
      predicate.isEqualTo(other.predicate) &&
      message == other.message;
}
