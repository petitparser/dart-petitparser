library petitparser.example.dart.grammar;

import 'package:petitparser/petitparser.dart';

/// Dart grammar.
class DartGrammar extends GrammarParser {
  DartGrammar() : super(DartGrammarDefinition());
}

/// Dart grammar definition.
class DartGrammarDefinition extends GrammarDefinition {
  Parser token(input) {
    if (input is String) {
      input = input.length == 1 ? char(input) : string(input);
    } else if (input is Function) {
      input = ref(input);
    }
    if (input is! Parser || input is TrimmingParser || input is TokenParser) {
      throw ArgumentError('Invalid token parser: $input');
    }
    return input.token().trim(ref(HIDDEN_STUFF));
  }

  // Copyright (c) 2011, the Dart project authors. Please see the AUTHORS file
  // for details. All rights reserved. Use of this source code is governed by a
  // BSD-style license that can be found in the LICENSE file.

  // -----------------------------------------------------------------
  // Keyword definitions.
  // -----------------------------------------------------------------
  BREAK() => ref(token, 'break');
  CASE() => ref(token, 'case');
  CATCH() => ref(token, 'catch');
  CONST() => ref(token, 'const');
  CONTINUE() => ref(token, 'continue');
  DEFAULT() => ref(token, 'default');
  DO() => ref(token, 'do');
  ELSE() => ref(token, 'else');
  FALSE() => ref(token, 'false');
  FINAL() => ref(token, 'final');
  FINALLY() => ref(token, 'finally');
  FOR() => ref(token, 'for');
  IF() => ref(token, 'if');
  IN() => ref(token, 'in');
  NEW() => ref(token, 'new');
  NULL() => ref(token, 'null');
  RETURN() => ref(token, 'return');
  SUPER() => ref(token, 'super');
  SWITCH() => ref(token, 'switch');
  THIS() => ref(token, 'this');
  THROW() => ref(token, 'throw');
  TRUE() => ref(token, 'true');
  TRY() => ref(token, 'try');
  VAR() => ref(token, 'var');
  VOID() => ref(token, 'void');
  WHILE() => ref(token, 'while');

  // Pseudo-keywords that should also be valid identifiers.
  ABSTRACT() => ref(token, 'abstract');
  AS() => ref(token, 'as');
  ASSERT() => ref(token, 'assert');
  CLASS() => ref(token, 'class');
  DEFERRED() => ref(token, 'deferred');
  EXPORT() => ref(token, 'export');
  EXTENDS() => ref(token, 'extends');
  FACTORY() => ref(token, 'factory');
  GET() => ref(token, 'get');
  HIDE() => ref(token, 'hide');
  IMPLEMENTS() => ref(token, 'implements');
  IMPORT() => ref(token, 'import');
  IS() => ref(token, 'is');
  LIBRARY() => ref(token, 'library');
  NATIVE() => ref(token, 'native');
  NEGATE() => ref(token, 'negate');
  OF() => ref(token, 'of');
  OPERATOR() => ref(token, 'operator');
  PART() => ref(token, 'part');
  SET() => ref(token, 'set');
  SHOW() => ref(token, 'show');
  STATIC() => ref(token, 'static');
  TYPEDEF() => ref(token, 'typedef');

  // -----------------------------------------------------------------
  // Grammar productions.
  // -----------------------------------------------------------------
  start() => ref(compilationUnit).end();

  compilationUnit() =>
      ref(HASHBANG).optional() &
      ref(libraryDirective).optional() &
      ref(importDirective).star() &
      ref(topLevelDefinition).star();

  libraryDirective() =>
      ref(LIBRARY) & ref(qualified) & ref(token, ';') |
      ref(PART) & ref(OF) & ref(qualified) & ref(token, ';');

  importDirective() =>
      ref(IMPORT) &
          ref(SINGLE_LINE_STRING) &
          ref(DEFERRED).optional() &
          (ref(AS) & ref(identifier)).optional() &
          ((ref(SHOW) | ref(HIDE)) &
                  ref(identifier).separatedBy(ref(token, ',')))
              .optional() &
          ref(token, ';') |
      ref(EXPORT) &
          ref(SINGLE_LINE_STRING) &
          ((ref(SHOW) | ref(HIDE)) &
                  ref(identifier).separatedBy(ref(token, ',')))
              .optional() &
          ref(token, ';') |
      ref(PART) & ref(SINGLE_LINE_STRING) & ref(token, ';');

  topLevelDefinition() =>
      ref(classDefinition) |
      ref(functionTypeAlias) |
      ref(functionDeclaration) & ref(functionBodyOrNative) |
      ref(returnType).optional() &
          ref(getOrSet) &
          ref(identifier) &
          ref(formalParameterList) &
          ref(functionBodyOrNative) |
      ref(FINAL) &
          ref(type).optional() &
          ref(staticFinalDeclarationList) &
          ref(token, ';') |
      ref(CONST) &
          ref(type).optional() &
          ref(staticFinalDeclarationList) &
          ref(token, ';') |
      ref(constInitializedVariableDeclaration) & ref(token, ';');

  classDefinition() =>
      ref(ABSTRACT).optional() &
          ref(CLASS) &
          ref(identifier) &
          ref(typeParameters).optional() &
          ref(superclass).optional() &
          ref(interfaces).optional() &
          ref(token, '{') &
          ref(classMemberDefinition).star() &
          ref(token, '}') |
      ref(ABSTRACT).optional() &
          ref(CLASS) &
          ref(identifier) &
          ref(typeParameters).optional() &
          ref(interfaces).optional() &
          ref(NATIVE) &
          ref(token, STRING) &
          ref(token, '{') &
          ref(classMemberDefinition).star() &
          ref(token, '}');

  typeParameter() => ref(identifier) & (ref(EXTENDS) & ref(type)).optional();

  typeParameters() =>
      ref(token, '<') &
      ref(typeParameter) &
      (ref(token, ',') & ref(typeParameter)).star() &
      ref(token, '>');

  superclass() => ref(EXTENDS) & ref(type);

  interfaces() => ref(IMPLEMENTS) & ref(typeList);

  // This rule is organized in a way that may not be most readable, but
  // gives the best error messages.
  classMemberDefinition() =>
      ref(declaration) & ref(token, ';') |
      ref(constructorDeclaration) & ref(token, ';') |
      ref(methodDeclaration) & ref(functionBodyOrNative) |
      ref(CONST) & ref(factoryConstructorDeclaration) & ref(functionNative);

  functionBodyOrNative() =>
      ref(NATIVE) & ref(functionBody) | ref(functionNative) | ref(functionBody);

  functionNative() =>
      ref(NATIVE) & ref(token, STRING).optional() & ref(token, ';');

  // A method, operator, or constructor (which all should be followed by
  // a block of code).
  methodDeclaration() =>
      ref(factoryConstructorDeclaration) |
      ref(STATIC) & ref(functionDeclaration) |
      ref(specialSignatureDefinition) |
      ref(functionDeclaration) & ref(initializers).optional() |
      ref(namedConstructorDeclaration) & ref(initializers).optional();

  // An abstract method/operator, a field, or const constructor (which
  // all should be followed by a semicolon).
  declaration() =>
      ref(functionDeclaration) & ref(redirection) |
      ref(namedConstructorDeclaration) & ref(redirection) |
      ref(ABSTRACT) & ref(specialSignatureDefinition) |
      ref(ABSTRACT) & ref(functionDeclaration) |
      ref(STATIC) &
          ref(FINAL) &
          ref(type).optional() &
          ref(staticFinalDeclarationList) |
      ref(STATIC).optional() & ref(constInitializedVariableDeclaration);

  initializers() =>
      ref(token, ':') &
      ref(superCallOrFieldInitializer) &
      (ref(token, ',') & ref(superCallOrFieldInitializer)).star();

  redirection() =>
      ref(token, ':') &
      ref(THIS) &
      (ref(token, '.') & ref(identifier)).optional() &
      ref(arguments);

  fieldInitializer() =>
      (ref(THIS) & ref(token, '.')).optional() &
      ref(identifier) &
      ref(token, '=') &
      ref(conditionalExpression);

  superCallOrFieldInitializer() =>
      ref(SUPER) & ref(arguments) |
      ref(SUPER) & ref(token, '.') & ref(identifier) & ref(arguments) |
      ref(fieldInitializer);

  staticFinalDeclarationList() =>
      ref(staticFinalDeclaration) &
      (ref(token, ',') & ref(staticFinalDeclaration)).star();

  staticFinalDeclaration() =>
      ref(identifier) & ref(token, '=') & ref(constantExpression);

  functionTypeAlias() =>
      ref(TYPEDEF) &
      ref(functionPrefix) &
      ref(typeParameters).optional() &
      ref(formalParameterList) &
      ref(token, ';');

  factoryConstructorDeclaration() =>
      ref(FACTORY) &
      ref(qualified) &
      ref(typeParameters).optional() &
      (ref(token, '.') & ref(identifier)).optional() &
      ref(formalParameterList);

  constructorDeclaration() =>
      ref(CONST).optional() &
          ref(identifier) &
          ref(formalParameterList) &
          (ref(redirection) | ref(initializers)).optional() |
      ref(CONST).optional() &
          ref(namedConstructorDeclaration) &
          (ref(redirection) | ref(initializers)).optional();

  namedConstructorDeclaration() =>
      ref(identifier) &
      ref(token, '.') &
      ref(identifier) &
      ref(formalParameterList);

  constantConstructorDeclaration() =>
      ref(CONST) & ref(qualified) & ref(formalParameterList);

  specialSignatureDefinition() =>
      ref(STATIC).optional() &
          ref(returnType).optional() &
          ref(getOrSet) &
          ref(identifier) &
          ref(formalParameterList) |
      ref(returnType).optional() &
          ref(OPERATOR) &
          ref(userDefinableOperator) &
          ref(formalParameterList);

  getOrSet() => ref(GET) | ref(SET);

  userDefinableOperator() =>
      ref(multiplicativeOperator) |
      ref(additiveOperator) |
      ref(shiftOperator) |
      ref(relationalOperator) |
      ref(bitwiseOperator) |
      ref(token, '==') // Disallow negative and === equality checks.
      |
      ref(token, '~') // Disallow ! operator.
      |
      ref(NEGATE) |
      ref(token, '[') & ref(token, ']') |
      ref(token, '[') & ref(token, ']') & ref(token, '=');

  prefixOperator() => ref(additiveOperator) | ref(negateOperator);

  postfixOperator() => ref(incrementOperator);

  negateOperator() => ref(token, '!') | ref(token, '~');

  multiplicativeOperator() =>
      ref(token, '*') | ref(token, '/') | ref(token, '%') | ref(token, '~/');

  assignmentOperator() =>
      ref(token, '=') |
      ref(token, '*=') |
      ref(token, '/=') |
      ref(token, '~/=') |
      ref(token, '%=') |
      ref(token, '+=') |
      ref(token, '-=') |
      ref(token, '<<=') |
      ref(token, '>>>=') |
      ref(token, '>>=') |
      ref(token, '&=') |
      ref(token, '^=') |
      ref(token, '|=');

  additiveOperator() => ref(token, '+') | ref(token, '-');

  incrementOperator() => ref(token, '++') | ref(token, '--');

  shiftOperator() => ref(token, '<<') | ref(token, '>>>') | ref(token, '>>');

  relationalOperator() =>
      ref(token, '>=') | ref(token, '>') | ref(token, '<=') | ref(token, '<');

  equalityOperator() =>
      ref(token, '===') |
      ref(token, '!==') |
      ref(token, '==') |
      ref(token, '!=');

  bitwiseOperator() => ref(token, '&') | ref(token, '^') | ref(token, '|');

  formalParameterList() =>
      ref(token, '(') &
          ref(optionalFormalParameters).optional() &
          ref(token, ')') |
      ref(token, '(') &
          ref(namedFormalParameters).optional() &
          ref(token, ')') |
      ref(token, '(') &
          ref(normalFormalParameter) &
          ref(normalFormalParameterTail).optional() &
          ref(token, ')');

  normalFormalParameterTail() =>
      ref(token, ',') & ref(optionalFormalParameters) |
      ref(token, ',') & ref(namedFormalParameters) |
      ref(token, ',') &
          ref(normalFormalParameter) &
          ref(normalFormalParameterTail).optional();

  normalFormalParameter() =>
      ref(fieldFormalParameter) |
      ref(functionDeclaration) |
      ref(simpleFormalParameter);

  simpleFormalParameter() => ref(declaredIdentifier) | ref(identifier);

  fieldFormalParameter() => ref(THIS) & ref(token, '.') & ref(identifier);

  optionalFormalParameters() =>
      ref(token, '[') &
      ref(defaultFormalParameter) &
      (ref(token, ',') & ref(defaultFormalParameter)).star() &
      ref(token, ']');

  namedFormalParameters() =>
      ref(token, '{') &
      ref(namedFormatParameter) &
      (ref(token, ',') & ref(namedFormatParameter)).star() &
      ref(token, '}');

  namedFormatParameter() =>
      ref(normalFormalParameter) &
      (ref(token, ':') & ref(constantExpression)).optional();

  defaultFormalParameter() =>
      ref(normalFormalParameter) &
      (ref(token, '=') & ref(constantExpression)).optional();

  returnType() => ref(VOID) | ref(type);

  // We have to introduce a separate rule for 'declared' identifiers to
  // allow ANTLR to decide if the first identifier we encounter after
  // final is a type or an identifier. Before this change, we used the
  // production 'finalVarOrType identifier' in numerous places.
  declaredIdentifier() =>
      ref(FINAL) & ref(type).optional() & ref(identifier) |
      ref(VAR) & ref(identifier) |
      ref(type) & ref(identifier);

  identifier() => ref(token, ref(IDENTIFIER));

  qualified() => ref(identifier) & (ref(token, '.') & ref(identifier)).star();

  type() => ref(qualified) & ref(typeArguments).optional();

  typeArguments() => ref(token, '<') & ref(typeList) & ref(token, '>');

  typeList() => ref(type) & (ref(token, ',') & ref(type)).star();

  block() => ref(token, '{') & ref(statements) & ref(token, '}');

  statements() => ref(statement).star();

  statement() => ref(label).star() & ref(nonLabelledStatement);

  nonLabelledStatement() =>
      ref(block) |
      ref(initializedVariableDeclaration) & ref(token, ';') |
      ref(iterationStatement) |
      ref(selectionStatement) |
      ref(tryStatement) |
      ref(BREAK) & ref(identifier).optional() & ref(token, ';') |
      ref(CONTINUE) & ref(identifier).optional() & ref(token, ';') |
      ref(RETURN) & ref(expression).optional() & ref(token, ';') |
      ref(THROW) & ref(expression).optional() & ref(token, ';') |
      ref(expression).optional() & ref(token, ';') |
      ref(ASSERT) &
          ref(token, '(') &
          ref(conditionalExpression) &
          ref(token, ')') &
          ref(token, ';') |
      ref(functionDeclaration) & ref(functionBody);

  label() => ref(identifier) & ref(token, ':');

  iterationStatement() =>
      ref(WHILE) &
          ref(token, '(') &
          ref(expression) &
          ref(token, ')') &
          ref(statement) |
      ref(DO) &
          ref(statement) &
          ref(WHILE) &
          ref(token, '(') &
          ref(expression) &
          ref(token, ')') &
          ref(token, ';') |
      ref(FOR) &
          ref(token, '(') &
          ref(forLoopParts) &
          ref(token, ')') &
          ref(statement);

  forLoopParts() =>
      ref(forInitializerStatement) &
          ref(expression).optional() &
          ref(token, ';') &
          ref(expressionList).optional() |
      ref(declaredIdentifier) & ref(IN) & ref(expression) |
      ref(identifier) & ref(IN) & ref(expression);

  forInitializerStatement() =>
      ref(initializedVariableDeclaration) & ref(token, ';') |
      ref(expression).optional() & ref(token, ';');

  selectionStatement() =>
      ref(IF) &
          ref(token, '(') &
          ref(expression) &
          ref(token, ')') &
          ref(statement) &
          (ref(ELSE) & ref(statement)).optional() |
      ref(SWITCH) &
          ref(token, '(') &
          ref(expression) &
          ref(token, ')') &
          ref(token, '{') &
          ref(switchCase).star() &
          ref(defaultCase).optional() &
          ref(token, '}');

  switchCase() =>
      ref(label).optional() &
      (ref(CASE) & ref(expression) & ref(token, ':')).plus() &
      ref(statements);

  defaultCase() =>
      ref(label).optional() & ref(DEFAULT) & ref(token, ':') & ref(statements);

  tryStatement() =>
      ref(TRY) &
      ref(block) &
      (ref(catchPart).plus() & ref(finallyPart).optional() | ref(finallyPart));

  catchPart() =>
      ref(CATCH) &
      ref(token, '(') &
      ref(declaredIdentifier) &
      (ref(token, ',') & ref(declaredIdentifier)).optional() &
      ref(token, ')') &
      ref(block);

  finallyPart() => ref(FINALLY) & ref(block);

  variableDeclaration() =>
      ref(declaredIdentifier) & (ref(token, ',') & ref(identifier)).star();

  initializedVariableDeclaration() =>
      ref(declaredIdentifier) &
      (ref(token, '=') & ref(expression)).optional() &
      (ref(token, ',') & ref(initializedIdentifier)).star();

  initializedIdentifierList() =>
      ref(initializedIdentifier) &
      (ref(token, ',') & ref(initializedIdentifier)).star();

  initializedIdentifier() =>
      ref(identifier) & (ref(token, '=') & ref(expression)).optional();

  constInitializedVariableDeclaration() =>
      ref(declaredIdentifier) &
      (ref(token, '=') & ref(constantExpression)).optional() &
      (ref(token, ',') & ref(constInitializedIdentifier)).star();

  constInitializedIdentifier() =>
      ref(identifier) & (ref(token, '=') & ref(constantExpression)).optional();

  // The constant expression production is used to mark certain expressions
  // as only being allowed to hold a compile-time constant. The grammar cannot
  // express these restrictions (yet), so this will have to be enforced by a
  // separate analysis phase.
  constantExpression() => ref(expression);

  expression() =>
      ref(assignableExpression) & ref(assignmentOperator) & ref(expression) |
      ref(conditionalExpression);

  expressionList() => ref(expression).separatedBy(ref(token, ','));

  arguments() =>
      ref(token, '(') & ref(argumentList).optional() & ref(token, ')');

  argumentList() => ref(argumentElement).separatedBy(ref(token, ','));

  argumentElement() => ref(label) & ref(expression) | ref(expression);

  assignableExpression() =>
      ref(primary) & (ref(arguments).star() & ref(assignableSelector)).plus() |
      ref(SUPER) & ref(assignableSelector) |
      ref(identifier);

  conditionalExpression() =>
      ref(logicalOrExpression) &
      (ref(token, '?') & ref(expression) & ref(token, ':') & ref(expression))
          .optional();

  logicalOrExpression() =>
      ref(logicalAndExpression) &
      (ref(token, '||') & ref(logicalAndExpression)).star();

  logicalAndExpression() =>
      ref(bitwiseOrExpression) &
      (ref(token, '&&') & ref(bitwiseOrExpression)).star();

  bitwiseOrExpression() =>
      ref(bitwiseXorExpression) &
          (ref(token, '|') & ref(bitwiseXorExpression)).star() |
      ref(SUPER) & (ref(token, '|') & ref(bitwiseXorExpression)).plus();

  bitwiseXorExpression() =>
      ref(bitwiseAndExpression) &
          (ref(token, '^') & ref(bitwiseAndExpression)).star() |
      ref(SUPER) & (ref(token, '^') & ref(bitwiseAndExpression)).plus();

  bitwiseAndExpression() =>
      ref(equalityExpression) &
          (ref(token, '&') & ref(equalityExpression)).star() |
      ref(SUPER) & (ref(token, '&') & ref(equalityExpression)).plus();

  equalityExpression() =>
      ref(relationalExpression) &
          (ref(equalityOperator) & ref(relationalExpression)).optional() |
      ref(SUPER) & ref(equalityOperator) & ref(relationalExpression);

  relationalExpression() =>
      ref(shiftExpression) &
          (ref(isOperator) & ref(type) |
                  ref(relationalOperator) & ref(shiftExpression))
              .optional() |
      ref(SUPER) & ref(relationalOperator) & ref(shiftExpression);

  isOperator() => ref(IS) & ref(token, '!').optional();

  shiftExpression() =>
      ref(additiveExpression) &
          (ref(shiftOperator) & ref(additiveExpression)).star() |
      ref(SUPER) & (ref(shiftOperator) & ref(additiveExpression)).plus();

  additiveExpression() =>
      ref(multiplicativeExpression) &
          (ref(additiveOperator) & ref(multiplicativeExpression)).star() |
      ref(SUPER) &
          (ref(additiveOperator) & ref(multiplicativeExpression)).plus();

  multiplicativeExpression() =>
      ref(unaryExpression) &
          (ref(multiplicativeOperator) & ref(unaryExpression)).star() |
      ref(SUPER) & (ref(multiplicativeOperator) & ref(unaryExpression)).plus();

  unaryExpression() =>
      ref(postfixExpression) |
      ref(prefixOperator) & ref(unaryExpression) |
      ref(negateOperator) & ref(SUPER) |
      ref(token, '-') & ref(SUPER) |
      ref(incrementOperator) & ref(assignableExpression);

  postfixExpression() =>
      ref(assignableExpression) & ref(postfixOperator) |
      ref(primary) & ref(selector).star();

  selector() => ref(assignableSelector) | ref(arguments);

  assignableSelector() =>
      ref(token, '[') & ref(expression) & ref(token, ']') |
      ref(token, '.') & ref(identifier);

  primary() =>
      ref(THIS) |
      ref(SUPER) & ref(assignableSelector) |
      ref(CONST).optional() &
          ref(typeArguments).optional() &
          ref(compoundLiteral) |
      (ref(NEW) | ref(CONST)) &
          ref(type) &
          (ref(token, '.') & ref(identifier)).optional() &
          ref(arguments) |
      ref(functionExpression) |
      ref(expressionInParentheses) |
      ref(literal) |
      ref(identifier);

  expressionInParentheses() =>
      ref(token, '(') & ref(expression) & ref(token, ')');

  literal() => ref(
      token,
      ref(NULL) |
          ref(TRUE) |
          ref(FALSE) |
          ref(HEX_NUMBER) |
          ref(NUMBER) |
          ref(STRING));

  compoundLiteral() => ref(listLiteral) | ref(mapLiteral);

  listLiteral() =>
      ref(token, '[') &
      (ref(expressionList) & ref(token, ',').optional()).optional() &
      ref(token, ']');

  mapLiteral() =>
      ref(token, '{') &
      (ref(mapLiteralEntry) &
              (ref(token, ',') & ref(mapLiteralEntry)).star() &
              ref(token, ',').optional())
          .optional() &
      ref(token, '}');

  mapLiteralEntry() => ref(token, STRING) & ref(token, ':') & ref(expression);

  functionExpression() =>
      ref(returnType).optional() &
      ref(identifier).optional() &
      ref(formalParameterList) &
      ref(functionExpressionBody);

  functionDeclaration() =>
      ref(returnType) & ref(identifier) & ref(formalParameterList) |
      ref(identifier) & ref(formalParameterList);

  functionPrefix() => ref(returnType).optional() & ref(identifier);

  functionBody() =>
      ref(token, '=>') & ref(expression) & ref(token, ';') | ref(block);

  functionExpressionBody() => ref(token, '=>') & ref(expression) | ref(block);

  // -----------------------------------------------------------------
  // Lexical tokens.
  // -----------------------------------------------------------------
  IDENTIFIER() => ref(IDENTIFIER_START) & ref(IDENTIFIER_PART).star();

  HEX_NUMBER() =>
      string('0x') & ref(HEX_DIGIT).plus() |
      string('0X') & ref(HEX_DIGIT).plus();

  NUMBER() =>
      ref(DIGIT).plus() &
          ref(NUMBER_OPT_FRACTIONAL_PART) &
          ref(EXPONENT).optional() &
          ref(NUMBER_OPT_ILLEGAL_END) |
      char('.') &
          ref(DIGIT).plus() &
          ref(EXPONENT).optional() &
          ref(NUMBER_OPT_ILLEGAL_END);

  NUMBER_OPT_FRACTIONAL_PART() => char('.') & ref(DIGIT).plus() | epsilon();

  NUMBER_OPT_ILLEGAL_END() => epsilon();
//        ref(IDENTIFIER_START).end()
//      | epsilon()
//      ;

  HEX_DIGIT() => pattern('0-9a-fA-F');

  IDENTIFIER_START() => ref(IDENTIFIER_START_NO_DOLLAR) | char('\$');

  IDENTIFIER_START_NO_DOLLAR() => ref(LETTER) | char('_');

  IDENTIFIER_PART() => ref(IDENTIFIER_START) | ref(DIGIT);

  LETTER() => letter();

  DIGIT() => digit();

  EXPONENT() => pattern('eE') & pattern('+-').optional() & ref(DIGIT).plus();

  STRING() =>
      char('@').optional() & ref(MULTI_LINE_STRING) | ref(SINGLE_LINE_STRING);

  MULTI_LINE_STRING() =>
      string('"""') & any().starLazy(string('"""')) & string('"""') |
      string("'''") & any().starLazy(string("'''")) & string("'''");

  SINGLE_LINE_STRING() =>
      char('"') & ref(STRING_CONTENT_DQ).star() & char('"') |
      char("'") & ref(STRING_CONTENT_SQ).star() & char("'") |
      string('@"') & pattern('^"\n\r').star() & char('"') |
      string("@'") & pattern("^'\n\r").star() & char("'");

  STRING_CONTENT_DQ() => pattern('^\\"\n\r') | char('\\') & pattern('\n\r');

  STRING_CONTENT_SQ() => pattern("^\\'\n\r") | char('\\') & pattern('\n\r');

  NEWLINE() => pattern('\n\r');

  HASHBANG() =>
      string('#!') & pattern('^\n\r').star() & ref(NEWLINE).optional();

  // -----------------------------------------------------------------
  // Whitespace and comments.
  // -----------------------------------------------------------------
  HIDDEN() => ref(HIDDEN_STUFF).plus();

  HIDDEN_STUFF() =>
      ref(WHITESPACE) | ref(SINGLE_LINE_COMMENT) | ref(MULTI_LINE_COMMENT);

  WHITESPACE() => whitespace();

  SINGLE_LINE_COMMENT() =>
      string('//') & ref(NEWLINE).neg().star() & ref(NEWLINE).optional();

  MULTI_LINE_COMMENT() =>
      string('/*') &
      (ref(MULTI_LINE_COMMENT) | string('*/').neg()).star() &
      string('*/');
}
