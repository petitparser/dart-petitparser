library petitparser.example.smalltalk.parser;

import 'package:petitparser/petitparser.dart';

import 'grammar.dart';

/// Smalltalk grammar.
class SmalltalkGrammar extends GrammarParser {
  SmalltalkGrammar() : super(new SmalltalkGrammarDefinition());
}
