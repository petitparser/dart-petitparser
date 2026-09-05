# PetitParser for Dart

[![Pub Package](https://img.shields.io/pub/v/petitparser.svg)](https://pub.dev/packages/petitparser)
[![Build Status](https://github.com/petitparser/dart-petitparser/actions/workflows/dart.yml/badge.svg?branch=main)](https://github.com/petitparser/dart-petitparser/actions)
[![Code Coverage](https://codecov.io/gh/petitparser/dart-petitparser/branch/main/graph/badge.svg?token=2yW74MVgun)](https://codecov.io/gh/petitparser/dart-petitparser)
[![GitHub Issues](https://img.shields.io/github/issues/petitparser/dart-petitparser.svg)](https://github.com/petitparser/dart-petitparser/issues)
[![GitHub Forks](https://img.shields.io/github/forks/petitparser/dart-petitparser.svg)](https://github.com/petitparser/dart-petitparser/network)
[![GitHub Stars](https://img.shields.io/github/stars/petitparser/dart-petitparser.svg)](https://github.com/petitparser/dart-petitparser/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/petitparser/dart-petitparser/main/LICENSE)

PetitParser makes writing parsers in Dart fast, enjoyable, and fully type-safe.

Instead of writing fragile regular expressions or configuring complex external code generators, PetitParser lets you build parsers directly in plain Dart code. You assemble small, specialized parsers like LEGO bricks to model everything from simple configuration values to full programming languages.

## ✨ Why PetitParser?

- 🧩 **Composable**: Combine simple parsers into rich grammars using familiar operators and methods.
- 🛡️ **Type-Safe**: Take advantage of modern Dart records, generics, and pattern matching without casting dynamic types.
- ⚡ **Fast & Efficient**: Optimized character predicates and dedicated fast-path parsing keep execution blazing fast.
- 🔍 **Debuggable**: Step through parsing in your IDE, inspect tokens, and visualize execution trees with built-in tools.
- 🛠️ **Extensible**: Transform raw text directly into strongly typed models, syntax trees, or domain objects on the fly.
- 🌐 **Open Source & Battle-Tested**: Highly tested, well-documented, and trusted across production Dart and Flutter applications.

## 🚀 Quick Start

Add PetitParser to your Dart or Flutter project:

```bash
dart pub add petitparser
```

Import the package, assemble your parser, and parse key-value pairs:

```dart
import 'package:petitparser/petitparser.dart';

void main() {
  // 1. Match a key of one or more letters:
  final key = letter().plus().flatten();

  // 2. Match a numeric value and convert it directly into an integer:
  final value = digit().plus().flatten().map(int.parse);

  // 3. Combine them: match key, discard '=', and match value:
  final entry = key.trim().skip(after: char('=')).then(value.trim());

  // 4. Transform the parsed pair into a typed Dart record:
  final parser = entry.map2((k, v) => (key: k, value: v));

  // 5. Parse the input:
  final result = parser.parse('port = 8080');

  print(result.value); // (key: port, value: 8080)
}
```

Notice what happened here:

- `letter().plus()` matched consecutive letters, and `.flatten()` turned them into a `String`.
- `digit().plus()` matched consecutive digits, and `.map(int.parse)` transformed them immediately into an `int`.
- `.skip(after: char('='))` consumed the separator without cluttering the result.
- `.then(...)` combined both parts into a strongly typed record `(String, int)`.
- `.map2(...)` mapped both positional values into a readable named record.

## 🧩 Core Building Blocks

Every grammar in PetitParser is constructed from three fundamental concepts: matching text, combining parsers, and transforming results.

### 🔡 Matching Text

Primitive parsers recognize basic character patterns:

- `char('a')` matches an exact single character:

  ```dart
  char('a').parse('a').value; // 'a'
  ```

- `string('dart')` matches an entire string:

  ```dart
  string('dart').parse('dart').value; // 'dart'
  ```

- `digit()` matches any digit from 0 to 9:

  ```dart
  digit().parse('7').value; // '7'
  ```

- `letter()` matches any uppercase or lowercase letter:

  ```dart
  letter().parse('x').value; // 'x'
  ```

- `word()` matches a letter, digit, or underscore:

  ```dart
  word().parse('_').value; // '_'
  ```

- `whitespace()` matches spaces, tabs, and newlines:

  ```dart
  whitespace().parse(' ').value; // ' '
  ```

- `pattern('0-9a-fA-F')` matches any character within a range:

  ```dart
  pattern('0-9a-fA-F').parse('f').value; // 'f'
  ```

- `any()` matches any character:

  ```dart
  any().parse('!').value; // '!'
  ```

Most character parsers accept optional parameters such as `ignoreCase: true` for case-insensitive matching and `unicode: true` for full Unicode code-point support.

### 🔗 Combining Parsers

Snap individual parsers together to recognize structured input:

- **Sequences**: Run parsers in order. `letter().then(digit())` returns a typed Dart record with each result:

  ```dart
  letter().then(digit()).parse('a1').value; // ('a', '1')
  ```

- **Choices**: Try options in order until one succeeds. `[letter(), digit()].toChoiceParser()` matches either a letter or a digit:

  ```dart
  [letter(), digit()].toChoiceParser().parse('a').value; // 'a'
  ```

- **Repetition**: Repeat patterns to collect multiple matches into a `List`:
  - `letter().star()` matches zero or more times:

    ```dart
    letter().star().parse('abc').value; // ['a', 'b', 'c']
    ```

  - `digit().plus()` matches one or more times:

    ```dart
    digit().plus().parse('123').value; // ['1', '2', '3']
    ```

  - `char('-').optional()` matches zero or one time, returning null when absent:

    ```dart
    char('-').optional().parse('-').value; // '-'
    char('-').optional().parse('+').value; // null
    ```

  - `letter().times(3)` matches an exact number of occurrences:

    ```dart
    letter().times(3).parse('abc').value; // ['a', 'b', 'c']
    ```

  - `digit().plusSeparated(char(','))` matches items separated by a delimiter:

    ```dart
    digit().plusSeparated(char(',')).parse('1,2,3').value.elements; // ['1', '2', '3']
    ```

### 🎨 Transforming Results

Rather than traversing an untyped syntax tree after the fact, PetitParser lets you transform data while parsing:

- `parser.flatten()` merges matched characters into a single `String`:

  ```dart
  digit().plus().flatten().parse('123').value; // '123'
  ```

- `parser.trim()` discards leading and trailing whitespace around a match:

  ```dart
  string('true').trim().parse('  true  ').value; // 'true'
  ```

- `parser.map(callback)` transforms the parsed value with a custom function:

  ```dart
  digit().plus().flatten().map(int.parse).parse('42').value; // 42
  ```

- `parser.map2(callback)` unpacks a two-element record and passes each value as an argument:

  ```dart
  letter().then(digit()).map2((l, d) => '$l:$d').parse('x9').value; // 'x:9'
  ```

- `parser.map3(callback)` similarly unpacks a three-element record:

  ```dart
  (letter(), char(':'), digit())
      .toSequenceParser()
      .map3((l, sep, d) => '$l$sep$d')
      .parse('a:1')
      .value; // 'a:1'
  ```

## 🎯 Handling Results

Calling `parse` on a string returns a `Result`. You can inspect the outcome using Dart pattern matching:

```dart
final parser = digit().plus().flatten().map(int.parse);

void handleResult(Result<int> result) {
  switch (result) {
    case Success(value: final value):
      print('Parsed $value');
    case Failure(message: final message, position: final position):
      print('Error at $position: $message');
  }
}

handleResult(parser.parse('123')); // Parsed 123
handleResult(parser.parse('abc')); // Error at 0: digit expected
```

If you only need to know whether an input string conforms to your grammar, use `accept`:

```dart
if (parser.accept('123')) {
  print('Valid input');
}
```

To extract all matching occurrences across a larger body of text, use `allMatches`:

```dart
final words = letter().plus().flatten();
final matches = words.allMatches('two words 123');

print(matches); // ('two', 'words')
```

## 🛠️ Practical Examples

### 📋 Delimited Lists

This example parses a comma-separated list of integers like `'1, 2, 3'` into a Dart `List<int>`:

```dart
final number = digit().plus().flatten().map(int.parse);
final numbers = number
    .plusSeparated(char(',').trim())
    .map((list) => list.elements);

final result = numbers.parse('1, 2, 3');
print(result.value); // [1, 2, 3]
```

`list.elements` gives you a typed `List<int>` containing only the parsed numbers, neatly dropping the comma characters.

### 🧮 Expression Builder

This example parses and evaluates mathematical expressions containing numbers, parentheses, negation, exponentiation, multiplication, division, addition, and subtraction:

```dart
import 'dart:math' as math;
import 'package:petitparser/petitparser.dart';

final builder = ExpressionBuilder<num>();

// Define primitives like floating-point or integer numbers:
builder.primitive(
  digit()
      .plus()
      .then(char('.').then(digit().plus()).optional())
      .flatten()
      .trim()
      .map(num.parse),
);

// Add parentheses with highest priority:
builder.group().wrapper(
  char('(').trim(),
  char(')').trim(),
  (left, value, right) => value,
);

// Add prefix operators:
builder.group().prefix(char('-').trim(), (op, value) => -value);

// Add right-associative power operator:
builder.group().right(
  char('^').trim(),
  (left, op, right) => math.pow(left, right),
);

// Add left-associative multiplication and division:
builder.group()
  ..left(char('*').trim(), (left, op, right) => left * right)
  ..left(char('/').trim(), (left, op, right) => left / right);

// Add left-associative addition and subtraction:
builder.group()
  ..left(char('+').trim(), (left, op, right) => left + right)
  ..left(char('-').trim(), (left, op, right) => left - right);

final parser = builder.build().end();

print(parser.parse('1 + 2 * 3').value);   // 7
print(parser.parse('(1 + 2) * 3').value); // 9
print(parser.parse('2 ^ 2 ^ 3').value);   // 256
print(parser.parse('-8 + 2').value);      // -6
```

### 🌲 Recursive Structures

This example parses nested JSON-style arrays of numbers like `'[1, [2, 3], 4]'` into a hierarchy of Dart lists:

```dart
final value = undefined<Object>();

// An array contains zero or more values separated by commas:
final array = char('[')
    .trim()
    .then(value.starSeparated(char(',').trim()))
    .then(char(']').trim())
    .map3((open, elements, close) => elements.elements);

final number = digit().plus().flatten().map(int.parse);

// Wire the recursive definition into the placeholder:
value.set([number, array].toChoiceParser());

final parser = value.end();

print(parser.parse('[1, [2, 3], 4]').value); // [1, [2, 3], 4]
```

### 🏛️ Large Grammars

When a grammar grows to dozens or hundreds of productions, organizing rules as separate variables can become difficult to maintain. Subclassing `GrammarDefinition` lets you organize rules as methods on a class, resolving complex mutual recursions cleanly.

This example parses and evaluates arithmetic expressions using a modular, strongly typed grammar definition:

```dart
class ExpressionGrammarDefinition extends GrammarDefinition<num> {
  @override
  Parser<num> start() => ref0(term).end();

  Parser<num> term() => [ref0(add), ref0(prod)].toChoiceParser();

  Parser<num> add() => ref0(prod)
      .then(char('+').trim())
      .then(ref0(term))
      .map3((left, _, right) => left + right);

  Parser<num> prod() => [ref0(mul), ref0(prim)].toChoiceParser();

  Parser<num> mul() => ref0(prim)
      .then(char('*').trim())
      .then(ref0(prod))
      .map3((left, _, right) => left * right);

  Parser<num> prim() => [ref0(parens), ref0(number)].toChoiceParser();

  Parser<num> parens() => char('(')
      .trim()
      .then(ref0(term))
      .then(char(')').trim())
      .map3((_, value, _) => value);

  Parser<num> number() => digit().plus().flatten().trim().map(num.parse);
}
```

References between rules use `ref0(rule)` to preserve strong types and resolve mutual dependencies dynamically when building the parser:

```dart
final definition = ExpressionGrammarDefinition();
final parser = definition.build();

print(parser.parse('1 + 2 * 3').value); // 7
print(parser.parse('(1 + 2) * 3').value); // 9
```

You can also build a parser starting from any specific production rule in the grammar using `buildFrom`:

```dart
final numberParser = definition.buildFrom(ref0(definition.number));
print(numberParser.parse('42').value); // 42
```

Organizing grammars this way makes them easy to navigate, refactor, and test production by production in your IDE.

## 🔬 Advanced Capabilities

### 📍 Source Positions and Tokens

If you are writing a compiler, linter, or syntax highlighter, you often need to know exactly where in the source file an element appeared. Wrap any parser with `.token()` to capture its start and stop offsets, line number, and column number:

```dart
final id = letter().plus().flatten().token();
final token = id.parse('hello').value;

print(token.value);  // 'hello'
print(token.start);  // 0
print(token.stop);   // 5
print(token.line);   // 1
print(token.column); // 1
```

### 🔭 Lookaheads and Semantic Guards

You can inspect the upcoming input stream without consuming characters:

- `parser.and()` performs positive lookahead, succeeding only if `parser` matches next without advancing the input position.
- `parser.not()` performs negative lookahead, succeeding only if `parser` fails to match next.
- `parser.where(predicate)` rejects a match dynamically if a condition is not met.

For example, match a keyword like `let` only when it is not immediately followed by more word characters:

```dart
final keyword = string('let').skip(after: word().not());

print(keyword.parse('let').value); // 'let'
print(keyword.accept('letter'));   // false
```

### ⏳ Lazy Repetition

Standard repetition combinators like `star()` are possessive and consume as much input as possible. When matching delimited content like multi-line comments or quoted strings, use `starLazy` or `plusLazy` to stop as soon as a boundary parser succeeds:

```dart
final comment = string('/*')
    .then(any().starLazy(string('*/')).flatten())
    .then(string('*/'))
    .map3((start, body, end) => body);

print(comment.parse('/* note */').value); // ' note '
```

### 🩺 Grammar Linter

Grammars can contain subtle issues such as unreachable branches, infinite loops, or accidental left-recursions. PetitParser provides a built-in linter in `package:petitparser/reflection.dart` that you can run in your tests:

```dart
import 'package:petitparser/reflection.dart';
import 'package:test/test.dart';

test('grammar verification', () {
  final parser = letter().plus();
  expect(linter(parser), isEmpty);
});
```

### ⏱️ Debugging, Tracing, and Profiling

When a parser behaves unexpectedly on a particular input, wrap it with `trace` to see each step it takes:

```dart
final parser = letter().then(digit());
trace(parser).parse('a1');
```

This prints a clear activation tree showing which parsers were called and how they succeeded or failed:

```text
SequenceParser2<String, String>
  SingleCharacterParser[letter expected]
  Success<String>[1:2]: a
  SingleCharacterParser[digit expected]
  Success<String>[1:3]: 1
Success<(String, String)>[1:3]: (a, 1)
```

For performance tuning, import `package:petitparser/debug.dart` and use `profile(parser)` to measure invocation counts and execution time per parser, or `progress(parser)` to inspect backtracking behavior.

## 📚 Resources

- [Website](https://petitparser.github.io/): Interactive web demos and ports to other languages.
- [GitHub Repository](https://github.com/petitparser/dart-petitparser): Source code, discussions, and issue tracker.
- [API Documentation](https://pub.dev/documentation/petitparser/latest/): Detailed class and method reference.
- [Examples Repository](https://github.com/petitparser/dart-petitparser-examples): Full implementations for JSON, Lisp, Math, Smalltalk, and more.

## 📜 History

Grammars for programming languages are traditionally specified statically. They are hard to compose and reuse due to ambiguities that inevitably arise. PetitParser combines ideas from [scannerless parsing](https://en.wikipedia.org/wiki/Scannerless_parsing), [parser combinators](https://en.wikipedia.org/wiki/Parser_combinator), [parsing expression grammars](https://en.wikipedia.org/wiki/Parsing_expression_grammar) (PEG), and packrat parsers to model grammars and parsers as objects that can be reconfigured dynamically.

PetitParser was originally created in [Smalltalk](https://www.lukas-renggli.ch/smalltalk/helvetia/petitparser). Later on, as a way to learn and explore these platforms, I reimplemented PetitParser in [Java](https://github.com/petitparser/java-petitparser) and [Dart](https://github.com/petitparser/dart-petitparser). All implementations share a consistent architecture while adopting the idioms and modern best practices of each target language.

## 📄 License

The MIT License, see [LICENSE](https://raw.githubusercontent.com/petitparser/dart-petitparser/main/LICENSE).
