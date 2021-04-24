import 'package:petitparser/petitparser.dart';

/// Smalltalk grammar definition.
class SmalltalkGrammarDefinition extends GrammarDefinition {
  // the original implementation used a handwritten parser to
  // build special token objects
  Parser token(Object source, [String? message]) {
    if (source is String) {
      return source
          .toParser(message: 'Expected ${message ?? source}')
          .token()
          .trim(ref0(spacer));
    } else if (source is Parser) {
      ArgumentError.checkNotNull(message, 'message');
      return source.flatten('Expected $message').token().trim(ref0(spacer));
    } else {
      throw ArgumentError('Unknown token type: $source.');
    }
  }

  // the original implementation uses a handwritten parser to
  // efficiently consume whitespace and comments
  Parser spacer() => whitespace().or(ref0(comment));
  Parser comment() => char('"').seq(char('"').neg().star()).seq(char('"'));

  // the original implementation uses the hand written number
  // parser of the system, this is the spec of the ANSI standard
  Parser number() => char('-').optional().seq(ref0(positiveNumber));
  Parser positiveNumber() =>
      ref0(scaledDecimal).or(ref0(float)).or(ref0(integer));

  Parser integer() => ref0(radixInteger).or(ref0(decimalInteger));
  Parser decimalInteger() => ref0(digits);
  Parser digits() => digit().plus();
  Parser radixInteger() =>
      ref0(radixSpecifier).seq(char('r')).seq(ref0(radixDigits));
  Parser radixSpecifier() => ref0(digits);
  Parser radixDigits() => pattern('0-9A-Z').plus();

  Parser float() =>
      ref0(mantissa).seq(ref0(exponentLetter).seq(ref0(exponent)).optional());
  Parser mantissa() => ref0(digits).seq(char('.')).seq(ref0(digits));
  Parser exponent() => char('-').seq(ref0(decimalInteger));
  Parser exponentLetter() => pattern('edq');

  Parser scaledDecimal() => ref0(scaledMantissa)
      .seq(char('s'))
      .seq(ref0(fractionalDigits).optional());
  Parser scaledMantissa() => ref0(decimalInteger).or(ref0(mantissa));
  Parser fractionalDigits() => ref0(decimalInteger);

  // the original smalltalk grammar
  Parser array() => ref1(token, '{')
      .seq(ref0(expression)
          .separatedBy(ref0(periodToken))
          .seq(ref0(periodToken).optional())
          .optional())
      .seq(ref1(token, '}'));
  Parser arrayItem() => ref0(literal)
      .or(ref0(symbolLiteralArray))
      .or(ref0(arrayLiteralArray))
      .or(ref0(byteLiteralArray));
  Parser arrayLiteral() =>
      ref1(token, '#(').seq(ref0(arrayItem).star()).seq(ref1(token, ')'));
  Parser arrayLiteralArray() =>
      ref1(token, '(').seq(ref0(arrayItem).star()).seq(ref1(token, ')'));
  Parser assignment() => ref0(variable).seq(ref0(assignmentToken));
  Parser assignmentToken() => ref1(token, ':=');
  Parser binary() => anyOf('!%&*+,-/<=>?@\\|~').plus();
  Parser binaryExpression() =>
      ref0(unaryExpression).seq(ref0(binaryMessage).star());
  Parser binaryMessage() =>
      ref0(binaryToken).seq(ref0(unaryExpression)).map(buildBinary);
  Parser binaryMethod() =>
      ref0(binaryToken).seq(ref0(variable)).map(buildBinary);
  Parser binaryPragma() =>
      ref0(binaryToken).seq(ref0(arrayItem)).map(buildBinary);
  Parser binaryToken() => ref2(token, ref0(binary), 'binary selector');
  Parser block() => ref1(token, '[').seq(ref0(blockBody)).seq(ref1(token, ']'));
  Parser blockArgument() => ref1(token, ':').seq(ref0(variable));
  Parser blockArguments() =>
      ref0(blockArgumentsWith).or(ref0(blockArgumentsWithout));
  Parser blockArgumentsWith() => ref0(blockArgument)
      .plus()
      .seq(ref1(token, '|').or(ref1(token, ']').and()));
  Parser blockArgumentsWithout() => epsilon();
  Parser blockBody() => ref0(blockArguments).seq(ref0(sequence));
  Parser byteLiteral() =>
      ref1(token, '#[').seq(ref0(numberLiteral).star()).seq(ref1(token, ']'));
  Parser byteLiteralArray() =>
      ref1(token, '[').seq(ref0(numberLiteral).star()).seq(ref1(token, ']'));
  Parser cascadeExpression() =>
      ref0(keywordExpression).seq(ref0(cascadeMessage).star());
  Parser cascadeMessage() => ref1(token, ';').seq(ref0(message));
  Parser character() => char('\$').seq(any());
  Parser characterLiteral() => ref0(characterToken);
  Parser characterToken() => ref2(token, ref0(character), 'character');
  Parser expression() => ref0(assignment).star().seq(ref0(cascadeExpression));
  Parser falseLiteral() => ref0(falseToken);
  Parser falseToken() =>
      ref2(token, 'false'.toParser() & word().not(), 'false');
  Parser identifier() => pattern('a-zA-Z_').seq(word().star());
  Parser identifierToken() => ref2(token, ref0(identifier), 'identifier');
  Parser keyword() => ref0(identifier).seq(char(':'));
  Parser keywordExpression() =>
      ref0(binaryExpression).seq(ref0(keywordMessage).optional());
  Parser keywordMessage() =>
      ref0(keywordToken).seq(ref0(binaryExpression)).plus().map(buildKeyword);
  Parser keywordMethod() =>
      ref0(keywordToken).seq(ref0(variable)).plus().map(buildKeyword);
  Parser keywordPragma() =>
      ref0(keywordToken).seq(ref0(arrayItem)).plus().map(buildKeyword);
  Parser keywordToken() => ref2(token, ref0(keyword), 'keyword selector');
  Parser literal() => ref0(numberLiteral)
      .or(ref0(stringLiteral))
      .or(ref0(characterLiteral))
      .or(ref0(arrayLiteral))
      .or(ref0(byteLiteral))
      .or(ref0(symbolLiteral))
      .or(ref0(nilLiteral))
      .or(ref0(trueLiteral))
      .or(ref0(falseLiteral));
  Parser message() =>
      ref0(keywordMessage).or(ref0(binaryMessage)).or(ref0(unaryMessage));
  Parser method() => ref0(methodDeclaration).seq(ref0(methodSequence));
  Parser methodDeclaration() =>
      ref0(keywordMethod).or(ref0(unaryMethod)).or(ref0(binaryMethod));
  Parser methodSequence() => ref0(periodToken)
      .star()
      .seq(ref0(pragmas))
      .seq(ref0(periodToken).star())
      .seq(ref0(temporaries))
      .seq(ref0(periodToken).star())
      .seq(ref0(pragmas))
      .seq(ref0(periodToken).star())
      .seq(ref0(statements));
  Parser multiword() => ref0(keyword).plus();
  Parser nilLiteral() => ref0(nilToken);
  Parser nilToken() => ref2(token, 'nil'.toParser() & word().not(), 'nil');
  Parser numberLiteral() => ref0(numberToken);
  Parser numberToken() => ref2(token, ref0(number), 'number');
  Parser parens() =>
      ref1(token, '(').seq(ref0(expression)).seq(ref1(token, ')'));
  Parser period() => char('.');
  Parser periodToken() => ref2(token, ref0(period), 'period');
  Parser pragma() =>
      ref1(token, '<').seq(ref0(pragmaMessage)).seq(ref1(token, '>'));
  Parser pragmaMessage() =>
      ref0(keywordPragma).or(ref0(unaryPragma)).or(ref0(binaryPragma));
  Parser pragmas() => ref0(pragma).star();
  Parser primary() => ref0(literal)
      .or(ref0(variable))
      .or(ref0(block))
      .or(ref0(parens))
      .or(ref0(array));
  Parser answer() => ref1(token, '^').seq(ref0(expression));
  Parser sequence() =>
      ref0(temporaries).seq(ref0(periodToken).star()).seq(ref0(statements));
  Parser start() => ref0(startMethod);
  Parser startMethod() => ref0(method).end();
  Parser statements() => ref0(expression)
      .seq(ref0(periodToken)
          .plus()
          .seq(ref0(statements))
          .or(ref0(periodToken).star()))
      .or(ref0(answer).seq(ref0(periodToken).star()))
      .or(ref0(periodToken).star());
  Parser _string() =>
      char('\'').seq(string('\'\'').or(pattern('^\'')).star()).seq(char('\''));
  Parser stringLiteral() => ref0(stringToken);
  Parser stringToken() => ref2(token, ref0(_string), 'string');
  Parser symbol() =>
      ref0(unary).or(ref0(binary)).or(ref0(multiword)).or(ref0(_string));
  Parser symbolLiteral() =>
      ref1(token, '#').plus().seq(ref2(token, ref0(symbol), 'symbol'));
  Parser symbolLiteralArray() => ref2(token, ref0(symbol), 'symbol');
  Parser temporaries() => ref1(token, '|')
      .seq(ref0(variable).star())
      .seq(ref1(token, '|'))
      .optional();
  Parser trueLiteral() => ref0(trueToken);
  Parser trueToken() => ref2(token, 'true'.toParser() & word().not(), 'true');
  Parser unary() => ref0(identifier).seq(char(':').not());
  Parser unaryExpression() => ref0(primary).seq(ref0(unaryMessage).star());
  Parser unaryMessage() => ref0(unaryToken).map(buildUnary);
  Parser unaryMethod() => ref0(identifierToken).map(buildUnary);
  Parser unaryPragma() => ref0(identifierToken).map(buildUnary);
  Parser unaryToken() => ref2(token, ref0(unary), 'unary selector');
  Parser variable() => ref0(identifierToken);
}

dynamic buildUnary(dynamic input) => [
      [input],
      [],
    ];
dynamic buildBinary(dynamic input) => [
      [input[0]],
      [input[1]],
    ];
dynamic buildKeyword(dynamic input) => [
      input.map((each) => each[0]).toList(),
      input.map((each) => each[1]).toList(),
    ];
