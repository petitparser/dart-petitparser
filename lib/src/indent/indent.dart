import 'package:meta/meta.dart';

import '../core/parser.dart';
import '../parser/action/where.dart';
import '../parser/character/pattern.dart';
import '../parser/combinator/and.dart';
import '../parser/combinator/generated/sequence_3.dart';
import '../parser/misc/epsilon.dart';
import '../parser/repeater/character.dart';

/// A stateful set of parsers to handled indentation based grammars.
///
/// Based on https://stackoverflow.com/a/56926044/82303.
@experimental
class Indent {
  new({Parser<String>? parser, String? message})
    : parser = parser ?? pattern(' \t'),
      message = message ?? 'indented expected';

  /// The parser used read a single indentation step.
  final Parser<String> parser;

  /// The error message to use when an indentation is expected.
  final String message;

  /// Internal field with the stack of indentations.
  @internal
  final List<String> stack = [];

  /// Internal field of the currently active indentation.
  @internal
  String current = '';

  /// A parser that increases the indentation.
  ///
  /// The parser performs the following actions in sequence:
  ///
  /// 1. verifies that the new indentation is deeper than the previous one,
  /// 2. pushes the previous indentation to the stack,
  /// 3. updates the current indentation with the new one, and
  /// 4. returns the new indentation without consuming it.
  ///
  late final Parser<String> increase = parser
      .plusString(message: message)
      .where((value) {
        if (value.startsWith(current) && value.length > current.length) {
          stack.add(current);
          current = value;
          return true;
        } else {
          return false;
        }
      })
      .and();

  /// A parser that consumes and matches the current indentation level.
  late final Parser<String> same = parser
      .starString(message: message)
      .where((value) => value == current);

  /// A parser that decreases the indentation by one level.
  late final Parser<void> decrease = epsilon().where((_) {
    if (stack.isNotEmpty) {
      current = stack.removeLast();
      return true;
    } else {
      return false;
    }
  });

  /// Helper to indent during the run of another parser.
  Parser<R> during<R>(Parser<R> parser) =>
      seq3(increase, parser, decrease).map3((_, body, _) => body);
}
