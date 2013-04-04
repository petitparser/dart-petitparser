// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of json;

/**
 * JSON parser definition.
 */
class JsonParser extends JsonGrammar {

  void initialize() {
    super.initialize();

    array((each) => each[1] != null ? each[1] : new List());
    object((each) {
      var result = new LinkedHashMap();
      if (each[1] != null) {
        for (var element in each[1]) {
          result[element[0]] = element[2];
        }
      }
      return result;
    });

    trueToken((each) => true);
    falseToken((each) => false);
    nullToken((each) => null);
    stringToken(stringPrimitive.trim());
    numberToken((each) {
      var floating = double.parse(each);
      var integral = floating.toInt();
      if (floating == integral && each.indexOf('.') == -1) {
        return integral;
      } else {
        return floating;
      }
    });

    stringPrimitive((each) => each[1].join(''));
    characterEscape((each) => ESCAPE_TABLE[each[1]]);
    characterOctal((each) {
      throw new UnsupportedError('Octal characters not supported yet');
    });

  }

}
