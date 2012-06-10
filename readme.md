PetitParser
===========

Grammars for programming languages are traditionally specified statically. They are hard to compose and reuse due to ambiguities that inevitably arise. PetitParser combines ideas from scannerless parsing, parser combinators, parsing expression grammars and packrat parsers to model grammars and parsers as objects that can be reconfigured dynamically.

Tasks
-----
* Get rid of the global functions creating `PredicateParser` instances.
* Use constructor initializiers in `PredicateParser` as soon as Dart allows functions in constructor initializers.
* Use character predicates in `PredicateParser` as soon as Dart provides them in the standard library.
* Figure out why #import('dart:unittest') does not work.
* Needs to patch Expectation.equals to make the test framework compare lists correctly (http://code.google.com/p/dart/issues/detail?id=3274)

Need to find workarounds for the following problems in Reflection.dart:
* Copying objects is not easily possible (http://code.google.com/p/dart/issues/detail?id=3367)
* hashCode() based on the object identity is not available (http://code.google.com/p/dart/issues/detail?id=3369)