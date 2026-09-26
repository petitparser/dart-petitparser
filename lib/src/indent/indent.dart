import 'package:meta/meta.dart';

import '../core/parser.dart';
import '../parser/action/where.dart';
import '../parser/character/pattern.dart';
import '../parser/combinator/and.dart';
import '../parser/combinator/choice.dart';
import '../parser/combinator/skip.dart';
import '../parser/misc/epsilon.dart';
import '../parser/misc/failure.dart';
import '../parser/repeater/character.dart';
import '../parser/utils/failure_joiner.dart';

/// A stateful set of parsers to handle indentation-based grammars.
///
/// Typical use combines [same] to match the indentation of items at the current
/// level and [during] to scope indented blocks:
///
/// ```dart
/// final indent = Indent();
/// final line = indent.same & word().plus().flatten();
/// final block = indent.during(line.plus());
/// ```
///
/// Based on https://stackoverflow.com/a/56926044/82303.
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
  /// Prefer using [during] instead to properly track the indentation state and
  /// ensure rollback on parse failure.
  @Deprecated('Use `during` instead to properly track the indentation state')
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
  ///
  /// Prefer using [during] instead to properly track the indentation state and
  /// ensure rollback on parse failure.
  @Deprecated('Use `during` instead to properly track the indentation state')
  late final Parser<void> decrease = epsilon().where((_) {
    if (stack.isNotEmpty) {
      current = stack.removeLast();
      return true;
    } else {
      return false;
    }
  });

  /// Runs [parser] in a deeper indentation scope.
  ///
  /// Before running [parser], verifies that the next line has a deeper
  /// indentation than the current level and pushes the previous level onto
  /// the indentation stack. After [parser] succeeds, pops and restores the
  /// previous indentation level.
  ///
  /// If [parser] fails, the indentation state is automatically rolled back
  /// to its state before entering the block, preserving the original parse
  /// failure position and message. This ensures that subsequent branches
  /// in choice combinators can backtrack safely without state corruption.
  ///
  /// For example, to parse an indented block of statements:
  ///
  /// ```dart
  /// final block = indent.during(statement.plus());
  /// ```
  Parser<R> during<R>(Parser<R> parser) =>
      [parser, failure<R>().skip(before: decrease)]
          .toChoiceParser(failureJoiner: selectFirst)
          .skip(before: increase, after: decrease);
}
