library petitparser.core.combinators.choice;

import 'package:petitparser/src/core/combinators/choice_custom_failure.dart';
import 'package:petitparser/src/core/combinators/choice_first_failure.dart';
import 'package:petitparser/src/core/combinators/choice_last_failure.dart';
import 'package:petitparser/src/core/combinators/list.dart';
import 'package:petitparser/src/core/parser.dart';

/// A parser that uses the first parser that succeeds.
abstract class ChoiceParser extends ListParser {
  /// Constructs a default choice parser reporting the last failure.
  factory ChoiceParser(Iterable<Parser> children) = ChoiceParserWithLastFailure;

  /// Canonical constructor for choice parsers.
  ChoiceParser.of(Iterable<Parser> children) : super(children) {
    if (children.isEmpty) {
      throw ArgumentError('Choice parser cannot be empty.');
    }
  }

  /// Return a new choice parser reporting the first failure.
  ChoiceParser withFirstFailure() => ChoiceParserWithFirstFailure(children);

  /// Return a new choice parser reporting the last failure.
  ChoiceParser withLastFailure() => ChoiceParserWithLastFailure(children);

  /// Return a new choice parser reporting a custom failure.
  ChoiceParser withCustomFailure(String message) =>
      ChoiceParserWithCustomFailure(children, message);
}
