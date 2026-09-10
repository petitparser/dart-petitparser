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

- **`result is Success<T>` / `result is Failure`**: Type checks for outcome inspection (or pattern matching via `switch (result)` / `if (result case Success(:final value))`). Note that `Result` is a sealed class without `isSuccess` or `isFailure` boolean getters.
- **`result.value`**: The parsed value. Throws `ParserException` if called on a `Failure`. Always guard with a pattern match or type check.
- **`result.position`**: Index of the character immediately following the consumed input.
- **Zero-Copy Slicing**: Use the optional `{int start = 0}` parameter to begin parsing at an arbitrary offset without creating sub-string copies:

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

- **The Unanchored Prefix Trap**:
  - Neither `parse()` nor `accept()` automatically check that the entire input is consumed.
  - A parser for `'foo'` successfully matches `'foo bar'` and consumes 3 characters.
  - Always append `.end()` to top-level entrypoint rules when full-string validation is required.
- **Unchecked `.value` Access**:
  - Invoking `.value` directly on an unchecked `Result<T>` throws an unhandled `ParserException` on failure.
  - Use Dart 3 pattern matching (`if (result case Success(:final value)) ...`) or verify `result is Success<T>` before accessing `.value`.
- **Allocating Results for Pure Validation**:
  - Never do `parser.parse(input) is Success` for simple validation.
  - Use `parser.accept(input)` instead to avoid intermediate object allocations.
- **AST vs. String Matching in `toPattern()`**:
  - `toPattern()` interfaces with Dart's `Match` API, which works on matched character ranges (`Match.start`, `Match.end`, `Match.group(0)`).
  - When parsed AST structures or mapped objects are needed, use `allMatches()` or `parse()` instead of `toPattern()`.
