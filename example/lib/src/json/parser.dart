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

  Parser array() => super.array().map((each) => each[1] ?? []);
  Parser object() => super.object().map((each) {
        final result = {};
        if (each[1] != null) {
          for (var element in each[1]) {
            result[element[0]] = element[2];
          }
        }
        return result;
      });

  Parser trueToken() => super.trueToken().map((each) => true);
  Parser falseToken() => super.falseToken().map((each) => false);
  Parser nullToken() => super.nullToken().map((each) => null);
  Parser stringToken() => ref(stringPrimitive).trim();
  Parser numberToken() => super.numberToken().map((each) {
        final floating = double.parse(each);
        final integral = floating.toInt();
        if (floating == integral && each.indexOf('.') == -1) {
          return integral;
        } else {
          return floating;
        }
      });

  Parser stringPrimitive() =>
      super.stringPrimitive().map((each) => each[1].join());
  Parser characterEscape() =>
      super.characterEscape().map((each) => jsonEscapeChars[each[1]]);
  Parser characterUnicode() => super.characterUnicode().map((each) {
        final charCode = int.parse(each[1].join(), radix: 16);
        return String.fromCharCode(charCode);
      });
}
