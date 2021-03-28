import 'package:petitparser/petitparser.dart';

/// Prolog grammar definition.
class PrologGrammarDefinition extends GrammarDefinition {
  Parser start() => throw UnsupportedError('Either parse rules or terms.');

  Parser<List> rules() => ref0(rule).star();
  Parser rule() =>
      ref0(term) &
      (ref0(definitionToken) &
              ref0(term)
                  .separatedBy(ref0(commaToken), includeSeparators: false))
          .optional() &
      ref0(terminatorToken);
  Parser term() =>
      ref0(atom) &
      (ref0(openParenToken) &
              ref0(parameter)
                  .separatedBy(ref0(commaToken), includeSeparators: false) &
              ref0(closeParentToken))
          .optional();
  Parser parameter() =>
      ref0(atom) &
      (ref0(openParenToken) &
              ref0(parameter)
                  .separatedBy(ref0(commaToken), includeSeparators: false) &
              ref0(closeParentToken))
          .optional();
  Parser atom() => ref0(variable) | ref0(value);

  Parser variable() => ref0(variableToken);
  Parser value() => ref0(valueToken);

  Parser space() => whitespace() | ref0(commentSingle) | ref0(commentMulti);
  Parser commentSingle() => char('%') & Token.newlineParser().neg().star();
  Parser commentMulti() => string('/*').starLazy(string('*/')) & string('*/');

  Parser token(Object parser, [String? message]) {
    if (parser is Parser) {
      return parser.flatten(message).trim(ref0(space));
    } else if (parser is String) {
      return parser
          .toParser(message: message ?? '$parser expected')
          .trim(ref0(space));
    } else {
      throw ArgumentError.value(parser, 'parser', 'Invalid parser type');
    }
  }

  Parser variableToken() => ref2(
        token,
        pattern('A-Z_') & pattern('A-Za-z0-9_').star(),
        'Variable expected',
      );
  Parser valueToken() => ref2(
        token,
        pattern('a-z') & pattern('A-Za-z0-9_').star(),
        'Value expected',
      );
  Parser openParenToken() => ref1(token, '(');
  Parser closeParentToken() => ref1(token, ')');
  Parser commaToken() => ref1(token, ',');
  Parser terminatorToken() => ref1(token, '.');
  Parser definitionToken() => ref1(token, ':-');
}
