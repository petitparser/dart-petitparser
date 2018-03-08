library petitparser.example.lisp.parser;

import 'package:petitparser/petitparser.dart';

import 'cons.dart';
import 'grammar.dart';
import 'name.dart';

/// The standard lisp parser definition.
final lispParser = new LispParser();

/// LISP parser.
class LispParser extends GrammarParser {
  LispParser() : super(new LispParserDefinition());
}

/// LISP parser definition.
class LispParserDefinition extends LispGrammarDefinition {
  list() => super.list().map((each) => each[1]);

  cell() => super.cell().map((each) => new Cons(each[0], each[1]));
  empty() => super.empty().map((each) => null);

  string() => super
      .string()
      .map((each) => new String.fromCharCodes(each[1] as Iterable<int>));
  characterEscape() =>
      super.characterEscape().map((each) => each[1].codeUnitAt(0));
  characterRaw() => super.characterRaw().map((each) => each.codeUnitAt(0));

  symbol() => super.symbol().map((each) => new Name(each));
  number() => super.number().map((each) {
        var floating = double.parse(each);
        var integral = floating.toInt();
        if (floating == integral && each.indexOf('.') == -1) {
          return integral;
        } else {
          return floating;
        }
      });

  quote() =>
      super.quote().map((each) => new Cons((_, Cons args) => args, each[1]));
}
