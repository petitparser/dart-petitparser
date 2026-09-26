---
name: petitparser-architecting
description: Organizes grammars into maintainable, scalable, and modular architectures using GrammarDefinition and Dart mixins, building typed AST hierarchies, handling expressions, whitespace, comments, parameterized rules, and stateful parsing.
---

# Grammar Architecture & Modularization

## Trigger Conditions

- Transitioning from standalone combinator scripts to production-grade, maintainable grammars.
- Architecting non-trivial language grammars (e.g. Python, Dart, SQL) with multiple syntactic domains.
- Constructing strongly-typed AST node hierarchies with sealed classes or domain models.
- Managing operator precedence, associativity, and grouping via `ExpressionBuilder`.
- Centralizing lexical whitespace and comment handling across all rules.
- Handling stateful parsing constraints (e.g. indentation levels, bracket nesting).
- Parameterizing grammar rules (`ref1`, `ref2`).

## Architectural Choice: `GrammarDefinition` vs. Standalone Combinators

Choose the architecture that matches the grammar's complexity:

- **Standalone Top-Level Combinators**:
  - Recommended for non-recursive or simple micro-syntaxes (e.g., URI/URL parsing, arithmetic calculators, CSV/tabular parsers, regex).
  - Lightweight, fast to instantiate, and avoids the boilerplate of `GrammarDefinition` when mutual recursion and sub-rule overrides are unnecessary.
  - Can use `undefined<T>()` and `.set()` for localized single-point recursion when needed.

- **`GrammarDefinition<R>` Subclasses**:
  - Recommended for non-trivial languages, programming language grammars, and complex DSLs with mutually recursive productions.
  - Enables sub-rule testing in isolation via `.buildFrom(ref0(production))`.
  - Supports horizontal decomposition across multiple files using mixins.

## `GrammarDefinition` Lifecycle

- Subclass `GrammarDefinition<R>` where each grammatical production is a method returning `Parser<T>`.
- Use `ref0(production)` to reference a zero-argument production.
- Use `ref1(production, arg)` to reference a 1-argument parameterized production.
- Use `ref2(production, arg1, arg2)` to reference a 2-argument parameterized production.
- Define `start()` returning the root entry rule of type `Parser<R>` (anchored with `.end()` for full-input validation).
- Call `.build()` on the definition instance to resolve mutual references into a runnable parser.
- Call `.buildFrom(ref0(production))` to compile any sub-rule in isolation for unit testing.

```dart
class SimpleGrammarDefinition extends GrammarDefinition<num> {
  @override
  Parser<num> start() => ref0(expression).end();

  Parser<num> expression() => [
    ref0(addition),
    ref0(factor),
  ].toChoiceParser();

  Parser<num> addition() => seq3(
    ref0(factor),
    char('+').trim(),
    ref0(expression),
  ).map3((left, _, right) => left + right);

  Parser<num> factor() => digit().plusString().map(num.parse);
}
```

### Parameterized Production Rules

Use `ref1` and `ref2` to create reusable parameterized grammar templates:

```dart
class TemplatedGrammarDefinition extends GrammarDefinition<List<String>> {
  @override
  Parser<List<String>> start() => ref1(commaList, ref0(identifier)).end();

  Parser<String> identifier() => letter().plusString();

  // Parameterized rule: accepts an element parser and returns a separated sequence of elements
  Parser<List<T>> commaList<T>(Parser<T> element) =>
      element.plusSeparated(char(',').trim()).map((sep) => sep.elements);
}
```

### Single-Tier vs. Obsolete Two-Tier Grammar Inheritance

Historically, grammars were often split into an untyped base grammar (e.g., `DartGrammarDefinition`) and a parser subclass overriding methods with AST mappers (e.g., `DartParserDefinition extends DartGrammarDefinition`).

**Single-tier grammars are always preferred**:

- Overriding methods in subclasses with different return types breaks Dart's strict typing.
- Leads to untyped `Parser<dynamic>` everywhere and brittle list index casts (`values[0] as String`).
- Instead, build strongly-typed AST nodes or values directly within the grammar definition.
- For large grammars, decompose horizontally using Dart mixins rather than vertical inheritance tiers.

### Modularization via Mixins

Decompose large grammars across multiple domain-specific mixin files:

```dart
// 1. Lexical mixin
mixin DartLexicalGrammar on GrammarDefinition<CompilationUnitNode> {
  Parser<void> hiddenWhitespace() => pattern(' \t\r\n').plus();
  Parser<Token<String>> keyword(String name) =>
      seq2(string(name), pattern('a-zA-Z0-9_').not())
          .flatten(message: '$name expected')
          .token()
          .trim();
}

// 2. Statement mixin
mixin DartStatementGrammar on GrammarDefinition<CompilationUnitNode>, DartLexicalGrammar {
  Parser<StatementNode> statement() => [
    ref0(returnStatement),
    ref0(expressionStatement),
  ].toChoiceParser();

  Parser<ReturnNode> returnStatement() => seq3(
    ref1(keyword, 'return'),
    ref0(expression).optional(),
    char(';').trim(),
  ).map3((_, expr, _) => ReturnNode(expr));

  Parser<ExpressionNode> expression(); // Abstract reference satisfied by expression mixin
  Parser<StatementNode> expressionStatement();
}

// 3. Composed definition
class DartGrammarDefinition extends GrammarDefinition<CompilationUnitNode>
    with DartLexicalGrammar, DartStatementGrammar, DartExpressionGrammar {
  @override
  Parser<CompilationUnitNode> start() => ref0(compilationUnit).end();
}
```

### Whitespace, Comments, and Token Processing

Centralize lexical trivia (whitespace, comments, line continuations) to keep grammatical rules clean:

```dart
mixin LexicalSyntax on GrammarDefinition<ASTNode> {
  /// Defines all non-semantic trivia.
  Parser<void> hiddenWhitespace() => [
    pattern(' \t\r\n').plus(),  // whitespaces
    seq2(char('#'), pattern('^\r\n').star()),  // single-line comment
  ].toChoiceParser();

  /// Standard token helper: wraps input parser in a Token and trims trivia.
  Parser<Token<T>> token<T>(Object input) => switch (input) {
    final Parser<T> parser => parser.token().trim(ref0(hiddenWhitespace)),
    final String literal => token(string(literal)),
    _ => throw ArgumentError.value(input, 'input', 'Unsupported token source'),
  };

  /// Keyword helper ensuring identifier boundary via negative lookahead.
  Parser<Token<String>> keyword(String value) => token(
    seq2(string(value), pattern('a-zA-Z0-9_').not()).flatten(message: '$value expected'),
  );
}
```

### Expression Parsing with `ExpressionBuilder<T>`

Use `ExpressionBuilder<T>` inside grammar definitions to handle complex operator precedence, associativity, and parentheses without manual left-recursion refactoring:

```dart
Parser<ExpressionNode> expression() {
  final builder = ExpressionBuilder<ExpressionNode>();

  // 1. Primitive atom terms
  builder.primitive(ref0(atomicExpression));

  // 2. Parentheses / Grouping wrappers (defined on an operator group)
  builder.group().wrapper(
    char('(').trim(),
    char(')').trim(),
    (left, value, right) => GroupExpressionNode(value),
  );

  // 3. Operator tiers: highest binding power to lowest
  builder.group()
    ..prefix(char('-').trim(), (op, value) => NegateNode(value))
    ..prefix(char('!').trim(), (op, value) => NotNode(value));

  builder.group()
    ..left(char('*').trim(), (left, op, right) => MultiplyNode(left, right))
    ..left(char('/').trim(), (left, op, right) => DivideNode(left, right));

  builder.group()
    ..left(char('+').trim(), (left, op, right) => AddNode(left, right))
    ..left(char('-').trim(), (left, op, right) => SubtractNode(left, right));

  builder.group()
    ..right(char('=').trim(), (left, op, right) => AssignNode(left, right));

  return builder.build();
}
```

**Expression Builder Rules**:

- Operator wrappers (parentheses) are declared on a group: `builder.group().wrapper(open, close, callback)`.
- Always `.trim()` operators inside `builder.group()`.
- Group from highest precedence to lowest precedence.
- Disambiguate overlapping symbols (e.g. prefix `-` vs binary `-`) by placing them in distinct method calls (`prefix` vs `left`).
- To model implicit concatenation/juxtaposition (e.g. in regex or command expressions), use `epsilon()` as an infix operator in a group: `builder.group()..left(epsilon(), (left, _, right) => ConcatNode(left, right));`.

### Avoid Stateful Parsing

Strongly prefer pure, functional parsers without side-effects:

- **Rely on Grammar Structure**: Model nesting (brackets, blocks, scopes) through recursive grammar rules rather than external counters or flags.
- **Synthesize Values Downstream**: Transform and accumulate data via `.map()`, `.mapN()`, or fold combinators instead of mutating external variables during parsing.
- **The `hasSideEffects` Flag**: `map()` and `mapN()` assume callbacks are pure functions without side effects. In fast-path parsing (`fastParseOn()`, used by `accept()` and lookaheads), callbacks are skipped to avoid allocations. If a callback mutates external state, pass `hasSideEffects: true` to prevent fast parsing from skipping it.
- **The Backtracking State Pitfall**: Combinators backtrack by resetting `Context.position`; they cannot automatically roll back external mutable state mutated during a failed speculative choice branch.

#### State Rollback Workaround (Learnings from `Indent`)

If external state is strictly unavoidable (as in [`Indent`](package:petitparser/indent.dart)):

1. **Never use naive symmetric sequences**: `seq3(before, body, after)` leaves state corrupted when `body` fails because `after` is never reached.
2. **Encapsulate rollback in a choice**: Wrap `body` in a `ChoiceParser` with `failureJoiner: selectFirst` so the fallback alternative runs `after` and fails with the original error:

```dart
Parser<R> scoped<R>(Parser<void> before, Parser<R> body, Parser<void> after) =>
    [body, failure<R>().skip(before: after)]
        .toChoiceParser(failureJoiner: selectFirst)
        .skip(before: before, after: after);
```

- **Success**: `body` matches; trailing `after` performs normal exit cleanup.
- **Failure**: Choice executes `failure<R>().skip(before: after)`, restoring state via `after` while `selectFirst` preserves the original error position and message from `body`.

In [`Indent`](package:petitparser/indent.dart), this pattern is built directly into [`Indent.during`]. Combine `indent.same` to verify line indentation and `indent.during` to scope indented blocks.

### Direct Value Synthesis vs. AST Construction

Choose the result model that directly matches your application goal:

#### 1. Direct Value Synthesis (Transformations & Evaluators)

When transforming input, evaluating calculations, or deserializing data, bypass intermediate AST trees:

- **String Transformations**: Emit transformed strings or string buffers directly (e.g. Markdown to HTML, query rewriting).
- **Computations & Evaluators**: Calculate primitive results (`num`, `bool`) during parsing using `.map()` (e.g. arithmetic calculators, boolean evaluators).
- **Direct Deserialization**: Build native `List`, `Map`, or typed config models directly (e.g. JSON, CSV).
- **Lightweight Records**: Group related outputs into Dart records (`(key: k, value: v)`) to preserve type safety without boilerplate node classes.

Eliminates intermediate memory allocations and avoids a redundant post-parse tree-walking pass.

#### 2. Abstract Syntax Tree (AST) Hierarchies (Tooling & Compilers)

Construct formal AST hierarchies only when required by multi-pass pipelines or source tooling:

- **Multi-Pass Pipelines**: Compilers and static analyzers requiring type checking, optimization, or code generation.
- **Source Tooling**: Language servers, formatters, and linters that inspect syntax structure and need coordinate navigation.

When ASTs are required, match the architecture to the language:

1. **Sealed Class Hierarchies**: Recommended for formal languages and compilers with closed sets of grammar productions to allow exhaustive Dart 3 switch expressions.
2. **Dynamic / S-Expression Models**: For homoiconic languages (like Lisp/Scheme), dynamic representation using `Cons`, `Name`, primitives, and lists is idiomatic and preferred over forced sealed hierarchies.
3. **Independent Domain Classes**: For grammars producing relational or declarative structures (like Prolog `Database`, `Rule`, `Term`), separate domain classes without a shared root interface are completely appropriate.
4. **Visitor-Based Open Hierarchies**: Ideal when downstream consumers need to extend AST processing with polymorphic visitors without modifying node classes.

#### AST Source Position Tracking & Equality

When AST nodes must track source coordinates for syntax highlighters, linters, or language servers:

- Define optional `final int? start, stop;` (or `final Token? token;`) on the base AST node class.
- Prefer `const` constructors on AST nodes where possible (`const Node({this.start, this.stop, ...})`).
- **Exclude source positions from `operator ==` and `hashCode`**: Compare only semantic and structural payload fields in equality checks. This allows clean, deterministic test assertions (`expect(node, LiteralNode(42))`) without requiring exact token offset coordinates in test expectations.

### Handling Semantic Validation & Evaluation Errors

Depending on the application context, choose the appropriate error strategy:

1. **Throwing Exceptions in Actions**:
   - Valid for self-evaluating calculators or CLI tools where the caller catches and reports errors.
   - Example: throwing `ArgumentError` or `FormatException` on unknown operators or arithmetic errors.
2. **Backtracking via `.where()`**:
   - Valid when semantic invalidity should be treated as a standard parse failure.
   - Example: `parser.where((val) => isValidIdentifier(val), message: 'reserved keyword cannot be identifier')`. Allows the parser to backtrack and attempt alternative choice branches.
3. **Deferred / Unresolved AST Nodes**:
   - Valid in multi-pass compilers and analyzers.
   - Construct placeholder nodes (e.g. `UnresolvedFunctionNode`, `ErrorNode`) so syntax parsing completes successfully, deferring diagnostics to a dedicated semantic analysis pass.

## Critical Heuristics & Anti-Patterns

- **Single-Tier Strongly-Typed Grammars**: Construct strongly typed ASTs directly in production methods; avoid untyped two-tier inheritance.
- **Strictly Typed Sequences**: Use `seq2`..`seq9` with `map2`..`map9`; avoid dynamic list index extraction (`values[0]`).
- **Anchoring Entrypoints**: Anchor top-level entrypoints with `.end()` when verifying complete input consumption. Omit `.end()` intentionally for prefix scanning or substring extraction.
- **Isolated Sub-rule Testing**: Design rules so they can be individually built and tested with `buildFrom(ref0(rule))` before integrating into the full grammar.
