import 'package:meta/meta.dart';

import '../core/parser.dart';
import '../parser/action/map.dart';
import '../parser/action/where.dart';
import '../parser/character/pattern.dart';
import '../parser/combinator/and.dart';
import '../parser/misc/epsilon.dart';
import '../parser/repeater/character.dart';

/// A stateful set of parsers to handled indentation based grammars.
///
/// Based on https://stackoverflow.com/a/56926044/82303.
@experimental
class Indent {
  Indent({
    Parser<String>? parser,
    String? message,
  })  : parser = parser ?? pattern(' \t'),
        message = message ?? 'indented expected';

  /// The parser used read a single indentation step.
  final Parser<String> parser;

  /// The error message to use when an indention is expected.
  final String message;

  /// Internal field with the stack of indentations.
  @internal
  final List<String> stack = [];

  /// Internal field of the currently active indentation.
  @internal
  String current = '';

  /// A parser that increases the current indentation and returns it, but does
  /// not consume anything.
  late Parser<String> increase = parser
      .plusString(message)
      .where((value) => value.length > current.length)
      .map((value) {
    stack.add(current);
    return current = value;
  }, hasSideEffects: true).and();

  /// A parser that consumes and returns the current indent.
  late Parser<String> same =
      parser.starString(message).where((value) => value == current);

  /// A parser that decreases the current indentation and returns it, but does
  /// not consume anything.
  late Parser<String> decrease = epsilon()
      .where((_) => stack.isNotEmpty)
      .map((_) => current = stack.removeLast(), hasSideEffects: true);
}
