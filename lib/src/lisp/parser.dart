part of lisp;

/**
 * LISP parser definition.
 */
class LispParser extends LispGrammar {

  @override
  void initialize() {
    super.initialize();

    action('list', (each) => each[1]);

    action('cell', (each) => new Cons(each[0], each[1]));
    action('null', (each) => null);

    action('string', (each) => new String.fromCharCodes(each[1]));
    action('character escape', (each) => each[1].codeUnitAt(0));
    action('character raw', (each) => each.codeUnitAt(0));

    action('symbol', (each) => new Name(each));
    action('number', (each) {
      var floating = double.parse(each);
      var integral = floating.toInt();
      if (floating == integral && each.indexOf('.') == -1) {
        return integral;
      } else {
        return floating;
      }
    });

    action('quote', (each) => new Cons(Natives._quote, each[1]));
  }

}
