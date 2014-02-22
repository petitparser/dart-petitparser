part of json;

/**
 * JSON parser definition.
 */
class JsonParser extends JsonGrammar {

  @override
  void initialize() {
    super.initialize();

    action('array', (each) => each[1] != null ? each[1] : new List());
    action('object', (each) {
      var result = new LinkedHashMap();
      if (each[1] != null) {
        for (var element in each[1]) {
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

    action('stringPrimitive', (each) => each[1].join(''));
    action('characterEscape', (each) => _escapeTable[each[1]]);
    action('characterOctal', (each) {
      throw new UnsupportedError('Octal characters not supported yet');
    });

  }

}
