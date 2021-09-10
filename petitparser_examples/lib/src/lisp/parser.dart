import 'package:petitparser/petitparser.dart';

import 'cons.dart';
import 'grammar.dart';
import 'name.dart';
import 'quote.dart';

/// The standard lisp parser definition.
final _definition = LispParserDefinition();

/// The standard prolog parser to read rules.
final lispParser = _definition.build();

/// LISP parser definition.
class LispParserDefinition extends LispGrammarDefinition {
  @override
  Parser list() => super.list().map((each) => each[1]);

  @override
  Parser cell() => super.cell().map((each) => Cons(each[0], each[1]));

  @override
  Parser empty() => super.empty().map((each) => null);

  @override
  Parser string() =>
      super.string().map((each) => String.fromCharCodes(each[1].cast<int>()));

  @override
  Parser characterEscape() =>
      super.characterEscape().map((each) => each[1].codeUnitAt(0));

  @override
  Parser characterRaw() =>
      super.characterRaw().map((each) => each.codeUnitAt(0));

  @override
  Parser symbol() => super.symbol().map((each) => Name(each));

  @override
  Parser number() => super.number().map((each) => num.parse(each));

  @override
  Parser quote() => super.quote().map((each) => Quote(each[1]));
}
