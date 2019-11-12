library petitparser.example.lisp.parser;

import 'package:petitparser/petitparser.dart';

import 'cons.dart';
import 'grammar.dart';
import 'name.dart';

/// The standard lisp parser definition.
final LispParser lispParser = LispParser();

/// LISP parser.
class LispParser extends GrammarParser {
  LispParser() : super(LispParserDefinition());
}

/// LISP parser definition.
class LispParserDefinition extends LispGrammarDefinition {
  Parser list() => super.list().map((each) => each[1]);

  Parser cell() => super.cell().map((each) => Cons(each[0], each[1]));
  Parser empty() => super.empty().map((each) => null);

  Parser string() =>
      super.string().map((each) => String.fromCharCodes(each[1].cast<int>()));
  Parser characterEscape() =>
      super.characterEscape().map((each) => each[1].codeUnitAt(0));
  Parser characterRaw() =>
      super.characterRaw().map((each) => each.codeUnitAt(0));

  Parser symbol() => super.symbol().map((each) => Name(each));
  Parser number() => super.number().map((each) {
        final floating = double.parse(each);
        final integral = floating.toInt();
        if (floating == integral && each.indexOf('.') == -1) {
          return integral;
        } else {
          return floating;
        }
      });

  Parser quote() =>
      super.quote().map((each) => Cons((_, args) => args, each[1]));
}
