part of lisp;

/**
 * LISP parser definition.
 */
class LispParserDefinition extends LispGrammarDefinition {

  list() => super.list().map((each) => each[1]);

  cell() => super.cell().map((each) => new Cons(each[0], each[1]));
  empty() => super.empty().map((each) => null);

  string() => super.string().map((each) => new String.fromCharCodes(each[1]));
  characterEscape() => super.characterEscape().map((each) => each[1].codeUnitAt(0));
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

  quote() => super.quote().map((each) => new Cons(Natives._quote, each[1]));

}
