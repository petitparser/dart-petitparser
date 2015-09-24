PetitParser for Dart
====================

[![Pub Package](https://img.shields.io/pub/v/petitparser.svg)](https://pub.dartlang.org/packages/petitparser)
[![Build Status](https://travis-ci.org/petitparser/dart-petitparser.svg)](https://travis-ci.org/petitparser/dart-petitparser)
[![Coverage Status](https://coveralls.io/repos/petitparser/dart-petitparser/badge.svg)](https://coveralls.io/r/petitparser/dart-petitparser)
[![Github Issues](http://githubbadges.herokuapp.com/petitparser/dart-petitparser/issues.svg)](https://github.com/petitparser/dart-petitparser/issues)
[![Gitter chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/petitparser/dart-petitparser)

Grammars for programming languages are traditionally specified statically. They are hard to compose and reuse due to ambiguities that inevitably arise. PetitParser combines ideas from scannnerless parsing, parser combinators, parsing expression grammars and packrat parsers to model grammars and parsers as objects that can be reconfigured dynamically.

This library is open source, stable and well tested. Development happens on [GitHub](https://github.com/petitparser/dart-petitparser). Feel free to report issues or create a pull-request there. General questions are best asked on [StackOverflow](http://stackoverflow.com/questions/tagged/petitparser+dart).

Up-to-date [class documentation](http://www.dartdocs.org/documentation/petitparser/latest/index.html) is created with every release.


Tutorial
--------

### Writing a Simple Grammar

Writing grammars with PetitParser is simple as writing Dart code. For example, to write a grammar that can parse identifiers that start with a letter followed by zero or more letter or digits is defined as follows:

```dart
Parser id = letter() & (letter() | digit()).star();
```

If you look at the object `id` in the debugger, you'll notice that the code above builds a tree of parser objects:

- Sequence: This parser accepts a sequence of parsers.
  - Predicate: This parser accepts a single letter.
  - Repeater: This parser accepts zero or more times another parser.
    - Choice: This parser accepts a single word character.
      - Predicate: This parser accepts a single letter.
      - Predicate: This parser accepts a single digit.

The operators `&` and `|` are overloaded and create a sequence and a choice parser respectively. In some contexts it might be more convenient to use chained function calls:

```dart
Parser id = letter().seq(letter().or(digit()).star());
```

### Parsing Some Input

To actually parse a `String` (or `List`) we can use the method `Parser.parse`:

```dart
Result id1 = id.parse('yeah');
Result id2 = id.parse('f12');
```

The method `Parser.parse` returns a parse `Result`, which is either an instance of `Success` or `Failure`. In both examples above we are successful and can retrieve the parse result using `Success.value`:

```dart
print(id1.value);                   // ['y', ['e', 'a', 'h']]
print(id2.value);                   // ['f', ['1', '2']]
```

While it seems odd to get these nested arrays with characters as a return value, this is the default decomposition of the input into a parse tree. We'll see in a while how that can be customized.

If we try to parse something invalid we get an instance of `Failure` as an answer and we can retrieve a descriptive error message using `Failure.message`:

```dart
Result id3 = id.parse('123');
print(id3.message);                 // 'letter expected'
print(id3.position);                // 0
```

Trying to retrieve the parse result by calling `Failure.value` would throw the exception `ParserError`. `Context.isSuccess` and `Context.isFailure` can be used to decide if the parse was successful.

If you are only interested if a given string matches or not you can use the helper method `Parser.accept`:

```dart
print(id.accept('foo'));            // true
print(id.accept('123'));            // false
```

### Different Kinds of Parsers

PetitParser provide a large set of ready-made parser that you can compose to consume and transform arbitrarily complex languages. The terminal parsers are the most simple ones. We've already seen a few of those:

- `char('a')` parses the character *a*.
- `string('abc')` parses the string *abc*.
- `any()` parses any character.
- `digit()` parses any digit from *0* to *9*.
- `letter()` parses any letter from *a* to *z* and *A* to *Z*.
- `word()` parses any letter or digit.

So instead of using the letter and digit predicate, we could have written our identifier parser like this:

```dart
var id = letter() & word().star();
```

The next set of parsers are used to combine other parsers together:

- `p1 & p2` and `p1.seq(p2)` parse *p1* followed by *p2* (sequence).
- `p1 | p2` and `p1.or(p2)` parse *p1*, if that doesn't work parse *p2* (ordered choice).
- `p.star()` parses *p* zero or more times.
- `p.plus()` parses *p* one or more times.
- `p.optional()` parses *p*, if possible.
- `p.and()` parses *p*, but does not consume its input.
- `p.not()` parses *p* and succeed when p fails, but does not consume its input.
- `p.end()` parses *p* and succeed at the end of the input.

To attach an action or transformation to a parser we can use the following methods:

- `p.map((value) => ...)` performs the transformation given the function.
- `p.pick(n)` returns the *n*-th element of the list *p* returns.
- `p.flatten()` creates a string from the result of *p*.
- `p.token()` creates a token from the result of *p*.
- `p.trim()` trims whitespaces before and after *p*.

To return a string of the parsed identifier, we can modify our parser like this:

```dart
var id = letter().seq(word().star()).flatten();
```

To conveniently find all matches in a given input string you can use `Parser.matchesSkipping`:

```dart
var matches = id.matchesSkipping('foo 123 bar4');
print(matches);                     // ['foo', 'bar4']
```

These are the basic elements to build parsers. There are a few more well documented and tested factory methods in the `Parser` class. If you want browse their documentation and tests.

### Writing a More Complicated Grammar

Now we are able to write a more complicated grammar for evaluating simple
arithmetic expressions. Within a file we start with the grammar for a
number (actually an integer):

```dart
var number = digit().plus().flatten().trim().map(int.parse);
```

Then we define the productions for addition and multiplication in order of precedence. Note that we instantiate the productions with undefined parsers upfront, because they recursively refer to each other. Later on we can resolve this recursion by setting their reference:

```dart
var term = undefined();
var prod = undefined();
var prim = undefined();

term.set(prod.seq(char('+').trim()).seq(term).map((values) {
  return values[0] + values[2];
}).or(prod));
prod.set(prim.seq(char('*').trim()).seq(prod).map((values) {
  return values[0] * values[2];
}).or(prim));
prim.set(char('(').trim().seq(term).seq(char(')'.trim())).map((values) {
  return values[1];
}).or(number));
```

To make sure that our parser consumes all input we wrap it with the `end()` parser into the start production:

```dart
var start = term.end();
```

That's it, now we can test our parser and evaluator:

```dart
print(start.parse('1 + 2 * 3').value);        // 7
print(start.parse('(1 + 2) * 3').value);      // 9
```

As an exercise we could extend the parser to also accept negative numbers and floating point numbers, not only integers. Furthermore it would be useful to support subtraction and division as well. All these features can be added with a few lines of PetitParser code.


Misc
----

### Examples

The package comes with a large collections of grammars and language experiments ready to explore:

- `lib/dart.dart` contains an experimental Dart grammar.
- `lib/json.dart` contains a complete JSON grammar and parser.
- `lib/lisp.dart` contains a complete Lisp grammar, parser and evaluator:
- `example/lisphell` contains a command line lisp interpreter.
  - `example/lispweb` contains a web based lisp interpreter.
  - `lib/smalltalk.dart` contains a complete Smalltalk grammar.

Furthermore, there are various open source projects using PetitParser:

- [Badger](https://github.com/badger-lang/badger) is an experimental programming language.
- [dart-xml](https://github.com/renggli/dart-xml) is a lightweight library for parsing, traversing, and querying XML documents.
- [InQlik](https://github.com/inqlik/inqlik_cli) is a parser for QlikView load script files.
- [intl](https://github.com/dart-lang/intl) provides internationalization and localization support to Dart.
- [PowerConfig](https://github.com/kaendfinger/powerconfig.dart) is a power config implementation.
- [RythmDart](https://github.com/freewind/RythmDart) is a rich featured, high performance template engine.
- [SharkDart](https://github.com/freewind/SharkDart) is a small template engine.

### History

PetitParser was originally implemented in [Smalltalk](http://scg.unibe.ch/research/helvetia/petitparser). Later on, as a mean to learn these languages, I reimplemented PetitParser in [Java](https://github.com/petitparser/java-petitparser) and [Dart](https://github.com/petitparser/dart-petitparser). The implementations are very similar in their API and the supported features. If possible, the implementations adopt best practises of the target language.

### Ports

- [Java](https://github.com/petitparser/java-petitparser)
- [PHP](https://github.com/mindplay-dk/petitparserphp)
- [Smalltalk](http://scg.unibe.ch/research/helvetia/petitparser)
- [TypeScript](https://github.com/mindplay-dk/petitparser-ts)

### License

The MIT License, see [LICENSE](https://raw.githubusercontent.com/petitparser/dart-petitparser/master/LICENSE).
