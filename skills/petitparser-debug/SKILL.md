---
name: petitparser-debug
description: Identifies, diagnoses, and remediates parser failures, infinite execution loops, stack overflows, and subtle PEG grammar design flaws using tracing, profiling, and minimal reproduction workflows.
---

# Diagnostics & Debugging

## Trigger Conditions

- Parser throws `StackOverflowError` during initialization or execution.
- Execution hangs or enters an infinite loop on specific input strings.
- Valid input unexpectedly yields `Failure`, or error positions report unintuitive offsets.
- Diagnosing grammar performance bottlenecks or heavily backtracking rules.

## Execution Tracing with `trace()`

Import `package:petitparser/debug.dart` to trace parser execution:

```dart
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';

final parser = seq2(letter(), word().starString());
trace(parser).parse('f1');
```

Output visualization:

```text
SequenceParser2<String, String>
  SingleCharacterParser[letter expected]
  Success<String>[1:2]: f
  RepeatingCharacterParser[letter or digit expected, 0..*]
  Success<String>[1:3]: 1
Success<(String, String)>[1:3]: (f, 1)
```

- Indentation indicates activating/entering a parser combinator.
- Dedentation indicates exiting with `Success` or `Failure`.
- Use the `predicate` parameter to filter low-level parsers: `trace(parser, predicate: (p) => p is! CharacterParser).parse(input)`.

### Profiling and Progress Tracking

- **`profile(parser)`**:
  - Counts invocations, successes, failures, and elapsed execution time for every parser in the graph.
  - Pinpoints catastrophic backtracking hotspots.

  ```dart
  import 'package:petitparser/debug.dart';

  final profiled = profile(rootParser);
  profiled.parse(largeSource);
  ```

- **`progress(parser)`**:
  - Visualizes parsing progress and high-water mark position through the input stream.

### Failure Diagnostics & Coordinate Mapping

When a parse returns `Failure`:

- `failure.position`: 0-based character offset where the parser failed.
- `failure.message`: Descriptive reason for the failure.
- Convert character offset to 1-based line and column:

  ```dart
  final [line, column] = Token.lineAndColumnOf(input, failure.position);
  print('Failed at $line:$column: ${failure.message}');
  ```

- **Furthest Position Analysis**: In alternatives (`[a, b, c].toChoiceParser()`), the parser that progressed furthest into the input often pinpoints the real syntax mistake.

### Zero-Width Repetition Loops (Nullable Repeaters)

A major cause of execution hangs is wrapping a zero-width (nullable) matcher inside a repetition combinator (`star`, `plus`, `repeat`):

```dart
// BUG: Non-terminating loop! optional() matches "" with 0 characters consumed.
final badOptional = char('a').optional().star();

// BUG: Nested repetition! star() matches 0 characters on empty input, looping forever.
final badNested = char('a').star().plus();

// BUG: Lookahead predicate! and() succeeds without consuming any characters.
final badLookahead = char('a').and().star();
```

**Resolution**: Ensure that the repeated matcher strictly guarantees positive character consumption ($\ge 1$ character):

```dart
// FIXED:
final good1 = char('a').star(); // 0 or more characters directly
final good2 = char('a').plus(); // 1 or more characters directly
```

### Left-Recursion Elimination

PEG parsers are top-down recursive descent and cannot handle left-recursive rules directly.

#### Direct Left-Recursion

```dart
// BUG: Infinite call stack!
Parser<Expr> expr() => seq3(ref0(expr), char('+'), ref0(term)).map3(...);

// FIXED: Refactor to separated repetition:
Parser<Expr> expr() => ref0(term).plusSeparated(char('+')).map((list) => ...);
```

Alternatively, use `ExpressionBuilder` for operator expressions (see `petitparser-architecting`).

#### Indirect Left-Recursion

Rule `A` calls `B`, and `B` calls `A` without consuming input (`A -> B; B -> A`). Run the PetitParser linter (`linter(grammar.build())`) to statically detect indirect left-recursive cycles before execution.

### Minimal Reproduction Workflow

1. **Extract to Unit Test**: When a full file fails to parse, copy the failing snippet into a test case.
2. **Binary Reduction**: Delete lines iteratively until the failure isolates to 1-2 lines.
3. **Dual Pair**: Create a passing example and failing example differing by a single token.
4. **Trace Execution**: Apply `trace(production)` to observe the exact combinator branch where parsing diverged.
5. **Fix & Verify**: Fix the rule, re-run the minimal pair test, and only then evaluate against the full codebase.

## Critical Heuristics & Anti-Patterns

- **Trace Before Refactoring**: Never speculate on why a rule failed; run `trace()` on minimal input to inspect actual parser decisions.
- **Guarantee Loop Consumption**: Always verify that every rule passed to `star()` or `plus()` strictly consumes $\ge 1$ character on success.
- **Check Furthest Offset**: When a choice fails, inspect the alternative that achieved the greatest parse position offset to find the real syntax error.
