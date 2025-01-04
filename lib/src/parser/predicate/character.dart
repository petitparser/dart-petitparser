import 'package:meta/meta.dart';

import '../../core/parser.dart';
import '../character/predicate.dart';
import 'single_character.dart';
import 'unicode_character.dart';

/// Abstract parser for character classes.
abstract class CharacterParser extends Parser<String> {
  /// Factory constructor for a unicode parser.
  ///
  /// The [predicate] defines the character class to be detected. The [message]
  /// is the error text produces in case the parser failed to consume the
  /// input.
  ///
  /// By default, the parsers works on UTF-16 code units. If [unicode] is set
  /// to `true` unicode surrogate pairs are extracted and matched against the
  /// predicate.
  factory CharacterParser(CharacterPredicate predicate, String message,
          {bool unicode = false}) =>
      switch (unicode) {
        false => SingleCharacterParser(predicate, message),
        true => UnicodeCharacterParser(predicate, message),
      };

  /// Internal constructor
  @internal
  CharacterParser.internal(this.predicate, this.message);

  /// Predicate indicating whether a character can be consumed.
  final CharacterPredicate predicate;

  /// Error message to annotate parse failures with.
  final String message;

  @override
  String toString() => '${super.toString()}[$message]';

  @override
  bool hasEqualProperties(CharacterParser other) =>
      super.hasEqualProperties(other) &&
      predicate == other.predicate &&
      message == other.message;
}
