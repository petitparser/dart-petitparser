library petitparser.example.smalltalk.grammar;

import 'package:petitparser/petitparser.dart';

/// Smalltalk grammar.
class SmalltalkGrammar extends GrammarParser {
  SmalltalkGrammar() : super(new SmalltalkGrammarDefinition());
}

/// Smalltalk grammar definition.
class SmalltalkGrammarDefinition extends GrammarDefinition {
  // the original implementation used a handwritten parser to
  // build special token objects
  token(input) {
    if (input is String) {
      return token(input.length == 1 ? char(input) : string(input));
    } else if (input is Parser) {
      return input.token().trim(ref(spacer));
    } else {
      throw new ArgumentError('Invalid token parser: $input');
    }
  }

  // the original implementation uses a handwritten parser to
  // efficiently consume whitespace and comments
  spacer() => whitespace().or(ref(comment));
  comment() => char('"').seq(char('"').neg().star()).seq(char('"'));

  // the original implementation uses the hand written number
  // parser of the system, this is the spec of the ANSI standard
  number() => char('-').optional().seq(ref(positiveNumber));
  positiveNumber() => ref(scaledDecimal).or(ref(float)).or(ref(integer));

  integer() => ref(radixInteger).or(ref(decimalInteger));
  decimalInteger() => ref(digits);
  digits() => digit().plus();
  radixInteger() => ref(radixSpecifier).seq(char('r')).seq(ref(radixDigits));
  radixSpecifier() => ref(digits);
  radixDigits() => pattern('0-9A-Z').plus();

  float() =>
      ref(mantissa).seq(ref(exponentLetter).seq(ref(exponent)).optional());
  mantissa() => ref(digits).seq(char('.')).seq(ref(digits));
  exponent() => char('-').seq(ref(decimalInteger));
  exponentLetter() => pattern('edq');

  scaledDecimal() =>
      ref(scaledMantissa).seq(char('s')).seq(ref(fractionalDigits).optional());
  scaledMantissa() => ref(decimalInteger).or(ref(mantissa));
  fractionalDigits() => ref(decimalInteger);

  // the original smalltalk grammar
  array() => ref(token, '{')
      .seq(ref(expression)
          .separatedBy(ref(periodToken))
          .seq(ref(periodToken).optional())
          .optional())
      .seq(ref(token, '}'));
  arrayItem() => ref(literal)
      .or(ref(symbolLiteralArray))
      .or(ref(arrayLiteralArray))
      .or(ref(byteLiteralArray));
  arrayLiteral() =>
      ref(token, '#(').seq(ref(arrayItem).star()).seq(ref(token, ')'));
  arrayLiteralArray() =>
      ref(token, '(').seq(ref(arrayItem).star()).seq(ref(token, ')'));
  assignment() => ref(variable).seq(ref(assignmentToken));
  assignmentToken() => ref(token, ':=');
  binary() => pattern('!%&*+,-/<=>?@\\|~').plus();
  binaryExpression() => ref(unaryExpression).seq(ref(binaryMessage).star());
  binaryMessage() => ref(binaryToken).seq(ref(unaryExpression));
  binaryMethod() => ref(binaryToken).seq(ref(variable));
  binaryPragma() => ref(binaryToken).seq(ref(arrayItem));
  binaryToken() => ref(token, ref(binary));
  block() => ref(token, '[').seq(ref(blockBody)).seq(ref(token, ']'));
  blockArgument() => ref(token, ':').seq(ref(variable));
  blockArguments() => ref(blockArgumentsWith).or(ref(blockArgumentsWithout));
  blockArgumentsWith() =>
      ref(blockArgument).plus().seq(ref(token, '|').or(ref(token, ']').and()));
  blockArgumentsWithout() => epsilon();
  blockBody() => ref(blockArguments).seq(ref(sequence));
  byteLiteral() =>
      ref(token, '#[').seq(ref(numberLiteral).star()).seq(ref(token, ']'));
  byteLiteralArray() =>
      ref(token, '[').seq(ref(numberLiteral).star()).seq(ref(token, ']'));
  cascadeExpression() => ref(keywordExpression).seq(ref(cascadeMessage).star());
  cascadeMessage() => ref(token, ';').seq(ref(message));
  character() => char('\$').seq(any());
  characterLiteral() => ref(characterToken);
  characterToken() => ref(token, ref(character));
  expression() => ref(assignment).star().seq(ref(cascadeExpression));
  falseLiteral() => ref(falseToken);
  falseToken() => ref(token, 'false').seq(word().not());
  identifier() => pattern('a-zA-Z_').seq(word().star());
  identifierToken() => ref(token, ref(identifier));
  keyword() => ref(identifier).seq(char(':'));
  keywordExpression() =>
      ref(binaryExpression).seq(ref(keywordMessage).optional());
  keywordMessage() => ref(keywordToken).seq(ref(binaryExpression)).plus();
  keywordMethod() => ref(keywordToken).seq(ref(variable)).plus();
  keywordPragma() => ref(keywordToken).seq(ref(arrayItem)).plus();
  keywordToken() => ref(token, ref(keyword));
  literal() => ref(numberLiteral)
      .or(ref(stringLiteral))
      .or(ref(characterLiteral))
      .or(ref(arrayLiteral))
      .or(ref(byteLiteral))
      .or(ref(symbolLiteral))
      .or(ref(nilLiteral))
      .or(ref(trueLiteral))
      .or(ref(falseLiteral));
  message() => ref(keywordMessage).or(ref(binaryMessage)).or(ref(unaryMessage));
  method() => ref(methodDeclaration).seq(ref(methodSequence));
  methodDeclaration() =>
      ref(keywordMethod).or(ref(unaryMethod)).or(ref(binaryMethod));
  methodSequence() => ref(periodToken)
      .star()
      .seq(ref(pragmas))
      .seq(ref(periodToken).star())
      .seq(ref(temporaries))
      .seq(ref(periodToken).star())
      .seq(ref(pragmas))
      .seq(ref(periodToken).star())
      .seq(ref(statements));
  multiword() => ref(keyword).plus();
  nilLiteral() => ref(nilToken);
  nilToken() => ref(token, 'nil').seq(word().not());
  numberLiteral() => ref(numberToken);
  numberToken() => ref(token, ref(number));
  parens() => ref(token, '(').seq(ref(expression)).seq(ref(token, ')'));
  period() => char('.');
  periodToken() => ref(token, ref(period));
  pragma() => ref(token, '<').seq(ref(pragmaMessage)).seq(ref(token, '>'));
  pragmaMessage() =>
      ref(keywordPragma).or(ref(unaryPragma)).or(ref(binaryPragma));
  pragmas() => ref(pragma).star();
  primary() => ref(literal)
      .or(ref(variable))
      .or(ref(block))
      .or(ref(parens))
      .or(ref(array));
  answer() => ref(token, '^').seq(ref(expression));
  sequence() =>
      ref(temporaries).seq(ref(periodToken).star()).seq(ref(statements));
  start() => ref(startMethod);
  startMethod() => ref(method).end();
  statements() => ref(expression)
      .seq(ref(periodToken)
          .plus()
          .seq(ref(statements))
          .or(ref(periodToken).star()))
      .or(ref(answer).seq(ref(periodToken).star()))
      .or(ref(periodToken).star());
  string_() =>
      char('\'').seq(string('\'\'').or(pattern('^\'')).star()).seq(char('\''));
  stringLiteral() => ref(stringToken);
  stringToken() => ref(token, ref(string_));
  symbol() => ref(unary).or(ref(binary)).or(ref(multiword)).or(ref(string_));
  symbolLiteral() => ref(token, '#').plus().seq(ref(token, ref(symbol)));
  symbolLiteralArray() => ref(token, ref(symbol));
  temporaries() =>
      ref(token, '|').seq(ref(variable).star()).seq(ref(token, '|')).optional();
  trueLiteral() => ref(trueToken);
  trueToken() => ref(token, 'true').seq(word().not());
  unary() => ref(identifier).seq(char(':').not());
  unaryExpression() => ref(primary).seq(ref(unaryMessage).star());
  unaryMessage() => ref(unaryToken);
  unaryMethod() => ref(identifierToken);
  unaryPragma() => ref(identifierToken);
  unaryToken() => ref(token, ref(unary));
  variable() => ref(identifierToken);
}
