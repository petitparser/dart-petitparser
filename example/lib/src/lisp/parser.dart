library petitparser.example.lisp.parser;

import 'package:example/src/lisp/cons.dart';
import 'package:example/src/lisp/grammar.dart';
import 'package:example/src/lisp/name.dart';
import 'package:petitparser/petitparser.dart';

/// The standard lisp parser definition.
final LispParser lispParser = LispParser();

/// LISP parser.
class LispParser extends GrammarParser {
  LispParser() : super(LispParserDefinition());
}

/// LISP parser definition.
class LispParserDefinition extends LispGrammarDefinition {
  list() => super.list().map((each) => each[1]);

  cell() => super.cell().map((each) => Cons(each[0], each[1]));
  empty() => super.empty().map((each) => null);

  string() =>
      super.string().map((each) => String.fromCharCodes(each[1].cast<int>()));
  characterEscape() =>
      super.characterEscape().map((each) => each[1].codeUnitAt(0));
  characterRaw() => super.characterRaw().map((each) => each.codeUnitAt(0));

  symbol() => super.symbol().map((each) => Name(each));
  number() => super.number().map((each) {
        final floating = double.parse(each);
        final integral = floating.toInt();
        if (floating == integral && each.indexOf('.') == -1) {
          return integral;
        } else {
          return floating;
        }
      });

  quote() => super.quote().map((each) => Cons((_, args) => args, each[1]));
}
