// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

/**
 * LISP parser definition.
 */
class LispParser extends LispGrammar {

  void initialize() {
    super.initialize();

    action('list', (each) => each[1]);

    action('cell', (each) => new ConsCell(each[0], each[1]));
    action('null', (each) => NULL);

    action('string', (each) => new StringCell(new String.fromCharCodes(each[1])));
    action('character escape', (each) => each[1].charCodeAt(0));
    action('character raw', (each) => each.charCodeAt(0));

    action('symbol', (each) => new SymbolCell(each));
    action('number', (each) {
      var floating = Math.parseDouble(each);
      var integral = floating.toInt();
      if (floating == integral && each.indexOf('.') == -1) {
        return new NumberCell(integral);
      } else {
        return new NumberCell(floating);
      }
    });
  }

}