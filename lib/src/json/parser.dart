// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

part of json;

/**
 * JSON parser definition.
 */
class JsonParser extends JsonGrammar {

  void initialize() {
    super.initialize();

    action('array', (each) => each[1] != null ? each[1] : new List());
    redef('elements', (parser) => parser.withoutSeparators());
    redef('members', (parser) => parser.withoutSeparators());
    action('object', (each) {
      var result = new LinkedHashMap();
      if (each[1] != null) {
        for (List element in each[1]) {
          result[element[0]] = element[2];
        }
      }
      return result;
    });

    action('trueToken', (each) => true);
    action('falseToken', (each) => false);
    action('nullToken', (each) => null);
    redef('stringToken', (parser) => ref('stringPrimitive').trim());
    action('numberToken', (each) {
      var floating = double.parse(each);
      var integral = floating.toInt();
      if (floating == integral && each.indexOf('.') == -1) {
        return integral;
      } else {
        return floating;
      }
    });

    action('stringPrimitive', (each) => Strings.join(each[1], ''));
    action('characterEscape', (each) => ESCAPE_TABLE[each[1]]);
    action('characterOctal', (each) {
      throw new UnsupportedOperationException('Octal characters not supported yet');
    });

  }

}