---
name: petitparser-use
description: Executes, evaluates, and integrates PetitParser combinators within Dart application code, covering parsing, fast validation, occurrence scanning, and Pattern interoperability.
---

# Parser Execution & Pattern Integration

## Trigger Conditions

- Invoking parsers to evaluate user input or deserialize structured documents.
- Implementing fast form or input validation without AST allocation overhead.
- Finding, extracting, or streaming occurrences of structured tokens across arbitrary text.
- Using PetitParser as a composable, maintainable replacement for Dart's native `RegExp` in `String` operations (`split`, `replaceAll`, `replaceAllMapped`).

## Primary Execution (`parse`)

Execute a parser against an input string to obtain a `Result<T>`:

```dart
final result = parser.parse(input);
switch (result) {
  case Success(:final value, :final position):
    print('Parsed value: $value up to offset $position');
  case Failure(:final message, :final position):
    final [line, column] = Token.lineAndColumnOf(input, position);
    print('Syntax error at $line:$column: $message');
}
```

### Result Inspection Patterns

Choose between exception-based error propagation and inline pattern matching:

1. **Direct Value Access (`result.value`)**:
   - Calling `result.value` throws a `ParserException` on `Failure`.
   - Highly idiomatic for CLI entrypoints, unit test helpers, and APIs where parse failures are treated as exceptional conditions.
   - `ParserException` includes full diagnostic metadata: `message`, `offset`, and human-readable context.

   ```dart
   T parseOrThrow<T>(Parser<T> parser, String input) => parser.parse(input).value;
   ```

2. **Non-Throwing Pattern Matching**:
   - Recommended when failures are expected as normal control flow (e.g. IDE diagnostics, user form validation).
   - Use Dart 3 switch expressions or `if (result case Success(:final value))`.
   - Note: `Result` is a sealed class with subclasses `Success<T>` and `Failure<T>`.

### Zero-Copy Slicing

Use the optional `{int start = 0}` parameter to begin parsing at an arbitrary offset without creating substring copies:

```dart
final sliceResult = parser.parse(largeBuffer, start: 1024);
```

### Fast Syntax Validation (`accept`)

Validate whether input conforms to a grammar without constructing ASTs or allocating `Result`/`Context` objects:

```dart
final isValid = parser.accept(input);
```

- **Performance**: Short-circuits immediately on failure and avoids allocating intermediate token or AST objects.
- **Use Cases**: Ideal for UI form field validation, pre-commit guards, and schema acceptance checks.

### Occurrence Scanning & Extraction (`allMatches`)

Search for and extract repeated patterns within arbitrary unparsed or unstructured text using `allMatches`:

```dart
final integer = digit().plusString().map(int.parse);

// Scans text and yields successful matches, skipping non-matching interstitial characters:
final numbers = integer.allMatches('item 10 costs \$25 and 99 cents');
// numbers.toList() == [10, 25, 99]
```

- **`allMatches(input, {int start = 0, bool overlapping = false}) -> Iterable<T>`**:
  - Lazily streams parsed values found in the input.
  - Automatically advances through the input, skipping non-matching characters until a match is found.
  - Set `overlapping: true` to attempt matches at every consecutive index rather than advancing past matched tokens.

### Dart Standard Library `Pattern` Interoperability

Convert any parser into a standard Dart `Pattern` using `toPattern()`:

```dart
final delimiter = [char(';'), char(',')].toChoiceParser();
final pattern = delimiter.toPattern();

// 1. Splitting strings:
final parts = 'apple,banana;orange'.split(pattern);
// parts == ['apple', 'banana', 'orange']

// 2. Replacing strings:
final sanitized = 'hello   world'.replaceAll(whitespace().plus().toPattern(), ' ');
// sanitized == 'hello world'

// 3. Contextual replacement:
final capitalized = 'dart petitparser'.replaceAllMapped(
  letter().plusString().toPattern(),
  (match) => match.group(0)!.toUpperCase(),
);
// capitalized == 'DART PETITPARSER'

// 4. Substring presence check:
final hasDigits = 'abc 123'.contains(digit().toPattern());
```

## Critical Heuristics & Anti-Patterns

- **Intentional Anchoring vs. Prefix Scanning**:
  - Neither `parse()` nor `accept()` automatically check that the entire input is consumed.
  - A parser for `'foo'` successfully matches `'foo bar'` and consumes 3 characters.
  - Append `.end()` when complete input consumption is mandatory. Omit `.end()` intentionally when implementing prefix scanning, token streaming, or substring matching.
- **Allocating Results for Pure Validation**:
  - Never do `parser.parse(input) is Success` for simple boolean validation.
  - Use `parser.accept(input)` instead to eliminate intermediate object allocations.
- **AST vs. String Matching in `toPattern()`**:
  - `toPattern()` interfaces with Dart's `Match` API, which works on matched character ranges (`Match.start`, `Match.end`, `Match.group(0)`).
  - When parsed AST structures or mapped objects are needed, use `allMatches()` or `parse()` instead of `toPattern()`.
