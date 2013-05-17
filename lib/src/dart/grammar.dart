// Copyright (c) 2013, Lukas Renggli <renggli@gmail.com>

part of dart;

/**
 * Dart grammar definition.
 */
class DartGrammar extends CompositeParser2 {

  void initialize() {
    _whitespace();
    _lexemes();
    _keywords();
    _types();
    _declarations();
    _expressions();
    _statements();
    _libraries();
  }

  /** Defines the whitespace and comments. */
  void _whitespace() {
    def('whitespace', whitespace()
      .or(ref('singe line comment'))
      .or(ref('multi line comment')));
    def('singe line comment', string('//')
      .seq(Token.newlineParser().neg().star()));
    def('multi line comment', string('/*')
      .seq(string('*/').neg().star())
      .seq(string('*/')));
  }

  /** Defines a token parser that consumes whitespace. */
  Parser _token(String input) {
    assert(input != null && input.length > 0);
    var parser = input.length == 1 ? char(input) :
        string(input);
    return parser.token().trim(ref('whitespace'));
  }

  void _lexemes() {
    backSlash = _token('\\');
    colon = _token(':');
    comma = _token(',');
    dollar = _token('\$');
    dot = _token('.');
    doubleQuote = _token('"');
    equalSign = _token('=');
    lparen = _token('(');
    minus = _token('-');
    pluz = _token('+');
    rparen = _token(')');
    semicolon = _token(';');
    singleQuote = _token("'");
    tripleDoubleQuote = _token('"""');
    tripleSingleQuote = _token("'''");

    DIGIT = range('0', '9');
    LETTER = letter();
    HEX_DIGIT =
        range('a','f')
        | range('A','F')
        | DIGIT
        ;

    HEX_NUMBER =
        _token('0x') & HEX_DIGIT.plus()
    | _token('0X') & HEX_DIGIT.plus()
    ;

    EXPONENT =
      (_token('e') | _token('E')) & (pluz | minus).optional() & DIGIT.plus()
    ;

    NUMBER =
      DIGIT.plus() & (dot & DIGIT.plus()).optional() & EXPONENT.optional()
    |  dot & DIGIT.plus() & EXPONENT.optional()
    ;

    HEX_DIGIT_SEQUENCE =
      HEX_DIGIT & HEX_DIGIT.optional() & HEX_DIGIT.optional() & HEX_DIGIT.optional() & HEX_DIGIT.optional() & HEX_DIGIT.optional();

    ESCAPE_SEQUENCE =
        _token('\n')
      | _token('\r')
      | _token('\f')
      | _token('\b')
      | _token('\t')
      | _token('\v')
      | _token('\\x') & HEX_DIGIT & HEX_DIGIT
      | _token('\\u') & HEX_DIGIT & HEX_DIGIT & HEX_DIGIT & HEX_DIGIT
      | _token('\\u{') & HEX_DIGIT_SEQUENCE & _token('}')
      ;

  }

  void _keywords() {
    ASSERT = _token('assert');
    BREAK = _token('break');
    CASE = _token('case');
    CATCH = _token('catch');
    CLASS = _token('class');
    CONST = _token('const');
    CONTINUE = _token('continue');
    DEFAULT = _token('default');
    DO = _token('do');
    ELSE = _token('else');
    EXTENDS = _token('extends');
    FALSE = _token('false');
    FINAL = _token('final');
    FINALLY = _token('finally');
    FOR = _token('for');
    IF = _token('if');
    IN = _token('in');
    IS = _token('is');
    NEW = _token('new');
    NULL = _token('null');
    RETHROW = _token('rethrow');
    RETURN = _token('return');
    SUPER = _token('super');
    SWITCH = _token('switch');
    THIS = _token('this');
    THROW = _token('throw');
    TRUE = _token('true');
    TRY = _token('try');
    VAR = _token('var');
    VOID = _token('void');
    WHILE = _token('while');
    WITH = _token('with');

    // built-in identifiers

    ABSTRACT = _token('abstract');
    AS = _token('as');
    DYNAMIC = _token('dynamic');
    EXPORT = _token('export');
    EXTERNAL = _token('external');
    FACTORY = _token('factory');
    GET = _token('get');
    IMPLEMENTS = _token('implements');
    IMPORT = _token('import');
    LIBRARY = _token('library');
    OPERATOR = _token('operator');
    PART = _token('part');
    SET = _token('set');
    STATIC = _token('static');
    TYPEDEF = _token('typedef');

    // special cases
    HIDE = _token('hide');
    SHOW = _token('show');
    OF = _token('of');
    ON = _token('on');

  }

  void _types() {

    typeArguments = _token('<') & typeList & _token('>');
    typeName = qualified;
    type = typeName & typeArguments.optional();
    typeList = type.separatedBy(comma).optional();
    functionPrefix = returnType.optional() & identifier;
    functionTypeAlias = functionPrefix & typeParameters.optional() & formalParameterList & semicolon;
    typeAliasBody = identifier & typeParameters.optional() & equalSign & ABSTRACT.optional() & mixinApplication | functionTypeAlias;
    typeAlias = metadata & TYPEDEF & typeAliasBody;

  }

  void _declarations() {
    metadata = (_token('@') & qualified & (dot & identifier).optional() & arguments.optional()).star();

    typeParameter = metadata & identifier & (EXTENDS & type).optional();
    typeParameters = _token('<') & typeParameter.separatedBy(comma) & _token('>');

    returnType =
      VOID
      | type
    ;

    varOrType =
        VAR
        | type
        ;

    finalConstVarOrType =
      FINAL & type.optional()
      | CONST & type.optional()
      | varOrType
    ;

    declaredIdentifier = metadata & finalConstVarOrType & identifier;
    variableDeclaration = declaredIdentifier.separatedBy(comma);
    initializedIdentifier = identifier & (equalSign & expression).optional();
    initializedVariableDeclaration = declaredIdentifier & (equalSign & expression).optional() & (comma & initializedIdentifier).star();
    initializedIdentifierList = initializedIdentifier.separatedBy(comma);


    fieldFormalParameter = metadata & finalConstVarOrType.optional() & THIS & dot & identifier;

    simpleFormalParameter =
      declaredIdentifier
    | metadata & identifier
    ;

    normalFormalParameter =
      functionSignature
    | fieldFormalParameter
    | simpleFormalParameter
    ;

    normalFormalParameters = normalFormalParameter.separatedBy(comma);
    defaultFormalParameter = normalFormalParameter & (equalSign & expression).optional();
    defaultNamedParameter = normalFormalParameter & (colon & expression).optional();
    optionalPositionalFormalParameters = _token('[') & defaultFormalParameter.separatedBy(comma) & _token(']');

    optionalFormalParameters =
      optionalPositionalFormalParameters |
      namedFormalParameters
    ;

    formalParameterList =
      lparen & rparen
      | lparen & normalFormalParameters & (comma & optionalFormalParameters).optional() & rparen
      | lparen & optionalFormalParameters & rparen
    ;

    namedFormalParameters = _token('{') & defaultNamedParameter.separatedBy(comma) & _token('}');

    functionSignature = metadata & returnType.optional() & identifier & formalParameterList;
    block = _token('{') & statements & _token('}');

    functionBody =
      _token('=>') & expression & semicolon
      | block
    ;


    interfaces = IMPLEMENTS & typeList;
    superclass = EXTENDS & type;
    ;

    constantConstructorSignature = CONST & qualified & formalParameterList;
    redirectingFactoryConstructorSignature =
      CONST.optional() & FACTORY & identifier & (dot & identifier).optional() &  formalParameterList & equalSign & type & (dot & identifier).optional()
    ;
    factoryConstructorSignature =
        FACTORY & identifier & (dot & identifier).optional() & formalParameterList
    ;


    fieldInitializer = (THIS & dot).optional() & identifier & equalSign & conditionalExpression & cascadeSection.star();
    superCallOrFieldInitializer =
      SUPER & arguments
      | SUPER & dot & identifier & arguments
      | fieldInitializer
    ;

    initializers = colon & superCallOrFieldInitializer.separatedBy(comma);
    redirection = colon & THIS & (dot & identifier).optional() & arguments;
    constructorSignature = identifier & (dot & identifier).optional() & formalParameterList;
    setterSignature = returnType.optional() & SET & identifier & formalParameterList;
    getterSignature = type.optional() & GET & identifier;

    binaryOperator =
      multiplicativeOperator
    | additiveOperator
    | shiftOperator
    | relationalOperator
    | _token('==')
    | bitwiseOperator
    ;

    operator =
      _token('~')
    | binaryOperator
    | _token('[') & _token(']')
    | _token('[') & _token(']') & equalSign
    ;

    operatorSignature = returnType.optional() & OPERATOR & operator & formalParameterList;

    mixins = WITH & typeList;

    methodSignature =
      constructorSignature & initializers.optional()
    | factoryConstructorSignature
    | STATIC.optional() & functionSignature
    | STATIC.optional() & getterSignature
    | STATIC.optional() & setterSignature
    | operatorSignature
    ;

    staticFinalDeclaration = identifier & equalSign & expression;
    staticFinalDeclarationList = staticFinalDeclaration.separatedBy(comma);

    declaration =
      constantConstructorSignature & (redirection | initializers).optional()
    | constructorSignature & (redirection | initializers).optional()
    | EXTERNAL & constantConstructorSignature
    | EXTERNAL & constructorSignature
    | EXTERNAL & factoryConstructorSignature
    | (EXTERNAL & STATIC.optional()).optional() & getterSignature
    | (EXTERNAL & STATIC.optional()).optional() & setterSignature
    | EXTERNAL.optional() & operatorSignature
    | (EXTERNAL & STATIC.optional()).optional() & functionSignature
    | getterSignature
    | setterSignature
    | operatorSignature
    | functionSignature
    | STATIC & (FINAL | CONST) & type.optional() & staticFinalDeclarationList
    | CONST & type.optional() & staticFinalDeclarationList
    | FINAL & type.optional() & initializedIdentifierList
    | STATIC.optional() & (VAR | type) & initializedIdentifierList
    ;



    classMemberDefinition =
      declaration & semicolon
      | methodSignature & functionBody
    ;

    classDefinition =
        metadata & ABSTRACT.optional() & CLASS & identifier & typeParameters.optional() & (superclass & mixins.optional()).optional() & interfaces.optional()
        & _token('{') & (metadata & classMemberDefinition).star() & _token('}')
        ;

    mixinApplication = type & mixins & interfaces.optional();

  }

  void _expressions() {

    IDENTIFIER_START_NO_DOLLAR =
      LETTER
    | _token('_')
    ;

    IDENTIFIER_START =
      IDENTIFIER_START_NO_DOLLAR
    | dollar
    ;

    IDENTIFIER_PART_NO_DOLLAR =
      IDENTIFIER_START_NO_DOLLAR
    | DIGIT
    ;


    IDENTIFIER_PART =
      IDENTIFIER_START
    | DIGIT
    ;

    IDENTIFIER_NO_DOLLAR = IDENTIFIER_START_NO_DOLLAR & IDENTIFIER_PART_NO_DOLLAR.star();

    IDENTIFIER = IDENTIFIER_START & IDENTIFIER_PART.star();

    identifier = IDENTIFIER.flatten().token().trim();
    qualified = identifier.separatedBy(dot);

    assignableSelector =
      _token('[') & expression & _token(']')
    | dot & identifier
    ;

    assignableExpression =
      primary & (arguments.star() & assignableSelector).plus()
    | SUPER & assignableSelector
    | identifier
    ;

    incrementOperator = _token('++') | _token('--');
    selector = assignableSelector | arguments;
    postfixOperator = incrementOperator;

    postfixExpression =
      assignableExpression & postfixOperator
    | primary & selector.star()
    ;

    unaryOperator = _token('!') | _token('~');
    prefixOperator = minus | unaryOperator;
    unaryExpression =
      prefixOperator & unaryExpression
    | postfixExpression
    | prefixOperator & SUPER
    | incrementOperator & assignableExpression
    ;

    multiplicativeOperator = _token('*') | _token('/') | _token('%') | _token('~/');
    multiplicativeExpression =
      unaryExpression & (multiplicativeOperator & unaryExpression).star()
    | SUPER & (multiplicativeOperator & unaryExpression).plus()
    ;

    additiveOperator = pluz | minus;

    additiveExpression =
      multiplicativeExpression & (additiveOperator & multiplicativeExpression).star()
    | SUPER & (additiveOperator & multiplicativeExpression).plus()
    ;

    shiftOperator = _token('<<') | _token('>>');
    shiftExpression =
      additiveExpression & (shiftOperator & additiveExpression).star()
    | SUPER & (shiftOperator & additiveExpression).plus()
    ;

    relationalOperator = _token('<') | _token('>') | _token('<=') | _token('>=');
    relationalExpression =
      shiftExpression & (typeTest | typeCast | relationalOperator & shiftExpression).optional()
    | SUPER & relationalOperator & shiftExpression
    ;

    equalityOperator = _token('==') | _token('!=');
    equalityExpression =
      relationalExpression & (equalityOperator & relationalExpression).optional()
    | SUPER & equalityOperator & relationalExpression
    ;

    bitwiseOperator = _token('|') | _token('&') | _token('^');
    bitwiseAndExpression =
      equalityExpression & (_token('&') & equalityExpression).star()
    | SUPER & (_token('&') & equalityExpression).plus()
    ;
    bitwiseXorExpression =
      bitwiseAndExpression & (_token('^') & bitwiseAndExpression).star()
    | SUPER & (_token('^') & bitwiseAndExpression).plus()
    ;
    bitwiseOrExpression =
        bitwiseXorExpression & (_token('|') & bitwiseXorExpression).star()
        | SUPER & (_token('|') & bitwiseXorExpression).plus()
        ;

    logicalAndExpression = bitwiseOrExpression & (_token('&&') & bitwiseOrExpression).star();
    logicalOrExpression = logicalAndExpression & (_token('||') & logicalAndExpression).star();

    conditionalExpression = logicalOrExpression & (_token('?') & expressionWithoutCascade & colon & expressionWithoutCascade).optional();

    compoundAssignmentOperator =
      _token('*=')
    | _token('/=')
    | _token('~/=')
    | _token('%=')
    | _token('+=')
    | _token('-=')
    | _token('<<=')
    | _token('>>=')
    | _token('&=')
    | _token('^=')
    | _token('|=')
    ;
    assignmentOperator = equalSign | compoundAssignmentOperator;

    cascadeSelector =
      _token('[') & expression & _token(']')
      | identifier
      ;
    cascadeSection =
      _token('..')  &
      (cascadeSelector & arguments.star()) &
      (assignableSelector & arguments.star()).star() &
      (assignmentOperator & expressionWithoutCascade).optional()
    ;

    namedArgument = label & expression;
    argumentList =
      namedArgument.separatedBy(comma)
    | expressionList.separatedBy(comma)
    ;
    arguments = lparen & argumentList.optional() & rparen;

    isOperator = IS & _token('!').optional();
    typeTest = isOperator & type;
    typeCast = AS & type;
    argumentDefinitionTest = _token('?') & identifier;

    constObjectExpression = CONST & type & (dot & identifier).optional() & arguments;
    newExpression = NEW & type & (dot & identifier).optional() & arguments;

    thisExpression = THIS;

    functionExpressionBody =
      _token('=>') & expression
    | block
    ;
    functionExpression = formalParameterList & functionExpressionBody;

    rethrowExpression = RETHROW;
    throwExpression = THROW & expression;
    throwExpressionWithoutCascade = THROW & expressionWithoutCascade;

    mapLiteralEntry = stringLiteral & colon & expression;
    mapLiteral =
      CONST.optional() &
      typeArguments.optional() &
      _token('{') &
      (mapLiteralEntry & (dot & mapLiteralEntry).star() & comma.optional()).optional() &
      _token('}');

    listLiteral =
        CONST.optional() & typeArguments.optional() & _token('[') & (expressionList & comma.optional()).optional() & _token(']');

    stringInterpolation = dollar & IDENTIFIER_NO_DOLLAR |
        dollar & _token('{') & expression & _token('}');
    NEWLINE = _token('\\n') | _token('\r');
    stringContentDQ = (backSlash | doubleQuote | dollar | NEWLINE).neg() |
        backSlash & NEWLINE.neg() |
        stringInterpolation;
    stringContentSQ = (backSlash | singleQuote | dollar | NEWLINE).neg() |
        backSlash & NEWLINE.neg() |
        stringInterpolation;
    stringContentTDQ = (backSlash | tripleDoubleQuote | dollar | NEWLINE).not() |
        backSlash & NEWLINE.not() |
        stringInterpolation;
    stringContentTSQ = (backSlash | tripleSingleQuote | dollar | NEWLINE).not() |
        backSlash & NEWLINE.not() |
        stringInterpolation;

    multilineString =
      tripleDoubleQuote & stringContentTDQ.star() & tripleDoubleQuote
      | tripleSingleQuote & stringContentTSQ.star() & tripleSingleQuote
      | _token('r') & tripleDoubleQuote & doubleQuote.not().star() & tripleDoubleQuote
      | _token('r') & tripleSingleQuote & singleQuote.not().star() & tripleSingleQuote
    ;

    singleLineString =
        doubleQuote & stringContentDQ.star() & doubleQuote
        | singleQuote & stringContentSQ.star() & singleQuote
        | _token('r') & doubleQuote & ( doubleQuote | NEWLINE ).neg().star() & doubleQuote
        | _token('r') & singleQuote & ( singleQuote | NEWLINE ).neg().star() & singleQuote
        ;


    stringLiteral =
      multilineString.plus()
    | singleLineString.plus()
    ;

    numericLiteral =
      NUMBER
      | HEX_NUMBER
    ;

    booleanLiteral =
      TRUE
    | FALSE
    ;

    nullLiteral = NULL;

    literal =
      nullLiteral
    | booleanLiteral
    | numericLiteral
    | stringLiteral
    | mapLiteral
    | listLiteral
    ;

    expression =
      assignableExpression & assignmentOperator & expression
      | conditionalExpression & cascadeSection.star()
      | throwExpression
      | rethrowExpression
    ;



    expressionWithoutCascade =
      assignableExpression & assignmentOperator & expressionWithoutCascade
      | conditionalExpression
      | throwExpressionWithoutCascade
      | rethrowExpression
    ;

    expressionList =  expression.separatedBy(comma);


    primary =
      thisExpression
      | SUPER & assignableSelector
      | functionExpression
      | literal
      | identifier
      | newExpression
      | constObjectExpression
      | lparen & expression & rparen
      | argumentDefinitionTest
    ;

  }

  void _statements() {

    assertStatement = ASSERT & lparen & conditionalExpression & rparen & semicolon;
    continueStatement = CONTINUE & identifier.optional() & semicolon;
    breakStatement = BREAK & identifier.optional() & semicolon;
    label = identifier & colon;
    returnStatement = RETURN & expression.optional() & semicolon;

    finallyPart = FINALLY & block;
    catchPart = CATCH & lparen & identifier & (comma & identifier).optional() & rparen;
    onPart =
        catchPart &  block
        | ON & type & catchPart.optional() & block
    ;

    tryStatement = TRY & block & (onPart.plus() & finallyPart.optional() | finallyPart);

    defaultCase = label.star() & DEFAULT & colon & statements;
    switchCase = label.star() & (CASE & expression & colon) & statements;
    switchStatement = SWITCH & lparen & expression & rparen & _token('{') & switchCase.star() & defaultCase.optional() & _token('}');
    doStatement = DO & statement & WHILE & lparen & expression & rparen & semicolon;
    whileStatement = WHILE & lparen & expression & rparen & statement;

    forInitializerStatement =
      localVariableDeclaration & semicolon
    | expression.optional() & semicolon
    ;

    forLoopParts =
      forInitializerStatement & expression.optional() & semicolon & expressionList.optional()
    | declaredIdentifier & IN & expression
    | identifier & IN & expression
    ;

    forStatement = FOR & lparen & forLoopParts & rparen & statement;
    ifStatement = IF & lparen & expression & rparen & statement & (ELSE & statement).optional();
    localFunctionDeclaration = functionSignature & functionBody;
    localVariableDeclaration = initializedVariableDeclaration & semicolon;
    expressionStatement = expression.optional() & semicolon;

    nonLabelledStatement =
          block
          | localVariableDeclaration & semicolon
          | forStatement
          | whileStatement
          | doStatement
          | switchStatement
          | ifStatement
          | tryStatement
          | breakStatement
          | continueStatement
          | returnStatement
          | expressionStatement
          | assertStatement
          | localFunctionDeclaration;


    statement = label.star() & nonLabelledStatement;
    statements = statement.star();

  }

  void _libraries() {

    uri = stringLiteral;
    getOrSet = GET | SET;

    topLevelDefinition =
        classDefinition
        | mixinApplication
        | typeAlias
        | EXTERNAL & functionSignature
        | EXTERNAL & getterSignature
        | EXTERNAL & setterSignature
        | functionSignature & functionBody
        | returnType.optional() & getOrSet & identifier & formalParameterList & functionBody
        | (FINAL | CONST) & type.optional() & staticFinalDeclarationList & semicolon
        | variableDeclaration & semicolon
        ;

    identifierList = identifier.separatedBy(comma).optional();
    combinator =
        SHOW & identifierList
        | HIDE & identifierList;


    libraryImport = metadata & IMPORT & (AS & identifier).optional() & combinator.star() & semicolon;
    libraryExport = metadata & EXPORT & uri & combinator.star() & semicolon;
    importOrExport = libraryImport | libraryExport;

    libraryName = metadata & LIBRARY & identifier.separatedBy(dot) & semicolon;

    partDirective = metadata & PART & stringLiteral & semicolon;
    partHeader = metadata & PART & OF & identifier.separatedBy(dot) & semicolon;
    partDeclaration = partHeader & topLevelDefinition.star();

    libraryDefinition = libraryName.optional() & importOrExport.star() & partDirective.star() & topLevelDefinition.star();

    scriptTag = _token('#!') & NEWLINE.not().star() & NEWLINE;
    scriptDefinition = scriptTag.optional() & libraryDefinition;

    start = scriptDefinition.end();

  }

}