import '../core/parser.dart';
import '../parser/combinator/optional.dart';
import '../parser/misc/epsilon.dart';
import '../parser/repeater/repeating.dart';

/// Returns `true`, if [parser] is a nullable parser and can successfully parse
/// nothing.
bool isNullable(Parser parser) {
  if (parser is OptionalParser || parser is EpsilonParser) {
    return true;
  }
  if (parser is RepeatingParser && parser.min == 0) {
    return true;
  }
  return false;
}

/// Returns `true`, if [parser] is a terminal or leaf parser. This means it
/// does not delegate to any other parser.
bool isTerminal(Parser parser) => parser.children.isEmpty;
