part of dart;

/**
 * Dart grammar definition.
 */
@proxy
class DartGrammar extends CompositeParser2 {

  @override
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

  /** Defines whitespace, documentation and comments. */
  void _whitespace() {
    def('whitespace', whitespace()
      .or(ref('singe-line comment'))
      .or(ref('multi-line comment')));
    def('newline', Token.newlineParser());

    def('singe-line comment', string('//')
      .seq(ref('newline').neg().star())
      .seq(ref('newline').optional()));
    def('multi-line comment', string('/*')
      .seq(ref('multi-line comment')
          .or(string('*/').neg())
          .star())
      .seq(string('*/')));
  }

  /** Helper to define a token parser that consumes whitespace. */
  Parser _token(input) {
    var parser = input is Parser ? input :
      input.length == 1 ? char(input) :
      string(input);
    return parser.token().trim(ref('whitespace'));
  }

  void _lexemes() {
    DIGIT = digit();
    LETTER = letter();
    HEX_DIGIT = range('a', 'f')
              | range('A', 'F')
              | DIGIT
              ;

    HEX_NUMBER = string('0x') & HEX_DIGIT.plus()
               | string('0X') & HEX_DIGIT.plus()
               ;

    EXPONENT = (char('e') | char('E')) & (char('+') | char('-')).optional() & DIGIT.plus();

    NUMBER = DIGIT.plus() & (char('.') & DIGIT.plus()).optional() & EXPONENT.optional()
           | char('.') & DIGIT.plus() & EXPONENT.optional()
           ;

    HEX_DIGIT_SEQUENCE = HEX_DIGIT.repeat(1, 6);

    ESCAPE_SEQUENCE =
        string('\\n')
      | string('\\r')
      | string('\\f')
      | string('\\b')
      | string('\\t')
      | string('\\v')
      | string('\\x') & HEX_DIGIT & HEX_DIGIT
      | string('\\u') & HEX_DIGIT & HEX_DIGIT & HEX_DIGIT & HEX_DIGIT
      | string('\\u{') & HEX_DIGIT_SEQUENCE & char('}')
      ;

  }

  void _keywords() {

    // A reserved word may not be used as an identifier; it is a compile-time error if a
    // reserved word is used where an identifier is expected.
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
    ENUM = _token('enum');
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
    typeList = type.separatedBy(_token(',')).optional();
    functionPrefix = returnType.optional() & identifier;
    functionTypeAlias = functionPrefix & typeParameters.optional() & formalParameterList & _token(';');
    typeAliasBody = identifier & typeParameters.optional() & _token('=') & ABSTRACT.optional() & mixinApplication | functionTypeAlias;
    typeAlias = metadata & TYPEDEF & typeAliasBody;

  }

  void _declarations() {
    metadata = (_token('@') & qualified & (_token('.') & identifier).optional() & arguments.optional()).star();

    typeParameter = metadata & identifier & (EXTENDS & type).optional();
    typeParameters = _token('<') & typeParameter.separatedBy(_token(',')) & _token('>');

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
    variableDeclaration = declaredIdentifier.separatedBy(_token(','));
    initializedIdentifier = identifier & (_token('=') & expression).optional();
    initializedVariableDeclaration = declaredIdentifier & (_token('=') & expression).optional() & (_token(',') & initializedIdentifier).star();
    initializedIdentifierList = initializedIdentifier.separatedBy(_token(','));


    fieldFormalParameter = metadata & finalConstVarOrType.optional() & THIS & _token('.') & identifier;

    simpleFormalParameter =
      declaredIdentifier
    | metadata & identifier
    ;

    normalFormalParameter =
      functionSignature
    | fieldFormalParameter
    | simpleFormalParameter
    ;

    normalFormalParameters = normalFormalParameter.separatedBy(_token(','));
    defaultFormalParameter = normalFormalParameter & (_token('=') & expression).optional();
    defaultNamedParameter = normalFormalParameter & (_token(':') & expression).optional();
    optionalPositionalFormalParameters = _token('[') & defaultFormalParameter.separatedBy(_token(',')) & _token(']');

    optionalFormalParameters =
      optionalPositionalFormalParameters |
      namedFormalParameters
    ;

    formalParameterList =
      _token('(') & _token(')')
      | _token('(') & normalFormalParameters & (_token(',') & optionalFormalParameters).optional() & _token(')')
      | _token('(') & optionalFormalParameters & _token(')')
    ;

    namedFormalParameters = _token('{') & defaultNamedParameter.separatedBy(_token(',')) & _token('}');

    functionSignature = metadata & returnType.optional() & identifier & formalParameterList;
    block = _token('{') & statements & _token('}');

    functionBody =
      _token('=>') & expression & _token(';')
      | block
    ;


    interfaces = IMPLEMENTS & typeList;
    superclass = EXTENDS & type;
    ;

    constantConstructorSignature = CONST & qualified & formalParameterList;
    redirectingFactoryConstructorSignature =
      CONST.optional() & FACTORY & identifier & (_token('.') & identifier).optional() &  formalParameterList & _token('=') & type & (_token('.') & identifier).optional()
    ;
    factoryConstructorSignature =
        FACTORY & identifier & (_token('.') & identifier).optional() & formalParameterList
    ;


    fieldInitializer = (THIS & _token('.')).optional() & identifier & _token('=') & conditionalExpression & cascadeSection.star();
    superCallOrFieldInitializer =
      SUPER & arguments
      | SUPER & _token('.') & identifier & arguments
      | fieldInitializer
    ;

    initializers = _token(':') & superCallOrFieldInitializer.separatedBy(_token(','));
    redirection = _token(':') & THIS & (_token('.') & identifier).optional() & arguments;
    constructorSignature = identifier & (_token('.') & identifier).optional() & formalParameterList;
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
    | _token('[') & _token(']') & _token('=')
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

    staticFinalDeclaration = identifier & _token('=') & expression;
    staticFinalDeclarationList = staticFinalDeclaration.separatedBy(_token(','));

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
      declaration & _token(';')
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
    | char('_')
    ;

    IDENTIFIER_START =
      IDENTIFIER_START_NO_DOLLAR
    | char('\$')
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
    qualified = identifier.separatedBy(_token('.'));

    assignableSelector =
      _token('[') & expression & _token(']')
    | _token('.') & identifier
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
    prefixOperator = _token('-') | unaryOperator;
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

    additiveOperator = _token('+') | _token('-');

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

    conditionalExpression = logicalOrExpression & (_token('?') & expressionWithoutCascade & _token(':') & expressionWithoutCascade).optional();

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
    assignmentOperator = _token('=') | compoundAssignmentOperator;

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
      namedArgument.separatedBy(_token(','))
    | expressionList.separatedBy(_token(','))
    ;
    arguments = _token('(') & argumentList.optional() & _token(')');

    isOperator = IS & _token('!').optional();
    typeTest = isOperator & type;
    typeCast = AS & type;
    argumentDefinitionTest = _token('?') & identifier;

    constObjectExpression = CONST & type & (_token('.') & identifier).optional() & arguments;
    newExpression = NEW & type & (_token('.') & identifier).optional() & arguments;

    thisExpression = THIS;

    functionExpressionBody =
      _token('=>') & expression
    | block
    ;
    functionExpression = formalParameterList & functionExpressionBody;

    throwExpression = THROW & expression;
    throwExpressionWithoutCascade = THROW & expressionWithoutCascade;

    mapLiteralEntry = stringLiteral & _token(':') & expression;
    mapLiteral =
      CONST.optional() &
      typeArguments.optional() &
      _token('{') &
      (mapLiteralEntry & (_token('.') & mapLiteralEntry).star() & _token(',').optional()).optional() &
      _token('}');

    listLiteral =
        CONST.optional() & typeArguments.optional() & _token('[') & (expressionList & _token(',').optional()).optional() & _token(']');

    stringInterpolation = char('\$') & IDENTIFIER_NO_DOLLAR |
        char('\$') & char('{') & expression & char('}');
    NEWLINE = Token.newlineParser();
    stringContentDQ = (char('\\') | char('"') | char('\$') | NEWLINE).neg() |
        char('\\') & NEWLINE.neg() |
        stringInterpolation;
    stringContentSQ = (char('\\') | char("'") | char('\$') | NEWLINE).neg() |
        char('\\') & NEWLINE.neg() |
        stringInterpolation;
    stringContentTDQ = (char('\\') | string('"""') | char('\$') | NEWLINE).not() |
        char('\\') & NEWLINE.not() |
        stringInterpolation;
    stringContentTSQ = (char('\\') | string("'''") | char('\$') | NEWLINE).not() |
        char('\\') & NEWLINE.not() |
        stringInterpolation;

    multilineString =
        string('"""') & stringContentTDQ.star() & string('"""')
      | string("'''") & stringContentTSQ.star() & string("'''")
      | char('r') & string('"""') & string('"""').not().star() & string('"""')
      | char('r') & string("'''") & string("'''").not().star() & string("'''")
    ;

    singleLineString =
          char('"') & stringContentDQ.star() & char('"')
        | char("'") & stringContentSQ.star() & char("'")
        | char('r') & char('"') & (char('"') | NEWLINE).neg().star() & char('"')
        | char('r') & char("'") & (char("'") | NEWLINE).neg().star() & char("'")
        ;


    stringLiteral =
      multilineString.plus()
    | singleLineString.plus()
    ;

    numericLiteral = _token(NUMBER | HEX_NUMBER);

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
    ;



    expressionWithoutCascade =
      assignableExpression & assignmentOperator & expressionWithoutCascade
      | conditionalExpression
      | throwExpressionWithoutCascade
    ;

    expressionList =  expression.separatedBy(_token(','));


    primary =
      thisExpression
      | SUPER & assignableSelector
      | functionExpression
      | literal
      | identifier
      | newExpression
      | constObjectExpression
      | _token('(') & expression & _token(')')
      | argumentDefinitionTest
    ;

  }

  void _statements() {
    assertStatement = ASSERT & _token('(') & conditionalExpression & _token(')') & _token(';');
    continueStatement = CONTINUE & identifier.optional() & _token(';');
    breakStatement = BREAK & identifier.optional() & _token(';');
    label = identifier & _token(':');
    returnStatement = RETURN & expression.optional() & _token(';');

    finallyPart = FINALLY & block;
    catchPart = CATCH & _token('(') & identifier & (_token(',') & identifier).optional() & _token(')');
    onPart =
        catchPart &  block
        | ON & type & catchPart.optional() & block
    ;

    tryStatement = TRY & block & (onPart.plus() & finallyPart.optional() | finallyPart);

    defaultCase = label.star() & DEFAULT & _token(':') & statements;
    switchCase = label.star() & (CASE & expression & _token(':')) & statements;
    switchStatement = SWITCH & _token('(') & expression & _token(')') & _token('{') & switchCase.star() & defaultCase.optional() & _token('}');
    doStatement = DO & statement & WHILE & _token('(') & expression & _token(')') & _token(';');
    whileStatement = WHILE & _token('(') & expression & _token(')') & statement;

    forInitializerStatement =
      localVariableDeclaration & _token(';')
    | expression.optional() & _token(';')
    ;

    forLoopParts =
      forInitializerStatement & expression.optional() & _token(';') & expressionList.optional()
    | declaredIdentifier & IN & expression
    | identifier & IN & expression
    ;

    forStatement = FOR & _token('(') & forLoopParts & _token(')') & statement;
    ifStatement = IF & _token('(') & expression & _token(')') & statement & (ELSE & statement).optional();
    rethrowStatement = RETHROW;
    localFunctionDeclaration = functionSignature & functionBody;
    localVariableDeclaration = initializedVariableDeclaration & _token(';');
    expressionStatement = expression.optional() & _token(';');

    nonLabelledStatement =
          block
          | localVariableDeclaration & _token(';')
          | forStatement
          | whileStatement
          | doStatement
          | switchStatement
          | ifStatement
          | rethrowStatement
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
        | (FINAL | CONST) & type.optional() & staticFinalDeclarationList & _token(';')
        | variableDeclaration & _token(';')
        ;

    identifierList = identifier.separatedBy(_token(',')).optional();
    combinator =
        SHOW & identifierList
        | HIDE & identifierList;


    libraryImport = metadata & IMPORT & (AS & identifier).optional() & combinator.star() & _token(';');
    libraryExport = metadata & EXPORT & uri & combinator.star() & _token(';');
    importOrExport = libraryImport | libraryExport;

    libraryName = metadata & LIBRARY & identifier.separatedBy(_token('.')) & _token(';');

    partDirective = metadata & PART & stringLiteral & _token(';');
    partHeader = metadata & PART & OF & identifier.separatedBy(_token('.')) & _token(';');
    partDeclaration = partHeader & topLevelDefinition.star();

    libraryDefinition = libraryName.optional() & importOrExport.star() & partDirective.star() & topLevelDefinition.star();

    scriptTag = _token('#!') & NEWLINE.not().star() & NEWLINE;
    scriptDefinition = scriptTag.optional() & libraryDefinition;

    start = scriptDefinition.end();
  }

}
