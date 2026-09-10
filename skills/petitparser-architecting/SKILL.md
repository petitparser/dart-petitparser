---
name: petitparser-architecting
description: Organizes grammars into maintainable, scalable, and modular architectures using GrammarDefinition and Dart mixins, building typed AST hierarchies, handling expressions, whitespace, comments, parameterized rules, and stateful parsing.
---

# Grammar Architecture & Modularization

## Trigger Conditions

- Transitioning from standalone combinator scripts to production-grade, maintainable grammars.
- Architecting non-trivial language grammars (e.g. Python, Dart, SQL) with multiple syntactic domains.
- Constructing strongly-typed AST node hierarchies with sealed classes.
- Managing operator precedence, associativity, and grouping via `ExpressionBuilder`.
- Centralizing lexical whitespace and comment handling across all rules.
- Handling stateful parsing constraints (e.g. indentation levels, bracket nesting).
- Parameterizing grammar rules (`ref1`, `ref2`).

## `GrammarDefinition` Lifecycle

- Subclass `GrammarDefinition<R>` where each grammatical production is a zero-argument method returning `Parser<T>`.
- Use `ref0(production)` to reference a zero-argument production.
- Use `ref1(production, arg)` to reference a 1-argument parameterized production.
- Use `ref2(production, arg1, arg2)` to reference a 2-argument parameterized production.
- Define `start()` returning the root entry rule anchored with `.end()`.
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

### Obsolete Anti-Pattern: Two-Tier Grammar Inheritance

Historically, grammars were split into an untyped base grammar (e.g., `DartGrammarDefinition`) and a parser subclass overriding methods with AST mappers (e.g., `DartParserDefinition extends DartGrammarDefinition`).

**Do not use this two-tier inheritance pattern**:

- Overriding methods in subclasses with different return types breaks Dart's strict typing.
- Leads to untyped `Parser<dynamic>` everywhere and brittle list index casts (`values[0] as String`).
- Instead, build the strongly-typed AST directly within the grammar definition, and split large grammars horizontally using mixins.

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

### Stateful Parsing & Side Effects

When grammar rules depend on external context (e.g. Python indentation stacks, bracket nesting counters):

- Use `hasSideEffects: true` when performing state mutations inside `.map()` or `.map2()`.
- Encapsulate scoped transitions via combinators:

```dart
class IndentState {
  int bracketNesting = 0;

  /// Temporarily increments bracket nesting so newlines are ignored inside delimiters.
  Parser<R> ignore<R>(Parser<R> parser) => seq3(
    epsilon().map((_) => bracketNesting++, hasSideEffects: true),
    parser,
    epsilon().map((_) => bracketNesting--, hasSideEffects: true),
  ).map3((_, body, _) => body);
}
```

### AST Construction with Sealed Hierarchies

Structure syntax trees using Dart 3 sealed class hierarchies:

```dart
sealed class ASTNode {
  const ASTNode();
}

sealed class StatementNode extends ASTNode {
  const StatementNode();
}

class ReturnNode extends StatementNode {
  const ReturnNode(this.expression);
  final ExpressionNode? expression;
}

class VariableDeclarationNode extends StatementNode {
  const VariableDeclarationNode({required this.name, required this.initializer});
  final String name;
  final ExpressionNode initializer;
}
```

## Critical Heuristics & Anti-Patterns

- **Agnostic Syntax Rules**: Keep grammar productions focused strictly on parsing and AST creation. Avoid embedding evaluation, execution, or UI formatting directly in the grammar.
- **Strictly Typed Sequences**: Use `seq2`..`seq9` with `map2`..`map9`. Avoid dynamic list index extraction (`values[0]`).
- **Always Anchor Entry**: Ensure `start()` terminates with `.end()` to reject partial matches.
- **Isolated Sub-rule Testing**: Design rules so they can be individually built and tested with `buildFrom(ref0(rule))` before integrating into the full grammar.
