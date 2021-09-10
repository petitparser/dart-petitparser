import 'package:petitparser/petitparser.dart';

import 'grammar.dart';

/// JSON parser definition.
class JsonParserDefinition extends JsonGrammarDefinition {
  @override
  Parser array() => super.array().map((each) => each[1] ?? []);
  @override
  Parser object() => super.object().map((each) {
        final result = {};
        if (each[1] != null) {
          for (final element in each[1]) {
            result[element[0]] = element[2];
          }
        }
        return result;
      });

  @override
  Parser trueToken() => super.trueToken().map((each) => true);
  @override
  Parser falseToken() => super.falseToken().map((each) => false);
  @override
  Parser nullToken() => super.nullToken().map((each) => null);
  @override
  Parser stringToken() => ref0(stringPrimitive).trim();
  @override
  Parser numberToken() => super.numberToken().map((each) => num.parse(each));

  @override
  Parser stringPrimitive() =>
      super.stringPrimitive().map((each) => each[1].join());
  @override
  Parser characterEscape() =>
      super.characterEscape().map((each) => jsonEscapeChars[each[1]]);
  @override
  Parser characterUnicode() => super.characterUnicode().map((each) {
        final charCode = int.parse(each[1].join(), radix: 16);
        return String.fromCharCode(charCode);
      });
}
