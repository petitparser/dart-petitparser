PetitParser for Dart
====================

Grammars for programming languages are traditionally specified statically. They are hard to compose and reuse due to ambiguities that inevitably arise. PetitParser combines ideas from scannnerless parsing, parser combinators, parsing expression grammars and packrat parsers to model grammars and parsers as objects that can be reconfigured dynamically.

This library is open source, stable and well tested. Development happens on [GitHub](https://github.com/renggli/dart-petitparser). Feel free to report issues or create a pull-request there. General questions are best asked on [StackOverflow](http://stackoverflow.com/questions/tagged/petitparser).

Continuous build results are available from [Jenkins](http://jenkins.lukas-renggli.ch/job/dart-petitparser). An introductionary tutorial is part of the [class documentation](http://jenkins.lukas-renggli.ch/job/dart-petitparser/javadoc).


Basic Usage
-----------

### Installation

Add the dependency to your package's pubspec.yaml file:

    dependencies:
      petitparser: ">=1.0.0 <2.0.0"

Then on the command line run:

    $ pub get

To PetitParser in your Dart code write:

    import 'package:petitparser/petitparser.dart';

### Examples

The package comes with a large collections of grammars and language experiments ready to explore:

- `lib/dart.dart` contains an experimental Dart grammar.
- `lib/json.dart` contains a complete JSON grammar and parser.
- `lib/lisp.dart` contains a complete Lisp grammar, parser and evaluator:
- `example/lisphell` contains a command line lisp interpreter.
  - `example/lispweb` contains a web based lisp interpreter.
  - `lib/smalltalk.dart` contains a complete Smalltalk grammar.

Furthermore, there are various open source projects using PetitParser:

- [dart-xml](https://github.com/renggli/dart-xml) is a lightweight library for parsing, traversing, and querying XML documents.
- [Haml.dart](https://github.com/kevmoo/haml.dart) is an implementation of Haml in Dart.
- [RythmDart](https://github.com/freewind/RythmDart) is a rich featured, high performance template engine.
- [SharkDart](https://github.com/freewind/SharkDart) is a small template engine.


Misc
----

### History

PetitParser was originally implemented in [Smalltalk](http://scg.unibe.ch/research/helvetia/petitparser). Later on, as a mean to learn these languages, I reimplemented PetitParser in [Java](https://github.com/renggli/PetitParserJava) and [Dart](https://github.com/renggli/PetitParserDart). The implementations are very similar in their API and the supported features. If possible, the implementations adopt best practises of the target language.

### Ports

- [Java](https://github.com/renggli/PetitParserJava)
- [PHP](https://github.com/mindplay-dk/petitparserphp)
- [Smalltalk](http://scg.unibe.ch/research/helvetia/petitparser)

### License

The MIT License, see [LICENSE](LICENSE).
