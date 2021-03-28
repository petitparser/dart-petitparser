import 'package:petitparser/petitparser.dart';

/// Dart grammar definition.
class DartGrammarDefinition extends GrammarDefinition {
  Parser token(Object input) {
    if (input is Parser) {
      return input.token().trim(ref(hiddenStuffWhitespace));
    } else if (input is String) {
      return token(input.toParser());
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
  Parser breakToken() => ref(token, 'break');
  Parser caseToken() => ref(token, 'case');
  Parser catchToken() => ref(token, 'catch');
  Parser constToken() => ref(token, 'const');
  Parser continueToken() => ref(token, 'continue');
  Parser defaultToken() => ref(token, 'default');
  Parser doToken() => ref(token, 'do');
  Parser elseToken() => ref(token, 'else');
  Parser falseToken() => ref(token, 'false');
  Parser finalToken() => ref(token, 'final');
  Parser finallyToken() => ref(token, 'finally');
  Parser forToken() => ref(token, 'for');
  Parser ifToken() => ref(token, 'if');
  Parser inToken() => ref(token, 'in');
  Parser newToken() => ref(token, 'new');
  Parser nullToken() => ref(token, 'null');
  Parser returnToken() => ref(token, 'return');
  Parser superToken() => ref(token, 'super');
  Parser switchToken() => ref(token, 'switch');
  Parser thisToken() => ref(token, 'this');
  Parser throwToken() => ref(token, 'throw');
  Parser trueToken() => ref(token, 'true');
  Parser tryToken() => ref(token, 'try');
  Parser varToken() => ref(token, 'var');
  Parser voidToken() => ref(token, 'void');
  Parser whileToken() => ref(token, 'while');

  // Pseudo-keywords that should also be valid identifiers.
  Parser abstractToken() => ref(token, 'abstract');
  Parser asToken() => ref(token, 'as');
  Parser assertToken() => ref(token, 'assert');
  Parser classToken() => ref(token, 'class');
  Parser deferredToken() => ref(token, 'deferred');
  Parser exportToken() => ref(token, 'export');
  Parser extendsToken() => ref(token, 'extends');
  Parser factoryToken() => ref(token, 'factory');
  Parser getToken() => ref(token, 'get');
  Parser hideToken() => ref(token, 'hide');
  Parser implementsToken() => ref(token, 'implements');
  Parser importToken() => ref(token, 'import');
  Parser isToken() => ref(token, 'is');
  Parser libraryToken() => ref(token, 'library');
  Parser nativeToken() => ref(token, 'native');
  Parser negateToken() => ref(token, 'negate');
  Parser ofToken() => ref(token, 'of');
  Parser operatorToken() => ref(token, 'operator');
  Parser partToken() => ref(token, 'part');
  Parser setToken() => ref(token, 'set');
  Parser showToken() => ref(token, 'show');
  Parser staticToken() => ref(token, 'static');
  Parser typedefToken() => ref(token, 'typedef');

  // -----------------------------------------------------------------
  // Grammar productions.
  // -----------------------------------------------------------------
  Parser start() => ref(compilationUnit).end();

  Parser compilationUnit() =>
      ref(hashbangLexicalToken).optional() &
      ref(libraryDirective).optional() &
      ref(importDirective).star() &
      ref(topLevelDefinition).star();

  Parser libraryDirective() =>
      ref(libraryToken) & ref(qualified) & ref(token, ';') |
      ref(partToken) & ref(ofToken) & ref(qualified) & ref(token, ';');

  Parser importDirective() =>
      ref(importToken) &
          ref(singleLineStringLexicalToken) &
          ref(deferredToken).optional() &
          (ref(asToken) & ref(identifier)).optional() &
          ((ref(showToken) | ref(hideToken)) &
                  ref(identifier).separatedBy(ref(token, ',')))
              .optional() &
          ref(token, ';') |
      ref(exportToken) &
          ref(singleLineStringLexicalToken) &
          ((ref(showToken) | ref(hideToken)) &
                  ref(identifier).separatedBy(ref(token, ',')))
              .optional() &
          ref(token, ';') |
      ref(partToken) & ref(singleLineStringLexicalToken) & ref(token, ';');

  Parser topLevelDefinition() =>
      ref(classDefinition) |
      ref(functionTypeAlias) |
      ref(functionDeclaration) & ref(functionBodyOrNative) |
      ref(returnType).optional() &
          ref(getOrSet) &
          ref(identifier) &
          ref(formalParameterList) &
          ref(functionBodyOrNative) |
      ref(finalToken) &
          ref(type).optional() &
          ref(staticFinalDeclarationList) &
          ref(token, ';') |
      ref(constToken) &
          ref(type).optional() &
          ref(staticFinalDeclarationList) &
          ref(token, ';') |
      ref(constInitializedVariableDeclaration) & ref(token, ';');

  Parser classDefinition() =>
      ref(abstractToken).optional() &
          ref(classToken) &
          ref(identifier) &
          ref(typeParameters).optional() &
          ref(superclass).optional() &
          ref(interfaces).optional() &
          ref(token, '{') &
          ref(classMemberDefinition).star() &
          ref(token, '}') |
      ref(abstractToken).optional() &
          ref(classToken) &
          ref(identifier) &
          ref(typeParameters).optional() &
          ref(interfaces).optional() &
          ref(nativeToken) &
          ref(token, stringLexicalToken) &
          ref(token, '{') &
          ref(classMemberDefinition).star() &
          ref(token, '}');

  Parser typeParameter() =>
      ref(identifier) & (ref(extendsToken) & ref(type)).optional();

  Parser typeParameters() =>
      ref(token, '<') &
      ref(typeParameter) &
      (ref(token, ',') & ref(typeParameter)).star() &
      ref(token, '>');

  Parser superclass() => ref(extendsToken) & ref(type);

  Parser interfaces() => ref(implementsToken) & ref(typeList);

  // This rule is organized in a way that may not be most readable, but
  // gives the best error messages.
  Parser classMemberDefinition() =>
      ref(declaration) & ref(token, ';') |
      ref(constructorDeclaration) & ref(token, ';') |
      ref(methodDeclaration) & ref(functionBodyOrNative) |
      ref(constToken) &
          ref(factoryConstructorDeclaration) &
          ref(functionNative);

  Parser functionBodyOrNative() =>
      ref(nativeToken) & ref(functionBody) |
      ref(functionNative) |
      ref(functionBody);

  Parser functionNative() =>
      ref(nativeToken) &
      ref(token, stringLexicalToken).optional() &
      ref(token, ';');

  // A method, operator, or constructor (which all should be followed by
  // a block of code).
  Parser methodDeclaration() =>
      ref(factoryConstructorDeclaration) |
      ref(staticToken) & ref(functionDeclaration) |
      ref(specialSignatureDefinition) |
      ref(functionDeclaration) & ref(initializers).optional() |
      ref(namedConstructorDeclaration) & ref(initializers).optional();

  // An abstract method/operator, a field, or const constructor (which
  // all should be followed by a semicolon).
  Parser declaration() =>
      ref(functionDeclaration) & ref(redirection) |
      ref(namedConstructorDeclaration) & ref(redirection) |
      ref(abstractToken) & ref(specialSignatureDefinition) |
      ref(abstractToken) & ref(functionDeclaration) |
      ref(staticToken) &
          ref(finalToken) &
          ref(type).optional() &
          ref(staticFinalDeclarationList) |
      ref(staticToken).optional() & ref(constInitializedVariableDeclaration);

  Parser initializers() =>
      ref(token, ':') &
      ref(superCallOrFieldInitializer) &
      (ref(token, ',') & ref(superCallOrFieldInitializer)).star();

  Parser redirection() =>
      ref(token, ':') &
      ref(thisToken) &
      (ref(token, '.') & ref(identifier)).optional() &
      ref(arguments);

  Parser fieldInitializer() =>
      (ref(thisToken) & ref(token, '.')).optional() &
      ref(identifier) &
      ref(token, '=') &
      ref(conditionalExpression);

  Parser superCallOrFieldInitializer() =>
      ref(superToken) & ref(arguments) |
      ref(superToken) & ref(token, '.') & ref(identifier) & ref(arguments) |
      ref(fieldInitializer);

  Parser staticFinalDeclarationList() =>
      ref(staticFinalDeclaration) &
      (ref(token, ',') & ref(staticFinalDeclaration)).star();

  Parser staticFinalDeclaration() =>
      ref(identifier) & ref(token, '=') & ref(constantExpression);

  Parser functionTypeAlias() =>
      ref(typedefToken) &
      ref(functionPrefix) &
      ref(typeParameters).optional() &
      ref(formalParameterList) &
      ref(token, ';');

  Parser factoryConstructorDeclaration() =>
      ref(factoryToken) &
      ref(qualified) &
      ref(typeParameters).optional() &
      (ref(token, '.') & ref(identifier)).optional() &
      ref(formalParameterList);

  Parser constructorDeclaration() =>
      ref(constToken).optional() &
          ref(identifier) &
          ref(formalParameterList) &
          (ref(redirection) | ref(initializers)).optional() |
      ref(constToken).optional() &
          ref(namedConstructorDeclaration) &
          (ref(redirection) | ref(initializers)).optional();

  Parser namedConstructorDeclaration() =>
      ref(identifier) &
      ref(token, '.') &
      ref(identifier) &
      ref(formalParameterList);

  Parser constantConstructorDeclaration() =>
      ref(constToken) & ref(qualified) & ref(formalParameterList);

  Parser specialSignatureDefinition() =>
      ref(staticToken).optional() &
          ref(returnType).optional() &
          ref(getOrSet) &
          ref(identifier) &
          ref(formalParameterList) |
      ref(returnType).optional() &
          ref(operatorToken) &
          ref(userDefinableOperator) &
          ref(formalParameterList);

  Parser getOrSet() => ref(getToken) | ref(setToken);

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
      ref(negateToken) |
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
      ref(thisToken) & ref(token, '.') & ref(identifier);

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

  Parser returnType() => ref(voidToken) | ref(type);

  // We have to introduce a separate rule for 'declared' identifiers to
  // allow ANTLR to decide if the first identifier we encounter after
  // final is a type or an identifier. Before this change, we used the
  // production 'finalVarOrType identifier' in numerous places.
  Parser declaredIdentifier() =>
      ref(finalToken) & ref(type).optional() & ref(identifier) |
      ref(varToken) & ref(identifier) |
      ref(type) & ref(identifier);

  Parser identifier() => ref(token, ref(identifierLexicalToken));

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
      ref(breakToken) & ref(identifier).optional() & ref(token, ';') |
      ref(continueToken) & ref(identifier).optional() & ref(token, ';') |
      ref(returnToken) & ref(expression).optional() & ref(token, ';') |
      ref(throwToken) & ref(expression).optional() & ref(token, ';') |
      ref(expression).optional() & ref(token, ';') |
      ref(assertToken) &
          ref(token, '(') &
          ref(conditionalExpression) &
          ref(token, ')') &
          ref(token, ';') |
      ref(functionDeclaration) & ref(functionBody);

  Parser label() => ref(identifier) & ref(token, ':');

  Parser iterationStatement() =>
      ref(whileToken) &
          ref(token, '(') &
          ref(expression) &
          ref(token, ')') &
          ref(statement) |
      ref(doToken) &
          ref(statement) &
          ref(whileToken) &
          ref(token, '(') &
          ref(expression) &
          ref(token, ')') &
          ref(token, ';') |
      ref(forToken) &
          ref(token, '(') &
          ref(forLoopParts) &
          ref(token, ')') &
          ref(statement);

  Parser forLoopParts() =>
      ref(forInitializerStatement) &
          ref(expression).optional() &
          ref(token, ';') &
          ref(expressionList).optional() |
      ref(declaredIdentifier) & ref(inToken) & ref(expression) |
      ref(identifier) & ref(inToken) & ref(expression);

  Parser forInitializerStatement() =>
      ref(initializedVariableDeclaration) & ref(token, ';') |
      ref(expression).optional() & ref(token, ';');

  Parser selectionStatement() =>
      ref(ifToken) &
          ref(token, '(') &
          ref(expression) &
          ref(token, ')') &
          ref(statement) &
          (ref(elseToken) & ref(statement)).optional() |
      ref(switchToken) &
          ref(token, '(') &
          ref(expression) &
          ref(token, ')') &
          ref(token, '{') &
          ref(switchCase).star() &
          ref(defaultCase).optional() &
          ref(token, '}');

  Parser switchCase() =>
      ref(label).optional() &
      (ref(caseToken) & ref(expression) & ref(token, ':')).plus() &
      ref(statements);

  Parser defaultCase() =>
      ref(label).optional() &
      ref(defaultToken) &
      ref(token, ':') &
      ref(statements);

  Parser tryStatement() =>
      ref(tryToken) &
      ref(block) &
      (ref(catchPart).plus() & ref(finallyPart).optional() | ref(finallyPart));

  Parser catchPart() =>
      ref(catchToken) &
      ref(token, '(') &
      ref(declaredIdentifier) &
      (ref(token, ',') & ref(declaredIdentifier)).optional() &
      ref(token, ')') &
      ref(block);

  Parser finallyPart() => ref(finallyToken) & ref(block);

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
      ref(superToken) & ref(assignableSelector) |
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
      ref(superToken) & (ref(token, '|') & ref(bitwiseXorExpression)).plus();

  Parser bitwiseXorExpression() =>
      ref(bitwiseAndExpression) &
          (ref(token, '^') & ref(bitwiseAndExpression)).star() |
      ref(superToken) & (ref(token, '^') & ref(bitwiseAndExpression)).plus();

  Parser bitwiseAndExpression() =>
      ref(equalityExpression) &
          (ref(token, '&') & ref(equalityExpression)).star() |
      ref(superToken) & (ref(token, '&') & ref(equalityExpression)).plus();

  Parser equalityExpression() =>
      ref(relationalExpression) &
          (ref(equalityOperator) & ref(relationalExpression)).optional() |
      ref(superToken) & ref(equalityOperator) & ref(relationalExpression);

  Parser relationalExpression() =>
      ref(shiftExpression) &
          (ref(isOperator) & ref(type) |
                  ref(relationalOperator) & ref(shiftExpression))
              .optional() |
      ref(superToken) & ref(relationalOperator) & ref(shiftExpression);

  Parser isOperator() => ref(isToken) & ref(token, '!').optional();

  Parser shiftExpression() =>
      ref(additiveExpression) &
          (ref(shiftOperator) & ref(additiveExpression)).star() |
      ref(superToken) & (ref(shiftOperator) & ref(additiveExpression)).plus();

  Parser additiveExpression() =>
      ref(multiplicativeExpression) &
          (ref(additiveOperator) & ref(multiplicativeExpression)).star() |
      ref(superToken) &
          (ref(additiveOperator) & ref(multiplicativeExpression)).plus();

  Parser multiplicativeExpression() =>
      ref(unaryExpression) &
          (ref(multiplicativeOperator) & ref(unaryExpression)).star() |
      ref(superToken) &
          (ref(multiplicativeOperator) & ref(unaryExpression)).plus();

  Parser unaryExpression() =>
      ref(postfixExpression) |
      ref(prefixOperator) & ref(unaryExpression) |
      ref(negateOperator) & ref(superToken) |
      ref(token, '-') & ref(superToken) |
      ref(incrementOperator) & ref(assignableExpression);

  Parser postfixExpression() =>
      ref(assignableExpression) & ref(postfixOperator) |
      ref(primary) & ref(selector).star();

  Parser selector() => ref(assignableSelector) | ref(arguments);

  Parser assignableSelector() =>
      ref(token, '[') & ref(expression) & ref(token, ']') |
      ref(token, '.') & ref(identifier);

  Parser primary() =>
      ref(thisToken) |
      ref(superToken) & ref(assignableSelector) |
      ref(constToken).optional() &
          ref(typeArguments).optional() &
          ref(compoundLiteral) |
      (ref(newToken) | ref(constToken)) &
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
      ref(nullToken) |
          ref(trueToken) |
          ref(falseToken) |
          ref(hexNumberLexicalToken) |
          ref(numberLexicalToken) |
          ref(stringLexicalToken));

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
      ref(token, stringLexicalToken) & ref(token, ':') & ref(expression);

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
  Parser identifierLexicalToken() =>
      ref(identifierStartLexicalToken) & ref(identifierPartLexicalToken).star();

  Parser hexNumberLexicalToken() =>
      string('0x') & ref(hexDigitLexicalToken).plus() |
      string('0X') & ref(hexDigitLexicalToken).plus();

  Parser numberLexicalToken() =>
      ref(digitLexicalToken).plus() &
          ref(numberOptFractionalPartLexicalToken) &
          ref(exponentLexicalToken).optional() &
          ref(numberOptIllegalEndLexicalToken) |
      char('.') &
          ref(digitLexicalToken).plus() &
          ref(exponentLexicalToken).optional() &
          ref(numberOptIllegalEndLexicalToken);

  Parser numberOptFractionalPartLexicalToken() =>
      char('.') & ref(digitLexicalToken).plus() | epsilon();

  Parser numberOptIllegalEndLexicalToken() => epsilon();
//        ref(IDENTIFIER_START).end()
//      | epsilon()
//      ;

  Parser hexDigitLexicalToken() => pattern('0-9a-fA-F');

  Parser identifierStartLexicalToken() =>
      ref(identifierStartNoDollarLexicalToken) | char('\$');

  Parser identifierStartNoDollarLexicalToken() =>
      ref(letterLexicalToken) | char('_');

  Parser identifierPartLexicalToken() =>
      ref(identifierStartLexicalToken) | ref(digitLexicalToken);

  Parser letterLexicalToken() => letter();

  Parser digitLexicalToken() => digit();

  Parser exponentLexicalToken() =>
      pattern('eE') & pattern('+-').optional() & ref(digitLexicalToken).plus();

  Parser stringLexicalToken() =>
      char('@').optional() & ref(multiLineStringLexicalToken) |
      ref(singleLineStringLexicalToken);

  Parser multiLineStringLexicalToken() =>
      string('"""') & any().starLazy(string('"""')) & string('"""') |
      string("'''") & any().starLazy(string("'''")) & string("'''");

  Parser singleLineStringLexicalToken() =>
      char('"') &
          ref(stringContentDoubleQuotedLexicalToken).star() &
          char('"') |
      char("'") &
          ref(stringContentSingleQuotedLexicalToken).star() &
          char("'") |
      string('@"') & pattern('^"\n\r').star() & char('"') |
      string("@'") & pattern("^'\n\r").star() & char("'");

  Parser stringContentDoubleQuotedLexicalToken() =>
      pattern('^\\"\n\r') | char('\\') & pattern('\n\r');

  Parser stringContentSingleQuotedLexicalToken() =>
      pattern("^\\'\n\r") | char('\\') & pattern('\n\r');

  Parser newlineLexicalToken() => pattern('\n\r');

  Parser hashbangLexicalToken() =>
      string('#!') &
      pattern('^\n\r').star() &
      ref(newlineLexicalToken).optional();

  // -----------------------------------------------------------------
  // Whitespace and comments.
  // -----------------------------------------------------------------
  Parser hiddenWhitespace() => ref(hiddenStuffWhitespace).plus();

  Parser hiddenStuffWhitespace() =>
      ref(visibleWhitespace) | ref(singleLineComment) | ref(multiLineComment);

  Parser visibleWhitespace() => whitespace();

  Parser singleLineComment() =>
      string('//') &
      ref(newlineLexicalToken).neg().star() &
      ref(newlineLexicalToken).optional();

  Parser multiLineComment() =>
      string('/*') &
      (ref(multiLineComment) | string('*/').neg()).star() &
      string('*/');
}
