PetitParser for Dart
====================

[![Pub Package](https://img.shields.io/pub/v/petitparser.svg)](https://pub.dev/packages/petitparser)
[![Build Status](https://travis-ci.org/petitparser/dart-petitparser.svg)](https://travis-ci.org/petitparser/dart-petitparser)
[![Coverage Status](https://coveralls.io/repos/petitparser/dart-petitparser/badge.svg)](https://coveralls.io/r/petitparser/dart-petitparser)
[![GitHub Issues](https://img.shields.io/github/issues/petitparser/dart-petitparser.svg)](https://github.com/petitparser/dart-petitparser/issues)
[![GitHub Forks](https://img.shields.io/github/forks/petitparser/dart-petitparser.svg)](https://github.com/petitparser/dart-petitparser/network)
[![GitHub Stars](https://img.shields.io/github/stars/petitparser/dart-petitparser.svg)](https://github.com/petitparser/dart-petitparser/stargazers)
[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/petitparser/dart-petitparser/main/LICENSE)

Grammars for programming languages are traditionally specified statically. They are hard to compose and reuse due to ambiguities that inevitably arise. PetitParser combines ideas from [scannnerless parsing](https://en.wikipedia.org/wiki/Scannerless_parsing), [parser combinators](https://en.wikipedia.org/wiki/Parser_combinator), [parsing expression grammars](https://en.wikipedia.org/wiki/Parsing_expression_grammar) (PEG) and packrat parsers to model grammars and parsers as objects that can be reconfigured dynamically.

This library is open source, stable and well tested. Development happens on [GitHub](https://github.com/petitparser/dart-petitparser). Feel free to report issues or create a pull-request there. General questions are best asked on [StackOverflow](https://stackoverflow.com/questions/tagged/petitparser+dart).

The package is hosted on [dart packages](https://pub.dev/packages/petitparser). Up-to-date [API documentation](https://pub.dev/documentation/petitparser/latest/) is created with every release.


Tutorial
--------

Below are step-by-step instructions of how to write your first parser. More elaborate examples (JSON parser, LISP parser and evaluator, Prolog parser and evaluator, etc.) are included in the [example repository](https://github.com/petitparser/dart-petitparser/tree/main/example).

### Installation

Follow the installation instructions on [dart packages](https://pub.dev/packages/petitparser#-installing-tab-).

Import the package into your Dart code using:

```dart
import 'package:petitparser/petitparser.dart';
```

### Writing a Simple Grammar

Writing grammars with PetitParser is as simple as writing Dart code. For example, the following code creates a parser that can read identifiers (a letter followed by zero or more letter or digits):

```dart
final id = letter() & (letter() | digit()).star();
```

If you inspect the object `id` in the debugger, you'll notice that the code above builds a tree of parser objects:

- SequenceParser: This parser accepts a sequence of parsers.
  - CharacterParser: This parser accepts a single letter.
  - PossessiveRepeatingParser: This parser accepts zero or more times another parser.
    - ChoiceParser: This parser accepts a single word character.
      - CharacterParser: This parser accepts a single letter.
      - CharacterParser: This parser accepts a single digit.

The operators `&` and `|` are overloaded and create a sequence and a choice parser respectively. In some contexts it might be more convenient to use chained function calls, or the extension methods on lists. Both of the parsers below are equivalent to the one above:

```dart
final id1 = letter().seq(letter().or(digit()).star());
final id2 = [letter(), [letter(), digit()].toChoiceParser()].toSequenceParser().star();
```

### Parsing Some Input

To actually consume an input string we use the method `Parser.parse`:

```dart
final result1 = id.parse('yeah');
final result2 = id.parse('f12');
```

The method `Parser.parse` returns a `Result`, which is either an instance of `Success` or `Failure`. In both examples  we are successful and can retrieve the resulting value using `Success.value`:

```dart
print(result1.value);                   // ['y', ['e', 'a', 'h']]
print(result2.value);                   // ['f', ['1', '2']]
```

While it seems odd to get these nested arrays with characters as a return value, this is the default decomposition of the input into a parse-tree. We'll see in a while how that can be customized.

If we try to parse something invalid we get an instance of `Failure` and we can retrieve a descriptive error message using `Failure.message`:

```dart
final result3 = id.parse('123');
print(result3.message);                 // 'letter expected'
print(result3.position);                // 0
```

Trying to retrieve result by calling `Failure.value` would throw the exception `ParserError`. `Context.isSuccess` and `Context.isFailure` can be used to decide if the parsing was successful.

If you are only interested if a given string is valid you can use the helper method `Parser.accept`:

```dart
print(id.accept('foo'));                // true
print(id.accept('123'));                // false
```

### Different Kinds of Parsers

PetitParser provides a large set of ready-made parser that you can compose to consume and transform arbitrarily complex languages. Terminal parsers are the simplest. We've already seen a few of those:

- `char('a')` (or `'a'.toParser()`) parses the character *a*.
- `string('abc')` (or `'abc'.toParser()`) parses the string *abc*.
- `pattern('a-f')` (or `'abc'.toParser(isPattern: true)`) parsers any character between _a_ and _f_.
- `any()` parses any character.
- `digit()` parses any digit from *0* to *9*.
- `letter()` parses any letter from *a* to *z* and *A* to *Z*.
- `word()` parses any letter or digit.

So instead of using the letter and digit predicate, we could have written our identifier parser like this:

```dart
final id = letter() & word().star();
```

The next set of parsers are used to combine other parsers together:

- `p1 & p2`, `p1.seq(p2)`, or `[p1, p2].toSequenceParser()` parse *p1* followed by *p2* (sequence).
- `p1 | p2`, `p1.or(p2)`, or `[p1, p2].toChoiceParser()` parse *p1*, if that doesn't work parse *p2* (ordered choice).
- `p.star()` parses *p* zero or more times.
- `p.plus()` parses *p* one or more times.
- `p.optional()` parses *p*, if possible.
- `p.and()` parses *p*, but does not consume its input.
- `p.not()` parses *p* and succeed when p fails, but does not consume its input.
- `p.end()` parses *p* and succeed at the end of the input.

The last type of parsers are actions or transformations we can use as follows:

- `p.map((value) => ...)` performs the transformation using the provided callback.
- `p.pick(n)` returns the *n*-th element of the list *p* returns.
- `p.flatten()` creates a string from the consumed input of *p*.
- `p.token()` creates a token from the result of *p*.
- `p.trim()` trims whitespaces before and after *p*.
- `p.cast<T>()` casts the result of *p* to the type `T`.

To return a string of the parsed identifier, we can modify our parser like this:

```dart
final id = (letter() & word().star()).flatten();
```

To conveniently find all matches in a given input string you can use `Parser.matchesSkipping`:

```dart
final matches = id.matchesSkipping('foo 123 bar4');
print(matches);                         // ['foo', 'bar4']
```

These are the basic elements to build parsers. There are a few more well documented and tested factory methods in the `Parser` class. If you want browse their documentation and tests.

### Writing a More Complicated Grammar

Now we are able to write a more complicated grammar for evaluating simple arithmetic expressions. Within a file we start with the grammar for a number (actually an integer):

```dart
final number = digit().plus().flatten().trim().map(int.parse);
```

Then we define the productions for addition and multiplication in order of precedence. Note that we instantiate the productions with undefined parsers upfront, because they recursively refer to each other. Later on we can resolve this recursion by setting their reference:

```dart
final term = undefined();
final prod = undefined();
final prim = undefined();

final add = (prod & char('+').trim() & term)
    .map((values) => values[0] + values[2]);
term.set(add | prod);

final mul = (prim & char('*').trim() & prod)
    .map((values) => values[0] * values[2]);
prod.set(mul | prim);

final parens = (char('(').trim() & term & char(')').trim())
    .map((values) => values[1]);
final number = digit().plus().flatten().trim().map(int.parse);
prim.set(parens | number);
```

To make sure our parser consumes all input we wrap it with the `end()` parser into the start production:

```dart
final parser = term.end();
```

That's it, now we can test our parser and evaluator:

```dart
parser.parse('1 + 2 * 3');              // 7
parser.parse('(1 + 2) * 3');            // 9
```

### Using the Expression Builder

Writing such expression parsers is pretty common and can be quite tricky to get right. To simplify things, PetitParser comes with a builder that can help you to define such grammars easily. It supports the definition of operator precedence; and prefix, postfix, left- and right-associative operators.

The following code creates the empty expression builder:

```dart
final builder = ExpressionBuilder();
```

Then we define the operator-groups in descending precedence. The highest precedence are the literal numbers themselves. This time we accept floating-point numbers, not just integers. In the same group we add support for the parenthesis:

```dart
builder.group()
  ..primitive(digit()
      .plus()
      .seq(char('.').seq(digit().plus()).optional())
      .flatten()
      .trim()
      .map((a) => num.tryParse(a)))
  ..wrapper(char('(').trim(), char(')').trim(), (String l, num a, String r) => a);
```

Then come the normal arithmetic operators. Note, that the action blocks receive both, the terms and the parsed operator in the order they appear in the parsed input:

```dart
// negation is a prefix operator
builder.group()
  ..prefix(char('-').trim(), (String op, num a) => -a);

// power is right-associative
builder.group()
  ..right(char('^').trim(), (num a, String op, num b) => math.pow(a, b));

// multiplication and addition are left-associative
builder.group()
  ..left(char('*').trim(), (num a, String op, num b) => a * b)
  ..left(char('/').trim(), (num a, String op, num b) => a / b);
builder.group()
  ..left(char('+').trim(), (num a, String op, num b) => a + b)
  ..left(char('-').trim(), (num a, String op, num b) => a - b);
```

Finally, we can build the parser:

```dart
final parser = builder.build().end();
```

After executing the above code we get an efficient parser that correctly
evaluates expressions like:

```dart
parser.parse('-8');                     // -8
parser.parse('1+2*3');                  // 7
parser.parse('1*2+3');                  // 5
parser.parse('8/4/2');                  // 1
parser.parse('2^2^3');                  // 256
```

Misc
----

### Examples

The package comes with a large collection of example grammars and language experiments ready to explore:

- `example/lib/dart` contains an experimental Dart grammar.
- `example/lib/json` contains a complete JSON grammar and parser.
- `example/lib/lisp` contains a complete LISP grammar, parser and evaluator.
- `example/lib/prolog` contains a basic Prolog grammar, parser and evaluator.
- `example/lib/smalltalk` contains a complete Smalltalk grammar.

Furthermore, there are [numerous open source projects](https://pub.dev/packages?q=dependency:petitparser) using PetitParser:

- [badger](https://github.com/badger-lang/badger) is an experimental programming language.
- [expression_language](https://pub.dev/packages/expression_language) is a library for parsing and evaluating expressions.
- [intl_translation](https://pub.dev/packages/intl_translation) provides internationalization and localization support to Dart.
- [pem](https://pub.dev/packages/pem) encodes and decodes textual cryptographic keys.
- [powerconfig](https://github.com/kaendfinger/powerconfig.dart) is a power config implementation.
- [query](https://pub.dev/packages/query) implements search queries with support for boolean groups, field scopes, ranges, etc.
- [rythm](https://github.com/freewind/RythmDart) is a rich featured, high performance template engine.
- [xml](https://pub.dev/packages/xml) is a lightweight library for parsing, traversing, and querying XML documents.

### History

PetitParser was originally implemented in [Smalltalk](https://www.lukas-renggli.ch/smalltalk/helvetia/petitparser). Later on, as a mean to learn these languages, I reimplemented PetitParser in [Java](https://github.com/petitparser/java-petitparser) and [Dart](https://github.com/petitparser/dart-petitparser). The implementations are very similar in their API and the supported features. If possible, the implementations adopt best practises of the target language.

### Implementations

- [Dart](https://github.com/petitparser/dart-petitparser)
- [Java](https://github.com/petitparser/java-petitparser)
- [PHP](https://github.com/mindplay-dk/petitparserphp)
- [Smalltalk](https://www.lukas-renggli.ch/smalltalk/helvetia/petitparser)
- [Swift](https://github.com/philipparndt/swift-petitparser)
- [TypeScript](https://github.com/mindplay-dk/petitparser-ts)

### License

The MIT License, see [LICENSE](https://raw.githubusercontent.com/petitparser/dart-petitparser/main/LICENSE).
