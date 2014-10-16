part of dart;

/**
 * Dart grammar.
 */
class DartGrammar extends GrammarParser {
  DartGrammar() : super(new DartGrammarDefinition());
}

/**
 * Dart grammar definition.
 *
 * Adapted from [https://code.google.com/p/dart/source/browse/branches/bleeding_edge/dart/language/grammar/Dart.g].
 */
class DartGrammarDefinition extends GrammarDefinition {

  // Copyright (c) 2011, the Dart project authors. Please see the AUTHORS file
  // for details. All rights reserved. Use of this source code is governed by a
  // BSD-style license that can be found in the LICENSE file.

  // -----------------------------------------------------------------
  // Keyword definitions.
  // -----------------------------------------------------------------
  BREAK()      => ref(token, 'break');
  CASE()       => ref(token, 'case');
  CATCH()      => ref(token, 'catch');
  CONST()      => ref(token, 'const');
  CONTINUE()   => ref(token, 'continue');
  DEFAULT()    => ref(token, 'default');
  DO()         => ref(token, 'do');
  ELSE()       => ref(token, 'else');
  FALSE()      => ref(token, 'false');
  FINAL()      => ref(token, 'final');
  FINALLY()    => ref(token, 'finally');
  FOR()        => ref(token, 'for');
  IF()         => ref(token, 'if');
  IN()         => ref(token, 'in');
  NEW()        => ref(token, 'new');
  NULL()       => ref(token, 'null');
  RETURN()     => ref(token, 'return');
  SUPER()      => ref(token, 'super');
  SWITCH()     => ref(token, 'switch');
  THIS()       => ref(token, 'this');
  THROW()      => ref(token, 'throw');
  TRUE()       => ref(token, 'true');
  TRY()        => ref(token, 'try');
  VAR()        => ref(token, 'var');
  VOID()       => ref(token, 'void');
  WHILE()      => ref(token, 'while');

  // Pseudo-keywords that should also be valid identifiers.
  ABSTRACT()   => ref(token, 'abstract');
  ASSERT()     => ref(token, 'assert');
  CLASS()      => ref(token, 'class');
  EXTENDS()    => ref(token, 'extends');
  FACTORY()    => ref(token, 'factory');
  GET()        => ref(token, 'get');
  IMPLEMENTS() => ref(token, 'implements');
  IMPORT()     => ref(token, 'import');
  INTERFACE()  => ref(token, 'interface');
  IS()         => ref(token, 'is');
  LIBRARY()    => ref(token, 'library');
  NATIVE()     => ref(token, 'native');
  NEGATE()     => ref(token, 'negate');
  OPERATOR()   => ref(token, 'operator');
  SET()        => ref(token, 'set');
  SOURCE()     => ref(token, 'source');
  STATIC()     => ref(token, 'static');
  TYPEDEF()    => ref(token, 'typedef');

  // -----------------------------------------------------------------
  // Grammar productions.
  // -----------------------------------------------------------------
  start() => ref(compilationUnit).end();

  compilationUnit() =>
        ref(HASHBANG).optional()
      & ref(directive).star()
      & ref(topLevelDefinition).star();

  directive() =>
        ref(token, '#')
      & ref(identifier)
      & ref(arguments)
      & ref(token, ';');

  topLevelDefinition() =>
        ref(classDefinition)
      | ref(interfaceDefinition)
      | ref(functionTypeAlias)
      | ref(functionDeclaration) & ref(functionBodyOrNative)
      | ref(returnType).optional() & ref(getOrSet) & ref(identifier) & ref(formalParameterList) & ref(functionBodyOrNative)
      | ref(FINAL) & ref(type).optional() & ref(staticFinalDeclarationList) & ref(token, ';')
      | ref(constInitializedVariableDeclaration) & ref(token, ';');

  classDefinition() =>
        ref(CLASS) & ref(identifier) & ref(typeParameters).optional() & ref(superclass).optional() & ref(interfaces).optional() &
        ref(token, '{') & ref(classMemberDefinition).star() & ref(token, '}')
      | ref(CLASS) & ref(identifier) & ref(typeParameters).optional() & ref(interfaces).optional() & ref(NATIVE) & ref(STRING) &
        ref(token, '{') & ref(classMemberDefinition).star() & ref(token, '}');

  typeParameter() => ref(identifier) & (ref(EXTENDS) & ref(type)).optional();

  typeParameters() => ref(token, '<') & ref(typeParameter) & (ref(token, ',') & ref(typeParameter)).star() & ref(token, '>');

  superclass() => ref(EXTENDS) & ref(type);

  interfaces() => ref(IMPLEMENTS) & ref(typeList);

  superinterfaces() => ref(EXTENDS) & ref(typeList);

  // This rule is organized in a way that may not be most readable, but
  // gives the best error messages.
  classMemberDefinition() =>
        ref(declaration) & ref(token, ';')
      | ref(constructorDeclaration) & ref(token, ';')
      | ref(methodDeclaration) & ref(functionBodyOrNative)
      | ref(CONST) & ref(factoryConstructorDeclaration) & ref(functionNative);

  functionBodyOrNative() =>
        ref(NATIVE) & ref(functionBody)
      | ref(functionNative)
      | ref(functionBody);

  functionNative() => ref(NATIVE) & ref(STRING).optional() & ref(token, ';');

  // A method, operator, or constructor (which all should be followed by
  // a block of code).
  methodDeclaration() =>
        ref(factoryConstructorDeclaration)
      | ref(STATIC) & ref(functionDeclaration)
      | ref(specialSignatureDefinition)
      | ref(functionDeclaration) & ref(initializers).optional()
      | ref(namedConstructorDeclaration) & ref(initializers).optional();

// An abstract method/operator, a field, or const constructor (which
// all should be followed by a semicolon).
  declaration() =>
        ref(constantConstructorDeclaration) & (ref(redirection) | ref(initializers)).optional()
      | ref(functionDeclaration) & ref(redirection)
      | ref(namedConstructorDeclaration) & ref(redirection)
      | ref(ABSTRACT) & ref(specialSignatureDefinition)
      | ref(ABSTRACT) & ref(functionDeclaration)
      | ref(STATIC) & ref(FINAL) & ref(type).optional() & ref(staticFinalDeclarationList)
      | ref(STATIC).optional() & ref(constInitializedVariableDeclaration);

  initializers() => ref(token, ':') & ref(superCallOrFieldInitializer) & (ref(token, ',') & ref(superCallOrFieldInitializer)).star();

  redirection() => ref(token, ':') & ref(THIS) & (ref(token, '.') & ref(identifier)).optional() & ref(arguments);

  fieldInitializer() => (ref(THIS) & ref(token, '.')).optional() & ref(identifier) & ref(token, '=') & ref(conditionalExpression);

  superCallOrFieldInitializer() =>
        ref(SUPER) & ref(arguments)
      | ref(SUPER) & ref(token, '.') & ref(identifier) & ref(arguments)
      | ref(fieldInitializer);

  staticFinalDeclarationList() => ref(staticFinalDeclaration) & (ref(token, ',') & ref(staticFinalDeclaration)).star();

  staticFinalDeclaration() => ref(identifier) & ref(token, '=') & ref(constantExpression);

  interfaceDefinition() => ref(INTERFACE) & ref(identifier) & ref(typeParameters).optional() &
      ref(superinterfaces).optional() & ref(factorySpecification).optional() & ref(token, '{') &
      ref(interfaceMemberDefinition).star() & ref(token, '}');

  factorySpecification() => ref(FACTORY) & ref(type);

  functionTypeAlias() => ref(TYPEDEF) & ref(functionPrefix) & ref(typeParameters).optional() &
      ref(formalParameterList) & ref(token, ';');

  interfaceMemberDefinition() =>
        ref(STATIC) & ref(FINAL) & ref(type).optional() & ref(initializedIdentifierList) & ref(token, ';')
      | ref(functionDeclaration) & ref(token, ';')
      | ref(constantConstructorDeclaration) & ref(token, ';')
      | ref(namedConstructorDeclaration) & ref(token, ';')
      | ref(specialSignatureDefinition) & ref(token, ';')
      | ref(variableDeclaration) & ref(token, ';');

  factoryConstructorDeclaration() => ref(FACTORY) & ref(qualified) & ref(typeParameters).optional() &
      (ref(token, '.') & ref(identifier)).optional() & ref(formalParameterList);

  namedConstructorDeclaration() => ref(identifier) & ref(token, '.') & ref(identifier) &
      ref(formalParameterList);

  constructorDeclaration() =>
        ref(identifier) & ref(formalParameterList) & (ref(redirection) | ref(initializers)).optional()
      | ref(namedConstructorDeclaration) & (ref(redirection) | ref(initializers)).optional();

  constantConstructorDeclaration() => ref(CONST) & ref(qualified) & ref(formalParameterList);

  specialSignatureDefinition() =>
        ref(STATIC).optional() & ref(returnType).optional() & ref(getOrSet) & ref(identifier) & ref(formalParameterList)
      | ref(returnType).optional() & ref(OPERATOR) & ref(userDefinableOperator) & ref(formalParameterList);

  getOrSet() => ref(GET) | ref(SET);

  userDefinableOperator() =>
        ref(multiplicativeOperator)
      | ref(additiveOperator)
      | ref(shiftOperator)
      | ref(relationalOperator)
      | ref(bitwiseOperator)
      | ref(token, '==')  // Disallow negative and === equality checks.
      | ref(token, '~')   // Disallow ! operator.
      | ref(NEGATE)
      | ref(token, '[') & ref(token, ']')
      | ref(token, '[') & ref(token, ']') & ref(token, '=');

  prefixOperator() =>
        ref(additiveOperator)
      | ref(negateOperator);

  postfixOperator() =>
      ref(incrementOperator);

  negateOperator() =>
        ref(token, '!')
      | ref(token, '~');

  multiplicativeOperator() =>
        ref(token, '*')
      | ref(token, '/')
      | ref(token, '%')
      | ref(token, '~/');

  assignmentOperator() =>
        ref(token, '=')
      | ref(token, '*=')
      | ref(token, '/=')
      | ref(token, '~/=')
      | ref(token, '%=')
      | ref(token, '+=')
      | ref(token, '-=')
      | ref(token, '<<=')
      | ref(token, '>') & ref(token, '>') & ref(token, '>') & ref(token, '=')
      | ref(token, '>') & ref(token, '>') & ref(token, '=')
      | ref(token, '&=')
      | ref(token, '^=')
      | ref(token, '|=');

  additiveOperator() =>
        ref(token, '+')
      | ref(token, '-');

  incrementOperator() =>
        ref(token, '++')
      | ref(token, '--');

  shiftOperator() =>
        ref(token, '<<')
      | ref(token, '>') & ref(token, '>') & ref(token, '>')
      | ref(token, '>') & ref(token, '>');

  relationalOperator() =>
        ref(token, '>') & ref(token, '=')
      | ref(token, '>')
      | ref(token, '<=')
      | ref(token, '<');

  equalityOperator() =>
        ref(token, '==')
      | ref(token, '!=')
      | ref(token, '===')
      | ref(token, '!==');

  bitwiseOperator() =>
        ref(token, '&')
      | ref(token, '^')
      | ref(token, '|');

  formalParameterList() =>
        ref(token, '(') & ref(namedFormalParameters).optional() & ref(token, ')')
      | ref(token, '(') & ref(normalFormalParameter) & ref(normalFormalParameterTail).optional() & ref(token, ')');

  normalFormalParameterTail() =>
        ref(token, ',') & ref(namedFormalParameters)
      | ref(token, ',') & ref(normalFormalParameter) & ref(normalFormalParameterTail).optional();

  normalFormalParameter() =>
        ref(functionDeclaration)
      | ref(fieldFormalParameter)
      | ref(simpleFormalParameter);

  simpleFormalParameter() =>
        ref(declaredIdentifier)
      | ref(identifier);

  fieldFormalParameter() =>
        ref(finalVarOrType).optional() & ref(THIS) & ref(token, '.') & ref(identifier);

  namedFormalParameters() =>
        ref(token, '[') & ref(defaultFormalParameter) & (ref(token, ',') & ref(defaultFormalParameter)).star() & ref(token, ']');

  defaultFormalParameter() =>
        ref(normalFormalParameter) & (ref(token, '=') & ref(constantExpression)).optional();

  returnType() =>
        ref(VOID)
      | ref(type);

  finalVarOrType() =>
        ref(FINAL) & ref(type).optional()
      | ref(VAR)
      | ref(type)
      ;

  // We have to introduce a separate rule for 'declared' identifiers to
  // allow ANTLR to decide if the first identifier we encounter after
  // final is a type or an identifier. Before this change, we used the
  // production 'finalVarOrType identifier' in numerous places.
  declaredIdentifier() =>
        ref(FINAL) & ref(type).optional() & ref(identifier)
      | ref(VAR) & ref(identifier)
      | ref(type) & ref(identifier)
      ;

  identifier() =>
        ref(IDENTIFIER_NO_DOLLAR)
      | ref(IDENTIFIER)
      | ref(ABSTRACT)
      | ref(ASSERT)
      | ref(CLASS)
      | ref(EXTENDS)
      | ref(FACTORY)
      | ref(GET)
      | ref(IMPLEMENTS)
      | ref(IMPORT)
      | ref(INTERFACE)
      | ref(IS)
      | ref(LIBRARY)
      | ref(NATIVE)
      | ref(NEGATE)
      | ref(OPERATOR)
      | ref(SET)
      | ref(SOURCE)
      | ref(STATIC)
      | ref(TYPEDEF)
      ;

  qualified() =>
        ref(identifier) & (ref(token, '.') & ref(identifier)).optional()
      ;

  type() =>
        ref(qualified) & ref(typeArguments).optional()
      ;

  typeArguments() =>
        ref(token, '<') & ref(typeList) & ref(token, '>')
      ;

  typeList() =>
        ref(type) & (ref(token, ',') & ref(type)).star()
      ;

  block() =>
        ref(token, '{') & ref(statements) & ref(token, '}')
      ;

  statements() =>
        ref(statement).star()
      ;

  statement() =>
        ref(label).star() & ref(nonLabelledStatement)
      ;

  nonLabelledStatement() =>
        ref(block)
      | ref(initializedVariableDeclaration) & ref(token, ';')
      | ref(iterationStatement)
      | ref(selectionStatement)
      | ref(tryStatement)
      | ref(BREAK) & ref(identifier).optional() & ref(token, ';')
      | ref(CONTINUE) & ref(identifier).optional() & ref(token, ';')
      | ref(RETURN) & ref(expression).optional() & ref(token, ';')
      | ref(THROW) & ref(expression).optional() & ref(token, ';')
      | ref(expression).optional() & ref(token, ';')
      | ref(ASSERT) & ref(token, '(') & ref(conditionalExpression) & ref(token, ')') & ref(token, ';')
      | ref(functionDeclaration) & ref(functionBody)
      ;

  label() =>
        ref(identifier) & ref(token, ':')
      ;

  iterationStatement() =>
        ref(WHILE) & ref(token, '(') & ref(expression) & ref(token, ')') & ref(statement)
      | ref(DO) & ref(statement) & ref(WHILE) & ref(token, '(') & ref(expression) & ref(token, ')') & ref(token, ';')
      | ref(FOR) & ref(token, '(') & ref(forLoopParts) & ref(token, ')') & ref(statement)
      ;

  forLoopParts() =>
        ref(forInitializerStatement) & ref(expression).optional() & ref(token, ';') & ref(expressionList).optional()
      | ref(declaredIdentifier) & ref(IN) & ref(expression)
      | ref(identifier) & ref(IN) & ref(expression)
      ;

  forInitializerStatement() =>
        ref(initializedVariableDeclaration) & ref(token, ';')
      | ref(expression).optional() & ref(token, ';')
      ;

  selectionStatement() =>
        ref(IF) & ref(token, '(') & ref(expression) & ref(token, ')') & ref(statement) & (ref(ELSE) & ref(statement)).optional()
      | ref(SWITCH) & ref(token, '(') & ref(expression) & ref(token, ')') & ref(token, '{') & ref(switchCase).star() & ref(defaultCase).optional() & ref(token, '}')
      ;

  switchCase() =>
        ref(label).optional() & (ref(CASE) & ref(expression) & ref(token, ':')).plus() & ref(statements)
      ;

  defaultCase() =>
        ref(label).optional() & (ref(CASE) & ref(expression) & ref(token, ':')).star() & ref(DEFAULT) & ref(token, ':') & ref(statements)
      ;

  tryStatement() =>
        ref(TRY) & ref(block) & (ref(catchPart).plus() & ref(finallyPart).optional() | finallyPart)
      ;

  catchPart() =>
        ref(CATCH) & ref(token, '(') & ref(declaredIdentifier) & (ref(token, ',') & ref(declaredIdentifier)).optional() & ref(token, ')') & ref(block)
      ;

  finallyPart() =>
        ref(FINALLY) & ref(block)
      ;

  variableDeclaration() =>
        ref(declaredIdentifier) & (ref(token, ',') & ref(identifier)).star()
      ;

  initializedVariableDeclaration() =>
        ref(declaredIdentifier) & (ref(token, '=') & ref(expression)).optional() & (ref(token, ',') & ref(initializedIdentifier)).star()
      ;

  initializedIdentifierList() =>
        ref(initializedIdentifier) & (ref(token, ',') & ref(initializedIdentifier)).star()
      ;

  initializedIdentifier() =>
        ref(identifier) & (ref(token, '=') & ref(expression)).optional()
      ;

  constInitializedVariableDeclaration() =>
        ref(declaredIdentifier) & (ref(token, '=') & ref(constantExpression)).optional()
        (ref(token, ',') & ref(constInitializedIdentifier)).star()
      ;

  constInitializedIdentifier() =>
        ref(identifier) & (ref(token, '=') & ref(constantExpression)).optional()
      ;

  // The constant expression production is used to mark certain expressions
  // as only being allowed to hold a compile-time constant. The grammar cannot
  // express these restrictions (yet), so this will have to be enforced by a
  // separate analysis phase.
  constantExpression() =>
        ref(expression)
      ;

  expression() =>
        ref(assignableExpression) & ref(assignmentOperator) & ref(expression)
      | ref(conditionalExpression)
      ;

  expressionList() =>
        ref(expression) & (ref(token, ',') & ref(expression)).star()
      ;

  arguments() =>
        ref(token, '(') & ref(argumentList).optional() & ref(token, ')')
      ;

  argumentList() =>
        ref(namedArgument) & (ref(token, ',') & namedArgument).star()
      | ref(expressionList) & (ref(token, ',') & namedArgument).star()
      ;

  namedArgument() =>
        ref(label) & ref(expression)
      ;

  assignableExpression() =>
        ref(primary) & (ref(arguments).star() & ref(assignableSelector)).plus()
      | ref(SUPER) & ref(assignableSelector)
      | ref(identifier)
      ;

  conditionalExpression() =>
        ref(logicalOrExpression) & (ref(token, '?') & ref(expression) & ref(token, ':') & ref(expression)).optional()
      ;

  logicalOrExpression() =>
       logicalAndExpression (ref(token, '||') logicalAndExpression).star()
      ;

  logicalAndExpression() =>
       bitwiseOrExpression (ref(token, '&&') bitwiseOrExpression).star()
      ;

  bitwiseOrExpression() =>
       bitwiseXorExpression (ref(token, '|') bitwiseXorExpression).star()
      | SUPER (ref(token, '|') bitwiseXorExpression).plus()
      ;

  bitwiseXorExpression() =>
       bitwiseAndExpression (ref(token, '^') bitwiseAndExpression).star()
      | SUPER (ref(token, '^') bitwiseAndExpression).plus()
      ;

  bitwiseAndExpression() =>
       equalityExpression (ref(token, '&') equalityExpression).star()
      | SUPER (ref(token, '&') equalityExpression).plus()
      ;

  equalityExpression() =>
       relationalExpression (equalityOperator relationalExpression).optional()
      | SUPER equalityOperator relationalExpression
      ;

  relationalExpression() =>
       shiftExpression (isOperator type | relationalOperator shiftExpression).optional()
      | SUPER relationalOperator shiftExpression
      ;

  isOperator() =>
       IS ref(token, '!').optional()
      ;

  shiftExpression() =>
       additiveExpression (shiftOperator additiveExpression).star()
      | SUPER (shiftOperator additiveExpression).plus()
      ;

  additiveExpression() =>
       multiplicativeExpression (additiveOperator multiplicativeExpression).star()
      | SUPER (additiveOperator multiplicativeExpression).plus()
      ;

  multiplicativeExpression() =>
       unaryExpression (multiplicativeOperator unaryExpression).star()
      | SUPER (multiplicativeOperator unaryExpression).plus()
      ;

  unaryExpression() =>
       postfixExpression
      | prefixOperator unaryExpression
      | negateOperator SUPER
      | ref(token, '-') SUPER  // Invokes the NEGATE operator.
      | incrementOperator assignableExpression
      ;

  postfixExpression() =>
       assignableExpression postfixOperator
      | primary ref(selector).star()
      ;

  selector() =>
       assignableSelector
      | arguments
      ;

  assignableSelector
      : ref(token, '[') expression ref(token, ']')
      | ref(token, '.') identifier
      ;

  primary() =>
       {!parseFunctionExpressions}?=> primaryNoFE
      | primaryFE
      ;

  primaryFE() =>
       functionExpression
      | primaryNoFE
      ;

  primaryNoFE() =>
       THIS
      | SUPER assignableSelector
      | literal
      | identifier
      | ref(CONST).optional() ref(typeArguments).optional() compoundLiteral
      | (NEW | CONST) type (ref(token, '.') identifier).optional() arguments
      | expressionInParentheses
      ;

  expressionInParentheses
      :ref(token, '(') expression ref(token, ')')
      ;

  literal() =>
       NULL
      | TRUE
      | FALSE
      | HEX_NUMBER
      | NUMBER
      | STRING
      ;

  compoundLiteral
      : listLiteral
      | mapLiteral
      ;

// The list literal syntax doesn't allow elided elements, unlike
// in ECMAScript. We do allow a trailing comma.
  listLiteral() =>
       '[' (expressionList ','?).optional() ']'
      ;

  mapLiteral() =>
       '{' (mapLiteralEntry (',' mapLiteralEntry).star() ','?).optional() '}'
      ;

  mapLiteralEntry() =>
       STRING ':' expression
      ;

  functionExpression() =>
       (ref(returnType).optional() identifier).optional() formalParameterList functionExpressionBody
      ;

  functionDeclaration() =>
       ref(returnType).optional() identifier formalParameterList
      ;

  functionPrefix() =>
       ref(returnType).optional() identifier
      ;

  functionBody() =>
       '=>' expression ';'
      | block
      ;

  functionExpressionBody() =>
       '=>' expression
      | block
      ;

  // -----------------------------------------------------------------
  // Library files.
  // -----------------------------------------------------------------
  libraryUnit() =>
       libraryDefinition EOF
      ;

  libraryDefinition() =>
       LIBRARY '{' libraryBody '}'
      ;

  libraryBody() =>
       ref(libraryImport).optional() ref(librarySource).optional()
      ;

  libraryImport() =>
       IMPORT '=' '[' ref(importReferences).optional() ']'
      ;

  importReferences() =>
       importReference (',' importReference).star() ','?
      ;

  importReference() =>
       (IDENTIFIER ':').optional() STRING
      ;

  librarySource() =>
       SOURCE '=' '[' ref(sourceUrls).optional() ']'
      ;

  sourceUrls() =>
       STRING (',' STRING).star() ','?
      ;


  // -----------------------------------------------------------------
  // Lexical tokens.
  // -----------------------------------------------------------------
  IDENTIFIER_NO_DOLLAR() =>
       IDENTIFIER_START_NO_DOLLAR ref(IDENTIFIER_PART_NO_DOLLAR).star()
      ;

  IDENTIFIER() =>
       IDENTIFIER_START ref(IDENTIFIER_PART).star()
      ;

  HEX_NUMBER() =>
       '0x' ref(HEX_DIGIT).plus()
      | '0X' ref(HEX_DIGIT).plus()
      ;

  NUMBER() =>
       ref(DIGIT).plus() NUMBER_OPT_FRACTIONAL_PART ref(EXPONENT).optional() NUMBER_OPT_ILLEGAL_END
      | '.' ref(DIGIT).plus() ref(EXPONENT).optional() NUMBER_OPT_ILLEGAL_END
      ;

  fragment NUMBER_OPT_FRACTIONAL_PART
      : ('.' DIGIT)=> ('.' ref(DIGIT).plus())
      | // Empty fractional part.
      ;

  fragment NUMBER_OPT_ILLEGAL_END
      : (IDENTIFIER_START)=> { error("numbers cannot contain identifiers"); }
      | // Empty illegal end (good!).
      ;

  fragment HEX_DIGIT
      : 'a'..'f'
      | 'A'..'F'
      | DIGIT
      ;

  fragment IDENTIFIER_START
      : IDENTIFIER_START_NO_DOLLAR
      | '$'
      ;

  fragment IDENTIFIER_START_NO_DOLLAR
      : LETTER
      | '_'
      ;

  fragment IDENTIFIER_PART_NO_DOLLAR
      : IDENTIFIER_START_NO_DOLLAR
      | DIGIT
      ;

  fragment IDENTIFIER_PART
      : IDENTIFIER_START
      | DIGIT
      ;

// Bug 5408613: Should be Unicode characters.
  fragment LETTER
      : 'a'..'z'
      | 'A'..'Z'
      ;

  fragment DIGIT
      : '0'..'9'
      ;

  fragment EXPONENT
      : ('e' | 'E') ('+' | '-').optional() ref(DIGIT).plus()
      ;

  STRING() =>
       '@'? MULTI_LINE_STRING
      | SINGLE_LINE_STRING
      ;

  fragment MULTI_LINE_STRING
  options { greedy=false; }
      : '"""' .* '"""'
    | '\'\'\'' .* '\'\'\''
    ;

  fragment SINGLE_LINE_STRING
      : '"' ref(STRING_CONTENT_DQ).star() '"'
      | '\'' ref(STRING_CONTENT_SQ).star() '\''
      | '@' '\'' (~( '\'' | NEWLINE )).star() '\''
      | '@' '"' (~( '"' | NEWLINE )).star() '"'
      ;

  fragment STRING_CONTENT_DQ
      : ~( '\\' | '"' | NEWLINE )
      | '\\' ~( NEWLINE )
      ;

  fragment STRING_CONTENT_SQ
      : ~( '\\' | '\'' | NEWLINE )
      | '\\' ~( NEWLINE )
      ;

  fragment NEWLINE
      : '\n'
      | '\r'
      ;

  BAD_STRING() =>
       UNTERMINATED_STRING NEWLINE { error("unterminated string"); }
      ;

  fragment UNTERMINATED_STRING
      : '@'? '\'' (~( '\'' | NEWLINE )).star()
      | '@'? '"' (~( '"' | NEWLINE )).star()
      ;

  HASHBANG() =>
       '#!' ~(NEWLINE).star() (NEWLINE).optional()
      ;


  // -----------------------------------------------------------------
  // Whitespace and comments.
  // -----------------------------------------------------------------
  WHITESPACE() =>
       ('\t' | ' ' | NEWLINE).plus() { $channel=HIDDEN; }
      ;

  SINGLE_LINE_COMMENT() =>
       '//' ~(NEWLINE).star() (NEWLINE).optional() { $channel=HIDDEN; }
      ;

  MULTI_LINE_COMMENT() =>
       '/*' (options { greedy=false; } : .).star() '*/' { $channel=HIDDEN; }
      ;

}
