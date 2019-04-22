library petitparser.example.dart.grammar;

import 'package:petitparser/petitparser.dart';

/// Dart grammar.
class DartGrammar extends GrammarParser {
  DartGrammar() : super(DartGrammarDefinition());
}

/// Dart grammar definition.
class DartGrammarDefinition extends GrammarDefinition {
  Parser token(Object input) {
    if (input is Parser) {
      return input.token().trim(ref(HIDDEN_STUFF));
    } else if (input is String) {
      return token(input.length == 1 ? char(input) : string(input));
    } else if (input is Function) {
      return token(ref(input));
    }
    throw ArgumentError.value(input, 'invalid token parser');
  }

  // Copyright (c) 2011, the Dart project authors. Please see the AUTHORS file
  // for details. All rights reserved. Use of this source code is governed by a
  // BSD-style license that can be found in the LICENSE file.

  // -----------------------------------------------------------------
  // Keyword definitions.
  // -----------------------------------------------------------------
  Parser BREAK() => ref(token, 'break');
  Parser CASE() => ref(token, 'case');
  Parser CATCH() => ref(token, 'catch');
  Parser CONST() => ref(token, 'const');
  Parser CONTINUE() => ref(token, 'continue');
  Parser DEFAULT() => ref(token, 'default');
  Parser DO() => ref(token, 'do');
  Parser ELSE() => ref(token, 'else');
  Parser FALSE() => ref(token, 'false');
  Parser FINAL() => ref(token, 'final');
  Parser FINALLY() => ref(token, 'finally');
  Parser FOR() => ref(token, 'for');
  Parser IF() => ref(token, 'if');
  Parser IN() => ref(token, 'in');
  Parser NEW() => ref(token, 'new');
  Parser NULL() => ref(token, 'null');
  Parser RETURN() => ref(token, 'return');
  Parser SUPER() => ref(token, 'super');
  Parser SWITCH() => ref(token, 'switch');
  Parser THIS() => ref(token, 'this');
  Parser THROW() => ref(token, 'throw');
  Parser TRUE() => ref(token, 'true');
  Parser TRY() => ref(token, 'try');
  Parser VAR() => ref(token, 'var');
  Parser VOID() => ref(token, 'void');
  Parser WHILE() => ref(token, 'while');

  // Pseudo-keywords that should also be valid identifiers.
  Parser ABSTRACT() => ref(token, 'abstract');
  Parser AS() => ref(token, 'as');
  Parser ASSERT() => ref(token, 'assert');
  Parser CLASS() => ref(token, 'class');
  Parser DEFERRED() => ref(token, 'deferred');
  Parser EXPORT() => ref(token, 'export');
  Parser EXTENDS() => ref(token, 'extends');
  Parser FACTORY() => ref(token, 'factory');
  Parser GET() => ref(token, 'get');
  Parser HIDE() => ref(token, 'hide');
  Parser IMPLEMENTS() => ref(token, 'implements');
  Parser IMPORT() => ref(token, 'import');
  Parser IS() => ref(token, 'is');
  Parser LIBRARY() => ref(token, 'library');
  Parser NATIVE() => ref(token, 'native');
  Parser NEGATE() => ref(token, 'negate');
  Parser OF() => ref(token, 'of');
  Parser OPERATOR() => ref(token, 'operator');
  Parser PART() => ref(token, 'part');
  Parser SET() => ref(token, 'set');
  Parser SHOW() => ref(token, 'show');
  Parser STATIC() => ref(token, 'static');
  Parser TYPEDEF() => ref(token, 'typedef');

  // -----------------------------------------------------------------
  // Grammar productions.
  // -----------------------------------------------------------------
  Parser start() => ref(compilationUnit).end();

  Parser compilationUnit() =>
      ref(HASHBANG).optional() &
      ref(libraryDirective).optional() &
      ref(importDirective).star() &
      ref(topLevelDefinition).star();

  Parser libraryDirective() =>
      ref(LIBRARY) & ref(qualified) & ref(token, ';') |
      ref(PART) & ref(OF) & ref(qualified) & ref(token, ';');

  Parser importDirective() =>
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

  Parser topLevelDefinition() =>
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

  Parser classDefinition() =>
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

  Parser typeParameter() =>
      ref(identifier) & (ref(EXTENDS) & ref(type)).optional();

  Parser typeParameters() =>
      ref(token, '<') &
      ref(typeParameter) &
      (ref(token, ',') & ref(typeParameter)).star() &
      ref(token, '>');

  Parser superclass() => ref(EXTENDS) & ref(type);

  Parser interfaces() => ref(IMPLEMENTS) & ref(typeList);

  // This rule is organized in a way that may not be most readable, but
  // gives the best error messages.
  Parser classMemberDefinition() =>
      ref(declaration) & ref(token, ';') |
      ref(constructorDeclaration) & ref(token, ';') |
      ref(methodDeclaration) & ref(functionBodyOrNative) |
      ref(CONST) & ref(factoryConstructorDeclaration) & ref(functionNative);

  Parser functionBodyOrNative() =>
      ref(NATIVE) & ref(functionBody) | ref(functionNative) | ref(functionBody);

  Parser functionNative() =>
      ref(NATIVE) & ref(token, STRING).optional() & ref(token, ';');

  // A method, operator, or constructor (which all should be followed by
  // a block of code).
  Parser methodDeclaration() =>
      ref(factoryConstructorDeclaration) |
      ref(STATIC) & ref(functionDeclaration) |
      ref(specialSignatureDefinition) |
      ref(functionDeclaration) & ref(initializers).optional() |
      ref(namedConstructorDeclaration) & ref(initializers).optional();

  // An abstract method/operator, a field, or const constructor (which
  // all should be followed by a semicolon).
  Parser declaration() =>
      ref(functionDeclaration) & ref(redirection) |
      ref(namedConstructorDeclaration) & ref(redirection) |
      ref(ABSTRACT) & ref(specialSignatureDefinition) |
      ref(ABSTRACT) & ref(functionDeclaration) |
      ref(STATIC) &
          ref(FINAL) &
          ref(type).optional() &
          ref(staticFinalDeclarationList) |
      ref(STATIC).optional() & ref(constInitializedVariableDeclaration);

  Parser initializers() =>
      ref(token, ':') &
      ref(superCallOrFieldInitializer) &
      (ref(token, ',') & ref(superCallOrFieldInitializer)).star();

  Parser redirection() =>
      ref(token, ':') &
      ref(THIS) &
      (ref(token, '.') & ref(identifier)).optional() &
      ref(arguments);

  Parser fieldInitializer() =>
      (ref(THIS) & ref(token, '.')).optional() &
      ref(identifier) &
      ref(token, '=') &
      ref(conditionalExpression);

  Parser superCallOrFieldInitializer() =>
      ref(SUPER) & ref(arguments) |
      ref(SUPER) & ref(token, '.') & ref(identifier) & ref(arguments) |
      ref(fieldInitializer);

  Parser staticFinalDeclarationList() =>
      ref(staticFinalDeclaration) &
      (ref(token, ',') & ref(staticFinalDeclaration)).star();

  Parser staticFinalDeclaration() =>
      ref(identifier) & ref(token, '=') & ref(constantExpression);

  Parser functionTypeAlias() =>
      ref(TYPEDEF) &
      ref(functionPrefix) &
      ref(typeParameters).optional() &
      ref(formalParameterList) &
      ref(token, ';');

  Parser factoryConstructorDeclaration() =>
      ref(FACTORY) &
      ref(qualified) &
      ref(typeParameters).optional() &
      (ref(token, '.') & ref(identifier)).optional() &
      ref(formalParameterList);

  Parser constructorDeclaration() =>
      ref(CONST).optional() &
          ref(identifier) &
          ref(formalParameterList) &
          (ref(redirection) | ref(initializers)).optional() |
      ref(CONST).optional() &
          ref(namedConstructorDeclaration) &
          (ref(redirection) | ref(initializers)).optional();

  Parser namedConstructorDeclaration() =>
      ref(identifier) &
      ref(token, '.') &
      ref(identifier) &
      ref(formalParameterList);

  Parser constantConstructorDeclaration() =>
      ref(CONST) & ref(qualified) & ref(formalParameterList);

  Parser specialSignatureDefinition() =>
      ref(STATIC).optional() &
          ref(returnType).optional() &
          ref(getOrSet) &
          ref(identifier) &
          ref(formalParameterList) |
      ref(returnType).optional() &
          ref(OPERATOR) &
          ref(userDefinableOperator) &
          ref(formalParameterList);

  Parser getOrSet() => ref(GET) | ref(SET);

  Parser userDefinableOperator() =>
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

  Parser prefixOperator() => ref(additiveOperator) | ref(negateOperator);

  Parser postfixOperator() => ref(incrementOperator);

  Parser negateOperator() => ref(token, '!') | ref(token, '~');

  Parser multiplicativeOperator() =>
      ref(token, '*') | ref(token, '/') | ref(token, '%') | ref(token, '~/');

  Parser assignmentOperator() =>
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

  Parser additiveOperator() => ref(token, '+') | ref(token, '-');

  Parser incrementOperator() => ref(token, '++') | ref(token, '--');

  Parser shiftOperator() =>
      ref(token, '<<') | ref(token, '>>>') | ref(token, '>>');

  Parser relationalOperator() =>
      ref(token, '>=') | ref(token, '>') | ref(token, '<=') | ref(token, '<');

  Parser equalityOperator() =>
      ref(token, '===') |
      ref(token, '!==') |
      ref(token, '==') |
      ref(token, '!=');

  Parser bitwiseOperator() =>
      ref(token, '&') | ref(token, '^') | ref(token, '|');

  Parser formalParameterList() =>
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

  Parser normalFormalParameterTail() =>
      ref(token, ',') & ref(optionalFormalParameters) |
      ref(token, ',') & ref(namedFormalParameters) |
      ref(token, ',') &
          ref(normalFormalParameter) &
          ref(normalFormalParameterTail).optional();

  Parser normalFormalParameter() =>
      ref(fieldFormalParameter) |
      ref(functionDeclaration) |
      ref(simpleFormalParameter);

  Parser simpleFormalParameter() => ref(declaredIdentifier) | ref(identifier);

  Parser fieldFormalParameter() =>
      ref(THIS) & ref(token, '.') & ref(identifier);

  Parser optionalFormalParameters() =>
      ref(token, '[') &
      ref(defaultFormalParameter) &
      (ref(token, ',') & ref(defaultFormalParameter)).star() &
      ref(token, ']');

  Parser namedFormalParameters() =>
      ref(token, '{') &
      ref(namedFormatParameter) &
      (ref(token, ',') & ref(namedFormatParameter)).star() &
      ref(token, '}');

  Parser namedFormatParameter() =>
      ref(normalFormalParameter) &
      (ref(token, ':') & ref(constantExpression)).optional();

  Parser defaultFormalParameter() =>
      ref(normalFormalParameter) &
      (ref(token, '=') & ref(constantExpression)).optional();

  Parser returnType() => ref(VOID) | ref(type);

  // We have to introduce a separate rule for 'declared' identifiers to
  // allow ANTLR to decide if the first identifier we encounter after
  // final is a type or an identifier. Before this change, we used the
  // production 'finalVarOrType identifier' in numerous places.
  Parser declaredIdentifier() =>
      ref(FINAL) & ref(type).optional() & ref(identifier) |
      ref(VAR) & ref(identifier) |
      ref(type) & ref(identifier);

  Parser identifier() => ref(token, ref(IDENTIFIER));

  Parser qualified() =>
      ref(identifier) & (ref(token, '.') & ref(identifier)).star();

  Parser type() => ref(qualified) & ref(typeArguments).optional();

  Parser typeArguments() => ref(token, '<') & ref(typeList) & ref(token, '>');

  Parser typeList() => ref(type) & (ref(token, ',') & ref(type)).star();

  Parser block() => ref(token, '{') & ref(statements) & ref(token, '}');

  Parser statements() => ref(statement).star();

  Parser statement() => ref(label).star() & ref(nonLabelledStatement);

  Parser nonLabelledStatement() =>
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

  Parser label() => ref(identifier) & ref(token, ':');

  Parser iterationStatement() =>
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

  Parser forLoopParts() =>
      ref(forInitializerStatement) &
          ref(expression).optional() &
          ref(token, ';') &
          ref(expressionList).optional() |
      ref(declaredIdentifier) & ref(IN) & ref(expression) |
      ref(identifier) & ref(IN) & ref(expression);

  Parser forInitializerStatement() =>
      ref(initializedVariableDeclaration) & ref(token, ';') |
      ref(expression).optional() & ref(token, ';');

  Parser selectionStatement() =>
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

  Parser switchCase() =>
      ref(label).optional() &
      (ref(CASE) & ref(expression) & ref(token, ':')).plus() &
      ref(statements);

  Parser defaultCase() =>
      ref(label).optional() & ref(DEFAULT) & ref(token, ':') & ref(statements);

  Parser tryStatement() =>
      ref(TRY) &
      ref(block) &
      (ref(catchPart).plus() & ref(finallyPart).optional() | ref(finallyPart));

  Parser catchPart() =>
      ref(CATCH) &
      ref(token, '(') &
      ref(declaredIdentifier) &
      (ref(token, ',') & ref(declaredIdentifier)).optional() &
      ref(token, ')') &
      ref(block);

  Parser finallyPart() => ref(FINALLY) & ref(block);

  Parser variableDeclaration() =>
      ref(declaredIdentifier) & (ref(token, ',') & ref(identifier)).star();

  Parser initializedVariableDeclaration() =>
      ref(declaredIdentifier) &
      (ref(token, '=') & ref(expression)).optional() &
      (ref(token, ',') & ref(initializedIdentifier)).star();

  Parser initializedIdentifierList() =>
      ref(initializedIdentifier) &
      (ref(token, ',') & ref(initializedIdentifier)).star();

  Parser initializedIdentifier() =>
      ref(identifier) & (ref(token, '=') & ref(expression)).optional();

  Parser constInitializedVariableDeclaration() =>
      ref(declaredIdentifier) &
      (ref(token, '=') & ref(constantExpression)).optional() &
      (ref(token, ',') & ref(constInitializedIdentifier)).star();

  Parser constInitializedIdentifier() =>
      ref(identifier) & (ref(token, '=') & ref(constantExpression)).optional();

  // The constant expression production is used to mark certain expressions
  // as only being allowed to hold a compile-time constant. The grammar cannot
  // express these restrictions (yet), so this will have to be enforced by a
  // separate analysis phase.
  Parser constantExpression() => ref(expression);

  Parser expression() =>
      ref(assignableExpression) & ref(assignmentOperator) & ref(expression) |
      ref(conditionalExpression);

  Parser expressionList() => ref(expression).separatedBy(ref(token, ','));

  Parser arguments() =>
      ref(token, '(') & ref(argumentList).optional() & ref(token, ')');

  Parser argumentList() => ref(argumentElement).separatedBy(ref(token, ','));

  Parser argumentElement() => ref(label) & ref(expression) | ref(expression);

  Parser assignableExpression() =>
      ref(primary) & (ref(arguments).star() & ref(assignableSelector)).plus() |
      ref(SUPER) & ref(assignableSelector) |
      ref(identifier);

  Parser conditionalExpression() =>
      ref(logicalOrExpression) &
      (ref(token, '?') & ref(expression) & ref(token, ':') & ref(expression))
          .optional();

  Parser logicalOrExpression() =>
      ref(logicalAndExpression) &
      (ref(token, '||') & ref(logicalAndExpression)).star();

  Parser logicalAndExpression() =>
      ref(bitwiseOrExpression) &
      (ref(token, '&&') & ref(bitwiseOrExpression)).star();

  Parser bitwiseOrExpression() =>
      ref(bitwiseXorExpression) &
          (ref(token, '|') & ref(bitwiseXorExpression)).star() |
      ref(SUPER) & (ref(token, '|') & ref(bitwiseXorExpression)).plus();

  Parser bitwiseXorExpression() =>
      ref(bitwiseAndExpression) &
          (ref(token, '^') & ref(bitwiseAndExpression)).star() |
      ref(SUPER) & (ref(token, '^') & ref(bitwiseAndExpression)).plus();

  Parser bitwiseAndExpression() =>
      ref(equalityExpression) &
          (ref(token, '&') & ref(equalityExpression)).star() |
      ref(SUPER) & (ref(token, '&') & ref(equalityExpression)).plus();

  Parser equalityExpression() =>
      ref(relationalExpression) &
          (ref(equalityOperator) & ref(relationalExpression)).optional() |
      ref(SUPER) & ref(equalityOperator) & ref(relationalExpression);

  Parser relationalExpression() =>
      ref(shiftExpression) &
          (ref(isOperator) & ref(type) |
                  ref(relationalOperator) & ref(shiftExpression))
              .optional() |
      ref(SUPER) & ref(relationalOperator) & ref(shiftExpression);

  Parser isOperator() => ref(IS) & ref(token, '!').optional();

  Parser shiftExpression() =>
      ref(additiveExpression) &
          (ref(shiftOperator) & ref(additiveExpression)).star() |
      ref(SUPER) & (ref(shiftOperator) & ref(additiveExpression)).plus();

  Parser additiveExpression() =>
      ref(multiplicativeExpression) &
          (ref(additiveOperator) & ref(multiplicativeExpression)).star() |
      ref(SUPER) &
          (ref(additiveOperator) & ref(multiplicativeExpression)).plus();

  Parser multiplicativeExpression() =>
      ref(unaryExpression) &
          (ref(multiplicativeOperator) & ref(unaryExpression)).star() |
      ref(SUPER) & (ref(multiplicativeOperator) & ref(unaryExpression)).plus();

  Parser unaryExpression() =>
      ref(postfixExpression) |
      ref(prefixOperator) & ref(unaryExpression) |
      ref(negateOperator) & ref(SUPER) |
      ref(token, '-') & ref(SUPER) |
      ref(incrementOperator) & ref(assignableExpression);

  Parser postfixExpression() =>
      ref(assignableExpression) & ref(postfixOperator) |
      ref(primary) & ref(selector).star();

  Parser selector() => ref(assignableSelector) | ref(arguments);

  Parser assignableSelector() =>
      ref(token, '[') & ref(expression) & ref(token, ']') |
      ref(token, '.') & ref(identifier);

  Parser primary() =>
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

  Parser expressionInParentheses() =>
      ref(token, '(') & ref(expression) & ref(token, ')');

  Parser literal() => ref(
      token,
      ref(NULL) |
          ref(TRUE) |
          ref(FALSE) |
          ref(HEX_NUMBER) |
          ref(NUMBER) |
          ref(STRING));

  Parser compoundLiteral() => ref(listLiteral) | ref(mapLiteral);

  Parser listLiteral() =>
      ref(token, '[') &
      (ref(expressionList) & ref(token, ',').optional()).optional() &
      ref(token, ']');

  Parser mapLiteral() =>
      ref(token, '{') &
      (ref(mapLiteralEntry) &
              (ref(token, ',') & ref(mapLiteralEntry)).star() &
              ref(token, ',').optional())
          .optional() &
      ref(token, '}');

  Parser mapLiteralEntry() =>
      ref(token, STRING) & ref(token, ':') & ref(expression);

  Parser functionExpression() =>
      ref(returnType).optional() &
      ref(identifier).optional() &
      ref(formalParameterList) &
      ref(functionExpressionBody);

  Parser functionDeclaration() =>
      ref(returnType) & ref(identifier) & ref(formalParameterList) |
      ref(identifier) & ref(formalParameterList);

  Parser functionPrefix() => ref(returnType).optional() & ref(identifier);

  Parser functionBody() =>
      ref(token, '=>') & ref(expression) & ref(token, ';') | ref(block);

  Parser functionExpressionBody() =>
      ref(token, '=>') & ref(expression) | ref(block);

  // -----------------------------------------------------------------
  // Lexical tokens.
  // -----------------------------------------------------------------
  Parser IDENTIFIER() => ref(IDENTIFIER_START) & ref(IDENTIFIER_PART).star();

  Parser HEX_NUMBER() =>
      string('0x') & ref(HEX_DIGIT).plus() |
      string('0X') & ref(HEX_DIGIT).plus();

  Parser NUMBER() =>
      ref(DIGIT).plus() &
          ref(NUMBER_OPT_FRACTIONAL_PART) &
          ref(EXPONENT).optional() &
          ref(NUMBER_OPT_ILLEGAL_END) |
      char('.') &
          ref(DIGIT).plus() &
          ref(EXPONENT).optional() &
          ref(NUMBER_OPT_ILLEGAL_END);

  Parser NUMBER_OPT_FRACTIONAL_PART() =>
      char('.') & ref(DIGIT).plus() | epsilon();

  Parser NUMBER_OPT_ILLEGAL_END() => epsilon();
//        ref(IDENTIFIER_START).end()
//      | epsilon()
//      ;

  Parser HEX_DIGIT() => pattern('0-9a-fA-F');

  Parser IDENTIFIER_START() => ref(IDENTIFIER_START_NO_DOLLAR) | char('\$');

  Parser IDENTIFIER_START_NO_DOLLAR() => ref(LETTER) | char('_');

  Parser IDENTIFIER_PART() => ref(IDENTIFIER_START) | ref(DIGIT);

  Parser LETTER() => letter();

  Parser DIGIT() => digit();

  Parser EXPONENT() =>
      pattern('eE') & pattern('+-').optional() & ref(DIGIT).plus();

  Parser STRING() =>
      char('@').optional() & ref(MULTI_LINE_STRING) | ref(SINGLE_LINE_STRING);

  Parser MULTI_LINE_STRING() =>
      string('"""') & any().starLazy(string('"""')) & string('"""') |
      string("'''") & any().starLazy(string("'''")) & string("'''");

  Parser SINGLE_LINE_STRING() =>
      char('"') & ref(STRING_CONTENT_DQ).star() & char('"') |
      char("'") & ref(STRING_CONTENT_SQ).star() & char("'") |
      string('@"') & pattern('^"\n\r').star() & char('"') |
      string("@'") & pattern("^'\n\r").star() & char("'");

  Parser STRING_CONTENT_DQ() =>
      pattern('^\\"\n\r') | char('\\') & pattern('\n\r');

  Parser STRING_CONTENT_SQ() =>
      pattern("^\\'\n\r") | char('\\') & pattern('\n\r');

  Parser NEWLINE() => pattern('\n\r');

  Parser HASHBANG() =>
      string('#!') & pattern('^\n\r').star() & ref(NEWLINE).optional();

  // -----------------------------------------------------------------
  // Whitespace and comments.
  // -----------------------------------------------------------------
  Parser HIDDEN() => ref(HIDDEN_STUFF).plus();

  Parser HIDDEN_STUFF() =>
      ref(WHITESPACE) | ref(SINGLE_LINE_COMMENT) | ref(MULTI_LINE_COMMENT);

  Parser WHITESPACE() => whitespace();

  Parser SINGLE_LINE_COMMENT() =>
      string('//') & ref(NEWLINE).neg().star() & ref(NEWLINE).optional();

  Parser MULTI_LINE_COMMENT() =>
      string('/*') &
      (ref(MULTI_LINE_COMMENT) | string('*/').neg()).star() &
      string('*/');
}
