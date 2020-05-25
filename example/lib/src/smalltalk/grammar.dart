library petitparser.example.smalltalk.grammar;

import 'package:petitparser/petitparser.dart';

/// Smalltalk grammar.
class SmalltalkGrammar extends GrammarParser {
  SmalltalkGrammar() : super(SmalltalkGrammarDefinition());
}

/// Smalltalk grammar definition.
class SmalltalkGrammarDefinition extends GrammarDefinition {
  // the original implementation used a handwritten parser to
  // build special token objects
  Parser token(Object source, [String message]) {
    if (source is String) {
      return source
          .toParser(message: 'Expected ${message ?? source}')
          .trim(ref(spacer));
    } else if (source is Parser) {
      ArgumentError.checkNotNull(message, 'message');
      return source.flatten('Expected $message').trim(ref(spacer));
    } else {
      throw ArgumentError('Unknow token type: $source.');
    }
  }

  // the original implementation uses a handwritten parser to
  // efficiently consume whitespace and comments
  Parser spacer() => whitespace().or(ref(comment));
  Parser comment() => char('"').seq(char('"').neg().star()).seq(char('"'));

  // the original implementation uses the hand written number
  // parser of the system, this is the spec of the ANSI standard
  Parser number() => char('-').optional().seq(ref(positiveNumber));
  Parser positiveNumber() => ref(scaledDecimal).or(ref(float)).or(ref(integer));

  Parser integer() => ref(radixInteger).or(ref(decimalInteger));
  Parser decimalInteger() => ref(digits);
  Parser digits() => digit().plus();
  Parser radixInteger() =>
      ref(radixSpecifier).seq(char('r')).seq(ref(radixDigits));
  Parser radixSpecifier() => ref(digits);
  Parser radixDigits() => pattern('0-9A-Z').plus();

  Parser float() =>
      ref(mantissa).seq(ref(exponentLetter).seq(ref(exponent)).optional());
  Parser mantissa() => ref(digits).seq(char('.')).seq(ref(digits));
  Parser exponent() => char('-').seq(ref(decimalInteger));
  Parser exponentLetter() => pattern('edq');

  Parser scaledDecimal() =>
      ref(scaledMantissa).seq(char('s')).seq(ref(fractionalDigits).optional());
  Parser scaledMantissa() => ref(decimalInteger).or(ref(mantissa));
  Parser fractionalDigits() => ref(decimalInteger);

  // the original smalltalk grammar
  Parser array() => ref(token, '{')
      .seq(ref(expression)
          .separatedBy(ref(periodToken))
          .seq(ref(periodToken).optional())
          .optional())
      .seq(ref(token, '}'));
  Parser arrayItem() => ref(literal)
      .or(ref(symbolLiteralArray))
      .or(ref(arrayLiteralArray))
      .or(ref(byteLiteralArray));
  Parser arrayLiteral() =>
      ref(token, '#(').seq(ref(arrayItem).star()).seq(ref(token, ')'));
  Parser arrayLiteralArray() =>
      ref(token, '(').seq(ref(arrayItem).star()).seq(ref(token, ')'));
  Parser assignment() => ref(variable).seq(ref(assignmentToken));
  Parser assignmentToken() => ref(token, ':=');
  Parser binary() => anyOf('!%&*+,-/<=>?@\\|~').plus();
  Parser binaryExpression() =>
      ref(unaryExpression).seq(ref(binaryMessage).star());
  Parser binaryMessage() => ref(binaryToken).seq(ref(unaryExpression));
  Parser binaryMethod() => ref(binaryToken).seq(ref(variable));
  Parser binaryPragma() => ref(binaryToken).seq(ref(arrayItem));
  Parser binaryToken() => ref(token, ref(binary), 'binary selector');
  Parser block() => ref(token, '[').seq(ref(blockBody)).seq(ref(token, ']'));
  Parser blockArgument() => ref(token, ':').seq(ref(variable));
  Parser blockArguments() =>
      ref(blockArgumentsWith).or(ref(blockArgumentsWithout));
  Parser blockArgumentsWith() =>
      ref(blockArgument).plus().seq(ref(token, '|').or(ref(token, ']').and()));
  Parser blockArgumentsWithout() => epsilon();
  Parser blockBody() => ref(blockArguments).seq(ref(sequence));
  Parser byteLiteral() =>
      ref(token, '#[').seq(ref(numberLiteral).star()).seq(ref(token, ']'));
  Parser byteLiteralArray() =>
      ref(token, '[').seq(ref(numberLiteral).star()).seq(ref(token, ']'));
  Parser cascadeExpression() =>
      ref(keywordExpression).seq(ref(cascadeMessage).star());
  Parser cascadeMessage() => ref(token, ';').seq(ref(message));
  Parser character() => char('\$').seq(any());
  Parser characterLiteral() => ref(characterToken);
  Parser characterToken() => ref(token, ref(character), 'character');
  Parser expression() => ref(assignment).star().seq(ref(cascadeExpression));
  Parser falseLiteral() => ref(falseToken);
  Parser falseToken() => ref(token, 'false').seq(word().not());
  Parser identifier() => pattern('a-zA-Z_').seq(word().star());
  Parser identifierToken() => ref(token, ref(identifier), 'identifier');
  Parser keyword() => ref(identifier).seq(char(':'));
  Parser keywordExpression() =>
      ref(binaryExpression).seq(ref(keywordMessage).optional());
  Parser keywordMessage() =>
      ref(keywordToken).seq(ref(binaryExpression)).plus();
  Parser keywordMethod() => ref(keywordToken).seq(ref(variable)).plus();
  Parser keywordPragma() => ref(keywordToken).seq(ref(arrayItem)).plus();
  Parser keywordToken() => ref(token, ref(keyword), 'keyword selector');
  Parser literal() => ref(numberLiteral)
      .or(ref(stringLiteral))
      .or(ref(characterLiteral))
      .or(ref(arrayLiteral))
      .or(ref(byteLiteral))
      .or(ref(symbolLiteral))
      .or(ref(nilLiteral))
      .or(ref(trueLiteral))
      .or(ref(falseLiteral));
  Parser message() =>
      ref(keywordMessage).or(ref(binaryMessage)).or(ref(unaryMessage));
  Parser method() => ref(methodDeclaration).seq(ref(methodSequence));
  Parser methodDeclaration() =>
      ref(keywordMethod).or(ref(unaryMethod)).or(ref(binaryMethod));
  Parser methodSequence() => ref(periodToken)
      .star()
      .seq(ref(pragmas))
      .seq(ref(periodToken).star())
      .seq(ref(temporaries))
      .seq(ref(periodToken).star())
      .seq(ref(pragmas))
      .seq(ref(periodToken).star())
      .seq(ref(statements));
  Parser multiword() => ref(keyword).plus();
  Parser nilLiteral() => ref(nilToken);
  Parser nilToken() => ref(token, 'nil').seq(word().not());
  Parser numberLiteral() => ref(numberToken);
  Parser numberToken() => ref(token, ref(number), 'number');
  Parser parens() => ref(token, '(').seq(ref(expression)).seq(ref(token, ')'));
  Parser period() => char('.');
  Parser periodToken() => ref(token, ref(period), 'period');
  Parser pragma() =>
      ref(token, '<').seq(ref(pragmaMessage)).seq(ref(token, '>'));
  Parser pragmaMessage() =>
      ref(keywordPragma).or(ref(unaryPragma)).or(ref(binaryPragma));
  Parser pragmas() => ref(pragma).star();
  Parser primary() => ref(literal)
      .or(ref(variable))
      .or(ref(block))
      .or(ref(parens))
      .or(ref(array));
  Parser answer() => ref(token, '^').seq(ref(expression));
  Parser sequence() =>
      ref(temporaries).seq(ref(periodToken).star()).seq(ref(statements));
  Parser start() => ref(startMethod);
  Parser startMethod() => ref(method).end();
  Parser statements() => ref(expression)
      .seq(ref(periodToken)
          .plus()
          .seq(ref(statements))
          .or(ref(periodToken).star()))
      .or(ref(answer).seq(ref(periodToken).star()))
      .or(ref(periodToken).star());
  Parser string_() =>
      char('\'').seq(string('\'\'').or(pattern('^\'')).star()).seq(char('\''));
  Parser stringLiteral() => ref(stringToken);
  Parser stringToken() => ref(token, ref(string_), 'string');
  Parser symbol() =>
      ref(unary).or(ref(binary)).or(ref(multiword)).or(ref(string_));
  Parser symbolLiteral() =>
      ref(token, '#').plus().seq(ref(token, ref(symbol), 'symbol'));
  Parser symbolLiteralArray() => ref(token, ref(symbol), 'symbol');
  Parser temporaries() =>
      ref(token, '|').seq(ref(variable).star()).seq(ref(token, '|')).optional();
  Parser trueLiteral() => ref(trueToken);
  Parser trueToken() => ref(token, 'true').seq(word().not());
  Parser unary() => ref(identifier).seq(char(':').not());
  Parser unaryExpression() => ref(primary).seq(ref(unaryMessage).star());
  Parser unaryMessage() => ref(unaryToken);
  Parser unaryMethod() => ref(identifierToken);
  Parser unaryPragma() => ref(identifierToken);
  Parser unaryToken() => ref(token, ref(unary), 'unary selector');
  Parser variable() => ref(identifierToken);
}
