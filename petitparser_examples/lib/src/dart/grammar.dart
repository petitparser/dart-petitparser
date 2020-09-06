import 'package:petitparser/petitparser.dart';

/// Dart grammar.
class DartGrammar extends GrammarParser {
  DartGrammar() : super(DartGrammarDefinition());
}

/// Dart grammar definition.
class DartGrammarDefinition extends GrammarDefinition {
  Parser token(Object input) {
    if (input is Parser) {
      return input.token().trim(ref0(HIDDEN_STUFF));
    } else if (input is String) {
      return token(input.toParser());
    } else if (input is Function) {
      return token(ref0(input));
    }
    throw ArgumentError.value(input, 'invalid token parser');
  }

  // Copyright (c) 2011, the Dart project authors. Please see the AUTHORS file
  // for details. All rights reserved. Use of this source code is governed by a
  // BSD-style license that can be found in the LICENSE file.

  // -----------------------------------------------------------------
  // Keyword definitions.
  // -----------------------------------------------------------------
  Parser BREAK() => ref1(token, 'break');
  Parser CASE() => ref1(token, 'case');
  Parser CATCH() => ref1(token, 'catch');
  Parser CONST() => ref1(token, 'const');
  Parser CONTINUE() => ref1(token, 'continue');
  Parser DEFAULT() => ref1(token, 'default');
  Parser DO() => ref1(token, 'do');
  Parser ELSE() => ref1(token, 'else');
  Parser FALSE() => ref1(token, 'false');
  Parser FINAL() => ref1(token, 'final');
  Parser FINALLY() => ref1(token, 'finally');
  Parser FOR() => ref1(token, 'for');
  Parser IF() => ref1(token, 'if');
  Parser IN() => ref1(token, 'in');
  Parser NEW() => ref1(token, 'new');
  Parser NULL() => ref1(token, 'null');
  Parser RETURN() => ref1(token, 'return');
  Parser SUPER() => ref1(token, 'super');
  Parser SWITCH() => ref1(token, 'switch');
  Parser THIS() => ref1(token, 'this');
  Parser THROW() => ref1(token, 'throw');
  Parser TRUE() => ref1(token, 'true');
  Parser TRY() => ref1(token, 'try');
  Parser VAR() => ref1(token, 'var');
  Parser VOID() => ref1(token, 'void');
  Parser WHILE() => ref1(token, 'while');

  // Pseudo-keywords that should also be valid identifiers.
  Parser ABSTRACT() => ref1(token, 'abstract');
  Parser AS() => ref1(token, 'as');
  Parser ASSERT() => ref1(token, 'assert');
  Parser CLASS() => ref1(token, 'class');
  Parser DEFERRED() => ref1(token, 'deferred');
  Parser EXPORT() => ref1(token, 'export');
  Parser EXTENDS() => ref1(token, 'extends');
  Parser FACTORY() => ref1(token, 'factory');
  Parser GET() => ref1(token, 'get');
  Parser HIDE() => ref1(token, 'hide');
  Parser IMPLEMENTS() => ref1(token, 'implements');
  Parser IMPORT() => ref1(token, 'import');
  Parser IS() => ref1(token, 'is');
  Parser LIBRARY() => ref1(token, 'library');
  Parser NATIVE() => ref1(token, 'native');
  Parser NEGATE() => ref1(token, 'negate');
  Parser OF() => ref1(token, 'of');
  Parser OPERATOR() => ref1(token, 'operator');
  Parser PART() => ref1(token, 'part');
  Parser SET() => ref1(token, 'set');
  Parser SHOW() => ref1(token, 'show');
  Parser STATIC() => ref1(token, 'static');
  Parser TYPEDEF() => ref1(token, 'typedef');

  // -----------------------------------------------------------------
  // Grammar productions.
  // -----------------------------------------------------------------
  Parser start() => ref0(compilationUnit).end();

  Parser compilationUnit() =>
      ref0(HASHBANG).optional() &
      ref0(libraryDirective).optional() &
      ref0(importDirective).star() &
      ref0(topLevelDefinition).star();

  Parser libraryDirective() =>
      ref0(LIBRARY) & ref0(qualified) & ref1(token, ';') |
      ref0(PART) & ref0(OF) & ref0(qualified) & ref1(token, ';');

  Parser importDirective() =>
      ref0(IMPORT) &
          ref0(SINGLE_LINE_STRING) &
          ref0(DEFERRED).optional() &
          (ref0(AS) & ref0(identifier)).optional() &
          ((ref0(SHOW) | ref0(HIDE)) &
                  ref0(identifier).separatedBy(ref1(token, ',')))
              .optional() &
          ref1(token, ';') |
      ref0(EXPORT) &
          ref0(SINGLE_LINE_STRING) &
          ((ref0(SHOW) | ref0(HIDE)) &
                  ref0(identifier).separatedBy(ref1(token, ',')))
              .optional() &
          ref1(token, ';') |
      ref0(PART) & ref0(SINGLE_LINE_STRING) & ref1(token, ';');

  Parser topLevelDefinition() =>
      ref0(classDefinition) |
      ref0(functionTypeAlias) |
      ref0(functionDeclaration) & ref0(functionBodyOrNative) |
      ref0(returnType).optional() &
          ref0(getOrSet) &
          ref0(identifier) &
          ref0(formalParameterList) &
          ref0(functionBodyOrNative) |
      ref0(FINAL) &
          ref0(type).optional() &
          ref0(staticFinalDeclarationList) &
          ref1(token, ';') |
      ref0(CONST) &
          ref0(type).optional() &
          ref0(staticFinalDeclarationList) &
          ref1(token, ';') |
      ref0(constInitializedVariableDeclaration) & ref1(token, ';');

  Parser classDefinition() =>
      ref0(ABSTRACT).optional() &
          ref0(CLASS) &
          ref0(identifier) &
          ref0(typeParameters).optional() &
          ref0(superclass).optional() &
          ref0(interfaces).optional() &
          ref1(token, '{') &
          ref0(classMemberDefinition).star() &
          ref1(token, '}') |
      ref0(ABSTRACT).optional() &
          ref0(CLASS) &
          ref0(identifier) &
          ref0(typeParameters).optional() &
          ref0(interfaces).optional() &
          ref0(NATIVE) &
          ref1(token, STRING) &
          ref1(token, '{') &
          ref0(classMemberDefinition).star() &
          ref1(token, '}');

  Parser typeParameter() =>
      ref0(identifier) & (ref0(EXTENDS) & ref0(type)).optional();

  Parser typeParameters() =>
      ref1(token, '<') &
      ref0(typeParameter) &
      (ref1(token, ',') & ref0(typeParameter)).star() &
      ref1(token, '>');

  Parser superclass() => ref0(EXTENDS) & ref0(type);

  Parser interfaces() => ref0(IMPLEMENTS) & ref0(typeList);

  // This rule is organized in a way that may not be most readable, but
  // gives the best error messages.
  Parser classMemberDefinition() =>
      ref0(declaration) & ref1(token, ';') |
      ref0(constructorDeclaration) & ref1(token, ';') |
      ref0(methodDeclaration) & ref0(functionBodyOrNative) |
      ref0(CONST) & ref0(factoryConstructorDeclaration) & ref0(functionNative);

  Parser functionBodyOrNative() =>
      ref0(NATIVE) & ref0(functionBody) |
      ref0(functionNative) |
      ref0(functionBody);

  Parser functionNative() =>
      ref0(NATIVE) & ref1(token, STRING).optional() & ref1(token, ';');

  // A method, operator, or constructor (which all should be followed by
  // a block of code).
  Parser methodDeclaration() =>
      ref0(factoryConstructorDeclaration) |
      ref0(STATIC) & ref0(functionDeclaration) |
      ref0(specialSignatureDefinition) |
      ref0(functionDeclaration) & ref0(initializers).optional() |
      ref0(namedConstructorDeclaration) & ref0(initializers).optional();

  // An abstract method/operator, a field, or const constructor (which
  // all should be followed by a semicolon).
  Parser declaration() =>
      ref0(functionDeclaration) & ref0(redirection) |
      ref0(namedConstructorDeclaration) & ref0(redirection) |
      ref0(ABSTRACT) & ref0(specialSignatureDefinition) |
      ref0(ABSTRACT) & ref0(functionDeclaration) |
      ref0(STATIC) &
          ref0(FINAL) &
          ref0(type).optional() &
          ref0(staticFinalDeclarationList) |
      ref0(STATIC).optional() & ref0(constInitializedVariableDeclaration);

  Parser initializers() =>
      ref1(token, ':') &
      ref0(superCallOrFieldInitializer) &
      (ref1(token, ',') & ref0(superCallOrFieldInitializer)).star();

  Parser redirection() =>
      ref1(token, ':') &
      ref0(THIS) &
      (ref1(token, '.') & ref0(identifier)).optional() &
      ref0(arguments);

  Parser fieldInitializer() =>
      (ref0(THIS) & ref1(token, '.')).optional() &
      ref0(identifier) &
      ref1(token, '=') &
      ref0(conditionalExpression);

  Parser superCallOrFieldInitializer() =>
      ref0(SUPER) & ref0(arguments) |
      ref0(SUPER) & ref1(token, '.') & ref0(identifier) & ref0(arguments) |
      ref0(fieldInitializer);

  Parser staticFinalDeclarationList() =>
      ref0(staticFinalDeclaration) &
      (ref1(token, ',') & ref0(staticFinalDeclaration)).star();

  Parser staticFinalDeclaration() =>
      ref0(identifier) & ref1(token, '=') & ref0(constantExpression);

  Parser functionTypeAlias() =>
      ref0(TYPEDEF) &
      ref0(functionPrefix) &
      ref0(typeParameters).optional() &
      ref0(formalParameterList) &
      ref1(token, ';');

  Parser factoryConstructorDeclaration() =>
      ref0(FACTORY) &
      ref0(qualified) &
      ref0(typeParameters).optional() &
      (ref1(token, '.') & ref0(identifier)).optional() &
      ref0(formalParameterList);

  Parser constructorDeclaration() =>
      ref0(CONST).optional() &
          ref0(identifier) &
          ref0(formalParameterList) &
          (ref0(redirection) | ref0(initializers)).optional() |
      ref0(CONST).optional() &
          ref0(namedConstructorDeclaration) &
          (ref0(redirection) | ref0(initializers)).optional();

  Parser namedConstructorDeclaration() =>
      ref0(identifier) &
      ref1(token, '.') &
      ref0(identifier) &
      ref0(formalParameterList);

  Parser constantConstructorDeclaration() =>
      ref0(CONST) & ref0(qualified) & ref0(formalParameterList);

  Parser specialSignatureDefinition() =>
      ref0(STATIC).optional() &
          ref0(returnType).optional() &
          ref0(getOrSet) &
          ref0(identifier) &
          ref0(formalParameterList) |
      ref0(returnType).optional() &
          ref0(OPERATOR) &
          ref0(userDefinableOperator) &
          ref0(formalParameterList);

  Parser getOrSet() => ref0(GET) | ref0(SET);

  Parser userDefinableOperator() =>
      ref0(multiplicativeOperator) |
      ref0(additiveOperator) |
      ref0(shiftOperator) |
      ref0(relationalOperator) |
      ref0(bitwiseOperator) |
      ref1(token, '==') // Disallow negative and === equality checks.
      |
      ref1(token, '~') // Disallow ! operator.
      |
      ref0(NEGATE) |
      ref1(token, '[') & ref1(token, ']') |
      ref1(token, '[') & ref1(token, ']') & ref1(token, '=');

  Parser prefixOperator() => ref0(additiveOperator) | ref0(negateOperator);

  Parser postfixOperator() => ref0(incrementOperator);

  Parser negateOperator() => ref1(token, '!') | ref1(token, '~');

  Parser multiplicativeOperator() =>
      ref1(token, '*') |
      ref1(token, '/') |
      ref1(token, '%') |
      ref1(token, '~/');

  Parser assignmentOperator() =>
      ref1(token, '=') |
      ref1(token, '*=') |
      ref1(token, '/=') |
      ref1(token, '~/=') |
      ref1(token, '%=') |
      ref1(token, '+=') |
      ref1(token, '-=') |
      ref1(token, '<<=') |
      ref1(token, '>>>=') |
      ref1(token, '>>=') |
      ref1(token, '&=') |
      ref1(token, '^=') |
      ref1(token, '|=');

  Parser additiveOperator() => ref1(token, '+') | ref1(token, '-');

  Parser incrementOperator() => ref1(token, '++') | ref1(token, '--');

  Parser shiftOperator() =>
      ref1(token, '<<') | ref1(token, '>>>') | ref1(token, '>>');

  Parser relationalOperator() =>
      ref1(token, '>=') |
      ref1(token, '>') |
      ref1(token, '<=') |
      ref1(token, '<');

  Parser equalityOperator() =>
      ref1(token, '===') |
      ref1(token, '!==') |
      ref1(token, '==') |
      ref1(token, '!=');

  Parser bitwiseOperator() =>
      ref1(token, '&') | ref1(token, '^') | ref1(token, '|');

  Parser formalParameterList() =>
      ref1(token, '(') &
          ref0(optionalFormalParameters).optional() &
          ref1(token, ')') |
      ref1(token, '(') &
          ref0(namedFormalParameters).optional() &
          ref1(token, ')') |
      ref1(token, '(') &
          ref0(normalFormalParameter) &
          ref0(normalFormalParameterTail).optional() &
          ref1(token, ')');

  Parser normalFormalParameterTail() =>
      ref1(token, ',') & ref0(optionalFormalParameters) |
      ref1(token, ',') & ref0(namedFormalParameters) |
      ref1(token, ',') &
          ref0(normalFormalParameter) &
          ref0(normalFormalParameterTail).optional();

  Parser normalFormalParameter() =>
      ref0(fieldFormalParameter) |
      ref0(functionDeclaration) |
      ref0(simpleFormalParameter);

  Parser simpleFormalParameter() => ref0(declaredIdentifier) | ref0(identifier);

  Parser fieldFormalParameter() =>
      ref0(THIS) & ref1(token, '.') & ref0(identifier);

  Parser optionalFormalParameters() =>
      ref1(token, '[') &
      ref0(defaultFormalParameter) &
      (ref1(token, ',') & ref0(defaultFormalParameter)).star() &
      ref1(token, ']');

  Parser namedFormalParameters() =>
      ref1(token, '{') &
      ref0(namedFormatParameter) &
      (ref1(token, ',') & ref0(namedFormatParameter)).star() &
      ref1(token, '}');

  Parser namedFormatParameter() =>
      ref0(normalFormalParameter) &
      (ref1(token, ':') & ref0(constantExpression)).optional();

  Parser defaultFormalParameter() =>
      ref0(normalFormalParameter) &
      (ref1(token, '=') & ref0(constantExpression)).optional();

  Parser returnType() => ref0(VOID) | ref0(type);

  // We have to introduce a separate rule for 'declared' identifiers to
  // allow ANTLR to decide if the first identifier we encounter after
  // final is a type or an identifier. Before this change, we used the
  // production 'finalVarOrType identifier' in numerous places.
  Parser declaredIdentifier() =>
      ref0(FINAL) & ref0(type).optional() & ref0(identifier) |
      ref0(VAR) & ref0(identifier) |
      ref0(type) & ref0(identifier);

  Parser identifier() => ref1(token, ref0(IDENTIFIER));

  Parser qualified() =>
      ref0(identifier) & (ref1(token, '.') & ref0(identifier)).star();

  Parser type() => ref0(qualified) & ref0(typeArguments).optional();

  Parser typeArguments() =>
      ref1(token, '<') & ref0(typeList) & ref1(token, '>');

  Parser typeList() => ref0(type) & (ref1(token, ',') & ref0(type)).star();

  Parser block() => ref1(token, '{') & ref0(statements) & ref1(token, '}');

  Parser statements() => ref0(statement).star();

  Parser statement() => ref0(label).star() & ref0(nonLabelledStatement);

  Parser nonLabelledStatement() =>
      ref0(block) |
      ref0(initializedVariableDeclaration) & ref1(token, ';') |
      ref0(iterationStatement) |
      ref0(selectionStatement) |
      ref0(tryStatement) |
      ref0(BREAK) & ref0(identifier).optional() & ref1(token, ';') |
      ref0(CONTINUE) & ref0(identifier).optional() & ref1(token, ';') |
      ref0(RETURN) & ref0(expression).optional() & ref1(token, ';') |
      ref0(THROW) & ref0(expression).optional() & ref1(token, ';') |
      ref0(expression).optional() & ref1(token, ';') |
      ref0(ASSERT) &
          ref1(token, '(') &
          ref0(conditionalExpression) &
          ref1(token, ')') &
          ref1(token, ';') |
      ref0(functionDeclaration) & ref0(functionBody);

  Parser label() => ref0(identifier) & ref1(token, ':');

  Parser iterationStatement() =>
      ref0(WHILE) &
          ref1(token, '(') &
          ref0(expression) &
          ref1(token, ')') &
          ref0(statement) |
      ref0(DO) &
          ref0(statement) &
          ref0(WHILE) &
          ref1(token, '(') &
          ref0(expression) &
          ref1(token, ')') &
          ref1(token, ';') |
      ref0(FOR) &
          ref1(token, '(') &
          ref0(forLoopParts) &
          ref1(token, ')') &
          ref0(statement);

  Parser forLoopParts() =>
      ref0(forInitializerStatement) &
          ref0(expression).optional() &
          ref1(token, ';') &
          ref0(expressionList).optional() |
      ref0(declaredIdentifier) & ref0(IN) & ref0(expression) |
      ref0(identifier) & ref0(IN) & ref0(expression);

  Parser forInitializerStatement() =>
      ref0(initializedVariableDeclaration) & ref1(token, ';') |
      ref0(expression).optional() & ref1(token, ';');

  Parser selectionStatement() =>
      ref0(IF) &
          ref1(token, '(') &
          ref0(expression) &
          ref1(token, ')') &
          ref0(statement) &
          (ref0(ELSE) & ref0(statement)).optional() |
      ref0(SWITCH) &
          ref1(token, '(') &
          ref0(expression) &
          ref1(token, ')') &
          ref1(token, '{') &
          ref0(switchCase).star() &
          ref0(defaultCase).optional() &
          ref1(token, '}');

  Parser switchCase() =>
      ref0(label).optional() &
      (ref0(CASE) & ref0(expression) & ref1(token, ':')).plus() &
      ref0(statements);

  Parser defaultCase() =>
      ref0(label).optional() &
      ref0(DEFAULT) &
      ref1(token, ':') &
      ref0(statements);

  Parser tryStatement() =>
      ref0(TRY) &
      ref0(block) &
      (ref0(catchPart).plus() & ref0(finallyPart).optional() |
          ref0(finallyPart));

  Parser catchPart() =>
      ref0(CATCH) &
      ref1(token, '(') &
      ref0(declaredIdentifier) &
      (ref1(token, ',') & ref0(declaredIdentifier)).optional() &
      ref1(token, ')') &
      ref0(block);

  Parser finallyPart() => ref0(FINALLY) & ref0(block);

  Parser variableDeclaration() =>
      ref0(declaredIdentifier) & (ref1(token, ',') & ref0(identifier)).star();

  Parser initializedVariableDeclaration() =>
      ref0(declaredIdentifier) &
      (ref1(token, '=') & ref0(expression)).optional() &
      (ref1(token, ',') & ref0(initializedIdentifier)).star();

  Parser initializedIdentifierList() =>
      ref0(initializedIdentifier) &
      (ref1(token, ',') & ref0(initializedIdentifier)).star();

  Parser initializedIdentifier() =>
      ref0(identifier) & (ref1(token, '=') & ref0(expression)).optional();

  Parser constInitializedVariableDeclaration() =>
      ref0(declaredIdentifier) &
      (ref1(token, '=') & ref0(constantExpression)).optional() &
      (ref1(token, ',') & ref0(constInitializedIdentifier)).star();

  Parser constInitializedIdentifier() =>
      ref0(identifier) &
      (ref1(token, '=') & ref0(constantExpression)).optional();

  // The constant expression production is used to mark certain expressions
  // as only being allowed to hold a compile-time constant. The grammar cannot
  // express these restrictions (yet), so this will have to be enforced by a
  // separate analysis phase.
  Parser constantExpression() => ref0(expression);

  Parser expression() =>
      ref0(assignableExpression) & ref0(assignmentOperator) & ref0(expression) |
      ref0(conditionalExpression);

  Parser expressionList() => ref0(expression).separatedBy(ref1(token, ','));

  Parser arguments() =>
      ref1(token, '(') & ref0(argumentList).optional() & ref1(token, ')');

  Parser argumentList() => ref0(argumentElement).separatedBy(ref1(token, ','));

  Parser argumentElement() => ref0(label) & ref0(expression) | ref0(expression);

  Parser assignableExpression() =>
      ref0(primary) &
          (ref0(arguments).star() & ref0(assignableSelector)).plus() |
      ref0(SUPER) & ref0(assignableSelector) |
      ref0(identifier);

  Parser conditionalExpression() =>
      ref0(logicalOrExpression) &
      (ref1(token, '?') &
              ref0(expression) &
              ref1(token, ':') &
              ref0(expression))
          .optional();

  Parser logicalOrExpression() =>
      ref0(logicalAndExpression) &
      (ref1(token, '||') & ref0(logicalAndExpression)).star();

  Parser logicalAndExpression() =>
      ref0(bitwiseOrExpression) &
      (ref1(token, '&&') & ref0(bitwiseOrExpression)).star();

  Parser bitwiseOrExpression() =>
      ref0(bitwiseXorExpression) &
          (ref1(token, '|') & ref0(bitwiseXorExpression)).star() |
      ref0(SUPER) & (ref1(token, '|') & ref0(bitwiseXorExpression)).plus();

  Parser bitwiseXorExpression() =>
      ref0(bitwiseAndExpression) &
          (ref1(token, '^') & ref0(bitwiseAndExpression)).star() |
      ref0(SUPER) & (ref1(token, '^') & ref0(bitwiseAndExpression)).plus();

  Parser bitwiseAndExpression() =>
      ref0(equalityExpression) &
          (ref1(token, '&') & ref0(equalityExpression)).star() |
      ref0(SUPER) & (ref1(token, '&') & ref0(equalityExpression)).plus();

  Parser equalityExpression() =>
      ref0(relationalExpression) &
          (ref0(equalityOperator) & ref0(relationalExpression)).optional() |
      ref0(SUPER) & ref0(equalityOperator) & ref0(relationalExpression);

  Parser relationalExpression() =>
      ref0(shiftExpression) &
          (ref0(isOperator) & ref0(type) |
                  ref0(relationalOperator) & ref0(shiftExpression))
              .optional() |
      ref0(SUPER) & ref0(relationalOperator) & ref0(shiftExpression);

  Parser isOperator() => ref0(IS) & ref1(token, '!').optional();

  Parser shiftExpression() =>
      ref0(additiveExpression) &
          (ref0(shiftOperator) & ref0(additiveExpression)).star() |
      ref0(SUPER) & (ref0(shiftOperator) & ref0(additiveExpression)).plus();

  Parser additiveExpression() =>
      ref0(multiplicativeExpression) &
          (ref0(additiveOperator) & ref0(multiplicativeExpression)).star() |
      ref0(SUPER) &
          (ref0(additiveOperator) & ref0(multiplicativeExpression)).plus();

  Parser multiplicativeExpression() =>
      ref0(unaryExpression) &
          (ref0(multiplicativeOperator) & ref0(unaryExpression)).star() |
      ref0(SUPER) &
          (ref0(multiplicativeOperator) & ref0(unaryExpression)).plus();

  Parser unaryExpression() =>
      ref0(postfixExpression) |
      ref0(prefixOperator) & ref0(unaryExpression) |
      ref0(negateOperator) & ref0(SUPER) |
      ref1(token, '-') & ref0(SUPER) |
      ref0(incrementOperator) & ref0(assignableExpression);

  Parser postfixExpression() =>
      ref0(assignableExpression) & ref0(postfixOperator) |
      ref0(primary) & ref0(selector).star();

  Parser selector() => ref0(assignableSelector) | ref0(arguments);

  Parser assignableSelector() =>
      ref1(token, '[') & ref0(expression) & ref1(token, ']') |
      ref1(token, '.') & ref0(identifier);

  Parser primary() =>
      ref0(THIS) |
      ref0(SUPER) & ref0(assignableSelector) |
      ref0(CONST).optional() &
          ref0(typeArguments).optional() &
          ref0(compoundLiteral) |
      (ref0(NEW) | ref0(CONST)) &
          ref0(type) &
          (ref1(token, '.') & ref0(identifier)).optional() &
          ref0(arguments) |
      ref0(functionExpression) |
      ref0(expressionInParentheses) |
      ref0(literal) |
      ref0(identifier);

  Parser expressionInParentheses() =>
      ref1(token, '(') & ref0(expression) & ref1(token, ')');

  Parser literal() => ref1(
      token,
      ref0(NULL) |
          ref0(TRUE) |
          ref0(FALSE) |
          ref0(HEX_NUMBER) |
          ref0(NUMBER) |
          ref0(STRING));

  Parser compoundLiteral() => ref0(listLiteral) | ref0(mapLiteral);

  Parser listLiteral() =>
      ref1(token, '[') &
      (ref0(expressionList) & ref1(token, ',').optional()).optional() &
      ref1(token, ']');

  Parser mapLiteral() =>
      ref1(token, '{') &
      (ref0(mapLiteralEntry) &
              (ref1(token, ',') & ref0(mapLiteralEntry)).star() &
              ref1(token, ',').optional())
          .optional() &
      ref1(token, '}');

  Parser mapLiteralEntry() =>
      ref1(token, STRING) & ref1(token, ':') & ref0(expression);

  Parser functionExpression() =>
      ref0(returnType).optional() &
      ref0(identifier).optional() &
      ref0(formalParameterList) &
      ref0(functionExpressionBody);

  Parser functionDeclaration() =>
      ref0(returnType) & ref0(identifier) & ref0(formalParameterList) |
      ref0(identifier) & ref0(formalParameterList);

  Parser functionPrefix() => ref0(returnType).optional() & ref0(identifier);

  Parser functionBody() =>
      ref1(token, '=>') & ref0(expression) & ref1(token, ';') | ref0(block);

  Parser functionExpressionBody() =>
      ref1(token, '=>') & ref0(expression) | ref0(block);

  // -----------------------------------------------------------------
  // Lexical tokens.
  // -----------------------------------------------------------------
  Parser IDENTIFIER() => ref0(IDENTIFIER_START) & ref0(IDENTIFIER_PART).star();

  Parser HEX_NUMBER() =>
      string('0x') & ref0(HEX_DIGIT).plus() |
      string('0X') & ref0(HEX_DIGIT).plus();

  Parser NUMBER() =>
      ref0(DIGIT).plus() &
          ref0(NUMBER_OPT_FRACTIONAL_PART) &
          ref0(EXPONENT).optional() &
          ref0(NUMBER_OPT_ILLEGAL_END) |
      char('.') &
          ref0(DIGIT).plus() &
          ref0(EXPONENT).optional() &
          ref0(NUMBER_OPT_ILLEGAL_END);

  Parser NUMBER_OPT_FRACTIONAL_PART() =>
      char('.') & ref0(DIGIT).plus() | epsilon();

  Parser NUMBER_OPT_ILLEGAL_END() => epsilon();
//        ref0(IDENTIFIER_START).end()
//      | epsilon()
//      ;

  Parser HEX_DIGIT() => pattern('0-9a-fA-F');

  Parser IDENTIFIER_START() => ref0(IDENTIFIER_START_NO_DOLLAR) | char('\$');

  Parser IDENTIFIER_START_NO_DOLLAR() => ref0(LETTER) | char('_');

  Parser IDENTIFIER_PART() => ref0(IDENTIFIER_START) | ref0(DIGIT);

  Parser LETTER() => letter();

  Parser DIGIT() => digit();

  Parser EXPONENT() =>
      pattern('eE') & pattern('+-').optional() & ref0(DIGIT).plus();

  Parser STRING() =>
      char('@').optional() & ref0(MULTI_LINE_STRING) | ref0(SINGLE_LINE_STRING);

  Parser MULTI_LINE_STRING() =>
      string('"""') & any().starLazy(string('"""')) & string('"""') |
      string("'''") & any().starLazy(string("'''")) & string("'''");

  Parser SINGLE_LINE_STRING() =>
      char('"') & ref0(STRING_CONTENT_DQ).star() & char('"') |
      char("'") & ref0(STRING_CONTENT_SQ).star() & char("'") |
      string('@"') & pattern('^"\n\r').star() & char('"') |
      string("@'") & pattern("^'\n\r").star() & char("'");

  Parser STRING_CONTENT_DQ() =>
      pattern('^\\"\n\r') | char('\\') & pattern('\n\r');

  Parser STRING_CONTENT_SQ() =>
      pattern("^\\'\n\r") | char('\\') & pattern('\n\r');

  Parser NEWLINE() => pattern('\n\r');

  Parser HASHBANG() =>
      string('#!') & pattern('^\n\r').star() & ref0(NEWLINE).optional();

  // -----------------------------------------------------------------
  // Whitespace and comments.
  // -----------------------------------------------------------------
  Parser HIDDEN() => ref0(HIDDEN_STUFF).plus();

  Parser HIDDEN_STUFF() =>
      ref0(WHITESPACE) | ref0(SINGLE_LINE_COMMENT) | ref0(MULTI_LINE_COMMENT);

  Parser WHITESPACE() => whitespace();

  Parser SINGLE_LINE_COMMENT() =>
      string('//') & ref0(NEWLINE).neg().star() & ref0(NEWLINE).optional();

  Parser MULTI_LINE_COMMENT() =>
      string('/*') &
      (ref0(MULTI_LINE_COMMENT) | string('*/').neg()).star() &
      string('*/');
}
