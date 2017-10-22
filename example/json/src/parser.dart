library petitparser.example.json.parser;

import 'package:petitparser/petitparser.dart';

import 'grammar.dart';

/// JSON parser.
class JsonParser extends GrammarParser {
  JsonParser() : super(const JsonParserDefinition());
}

/// JSON parser definition.
class JsonParserDefinition extends JsonGrammarDefinition {
  const JsonParserDefinition();

  array() => super.array().map((each) => each[1] ?? []);
  object() => super.object().map((each) {
    var result = {};
    if (each[1] != null) {
      for (var element in each[1]) {
        result[element[0]] = element[2];
      }
    }
    return result;
  });

  trueToken() => super.trueToken().map((each) => true);
  falseToken() => super.falseToken().map((each) => false);
  nullToken() => super.nullToken().map((each) => null);
  stringToken() => ref(stringPrimitive).trim();
  numberToken() => super.numberToken().map((each) {
    var floating = double.parse(each);
    var integral = floating.toInt();
    if (floating == integral && each.indexOf('.') == -1) {
      return integral;
    } else {
      return floating;
    }
  });

  stringPrimitive() => super.stringPrimitive().map((each) => each[1].join());
  characterEscape() => super.characterEscape().map((each) => jsonEscapeChars[each[1]]);
  characterUnicode() => super.characterUnicode().map((each) {
    var charCode = int.parse(each[1].join(), radix: 16);
    return new String.fromCharCode(charCode);
  });
}
