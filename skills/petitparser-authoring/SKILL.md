---
name: petitparser-authoring
description: Translates formal specifications (EBNF, PEG, regex, or natural language syntax requirements) into idiomatic PetitParser combinator trees, covering terminal matchers, combinators, lexical processing, errors/diagnostics, and high-performance parsing idioms.
---

# Grammar Authoring & Synthesis

## Trigger Conditions

- Generating new parsers or token matchers from scratch.
- Converting EBNF, ANTLR, or regex definitions into Dart combinators.
- Constructing lexerless parsers and syntactic matchers.
- Adding labels for debugging or custom failure messages for syntax diagnostics.
- Composing reusable parser factory functions.
- Writing high-throughput, memory-efficient parsers.

## Getting Started

Import most common features with `import 'package:petitparser/petitparser.dart';`.

Alternatively import the more specific packages `import 'package:petitparser/parser.dart';` for parser authoring, and `import 'package:petitparser/core.dart';` for parser use.

## Terminal Matchers

### Exact Matchers

- `char('a')`: Matches single character. Supports `ignoreCase: true`, `unicode: true`, and custom error `message:`.
- `string('const')`: Matches exact string literal. Supports `ignoreCase: true` and custom error `message:`.

### Predicate Matchers

- `pattern('0-9a-fA-F')`: Character class range/set syntax. Supports negation prefix (`pattern('^0-9')`), `unicode: true`, and custom error `message:`.
- `anyOf('+-*/')`: Matches any single character in the string. Supports `ignoreCase: true`, `unicode: true`, and custom error `message:`.
- `noneOf('\r\n')`: Matches any single character not in the string. Supports `ignoreCase: true`, `unicode: true`, and custom error `message:`.

### Built-in Character Matchers

- `digit()`, `letter()`, `word()`, `whitespace()`, `newline()`, `any()`. All accept an optional custom error `message:`.

```dart
final hexDigit = pattern('0-9a-fA-F');
final identifierStart = [letter(), char('_')].toChoiceParser();
final keyword = string('class');
final caseInsensitiveKeyword = string('select', ignoreCase: true);
```

## Combinator Composition

### Sequence

- Typed record combinators: `seq2(p1, p2)` through `seq9(p1, ..., p9)` return `Parser<(R1, R2)>` up to `Parser<(R1, ..., R9)>`.
- Record extension: `(p1, p2).toSequenceParser()` converts a record of parsers into `Parser<(R1, R2)>`.
- Chaining: `p1.then(p2).then(p3)` flattens typed parsers into a typed record `Parser<(R1, R2, R3)>`.
- List sequence: `[p1, p2, p3].toSequenceParser()` combines an iterable of parsers into `Parser<List<R>>` of their common supertype.
- Avoid dynamic `&` / `seq()` which decay to `SequenceParser<List<dynamic>>`.

### Ordered Choice

- `[p1, p2, p3].toChoiceParser()` creates an ordered choice typed to their closest common supertype.
- Prioritized PEG semantics: branches evaluate in declared order; first match wins.
- Avoid dynamic `|` / `or()` which decay to `ChoiceParser<dynamic>`.

### Repetition & String Buffering

- `parser.star()`: Zero or more occurrences (`List<T>`).
- `parser.plus()`: One or more occurrences (`List<T>`).
- `parser.repeat(min, max)`: Between `min` and `max` occurrences (`List<T>`).
- `parser.times(n)`: Exactly `n` occurrences (`List<T>`).
- **Zero-Allocation String Repetitions**: For character parsers, systematically prefer string combinators over `.star()` / `.plus()` to eliminate intermediate `List<String>` allocations:
  - `charParser.starString({String? message})`: Directly returns consumed `String`.
  - `charParser.plusString({String? message})`: Directly returns consumed non-empty `String`.
  - `charParser.timesString(n, {String? message})`: Matches exactly `n` characters into `String`.
  - `charParser.repeatString(min, max, {String? message})`: Matches bounded count into `String`.

### Separated Repetition

- `parser.starSeparated(separator)`: Zero or more elements delimited by `separator`.
- `parser.plusSeparated(separator)`: One or more elements delimited by `separator`.
- `parser.timesSeparated(separator, count)`: Exactly `count` elements delimited by `separator`.
- `parser.repeatSeparated(separator, min, max)`: Bounded elements delimited by `separator`.
- Returns `SeparatedList<R, S>` with `elements`, `separators`, `sequential`, `foldLeft`, and `foldRight`.

### Greedy and Lazy Repetition

- `starGreedy(limit)` and `plusGreedy(limit)`: Consumes as much as possible, then backtracks until `limit` matches.
- `starLazy(limit)` and `plusLazy(limit)`: Consumes as few repetitions as possible until `limit` matches. Preferred for delimited comments and quoted strings:

  ```dart
  final multiLineComment = seq3(string('/*'), any().starLazy(string('*/')), string('*/'));
  ```

### Optionality & Lookahead

- `parser.optional()`: Returns `T?` (`null` if absent).
- `parser.optionalWith(defaultValue)`: Returns `defaultValue` if absent.
- `parser.and()`: Positive lookahead without consuming input.
- `parser.not({String message = 'success not expected'})`: Negative lookahead without consuming input.
- `parser.neg({String message = 'input not expected'})`: Inverts a character parser, consuming any character not matched.
- `parser.end({String message = 'end of input expected'})`: Matches end of input.

### Delimiter Stripping with `.skip()`

Use `.skip()` to discard surrounding syntax delimiters without tuple unpacking:

```dart
// Discard open and close braces directly, returning Map<String, dynamic>:
final objectParser = members.skip(before: char('{').trim(), after: char('}').trim());

// Discard leading prefix token:
final negativeNumber = number.skip(before: char('-'));
```

## Lexical & Token Processing

- `parser.trim()`: Strips leading and trailing default whitespace. Pass custom parser to trim specific trivia (e.g. `parser.trim(ref0(hiddenWhitespace))`).
- `parser.flatten({String? message})`: Extracts consumed substring. Providing `message` enables fast parse mode.
- `parser.token()`: Wraps result in `Token<T>` containing `value`, `start`, `stop`, and `length`.

```dart
final integer = digit().plusString().map(int.parse);
final identifierToken = seq2(
  letter(),
  word().starString(),
).flatten(message: 'identifier expected').token();
```

### String Decoding & Escape Handling

Idiomatic pattern for quoted strings with escape sequences:

```dart
final escapedChar = seq2(
  char(r'\'),
  anyOf(r'"\/bfnrt'),
).map2((_, char) => switch (char) {
  'b' => '\b',
  'f' => '\f',
  'n' => '\n',
  'r' => '\r',
  't' => '\t',
  _ => char,
});

final unicodeChar = seq2(
  string(r'\u'),
  pattern('0-9a-fA-F').timesString(4, message: '4-digit hex expected'),
).map2((_, hex) => String.fromCharCode(int.parse(hex, radix: 16)));

final normalChar = pattern(r'^"\\');

final stringContent = [normalChar, escapedChar, unicodeChar].toChoiceParser();
final stringLiteral = stringContent.star().skip(before: char('"'), after: char('"')).map((chars) => chars.join());
```

For strings without escape transforms, avoid `map((chars) => chars.join())` and use `.flatten()`:

```dart
final rawQuotedString = pattern('^"').starString().skip(before: char('"'), after: char('"'));
```

## Production Actions & Mapping

- `seq2(p1, p2).map2((a, b) => ...)` through `map9`: Strongly-typed positional mapping for record sequences.
- `parser.map((val) => ...)`: Transforms output value.
- `parser.where((val) => condition, message: '...')`: Filters parsed values with optional failure message, turning invalid values into backtrackable parse failures.

```dart
final coordinate = seq3(
  digit().plusString().map(int.parse),
  char(','),
  digit().plusString().map(int.parse),
).map3((x, _, y) => Point(x, y));
```

## Empty & Explicit Failure Parsers

- `epsilon()`: Consumes nothing and returns `null` (`Parser<void>`). Useful for nullable defaults.
- `epsilonWith<R>(result)`: Consumes nothing and returns `result` (`Parser<R>`).
- `failure({String message = 'unable to parse'})`: Consumes nothing and fails with `message`.

## High-Performance Parsing Idioms

- Use record sequences (`seq2`–`seq9`, `(p1, p2).toSequenceParser()`, `then`) with `map2`–`map9` to eliminate intermediate lists and type casts.
- Use `[p1, p2].toSequenceParser()` only for homogeneous lists.
- Use `[p1, p2].toChoiceParser()` instead of `|` to maintain type inference.
- Use `charParser.starString()` and `charParser.plusString()` instead of `.star().flatten()` to avoid intermediate list allocations.
- Pass `message:` to `flatten(message: '...')` to activate fast parse mode.
- Avoid `cast<T>()` and `castList<T>()`; construct typed combinators directly.

## Diagnostics & Custom Failure Messages

- Provide `message:` directly to terminals and combinators (`char(';', message: "';' expected")`, `string()`, `flatten()`, `not()`, `end()`).
- Use `Token.lineAndColumnOf(input, failure.position)` to convert failure offsets to 1-based line and column coordinates.

```dart
final result = parser.parse(source);
if (result is Failure) {
  final [line, column] = Token.lineAndColumnOf(source, result.position);
  print('Error at line $line, column $column: ${result.message}');
}
```

## Dynamic Recursion & Factory Helpers

### Dynamic Recursion with `undefined()`

For local recursion outside `GrammarDefinition`, use `undefined<T>()` and `set()`:

```dart
final expression = undefined<num>();
final atom = digit().plusString().map(num.parse);
final parenthesized = seq3(
  char('('),
  expression,
  char(')'),
).map3((_, val, _) => val);

expression.set([atom, parenthesized].toChoiceParser());
```

### Combinator Factory Functions

Wrap recurring syntax patterns into reusable helper functions:

```dart
Parser<T> parenthesized<T>(Parser open, Parser<T> body, Parser close) =>
    body.skip(before: open.trim(), after: close.trim());

Parser<List<T>> commaSeparated<T>(Parser<T> element) =>
    element.plusSeparated(char(',').trim()).map((sep) => sep.elements);
```

## Critical Rules & Guidelines

- **PEG Choice Order**: More specific prefixes must precede general ones (`[string('=='), char('=')].toChoiceParser()`).
- **Anchoring with `.end()`**:
  - Append `.end()` when validating complete input files, documents, or data payloads.
  - Intentionally omit `.end()` for prefix scanning, substring extraction, streaming tokens, or embedding sub-languages.
- **No Nullable Repeaters**: Never wrap zero-width matchers (`optional()`, `star()`, `epsilon()`) inside `star()`, `plus()`, or `starSeparated()`.
- **Avoid `&` and `|`**: Always use typed sequences (`seq2`..`seq9`) and `toChoiceParser()`.
- **Avoid List Indexing**: Never unpack sequences with `values[0]` and runtime casts, or unpack records with `values.$0`; use `map2`..`map9`.
