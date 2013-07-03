PetitParser for Dart
====================

Grammars for programming languages are traditionally specified statically. They are hard to compose and reuse due to ambiguities that inevitably arise. PetitParser combines ideas from scannerless parsing, parser combinators, parsing expression grammars and packrat parsers to model grammars and parsers as objects that can be reconfigured dynamically.

The library is open source, stable and well tested. No breaking API changes are expected in the main library. Development happens on [GitHub](https://github.com/renggli/PetitParserDart). Feel free to report issues or create a pull-request there. General questions are best asked on [StackOverflow](http://stackoverflow.com/questions/tagged/petitparser).

Continuous build results are available from [Jenkins](http://jenkins.lukas-renggli.ch/job/PetitParserDart/). An introductionary tutorial is part of the [class documentation](http://jenkins.lukas-renggli.ch/job/PetitParserDart/javadoc/petitparser.html).

The package comes with a large collections of grammars and language experiments ready to explore:

- `lib/dart.dart` contains an experimental Dart grammar.
- `lib/json.dart` contains a complete JSON grammar and parser.
- `lib/lisp.dart` contains a complete Lisp grammar, parser and evaluator:
- `example/lisphell` contains a command line lisp interpreter.
  - `example/lispweb` contains a web based lisp interpreter.
  - `lib/smalltalk.dart` contains a complete Smalltalk grammar.
- `lib/xml.dart` contains a complete XML parser and AST.

PetitParser was originally implemented in [Smalltalk](http://scg.unibe.ch/research/helvetia/petitparser). Later on, as a mean to learn these languages, I reimplemented PetitParser in [Java](https://github.com/renggli/PetitParserJava) and [Dart](https://github.com/renggli/PetitParserDart). The implementations are very similar in their API and the supported features. If possible, the implementations adopt best practises of the target language.