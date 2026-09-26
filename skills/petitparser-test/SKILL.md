---
name: petitparser-test
description: Builds comprehensive, deterministic, and rigorous automated test suites for grammars, validating individual productions, end-to-end AST generation, edge-case token boundaries, and linter compliance.
---

# Grammar Testing & Verification

## Trigger Conditions

- Writing unit and regression tests for new or modified grammar rules.
- Isolating and testing individual grammar productions independently from the root parser.
- Validating grammar behavior against syntax edge cases (empty strings, Unicode, whitespace, malformed inputs).
- Running grammar linter checks to detect cycles, left recursion, and dead ends.

## Isolated Production Testing with `buildFrom`

Do not test all grammar rules exclusively through the top-level `start()` entrypoint. Compile and test sub-rules in total isolation using `buildFrom`:

```dart
import 'package:petitparser/petitparser.dart';
import 'package:test/test.dart';

void main() {
  final grammar = MyGrammarDefinition();

  // Compile individual rules in isolation, anchored with .end():
  final identifier = grammar.buildFrom(ref0(grammar.identifier)).end();
  final statement = grammar.buildFrom(ref0(grammar.statement)).end();

  group('identifier', () {
    test('valid identifiers', () {
      expect(identifier.parse('foo'), isA<Success>());
      expect(identifier.parse('_bar123'), isA<Success>());
    });

    test('invalid identifiers', () {
      expect(identifier.parse('123foo'), isA<Failure>());
      expect(identifier.parse(''), isA<Failure>());
    });
  });
}
```

## Dual-Verification Strategy

Every test suite must assert both valid input acceptance and invalid input rejection:

- **Success Assertions**: Verify that the input parses successfully, consumes expected length, and produces the expected value.
- **Failure Assertions**: Verify that malformed syntax produces a `Failure`, and optionally assert failure position and message.

```dart
// Success: assert value and successful parsing
expect(parser.parse('42').value, 42);
expect(parser.accept('42'), isTrue);

// Failure: assert Failure type or rejection
expect(parser.parse('abc'), isA<Failure>());
expect(parser.accept('abc'), isFalse);

// Detailed failure checks when needed:
expect(
  parser.parse('abc'),
  isA<Failure>()
      .having((f) => f.position, 'position', 0)
      .having((f) => f.message, 'message', 'digit expected'),
);
```

### Semantic AST Assertions

Assert the complete structure and types of returned AST nodes, not just boolean success:

```dart
test('parses binary expression AST', () {
  final result = exprParser.parse('1 + 2');
  expect(result, isA<Success>());

  final node = result.value;
  expect(node, isA<BinaryExpressionNode>()
    .having((n) => n.operator, 'operator', '+')
    .having((n) => n.left, 'left', isA<LiteralNode>().having((l) => l.value, 'value', 1))
    .having((n) => n.right, 'right', isA<LiteralNode>().having((l) => l.value, 'value', 2)));
});
```

### Automated Grammar Linter & Pragmatic Exclusions

PetitParser includes a built-in static grammar analyzer via `linter(parser)`. Add a dedicated test verifying the grammar is free of structural defects:

```dart
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

test('grammar linter passes without issues', () {
  final parser = MyGrammarDefinition().build();
  final issues = linter(parser);

  expect(issues, isEmpty, reason: issues.join('\n'));
});
```

The linter automatically checks for:

- Unreachable / unreferenced parsers.
- Left-recursive cycles that cause infinite call stacks.
- Repetition over nullable / zero-width parsers.
- Redundant and nested wrapper parsers.
- Duplicate parsers.

#### Pragmatic Linter Exclusions

While grammars should strive to pass all linter checks cleanly, certain rules can be legitimately ignored depending on grammar design:

- **`Duplicate parser`**: Often triggered when parameterized helper rules (e.g. `ref1(token, ',')`) or terminal tokens are independently generated across multiple productions. If consolidating them adds unnecessary coupling or complexity, exclude the rule pragmatically:

  ```dart
  expect(
    linter(parser, excludedRules: {'Duplicate parser'}),
    isEmpty,
  );
  ```

- Always document the rationale when passing `excludedRules` to `linter()`.

### Edge-Case & Boundary Matrix

Always include tests covering:

- **Empty input**: `""` should fail cleanly if input is required, or produce the default empty AST.
- **Whitespace variations**: Leading, trailing, internal newlines, tabs, and spaces.
- **Truncated inputs**: Unterminated strings (`"hello`), unclosed brackets (`[1, 2`), trailing operators (`1 +`).
- **Unicode characters**: Multi-byte code points, emojis, non-ASCII identifier characters.
- **Input boundary**: Ensure input following a valid token is either parsed or rejected (verifying `.end()`).

When debugging complex test failures, isolate the failure into a minimal test pair and use `trace()` as described in `petitparser-debug`.

## Critical Heuristics & Anti-Patterns

- **Dual-Verification Mandatory**: Never only test `isSuccess`. Testing invalid inputs with `isFailure` is essential to prevent false-positive over-matching.
- **Isolate Sub-Rules**: Test each production in isolation (`buildFrom`) to minimize search space when grammar rules break.
- **Verify Clean Linter**: Run `linter(parser)` as part of continuous integration, documenting any intentional exclusions.
