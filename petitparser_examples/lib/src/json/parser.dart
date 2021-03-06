import 'package:petitparser/petitparser.dart';

import 'grammar.dart';

/// JSON parser definition.
class JsonParserDefinition extends JsonGrammarDefinition {
  Parser array() => super.array().map((each) => each[1] ?? []);
  Parser object() => super.object().map((each) {
        final result = {};
        if (each[1] != null) {
          for (final element in each[1]) {
            result[element[0]] = element[2];
          }
        }
        return result;
      });

  Parser trueToken() => super.trueToken().map((each) => true);
  Parser falseToken() => super.falseToken().map((each) => false);
  Parser nullToken() => super.nullToken().map((each) => null);
  Parser stringToken() => ref0(stringPrimitive).trim();
  Parser numberToken() => super.numberToken().map((each) => num.parse(each));

  Parser stringPrimitive() =>
      super.stringPrimitive().map((each) => each[1].join());
  Parser characterEscape() =>
      super.characterEscape().map((each) => jsonEscapeChars[each[1]]);
  Parser characterUnicode() => super.characterUnicode().map((each) {
        final charCode = int.parse(each[1].join(), radix: 16);
        return String.fromCharCode(charCode);
      });
}
