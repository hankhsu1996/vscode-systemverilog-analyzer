parser grammar SystemVerilog2017Parser;
options {
	tokenVocab = SystemVerilog2017Lexer;
}

/*
 * IEEE1800-2017 grammar optimized for performance in the cost of allowing some ivalid syntax. (=
 * const/non-const is not checked, instance variants are same rule and ansi/non-ansi syntax can be
 * mixed) @note Thanks to lexer configuration abilities this grammar can be runtime configured to
 * parse any previous SystemVerilog standard.
 * 
 * This parser grammar is nearly target language independent. You have to replace "_input->LA".
 * (e.g. to "_input.LA" for Java/Python)
 */

/**********************************************************************************************************************/
/* The start rule */
sourceText: ( timeunitsDeclaration)? ( description)* EOF;
description:
	moduleDeclaration
	| udpDeclaration
	| interfaceDeclaration
	| programDeclaration
	| packageDeclaration
	| ( attributeInstance)* ( packageItem | bindDirective)
	| configDeclaration;
/******************************************** token groups ************************************************************/
assignmentOperator:
	ASSIGN
	| PLUS_ASSIGN
	| MINUS_ASSIGN
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| AND_ASSIGN
	| OR_ASSIGN
	| XOR_ASSIGN
	| SHIFT_LEFT_ASSIGN
	| SHIFT_RIGHT_ASSIGN
	| ARITH_SHIFT_LEFT_ASSIGN
	| ARITH_SHIFT_RIGHT_ASSIGN;
edgeIdentifier: KW_POSEDGE | KW_NEGEDGE | KW_EDGE;
identifier:
	C_IDENTIFIER
	| SIMPLE_IDENTIFIER
	| ESCAPED_IDENTIFIER
	| KW_SAMPLE
	| KW_RANDOMIZE
	| KW_TYPE_OPTION
	| KW_OPTION
	| KW_STD;
integerType: integerVectorType | integerAtomType;
integerAtomType:
	KW_BYTE
	| KW_SHORTINT
	| KW_INT
	| KW_LONGINT
	| KW_INTEGER
	| KW_TIME;
integerVectorType: KW_BIT | KW_LOGIC | KW_REG;
nonIntegerType: KW_SHORTREAL | KW_REAL | KW_REALTIME;
netType:
	KW_SUPPLY0
	| KW_SUPPLY1
	| KW_TRI
	| KW_TRIAND
	| KW_TRIOR
	| KW_TRIREG
	| KW_TRI0
	| KW_TRI1
	| KW_UWIRE
	| KW_WIRE
	| KW_WAND
	| KW_WOR;
unaryModulePathOperator:
	NOT
	| NEG
	| AMPERSAND
	| NAND
	| BAR
	| NOR
	| XOR
	| NXOR
	| XORN;
unaryOperator: PLUS | MINUS | unaryModulePathOperator;
incOrDecOperator: INCR | DECR;
implicitClassHandle: KW_THIS ( DOT KW_SUPER)? | KW_SUPER;
integralNumber:
	BASED_NUMBER_WITH_SIZE
	| ( UNSIGNED_NUMBER)? ANY_BASED_NUMBER
	| UNSIGNED_NUMBER;
realNumber: REAL_NUMBER_WITH_EXP | FIXED_POINT_NUMBER;
anySystemTfIdentifier:
	SYSTEM_TF_IDENTIFIER
	| KW_DOLAR_SETUPHOLD
	| KW_DOLAR_SETUP
	| KW_DOLAR_FULLSKEW
	| KW_DOLAR_WARNING
	| KW_DOLAR_WIDTH
	| KW_DOLAR_ROOT
	| KW_DOLAR_RECOVERY
	| KW_DOLAR_SKEW
	| KW_DOLAR_FATAL
	| KW_DOLAR_REMOVAL
	| KW_DOLAR_RECREM
	| KW_DOLAR_ERROR
	| KW_DOLAR_PERIOD
	| KW_DOLAR_HOLD
	| KW_DOLAR_INFO
	| KW_DOLAR_UNIT
	| KW_DOLAR_TIMESKEW
	| KW_DOLAR_NOCHANGE
	| KW_DOLAR_SDF_ANNOTATE
	| KW_DOLAR_DISPLAY
	| KW_DOLAR_DISPLAYB
	| KW_DOLAR_DISPLAYO
	| KW_DOLAR_DISPLAYH
	| KW_DOLAR_WRITE
	| KW_DOLAR_WRITEB
	| KW_DOLAR_WRITEO
	| KW_DOLAR_WRITEH
	| KW_DOLAR_STROBE
	| KW_DOLAR_STROBEB
	| KW_DOLAR_STROBEO
	| KW_DOLAR_STROBEH
	| KW_DOLAR_MONITOR
	| KW_DOLAR_MONITORB
	| KW_DOLAR_MONITORO
	| KW_DOLAR_MONITORH
	| KW_DOLAR_MONITORON
	| KW_DOLAR_MONITOROFF
	| KW_DOLAR_FOPEN
	| KW_DOLAR_FCLOSE
	| KW_DOLAR_FDISPLAY
	| KW_DOLAR_FDISPLAYB
	| KW_DOLAR_FDISPLAYH
	| KW_DOLAR_FDISPLAYO
	| KW_DOLAR_FWRITE
	| KW_DOLAR_FWRITEB
	| KW_DOLAR_FWRITEH
	| KW_DOLAR_FWRITEO
	| KW_DOLAR_FSTROBE
	| KW_DOLAR_FSTROBEB
	| KW_DOLAR_FSTROBEH
	| KW_DOLAR_FSTROBEO
	| KW_DOLAR_FMONITOR
	| KW_DOLAR_FMONITORB
	| KW_DOLAR_FMONITORO
	| KW_DOLAR_FMONITORH
	| KW_DOLAR_SWRITE
	| KW_DOLAR_SWRITEB
	| KW_DOLAR_SWRITEO
	| KW_DOLAR_SWRITEH
	| KW_DOLAR_SFORMAT
	| KW_DOLAR_SFORMATF
	| KW_DOLAR_FGETC
	| KW_DOLAR_UNGETC
	| KW_DOLAR_FGETS
	| KW_DOLAR_FSCANF
	| KW_DOLAR_SSCANF
	| KW_DOLAR_FREAD
	| KW_DOLAR_FTELL
	| KW_DOLAR_FSEEK
	| KW_DOLAR_REWIND
	| KW_DOLAR_FFLUSH
	| KW_DOLAR_FERROR
	| KW_DOLAR_FEOF
	| KW_DOLAR_READMEMB
	| KW_DOLAR_READMEMH
	| KW_DOLAR_WRITEMEMB
	| KW_DOLAR_WRITEMEMH
	| KW_DOLAR_TESTPLUSARGS
	| KW_DOLAR_VALUEPLUSARGS
	| KW_DOLAR_DUMPFILE
	| KW_DOLAR_DUMPVARS
	| KW_DOLAR_DUMPOFF
	| KW_DOLAR_DUMPON
	| KW_DOLAR_DUMPALL
	| KW_DOLAR_DUMPLIMIT
	| KW_DOLAR_DUMPFLUSH
	| KW_DOLAR_DUMPPORTS
	| KW_DOLAR_DUMPPORTSOFF
	| KW_DOLAR_DUMPPORTSON
	| KW_DOLAR_DUMPPORTSALL
	| KW_DOLAR_DUMPPORTSLIMIT
	| KW_DOLAR_DUMPPORTSFLUSH
	| KW_DOLAR_COUNTDRIVERS
	| KW_DOLAR_GETPATTERN
	| KW_DOLAR_INPUT
	| KW_DOLAR_KEY
	| KW_DOLAR_NOKEY
	| KW_DOLAR_LIST
	| KW_DOLAR_LOG
	| KW_DOLAR_NOLOG
	| KW_DOLAR_RESET
	| KW_DOLAR_RESET_COUNT
	| KW_DOLAR_RESET_VALUE
	| KW_DOLAR_SAVE
	| KW_DOLAR_INCSAVE
	| KW_DOLAR_RESTART
	| KW_DOLAR_SCALE
	| KW_DOLAR_SCOPE
	| KW_DOLAR_SHOWSCOPES
	| KW_DOLAR_SHOWVARS
	| KW_DOLAR_SREADMEMB
	| KW_DOLAR_SREADMEMH
	| KW_DOLAR_FINISH
	| KW_DOLAR_STOP
	| KW_DOLAR_EXIT
	| KW_DOLAR_TIME
	| KW_DOLAR_STIME
	| KW_DOLAR_REALTIME
	| KW_DOLAR_PRINTTIMESCALE
	| KW_DOLAR_TIMEFORMAT
	| KW_DOLAR_RTOI
	| KW_DOLAR_ITOR
	| KW_DOLAR_REALTOBITS
	| KW_DOLAR_BITSTOREAL
	| KW_DOLAR_SHORTREALTOBITS
	| KW_DOLAR_BITSTOSHORTREAL
	| KW_DOLAR_SIGNED
	| KW_DOLAR_UNSIGNED
	| KW_DOLAR_CAST
	| KW_DOLAR_TYPENAME
	| KW_DOLAR_BITS
	| KW_DOLAR_ISUNBOUNDED
	| KW_DOLAR_LEFT
	| KW_DOLAR_RIGHT
	| KW_DOLAR_INCREMENT
	| KW_DOLAR_LOW
	| KW_DOLAR_HIGH
	| KW_DOLAR_SIZE
	| KW_DOLAR_DIMENSIONS
	| KW_DOLAR_UNPACKED_DIMENSIONS
	| KW_DOLAR_CLOG2
	| KW_DOLAR_LN
	| KW_DOLAR_LOG10
	| KW_DOLAR_EXP
	| KW_DOLAR_SQRT
	| KW_DOLAR_POW
	| KW_DOLAR_FLOOR
	| KW_DOLAR_CEIL
	| KW_DOLAR_SIN
	| KW_DOLAR_COS
	| KW_DOLAR_TAN
	| KW_DOLAR_ASIN
	| KW_DOLAR_ACOS
	| KW_DOLAR_ATAN
	| KW_DOLAR_ATAN2
	| KW_DOLAR_HYPOT
	| KW_DOLAR_SINH
	| KW_DOLAR_COSH
	| KW_DOLAR_TANH
	| KW_DOLAR_ASINH
	| KW_DOLAR_ACOSH
	| KW_DOLAR_ATANH
	| KW_DOLAR_COUNTBITS
	| KW_DOLAR_COUNTONES
	| KW_DOLAR_ONEHOT
	| KW_DOLAR_ONEHOT0
	| KW_DOLAR_ISUNKNOWN
	| KW_DOLAR_ASSERTCONTROL
	| KW_DOLAR_ASSERTON
	| KW_DOLAR_ASSERTOFF
	| KW_DOLAR_ASSERTKILL
	| KW_DOLAR_ASSERTPASSON
	| KW_DOLAR_ASSERTPASSOFF
	| KW_DOLAR_ASSERTFAILON
	| KW_DOLAR_ASSERTFAILOFF
	| KW_DOLAR_ASSERTNONVACUOUSON
	| KW_DOLAR_ASSERTNONVACUOUSOFF
	| KW_DOLAR_SAMPLED
	| KW_DOLAR_ROSE
	| KW_DOLAR_FELL
	| KW_DOLAR_STABLE
	| KW_DOLAR_CHANGED
	| KW_DOLAR_PAST
	| KW_DOLAR_PAST_GCLK
	| KW_DOLAR_ROSE_GCLK
	| KW_DOLAR_FELL_GCLK
	| KW_DOLAR_STABLE_GCLK
	| KW_DOLAR_CHANGED_GCLK
	| KW_DOLAR_FUTURE_GCLK
	| KW_DOLAR_RISING_GCLK
	| KW_DOLAR_FALLING_GCLK
	| KW_DOLAR_STEADY_GCLK
	| KW_DOLAR_CHANGING_GCLK
	| KW_DOLAR_COVERAGE_CONTROL
	| KW_DOLAR_COVERAGE_GET_MAX
	| KW_DOLAR_COVERAGE_GET
	| KW_DOLAR_COVERAGE_MERGE
	| KW_DOLAR_COVERAGE_SAVE
	| KW_DOLAR_SET_COVERAGE_DB_NAME
	| KW_DOLAR_LOAD_COVERAGE_DB
	| KW_DOLAR_GET_COVERAGE
	| KW_DOLAR_RANDOM
	| KW_DOLAR_URANDOM
	| KW_DOLAR_URANDOM_RANGE
	| KW_DOLAR_DIST_UNIFORM
	| KW_DOLAR_DIST_NORMAL
	| KW_DOLAR_DIST_EXPONENTIAL
	| KW_DOLAR_DIST_POISSON
	| KW_DOLAR_DIST_CHI_SQUARE
	| KW_DOLAR_DIST_T
	| KW_DOLAR_DIST_ERLANG
	| KW_DOLAR_Q_INITIALIZE
	| KW_DOLAR_Q_ADD
	| KW_DOLAR_Q_REMOVE
	| KW_DOLAR_Q_FULL
	| KW_DOLAR_Q_EXAM
	| KW_DOLAR_ASYNCANDARRAY
	| KW_DOLAR_SYNCANDARRAY
	| KW_DOLAR_ASYNCNANDARRAY
	| KW_DOLAR_SYNCNANDARRAY
	| KW_DOLAR_ASYNCORARRAY
	| KW_DOLAR_SYNCORARRAY
	| KW_DOLAR_ASYNCNORARRAY
	| KW_DOLAR_SYNCNORARRAY
	| KW_DOLAR_ASYNCANDPLANE
	| KW_DOLAR_SYNCANDPLANE
	| KW_DOLAR_ASYNCNANDPLANE
	| KW_DOLAR_SYNCNANDPLANE
	| KW_DOLAR_ASYNCORPLANE
	| KW_DOLAR_SYNCORPLANE
	| KW_DOLAR_ASYNCNORPLANE
	| KW_DOLAR_SYNCNORPLANE
	| KW_DOLAR_SYSTEM;
signing: KW_SIGNED | KW_UNSIGNED;
number: integralNumber | realNumber;
timeunitsDeclaration:
	KW_TIMEUNIT TIME_LITERAL (
		( DIV | SEMI KW_TIMEPRECISION) TIME_LITERAL
	)? SEMI
	| KW_TIMEPRECISION TIME_LITERAL SEMI (
		KW_TIMEUNIT TIME_LITERAL SEMI
	)?;
lifetime: KW_STATIC | KW_AUTOMATIC;
portDirection: KW_INPUT | KW_OUTPUT | KW_INOUT | KW_REF;
alwaysKeyword:
	KW_ALWAYS
	| KW_ALWAYS_COMB
	| KW_ALWAYS_LATCH
	| KW_ALWAYS_FF;
joinKeyword: KW_JOIN | KW_JOIN_ANY | KW_JOIN_NONE;
uniquePriority: KW_UNIQUE | KW_UNIQUE0 | KW_PRIORITY;
driveStrength:
	LPAREN (
		KW_HIGHZ0 COMMA strength1
		| KW_HIGHZ1 COMMA strength0
		| strength0 COMMA ( KW_HIGHZ1 | strength1)
		| strength1 COMMA ( KW_HIGHZ0 | strength0)
	) RPAREN;
strength0: KW_SUPPLY0 | KW_STRONG0 | KW_PULL0 | KW_WEAK0;
strength1: KW_SUPPLY1 | KW_STRONG1 | KW_PULL1 | KW_WEAK1;
chargeStrength: LPAREN ( KW_SMALL | KW_MEDIUM | KW_LARGE) RPAREN;

sequenceLvarPortDirection: KW_INPUT | KW_INOUT | KW_OUTPUT;
binsKeyword: KW_BINS | KW_ILLEGAL_BINS | KW_IGNORE_BINS;
classItemQualifier: KW_STATIC | KW_PROTECTED | KW_LOCAL;
randomQualifier: KW_RAND | KW_RANDC;
propertyQualifier: randomQualifier | classItemQualifier;
methodQualifier: ( KW_PURE)? KW_VIRTUAL | classItemQualifier;
constraintPrototypeQualifier: KW_EXTERN | KW_PURE;

cmosSwitchtype: KW_CMOS | KW_RCMOS;
enableGatetype: KW_BUFIF0 | KW_BUFIF1 | KW_NOTIF0 | KW_NOTIF1;
mosSwitchtype: KW_NMOS | KW_PMOS | KW_RNMOS | KW_RPMOS;
nInputGatetype:
	KW_AND
	| KW_NAND
	| KW_OR
	| KW_NOR
	| KW_XOR
	| KW_XNOR;
nOutputGatetype: KW_BUF | KW_NOT;
passEnSwitchtype:
	KW_TRANIF0
	| KW_TRANIF1
	| KW_RTRANIF1
	| KW_RTRANIF0;
passSwitchtype: KW_TRAN | KW_RTRAN;
anyImplication: IMPLIES | IMPLIES_P | IMPLIES_N;
timingCheckEventControl:
	KW_POSEDGE
	| KW_NEGEDGE
	| KW_EDGE
	| EDGE_CONTROL_SPECIFIER;
importExport: KW_IMPORT | KW_EXPORT;
arrayMethodName:
	KW_UNIQUE
	| KW_AND
	| KW_OR
	| KW_XOR
	| identifier;
operatorMulDivMod: MUL | DIV | MOD;
operatorPlusMinus: PLUS | MINUS;
operatorShift:
	SHIFT_LEFT
	| SHIFT_RIGHT
	| ARITH_SHIFT_LEFT
	| ARITH_SHIFT_RIGHT;
operatorCmp: LT | LE | GT | GE;
operatorEqNeq:
	EQ
	| NE
	| CASE_EQ
	| CASE_NE
	| WILDCARD_EQ
	| WILDCARD_NE;
operatorXor: XOR | NXOR | XORN;
operatorImpl: ARROW | BI_DIR_ARROW;
/****************************************** udp ***********************************************************************/
udpNonansiDeclaration:
	(attributeInstance)* KW_PRIMITIVE identifier LPAREN identifierList2plus RPAREN SEMI;
udpAnsiDeclaration:
	(attributeInstance)* KW_PRIMITIVE identifier LPAREN udpDeclarationPortList RPAREN SEMI;
udpDeclaration:
	KW_EXTERN (udpNonansiDeclaration | udpAnsiDeclaration)
	| (
		(
			udpNonansiDeclaration udpPortDeclaration
			| (attributeInstance)* KW_PRIMITIVE identifier LPAREN DOT MUL RPAREN SEMI
		) (udpPortDeclaration)*
		| udpAnsiDeclaration
	) udpBody KW_ENDPRIMITIVE (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
udpDeclarationPortList:
	udpOutputDeclaration (COMMA udpInputDeclaration)+;
udpPortDeclaration:
	(
		udpOutputDeclaration
		| udpInputDeclaration
		| udpRegDeclaration
	) SEMI;
udpOutputDeclaration:
	(attributeInstance)* KW_OUTPUT (
		KW_REG identifier (ASSIGN constantExpression)?
		| identifier
	);
udpInputDeclaration: (attributeInstance)* KW_INPUT identifierList;
udpRegDeclaration: ( attributeInstance)* KW_REG identifier;
udpBody: combinationalBody | sequentialBody;
combinationalBody: KW_TABLE ( combinationalEntry)+ KW_ENDTABLE;
combinationalEntry: levelInputList COLON LEVEL_SYMBOL SEMI;
sequentialBody: (udpInitialStatement)? KW_TABLE (sequentialEntry)+ KW_ENDTABLE;
udpInitialStatement:
	KW_INITIAL identifier ASSIGN integralNumber SEMI;
sequentialEntry:
	seqInputList COLON currentState COLON nextState SEMI;
seqInputList: levelInputList | edgeInputList;
levelInputList: ( LEVEL_SYMBOL)+;
edgeInputList: ( LEVEL_SYMBOL)* edgeIndicator ( LEVEL_SYMBOL)*;
edgeIndicator:
	LPAREN LEVEL_SYMBOL LEVEL_SYMBOL RPAREN
	| EDGE_SYMBOL;
currentState: LEVEL_SYMBOL;
nextState: LEVEL_SYMBOL | MINUS;
/****************************************** interface *****************************************************************/
interfaceDeclaration:
	KW_EXTERN interfaceHeader
	| (
		(
			interfaceHeader
			| (attributeInstance)* KW_INTERFACE identifier LPAREN DOT MUL RPAREN SEMI
		) (timeunitsDeclaration)? (interfaceItem)*
	) KW_ENDINTERFACE (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
interfaceHeader:
	(attributeInstance)* KW_INTERFACE (lifetime)? identifier (
		packageImportDeclaration
	)* (parameterPortList)? (listOfPortDeclarations)? SEMI;
interfaceItem:
	ansiPortDeclaration SEMI
	| generateRegion
	| (attributeInstance)* (
		moduleOrGenerateOrInterfaceItem
		| externTfDeclaration
	)
	| programDeclaration
	| modportDeclaration
	| interfaceDeclaration
	| timeunitsDeclaration;
/***************************************** modport  ****************************************************************/
modportDeclaration:
	KW_MODPORT modportItem (COMMA modportItem)* SEMI;
modportItem:
	identifier LPAREN modportPortsDeclaration (
		COMMA modportPortsDeclaration
	)* RPAREN;
modportPortsDeclaration:
	(attributeInstance)* (
		modportSimplePortsDeclaration
		| modportTfPortsDeclaration
		| modportClockingDeclaration
	);
modportClockingDeclaration: KW_CLOCKING identifier;
modportSimplePortsDeclaration:
	portDirection modportSimplePort (COMMA modportSimplePort)*;
modportSimplePort: listOfArgumentsNamedItem | identifier;
modportTfPortsDeclaration:
	importExport modportTfPort (COMMA modportTfPort)*;
modportTfPort: methodPrototype | identifier;
/***************************************** statements  ****************************************************************/
statementOrNull: statement | ( attributeInstance)* SEMI;
initialConstruct: KW_INITIAL statementOrNull;
defaultClockingOrDissableConstruct:
	KW_DEFAULT (
		KW_CLOCKING identifier
		| KW_DISABLE KW_IFF expressionOrDist
	);
statement: (identifier COLON)? (attributeInstance)* statementItem;
statementItem:
	(
		blockingAssignment
		| nonblockingAssignment
		| proceduralContinuousAssignment
		| incOrDecExpression
		| primary
		| clockingDrive
	) SEMI
	| caseStatement
	| conditionalStatement
	| subroutineCallStatement
	| disableStatement
	| eventTrigger
	| loopStatement
	| jumpStatement
	| parBlock
	| proceduralTimingControlStatement
	| seqBlock
	| waitStatement
	| proceduralAssertionStatement
	| randsequenceStatement
	| randcaseStatement
	| expectPropertyStatement;
cycleDelay:
	DOUBLE_HASH (
		LPAREN expression RPAREN
		| integralNumber
		| identifier
	);
clockingDrive: clockvarExpression LE cycleDelay expression;
clockvarExpression: hierarchicalIdentifier select;
finalConstruct: KW_FINAL statement;
blockingAssignment:
	variableLvalue ASSIGN (
		delayOrEventControl expression
		| dynamicArrayNew
	)
	| packageOrClassScopedHierIdWithSelect ASSIGN classNew
	| operatorAssignment;
proceduralTimingControlStatement:
	proceduralTimingControl statementOrNull;
proceduralTimingControl:
	delayControl
	| eventControl
	| cycleDelay
	| cycleDelayRange;
eventControl:
	AT (
		LPAREN ( MUL | eventExpression) RPAREN
		| MUL
		| packageOrClassScopedHierIdWithSelect
	);
delayOrEventControl:
	delayControl
	| (KW_REPEAT LPAREN expression RPAREN)? eventControl;
delay3:
	HASH (
		LPAREN mintypmaxExpression (
			COMMA mintypmaxExpression (COMMA mintypmaxExpression)?
		)? RPAREN
		| delayValue
	);
delay2:
	HASH (
		LPAREN mintypmaxExpression (COMMA mintypmaxExpression)? RPAREN
		| delayValue
	);
delayValue:
	UNSIGNED_NUMBER
	| TIME_LITERAL
	| KW_1STEP
	| realNumber
	| psIdentifier;
delayControl:
	HASH (LPAREN mintypmaxExpression RPAREN | delayValue);
nonblockingAssignment:
	variableLvalue LE (delayOrEventControl)? expression;
proceduralContinuousAssignment:
	KW_ASSIGN variableAssignment
	| KW_DEASSIGN variableLvalue
	| KW_FORCE variableAssignment
	| KW_RELEASE variableLvalue;
variableAssignment: variableLvalue ASSIGN expression;
actionBlock:
	KW_ELSE statementOrNull
	| statementOrNull (
		KW_ELSE statementOrNull
		| {this._input.LA(1) != SystemVerilog2017Parser.KW_ELSE}?
	);
seqBlock:
	KW_BEGIN (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	) (blockItemDeclaration)* (statementOrNull)* KW_END (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
parBlock:
	KW_FORK (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	) (blockItemDeclaration)* (statementOrNull)* joinKeyword (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
/******************************************** case ********************************************************************/
caseStatement:
	(uniquePriority)? (
		KW_CASE LPAREN expression RPAREN KW_INSIDE (
			caseInsideItem
		)+
		| caseKeyword LPAREN expression RPAREN (
			KW_MATCHES ( casePatternItem)+
			| ( caseItem)+
		)
	) KW_ENDCASE;
caseKeyword: KW_CASE | KW_CASEZ | KW_CASEX;
caseItem:
	(KW_DEFAULT ( COLON)? | expression ( COMMA expression)* COLON) statementOrNull;
casePatternItem:
	(
		KW_DEFAULT ( COLON)?
		| pattern ( TRIPLE_AND expression)? COLON
	) statementOrNull;
caseInsideItem:
	(KW_DEFAULT ( COLON)? | openRangeList COLON) statementOrNull;
randcaseStatement: KW_RANDCASE ( randcaseItem)+ KW_ENDCASE;
randcaseItem: expression COLON statementOrNull;
/************************************************ if-then-else ********************************************************/
condPredicate:
	expression (KW_MATCHES pattern)? (
		TRIPLE_AND expression (KW_MATCHES pattern)?
	)*;
conditionalStatement:
	(uniquePriority)? KW_IF LPAREN condPredicate RPAREN statementOrNull (
		KW_ELSE statementOrNull
		| {this._input.LA(1) != SystemVerilog2017Parser.KW_ELSE}?
	);
subroutineCallStatement:
	(KW_VOID APOSTROPHE LPAREN expression RPAREN) SEMI;
disableStatement:
	KW_DISABLE (KW_FORK | hierarchicalIdentifier) SEMI;
eventTrigger:
	(ARROW | DOUBLE_RIGHT_ARROW ( delayOrEventControl)?) hierarchicalIdentifier SEMI;
/*********************************************** loop statements ******************************************************/
loopStatement:
	(
		KW_FOREVER
		| (
			(KW_REPEAT | KW_WHILE) LPAREN expression
			| KW_FOR LPAREN (forInitialization)? SEMI (
				expression
			)? SEMI (forStep)?
		) RPAREN
	) statementOrNull
	| KW_DO statementOrNull KW_WHILE LPAREN expression RPAREN SEMI
	| KW_FOREACH LPAREN packageOrClassScopedHierIdWithSelect LSQUARE_BR loopVariables RSQUARE_BR
		RPAREN statement;
listOfVariableAssignments:
	variableAssignment (COMMA variableAssignment)*;
forInitialization:
	listOfVariableAssignments
	| forVariableDeclaration (COMMA forVariableDeclaration)*;
forVariableDeclarationVarAssign: identifier ASSIGN expression;
forVariableDeclaration:
	(KW_VAR)? dataType forVariableDeclarationVarAssign (
		COMMA forVariableDeclarationVarAssign
	)*;
forStep: sequenceMatchItem ( COMMA sequenceMatchItem)*;
loopVariables: ( identifier)? ( COMMA ( identifier)?)*;
jumpStatement:
	(KW_RETURN ( expression)? | KW_BREAK | KW_CONTINUE) SEMI;
/**********************************************************************************************************************/
waitStatement:
	KW_WAIT (
		LPAREN expression RPAREN statementOrNull
		| KW_FORK SEMI
	)
	| KW_WAIT_ORDER LPAREN hierarchicalIdentifier (
		COMMA hierarchicalIdentifier
	)* RPAREN actionBlock;
/**********************************************************************************************************************/
nameOfInstance: identifier ( unpackedDimension)*;
checkerInstantiation:
	psIdentifier nameOfInstance LPAREN listOfCheckerPortConnections RPAREN SEMI;
listOfCheckerPortConnections:
	orderedCheckerPortConnection (
		COMMA orderedCheckerPortConnection
	)*
	| namedCheckerPortConnection (
		COMMA namedCheckerPortConnection
	)*;
orderedCheckerPortConnection:
	(attributeInstance)* (propertyActualArg)?;
namedCheckerPortConnection:
	(attributeInstance)* DOT (
		MUL
		| identifier ( LPAREN ( propertyActualArg)? RPAREN)?
	);
proceduralAssertionStatement:
	concurrentAssertionStatement
	| immediateAssertionStatement
	| checkerInstantiation;
concurrentAssertionStatement:
	(KW_ASSERT | KW_ASSUME) KW_PROPERTY LPAREN propertySpec RPAREN actionBlock
	| KW_COVER (
		KW_PROPERTY LPAREN propertySpec
		| KW_SEQUENCE LPAREN (clockingEvent)? (
			KW_DISABLE KW_IFF LPAREN expressionOrDist RPAREN
		)? sequenceExpr
	) RPAREN statementOrNull
	| KW_RESTRICT KW_PROPERTY LPAREN propertySpec RPAREN SEMI;
assertionItem:
	concurrentAssertionItem
	| (identifier COLON)? deferredImmediateAssertionStatement;
concurrentAssertionItem:
	(identifier COLON)? concurrentAssertionStatement
	| checkerInstantiation;
immediateAssertionStatement:
	simpleImmediateAssertionStatement
	| deferredImmediateAssertionStatement;
simpleImmediateAssertionStatement:
	simpleImmediateAssertStatement
	| simpleImmediateAssumeStatement
	| simpleImmediateCoverStatement;
simpleImmediateAssertStatement:
	KW_ASSERT LPAREN expression RPAREN actionBlock;
simpleImmediateAssumeStatement:
	KW_ASSUME LPAREN expression RPAREN actionBlock;
simpleImmediateCoverStatement:
	KW_COVER LPAREN expression RPAREN statementOrNull;
deferredImmediateAssertionStatement:
	deferredImmediateAssertStatement
	| deferredImmediateAssumeStatement
	| deferredImmediateCoverStatement;
primitiveDelay: HASH UNSIGNED_NUMBER;
deferredImmediateAssertStatement:
	KW_ASSERT (KW_FINAL | primitiveDelay) LPAREN expression RPAREN actionBlock;
deferredImmediateAssumeStatement:
	KW_ASSUME (KW_FINAL | primitiveDelay) LPAREN expression RPAREN actionBlock;
deferredImmediateCoverStatement:
	KW_COVER (KW_FINAL | primitiveDelay) LPAREN expression RPAREN statementOrNull;
/**********************************************************************************************************************/
weightSpecification:
	LPAREN expression RPAREN
	| integralNumber
	| psIdentifier;
productionItem: identifier ( LPAREN ( listOfArguments)? RPAREN)?;
rsCodeBlock:
	LBRACE (dataDeclaration)* (statementOrNull)* RBRACE;
randsequenceStatement:
	KW_RANDSEQUENCE LPAREN (identifier)? RPAREN (production)+ KW_ENDSEQUENCE;
rsProd:
	productionItem
	| rsCodeBlock
	| rsIfElse
	| rsRepeat
	| rsCase;
rsIfElse:
	KW_IF LPAREN expression RPAREN productionItem (
		KW_ELSE productionItem
		| {this._input.LA(1) != SystemVerilog2017Parser.KW_ELSE}?
	);
rsRepeat: KW_REPEAT LPAREN expression RPAREN productionItem;
rsCase:
	KW_CASE LPAREN expression RPAREN (rsCaseItem)+ KW_ENDCASE;
rsCaseItem:
	(KW_DEFAULT ( COLON)? | expression ( COMMA expression)* COLON) productionItem SEMI;
rsRule:
	rsProductionList (
		DIST_WEIGHT_ASSIGN weightSpecification (rsCodeBlock)?
	)?;
rsProductionList:
	KW_RAND KW_JOIN (LPAREN expression RPAREN)? productionItem (
		productionItem
	)+
	| ( rsProd)+;
production:
	(dataTypeOrVoid)? identifier (LPAREN tfPortList RPAREN)? COLON rsRule (
		BAR rsRule
	)* SEMI;
tfItemDeclaration: blockItemDeclaration | tfPortDeclaration;
tfPortList: tfPortItem ( COMMA tfPortItem)*;
tfPortItem:
	(attributeInstance)* (tfPortDirection)? (KW_VAR)? (
		dataTypeOrImplicit
	)? (identifier ( variableDimension)* ( ASSIGN expression)?)?;
tfPortDirection: KW_CONST KW_REF | portDirection;
tfPortDeclaration:
	(attributeInstance)* tfPortDirection (KW_VAR)? (
		dataTypeOrImplicit
	)? listOfTfVariableIdentifiers SEMI;
listOfTfVariableIdentifiersItem:
	identifier (variableDimension)* (ASSIGN expression)?;
// listOfVariableIdentifiers with a "= expr"
listOfTfVariableIdentifiers:
	listOfTfVariableIdentifiersItem (
		COMMA listOfTfVariableIdentifiersItem
	)*;
expectPropertyStatement:
	KW_EXPECT LPAREN propertySpec RPAREN actionBlock;
blockItemDeclaration:
	(attributeInstance)* (
		dataDeclaration
		| (localParameterDeclaration | parameterDeclaration) SEMI
		| letDeclaration
	);
paramAssignment:
	identifier (unpackedDimension)* (
		ASSIGN constantParamExpression
	)?;
typeAssignment: identifier ( ASSIGN dataType)?;
listOfTypeAssignments: typeAssignment ( COMMA typeAssignment)*;
listOfParamAssignments:
	paramAssignment (COMMA paramAssignment)*;
localParameterDeclaration:
	KW_LOCALPARAM (
		KW_TYPE listOfTypeAssignments
		| ( dataTypeOrImplicit)? listOfParamAssignments
	);
parameterDeclaration:
	KW_PARAMETER (
		KW_TYPE listOfTypeAssignments
		| ( dataTypeOrImplicit)? listOfParamAssignments
	);
typeDeclaration:
	KW_TYPEDEF (
		dataType identifier ( variableDimension)*
		| (
			KW_ENUM
			| KW_STRUCT
			| KW_UNION
			| identifierWithBitSelect DOT identifier
			| ( KW_INTERFACE)? KW_CLASS
		)? identifier
	) SEMI;
netTypeDeclaration:
	KW_NETTYPE (
		dataType identifier (KW_WITH packageOrClassScopedId)?
	) SEMI;

/**********************************************************************************************************************/
letDeclaration:
	KW_LET identifier (LPAREN ( letPortList)? RPAREN)? ASSIGN expression SEMI;
letPortList: letPortItem ( COMMA letPortItem)*;
letPortItem:
	(attributeInstance)* (letFormalType)? identifier (
		variableDimension
	)* (ASSIGN expression)?;
letFormalType: KW_UNTYPED | dataTypeOrImplicit;
/**********************************************************************************************************************/
packageImportDeclaration:
	KW_IMPORT packageImportItem (COMMA packageImportItem)* SEMI;
packageImportItem: identifier DOUBLE_COLON ( MUL | identifier);

/****************************************** property expr *************************************************************/
propertyListOfArguments:
	(
		DOT identifier LPAREN (propertyActualArg)? RPAREN
		| propertyActualArg ( COMMA ( propertyActualArg)?)*
		| ( COMMA ( propertyActualArg)?)+
	)? (COMMA DOT identifier LPAREN ( propertyActualArg)? RPAREN)*;
propertyActualArg: propertyExpr | sequenceActualArg;
propertyFormalType: KW_PROPERTY | sequenceFormalType;
sequenceFormalType:
	KW_SEQUENCE
	| KW_UNTYPED
	| dataTypeOrImplicit;
propertyInstance:
	packageOrClassScopedId (
		LPAREN propertyListOfArguments RPAREN
	)?;
propertySpec:
	(clockingEvent)? (
		KW_DISABLE KW_IFF LPAREN expressionOrDist RPAREN
	)? propertyExpr;
propertyExpr:
	(KW_STRONG | KW_WEAK)? LPAREN propertyExpr RPAREN
	| KW_IF LPAREN expressionOrDist RPAREN propertyExpr (
		KW_ELSE propertyExpr
		| {this._input.LA(1) != SystemVerilog2017Parser.KW_ELSE}?
	)
	| KW_CASE LPAREN expressionOrDist RPAREN (propertyCaseItem)+ KW_ENDCASE
	| sequenceExpr (
		(
			OVERLAPPING_IMPL
			| NONOVERLAPPING_IMPL
			| HASH_MINUS_HASH
			| HASH_EQ_HASH
		) propertyExpr
	)?
	| (
		KW_NOT
		| (KW_S_ALWAYS | KW_EVENTUALLY) LSQUARE_BR rangeExpression RSQUARE_BR
		| (
			KW_ACCEPT_ON
			| KW_REJECT_ON
			| KW_SYNC_ACCEPT_ON
			| KW_SYNC_REJECT_ON
		) LPAREN expressionOrDist RPAREN
		| (KW_NEXTTIME | KW_S_NEXTTIME) (
			LSQUARE_BR expression RSQUARE_BR
		)?
		| (KW_ALWAYS | KW_S_EVENTUALLY) (
			LSQUARE_BR cycleDelayConstRangeExpression RSQUARE_BR
		)?
		| clockingEvent
	) propertyExpr
	| propertyExpr (
		KW_OR
		| KW_AND
		| KW_UNTIL
		| KW_S_UNTIL
		| KW_UNTIL_WITH
		| KW_S_UNTIL_WITH
		| KW_IMPLIES
		| KW_IFF
	) propertyExpr
	| propertyInstance;
propertyCaseItem:
	(
		KW_DEFAULT ( COLON)?
		| expressionOrDist ( COMMA expressionOrDist)* COLON
	) propertyExpr SEMI;
/****************************************** ids and selects ***********************************************************/
bitSelect: LSQUARE_BR expression RSQUARE_BR;
identifierWithBitSelect: identifier ( bitSelect)*;
// '::' separated then '.' separated
packageOrClassScopedHierIdWithSelect:
	packageOrClassScopedPath (bitSelect)* (
		DOT identifierWithBitSelect
	)* (
		LSQUARE_BR expression (operatorPlusMinus)? COLON expression RSQUARE_BR
	)?;

packageOrClassScopedPathItem:
	identifier (parameterValueAssignment)?;
// '::' separated
packageOrClassScopedPath:
	(KW_LOCAL DOUBLE_COLON)? (
		KW_DOLAR_ROOT
		| implicitClassHandle
		| KW_DOLAR_UNIT
		| packageOrClassScopedPathItem
	) (DOUBLE_COLON packageOrClassScopedPathItem)*;
hierarchicalIdentifier:
	(KW_DOLAR_ROOT DOT)? (identifierWithBitSelect DOT)* identifier;
packageOrClassScopedId:
	(KW_DOLAR_UNIT | packageOrClassScopedPathItem) (
		DOUBLE_COLON packageOrClassScopedPathItem
	)*;
select:
	(DOT identifier | bitSelect)* (
		LSQUARE_BR arrayRangeExpression RSQUARE_BR
	)?;

/************************************************ eventExpression ****************************************************/
eventExpressionItem:
	LPAREN eventExpression RPAREN
	| ( edgeIdentifier)? expression ( KW_IFF expression)?;
eventExpression:
	eventExpressionItem (( KW_OR | COMMA) eventExpressionItem)*;
/************************************************ sequenceExpr *******************************************************/
booleanAbbrev:
	consecutiveRepetition
	| nonConsecutiveRepetition
	| gotoRepetition;
sequenceAbbrev: consecutiveRepetition;
consecutiveRepetition:
	LSQUARE_BR (MUL ( constOrRangeExpression)? | PLUS) RSQUARE_BR;
nonConsecutiveRepetition:
	LSQUARE_BR ASSIGN constOrRangeExpression RSQUARE_BR;
gotoRepetition:
	LSQUARE_BR ARROW constOrRangeExpression RSQUARE_BR;
cycleDelayConstRangeExpression:
	expression COLON (DOLAR | expression);
sequenceInstance:
	packageOrClassScopedPath (
		LPAREN (sequenceListOfArguments)? RPAREN
	)?;
sequenceExpr:
	KW_FIRST_MATCH LPAREN sequenceExpr (COMMA sequenceMatchItem)* RPAREN
	| ( cycleDelayRange sequenceExpr)+
	| expressionOrDist (
		KW_THROUGHOUT sequenceExpr
		| booleanAbbrev
	)?
	| sequenceExpr (
		(KW_AND | KW_INTERSECT | KW_OR | KW_WITHIN) sequenceExpr
		| ( cycleDelayRange sequenceExpr)+
	)
	| (
		LPAREN sequenceExpr (COMMA sequenceMatchItem)* RPAREN
		| sequenceInstance
	) (sequenceAbbrev)?
	| clockingEvent sequenceExpr;
sequenceMatchItem: operatorAssignment | expression;
operatorAssignment:
	variableLvalue assignmentOperator expression;
sequenceActualArg: eventExpression | sequenceExpr;
distWeight: ( DIST_WEIGHT_ASSIGN | COLON DIV) expression;
clockingDeclaration:
	(
		KW_GLOBAL KW_CLOCKING (identifier)? clockingEvent SEMI
		| (KW_DEFAULT)? KW_CLOCKING (identifier)? clockingEvent SEMI (
			clockingItem
		)*
	) KW_ENDCLOCKING (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
clockingItem:
	(
		KW_DEFAULT defaultSkew
		| clockingDirection listOfClockingDeclAssign
	) SEMI
	| (attributeInstance)* (
		propertyDeclaration
		| sequenceDeclaration
		| letDeclaration
	);
listOfClockingDeclAssign:
	clockingDeclAssign (COMMA clockingDeclAssign)*;
clockingDeclAssign: attrSpec;
defaultSkew:
	KW_INPUT clockingSkew (KW_OUTPUT clockingSkew)?
	| KW_OUTPUT clockingSkew;
clockingDirection:
	KW_INPUT (clockingSkew)? (KW_OUTPUT ( clockingSkew)?)?
	| KW_OUTPUT ( clockingSkew)?
	| KW_INOUT;
clockingSkew: edgeIdentifier ( delayControl)? | delayControl;
clockingEvent: AT ( identifier | LPAREN eventExpression RPAREN);
cycleDelayRange:
	DOUBLE_HASH (
		LSQUARE_BR (MUL | PLUS | cycleDelayConstRangeExpression) RSQUARE_BR
		| primary
	);
expressionOrDist:
	expression (KW_DIST LBRACE distItem ( COMMA distItem)* RBRACE)?;

covergroupDeclaration:
	KW_COVERGROUP identifier (LPAREN tfPortList RPAREN)? (
		coverageEvent
	)? SEMI (coverageSpecOrOption)* KW_ENDGROUP (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
coverCross:
	(identifier COLON)? KW_CROSS identifierList2plus (
		KW_IFF LPAREN expression RPAREN
	)? crossBody;
identifierList2plus: identifier ( COMMA identifier)+;
crossBody: LBRACE ( crossBodyItem)* RBRACE | SEMI;
crossBodyItem: functionDeclaration | binsSelectionOrOption SEMI;
binsSelectionOrOption:
	(attributeInstance)* (coverageOption | binsSelection);
binsSelection:
	binsKeyword identifier ASSIGN selectExpression (
		KW_IFF LPAREN expression RPAREN
	)?;
selectExpression:
	LPAREN selectExpression RPAREN
	| ( NOT)? selectCondition
	| selectExpression (AND_LOG | OR_LOG) selectExpression
	| selectExpression KW_WITH LPAREN covergroupExpression RPAREN (
		KW_MATCHES covergroupExpression
	)?
	| covergroupExpression (KW_MATCHES covergroupExpression)?;
selectCondition:
	KW_BINSOF LPAREN binsExpression RPAREN (
		KW_INTERSECT LBRACE covergroupRangeList RBRACE
	)?;
binsExpression: identifier ( DOT identifier)?;
covergroupRangeList:
	covergroupValueRange (COMMA covergroupValueRange)*;
covergroupValueRange:
	LSQUARE_BR covergroupExpression COLON covergroupExpression RSQUARE_BR
	| covergroupExpression;
covergroupExpression: expression;
coverageSpecOrOption:
	(attributeInstance)* (coverageSpec | coverageOption SEMI);
coverageOption:
	KW_OPTION DOT identifier ASSIGN expression
	| KW_TYPE_OPTION DOT identifier ASSIGN constantExpression;
coverageSpec: coverPoint | coverCross;
coverPoint:
	(( dataTypeOrImplicit)? identifier COLON)? KW_COVERPOINT expression (
		KW_IFF LPAREN expression RPAREN
	)? binsOrEmpty;
binsOrEmpty:
	LBRACE (attributeInstance)* (binsOrOptions SEMI)* RBRACE
	| SEMI;
binsOrOptions:
	coverageOption
	| (
		(KW_WILDCARD)? binsKeyword identifier (
			(LSQUARE_BR ( covergroupExpression)? RSQUARE_BR)? ASSIGN (
				LBRACE covergroupRangeList RBRACE (
					KW_WITH LPAREN covergroupExpression RPAREN
				)?
				| identifier KW_WITH LPAREN covergroupExpression RPAREN
				| covergroupExpression
			)
			| ( LSQUARE_BR RSQUARE_BR)? ASSIGN transList
		)
		| binsKeyword identifier (
			ASSIGN KW_DEFAULT KW_SEQUENCE
			| (LSQUARE_BR ( covergroupExpression)? RSQUARE_BR)? ASSIGN KW_DEFAULT
		)
	) (KW_IFF LPAREN expression RPAREN)?;
transList:
	LPAREN transSet RPAREN (COMMA LPAREN transSet RPAREN)*;
transSet: transRangeList ( IMPLIES transRangeList)*;
transRangeList:
	covergroupRangeList (
		LSQUARE_BR (MUL | ARROW | ASSIGN) repeatRange RSQUARE_BR
	)?;
repeatRange: covergroupExpression ( COLON covergroupExpression)?;
coverageEvent:
	(
		KW_WITH KW_FUNCTION KW_SAMPLE LPAREN tfPortList
		| DOUBLE_AT LPAREN blockEventExpression
	) RPAREN
	| clockingEvent;
blockEventExpression:
	(KW_BEGIN | KW_END) hierarchicalBtfIdentifier
	| blockEventExpression KW_OR blockEventExpression;
hierarchicalBtfIdentifier:
	hierarchicalIdentifier
	| (hierarchicalIdentifier DOT | classScope)? identifier;
assertionVariableDeclaration: (varDataType)? listOfVariableDeclAssignments SEMI;
distItem: valueRange ( distWeight)?;
valueRange: LSQUARE_BR rangeExpression RSQUARE_BR | expression;
/************************************************ attributeInstance **************************************************/
attributeInstance:
	LPAREN MUL attrSpec (COMMA attrSpec)* MUL RPAREN;
attrSpec: identifier ( ASSIGN expression)?;
/************************************************ type defs and dataType *********************************************/
classNew:
	KW_NEW expression
	| (classScope)? KW_NEW (LPAREN ( listOfArguments)? RPAREN)?;
paramExpression: mintypmaxExpression | dataType;
constantParamExpression: paramExpression;

unpackedDimension: LSQUARE_BR rangeExpression RSQUARE_BR;
packedDimension: LSQUARE_BR ( rangeExpression)? RSQUARE_BR;
variableDimension:
	LSQUARE_BR (MUL | dataType | arrayRangeExpression)? RSQUARE_BR;
structUnion: KW_STRUCT | KW_UNION ( KW_TAGGED)?;
enumBaseType:
	integerAtomType (signing)?
	| (integerVectorType ( signing)? | packageOrClassScopedId) (
		variableDimension
	)?
	| packedDimension;
dataTypePrimitive: integerType ( signing)? | nonIntegerType;
dataType:
	KW_STRING
	| KW_CHANDLE
	| KW_VIRTUAL (KW_INTERFACE)? identifier (
		parameterValueAssignment
	)? (DOT identifier)?
	| KW_EVENT
	| (
		dataTypePrimitive
		| KW_ENUM (enumBaseType)? enumBody
		| structUnion (KW_PACKED ( signing)?)? structUnionBody
		| packageOrClassScopedPath
	) (variableDimension)*
	| typeReference;
enumBody:
	LBRACE enumNameDeclaration (COMMA enumNameDeclaration)* RBRACE;
structUnionBody: LBRACE ( structUnionMember)+ RBRACE;
dataTypeOrImplicit: dataType | implicitDataType;
implicitDataType:
	signing (packedDimension)*
	| ( packedDimension)+;
/************************************************ listOfArguments ***************************************************/
// first normal arguments and then named arguments, while keeping the list not eps
sequenceListOfArgumentsNamedItem:
	DOT identifier LPAREN (sequenceActualArg)? RPAREN;
sequenceListOfArguments:
	(
		sequenceListOfArgumentsNamedItem
		| COMMA sequenceListOfArgumentsNamedItem
		| sequenceActualArg ( COMMA ( sequenceActualArg)?)*
		| ( COMMA ( sequenceActualArg)?)+
	) (COMMA sequenceListOfArgumentsNamedItem)*;
listOfArgumentsNamedItem:
	DOT identifier LPAREN (expression)? RPAREN;
listOfArguments:
	(
		listOfArgumentsNamedItem
		| COMMA listOfArgumentsNamedItem
		| expression ( COMMA ( expression)?)*
		| ( COMMA ( expression)?)+
	) (COMMA listOfArgumentsNamedItem)*;
/************************************************ primary *************************************************************/
primaryLiteral:
	TIME_LITERAL
	| UNBASED_UNSIZED_LITERAL
	| STRING_LITERAL
	| number
	| KW_NULL
	| KW_THIS
	| DOLAR;
typeReference: KW_TYPE LPAREN ( expression | dataType) RPAREN;
packageScope: ( KW_DOLAR_UNIT | identifier) DOUBLE_COLON;
psIdentifier: ( packageScope)? identifier;
listOfParameterValueAssignments:
	paramExpression (COMMA paramExpression)*
	| namedParameterAssignment (COMMA namedParameterAssignment)*;
parameterValueAssignment:
	HASH LPAREN (listOfParameterValueAssignments)? RPAREN;
classType:
	psIdentifier (parameterValueAssignment)? (
		DOUBLE_COLON identifier (parameterValueAssignment)?
	)*;
classScope: classType DOUBLE_COLON;
rangeExpression: expression ( COLON expression)?;
constantRangeExpression: rangeExpression;
constantMintypmaxExpression: mintypmaxExpression;
mintypmaxExpression:
	expression (COLON expression COLON expression)?;
namedParameterAssignment:
	DOT identifier LPAREN (paramExpression)? RPAREN;
// original primary+constantPrimary letExpression was remobed because it was same as call
primary:
	primaryLiteral						# PrimaryLit
	| packageOrClassScopedPath			# PrimaryPath
	| LPAREN mintypmaxExpression RPAREN	# PrimaryPar
	| (
		KW_STRING
		| KW_CONST
		| integerType
		| nonIntegerType
		| signing
	) APOSTROPHE LPAREN expression RPAREN					# PrimaryCast
	| primary APOSTROPHE LPAREN expression RPAREN			# PrimaryCast2
	| primary bitSelect										# PrimaryBitSelect
	| primary DOT identifier								# PrimaryDot
	| primary LSQUARE_BR arrayRangeExpression RSQUARE_BR	# PrimaryIndex
	| concatenation											# PrimaryConcat
	| streamingConcatenation								# PrimaryStreamingConcatenation
	| anySystemTfIdentifier (
		LPAREN dataType (COMMA listOfArguments)? (
			COMMA clockingEvent
		)? RPAREN
		| LPAREN listOfArguments (COMMA clockingEvent)? RPAREN
	)?										# PrimaryTfCall
	| (KW_STD DOUBLE_COLON)? randomizeCall	# PrimaryRandomize
	| primary DOT randomizeCall				# PrimaryRandomize2
	| assignmentPatternExpression			# PrimaryAssig
	| typeReference							# PrimaryTypeRef
	| primary (DOT arrayMethodName)? (attributeInstance)* LPAREN (
		listOfArguments
	)? RPAREN (KW_WITH LPAREN expression RPAREN)?											# PrimaryCall
	| primary DOT arrayMethodName															# PrimaryCallArrayMethodNoArgs
	| primary (DOT arrayMethodName)? (attributeInstance)* KW_WITH LPAREN expression RPAREN	#
		PrimaryCallWith;
/************************************************** expression ********************************************************/
constantExpression: expression;
incOrDecExpression:
	incOrDecOperator (attributeInstance)* variableLvalue	# IncOrDecExpressionPre
	| variableLvalue (attributeInstance)* incOrDecOperator	# IncOrDecExpressionPost;
expression:
	primary
	| LPAREN operatorAssignment RPAREN
	| KW_TAGGED identifier ( expression)?
	| unaryOperator ( attributeInstance)* primary
	| incOrDecExpression
	| expression DOUBLESTAR (attributeInstance)* expression
	| expression operatorMulDivMod (attributeInstance)* expression
	| expression operatorPlusMinus (attributeInstance)* expression
	| expression operatorShift (attributeInstance)* expression
	| expression operatorCmp (attributeInstance)* expression
	| expression KW_INSIDE LBRACE openRangeList RBRACE
	| expression operatorEqNeq (attributeInstance)* expression
	| expression AMPERSAND (attributeInstance)* expression
	| expression operatorXor (attributeInstance)* expression
	| expression BAR ( attributeInstance)* expression
	| expression AND_LOG ( attributeInstance)* expression
	| expression OR_LOG ( attributeInstance)* expression
	| expression (KW_MATCHES pattern)? TRIPLE_AND expression (
		KW_MATCHES pattern
	)?
	| <assoc = right> expression (KW_MATCHES pattern)? QUESTIONMARK (
		attributeInstance
	)* expression COLON expression
	| <assoc = right> expression operatorImpl (attributeInstance)* expression;

concatenation:
	LBRACE (expression ( concatenation | ( COMMA expression)+)?)? RBRACE;
dynamicArrayNew:
	KW_NEW LSQUARE_BR expression RSQUARE_BR (
		LPAREN expression RPAREN
	)?;
constOrRangeExpression:
	expression (COLON ( DOLAR | expression))?;
variableDeclAssignment:
	identifier (
		ASSIGN ( expression | classNew)
		| (variableDimension)+ (
			ASSIGN ( expression | dynamicArrayNew)
		)?
	)?;
/* assignmentPatternNetLvalue */
assignmentPatternVariableLvalue:
	APOSTROPHE_LBRACE variableLvalue (COMMA variableLvalue)* RBRACE;
streamOperator: SHIFT_RIGHT | SHIFT_LEFT;
sliceSize:
	integerType
	| nonIntegerType
	| packageOrClassScopedPath
	| expression;
streamingConcatenation:
	LBRACE streamOperator (sliceSize)? streamConcatenation RBRACE;
streamConcatenation:
	LBRACE streamExpression (COMMA streamExpression)* RBRACE;
streamExpression:
	expression (
		KW_WITH LSQUARE_BR arrayRangeExpression RSQUARE_BR
	)?;
arrayRangeExpression:
	expression (( operatorPlusMinus)? COLON expression)?;
openRangeList: valueRange ( COMMA valueRange)*;
pattern:
	DOT (MUL | identifier)
	| KW_TAGGED identifier ( pattern)?
	| APOSTROPHE_LBRACE (
		pattern ( COMMA pattern)*
		| identifier COLON pattern (
			COMMA identifier COLON pattern
		)*
	) RBRACE
	| expression;
assignmentPattern:
	APOSTROPHE_LBRACE (
		expression ( COMMA expression)*
		| structurePatternKey COLON expression (
			COMMA structurePatternKey COLON expression
		)*
		| arrayPatternKey COLON expression (
			COMMA arrayPatternKey COLON expression
		)*
		| constantExpression LBRACE expression (COMMA expression)* RBRACE
	)? RBRACE;
structurePatternKey: identifier | assignmentPatternKey;
arrayPatternKey: constantExpression | assignmentPatternKey;
assignmentPatternKey:
	KW_DEFAULT
	| integerType
	| nonIntegerType
	| packageOrClassScopedPath;
structUnionMember:
	(attributeInstance)* (randomQualifier)? dataTypeOrVoid listOfVariableDeclAssignments SEMI;
dataTypeOrVoid: KW_VOID | dataType;
enumNameDeclaration:
	identifier (
		LSQUARE_BR integralNumber (COLON integralNumber)? RSQUARE_BR
	)? (ASSIGN expression)?;
assignmentPatternExpression:
	(assignmentPatternExpressionType)? assignmentPattern;
assignmentPatternExpressionType:
	packageOrClassScopedPath
	| integerAtomType
	| typeReference;
netLvalue: variableLvalue;
variableLvalue:
	LBRACE variableLvalue (COMMA variableLvalue)* RBRACE
	| packageOrClassScopedHierIdWithSelect
	| (assignmentPatternExpressionType)? assignmentPatternVariableLvalue
	| streamingConcatenation;
solveBeforeList: primary ( COMMA primary)*;
constraintBlockItem:
	KW_SOLVE solveBeforeList KW_BEFORE solveBeforeList SEMI
	| constraintExpression;
constraintExpression:
	KW_IF LPAREN expression RPAREN constraintSet (
		KW_ELSE constraintSet
		| {this._input.LA(1) != SystemVerilog2017Parser.KW_ELSE}?
	)
	| (
		KW_DISABLE KW_SOFT primary
		| ( KW_SOFT)? expressionOrDist
		| uniquenessConstraint
	) SEMI
	| (
		KW_FOREACH LPAREN primary LSQUARE_BR loopVariables RSQUARE_BR RPAREN
		| expression ARROW
	) constraintSet;
uniquenessConstraint: KW_UNIQUE LBRACE openRangeList RBRACE;
constraintSet:
	LBRACE (constraintExpression)* RBRACE
	| constraintExpression;
randomizeCall:
	KW_RANDOMIZE (attributeInstance)* (
		LPAREN ( KW_NULL | listOfArguments)? RPAREN
	)? (
		KW_WITH (LPAREN ( listOfArguments)? RPAREN)? LBRACE (
			constraintBlockItem
		)* RBRACE
	)?;
/**************************************** module *********************************************************************/
moduleHeaderCommon:
	(attributeInstance)* moduleKeyword (lifetime)? identifier (
		packageImportDeclaration
	)* (parameterPortList)?;
moduleDeclaration:
	KW_EXTERN moduleHeaderCommon (listOfPortDeclarations)? SEMI
	| moduleHeaderCommon (
		listOfPortDeclarations
		| (LPAREN DOT MUL RPAREN)
	)? SEMI moduleDeclarationBody KW_ENDMODULE (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
moduleDeclarationBody: ( timeunitsDeclaration)? ( moduleItem)*;
moduleKeyword: KW_MODULE | KW_MACROMODULE;
/************************************* package ************************************************************************/
netPortType:
	KW_INTERCONNECT (implicitDataType)?
	| netType ( dataTypeOrImplicit)?
	| dataTypeOrImplicit;
varDataType: KW_VAR ( dataTypeOrImplicit)? | dataType;
netOrVarDataType:
	KW_INTERCONNECT (implicitDataType)?
	| KW_VAR ( dataTypeOrImplicit)?
	| netType ( dataTypeOrImplicit)?
	| dataTypeOrImplicit;
listOfDefparamAssignments:
	defparamAssignment (COMMA defparamAssignment)*;
listOfNetDeclAssignments:
	netDeclAssignment (COMMA netDeclAssignment)*;
listOfSpecparamAssignments:
	specparamAssignment (COMMA specparamAssignment)*;
listOfVariableDeclAssignments:
	variableDeclAssignment (COMMA variableDeclAssignment)*;
listOfVariableIdentifiersItem: identifier ( variableDimension)*;
/* listOfPortIdentifiers */
listOfVariableIdentifiers:
	listOfVariableIdentifiersItem (
		COMMA listOfVariableIdentifiersItem
	)*;
listOfVariablePortIdentifiers: listOfTfVariableIdentifiers;
defparamAssignment:
	hierarchicalIdentifier ASSIGN mintypmaxExpression;
netDeclAssignment:
	identifier (unpackedDimension)* (ASSIGN expression)?;
specparamAssignment:
	identifier ASSIGN mintypmaxExpression
	| pulseControlSpecparam;
errorLimitValue: mintypmaxExpression;
rejectLimitValue: mintypmaxExpression;
pulseControlSpecparam:
	KW_PATHPULSE_DOLAR (
		specifyInputTerminalDescriptor DOLAR specifyOutputTerminalDescriptor
	)? ASSIGN LPAREN rejectLimitValue (COMMA errorLimitValue)? RPAREN;
identifierDotedIndexAtEnd:
	identifier (DOT identifier)? (
		LSQUARE_BR rangeExpression RSQUARE_BR
	)*;
specifyTerminalDescriptor: identifierDotedIndexAtEnd;
specifyInputTerminalDescriptor: identifierDotedIndexAtEnd;
specifyOutputTerminalDescriptor: identifierDotedIndexAtEnd;
specifyItem:
	specparamDeclaration
	| pulsestyleDeclaration
	| showcancelledDeclaration
	| pathDeclaration
	| systemTimingCheck;
pulsestyleDeclaration:
	(KW_PULSESTYLE_ONEVENT | KW_PULSESTYLE_ONDETECT) listOfPathOutputs SEMI;
showcancelledDeclaration:
	(KW_SHOWCANCELLED | KW_NOSHOWCANCELLED) listOfPathOutputs SEMI;
pathDeclaration:
	(
		simplePathDeclaration
		| edgeSensitivePathDeclaration
		| stateDependentPathDeclaration
	) SEMI;
simplePathDeclaration:
	(parallelPathDescription | fullPathDescription) ASSIGN pathDelayValue;
pathDelayValue:
	LPAREN listOfPathDelayExpressions RPAREN
	| listOfPathDelayExpressions;
listOfPathOutputs: listOfPaths;
listOfPathInputs: listOfPaths;
listOfPaths:
	identifierDotedIndexAtEnd (COMMA identifierDotedIndexAtEnd)*;
listOfPathDelayExpressions:
	tPathDelayExpression
	| trisePathDelayExpression COMMA tfallPathDelayExpression (
		COMMA tzPathDelayExpression
	)?
	| t01PathDelayExpression COMMA t10PathDelayExpression COMMA t0zPathDelayExpression COMMA
		tz1PathDelayExpression COMMA t1zPathDelayExpression COMMA tz0PathDelayExpression (
		COMMA t0xPathDelayExpression COMMA tx1PathDelayExpression COMMA t1xPathDelayExpression COMMA
			tx0PathDelayExpression COMMA txzPathDelayExpression COMMA tzxPathDelayExpression
	)?;
tPathDelayExpression: constantMintypmaxExpression;
trisePathDelayExpression: constantMintypmaxExpression;
tfallPathDelayExpression: constantMintypmaxExpression;
tzPathDelayExpression: constantMintypmaxExpression;
t01PathDelayExpression: constantMintypmaxExpression;
t10PathDelayExpression: constantMintypmaxExpression;
t0zPathDelayExpression: constantMintypmaxExpression;
tz1PathDelayExpression: constantMintypmaxExpression;
t1zPathDelayExpression: constantMintypmaxExpression;
tz0PathDelayExpression: constantMintypmaxExpression;
t0xPathDelayExpression: constantMintypmaxExpression;
tx1PathDelayExpression: constantMintypmaxExpression;
t1xPathDelayExpression: constantMintypmaxExpression;
tx0PathDelayExpression: constantMintypmaxExpression;
txzPathDelayExpression: constantMintypmaxExpression;
tzxPathDelayExpression: constantMintypmaxExpression;
parallelPathDescription:
	LPAREN specifyInputTerminalDescriptor anyImplication specifyOutputTerminalDescriptor RPAREN;
fullPathDescription:
	LPAREN listOfPathInputs (operatorPlusMinus)? PATH_FULL listOfPathOutputs RPAREN;
identifierList: identifier ( COMMA identifier)*;
specparamDeclaration:
	KW_SPECPARAM (packedDimension)? listOfSpecparamAssignments SEMI;
edgeSensitivePathDeclaration:
	(
		parallelEdgeSensitivePathDescription
		| fullEdgeSensitivePathDescription
	) ASSIGN pathDelayValue;
parallelEdgeSensitivePathDescription:
	LPAREN (edgeIdentifier)? specifyInputTerminalDescriptor anyImplication LPAREN
		specifyOutputTerminalDescriptor (operatorPlusMinus)? COLON dataSourceExpression RPAREN
		RPAREN;
fullEdgeSensitivePathDescription:
	LPAREN (edgeIdentifier)? listOfPathInputs (operatorPlusMinus)? PATH_FULL LPAREN
		listOfPathOutputs (operatorPlusMinus)? COLON dataSourceExpression RPAREN RPAREN;
dataSourceExpression: expression;
dataDeclaration:
	(KW_CONST)? (
		KW_VAR ( lifetime)? ( dataTypeOrImplicit)?
		| ( lifetime)? dataTypeOrImplicit
	) listOfVariableDeclAssignments SEMI
	| typeDeclaration
	| packageImportDeclaration
	| netTypeDeclaration;

modulePathExpression: expression;
stateDependentPathDeclaration:
	KW_IF LPAREN modulePathExpression RPAREN (
		simplePathDeclaration
		| edgeSensitivePathDeclaration
	)
	| KW_IFNONE simplePathDeclaration;
packageExportDeclaration:
	KW_EXPORT (
		MUL DOUBLE_COLON MUL
		| packageImportItem ( COMMA packageImportItem)*
	) SEMI;
genvarDeclaration: KW_GENVAR identifierList SEMI;
netDeclaration:
	(
		KW_INTERCONNECT (implicitDataType)? (HASH delayValue)? identifier (
			unpackedDimension
		)* (COMMA identifier ( unpackedDimension)*)?
		| (
			netType (driveStrength | chargeStrength)? (
				KW_VECTORED
				| KW_SCALARED
			)? (dataTypeOrImplicit)? (delay3)?
			| identifier ( delayControl)?
		) listOfNetDeclAssignments
	) SEMI;

parameterPortList:
	HASH LPAREN (
		(listOfParamAssignments | parameterPortDeclaration) (
			COMMA parameterPortDeclaration
		)*
	)? RPAREN;
parameterPortDeclaration:
	KW_TYPE listOfTypeAssignments
	| parameterDeclaration
	| localParameterDeclaration
	| dataType listOfParamAssignments;

listOfPortDeclarationsAnsiItem:
	(attributeInstance)* ansiPortDeclaration;
listOfPortDeclarations:
	LPAREN (
		( nonansiPort ( COMMA ( nonansiPort)?)*)
		| ( COMMA ( nonansiPort)?)+
		| (
			listOfPortDeclarationsAnsiItem (
				COMMA listOfPortDeclarationsAnsiItem
			)*
		)
	)? RPAREN;

nonansiPortDeclaration:
	(attributeInstance)* (
		KW_INOUT (netPortType)? listOfVariableIdentifiers
		| KW_INPUT (netOrVarDataType)? listOfVariableIdentifiers
		| KW_OUTPUT (netOrVarDataType)? listOfVariablePortIdentifiers
		| identifier (DOT identifier)? listOfVariableIdentifiers // identifier=interfaceIdentifier
		| KW_REF ( varDataType)? listOfVariableIdentifiers
	);

nonansiPort:
	nonansiPortExpr
	| DOT identifier LPAREN ( nonansiPortExpr)? RPAREN;
nonansiPortExpr:
	identifierDotedIndexAtEnd
	| LBRACE identifierDotedIndexAtEnd (
		COMMA identifierDotedIndexAtEnd
	)* RBRACE;
portIdentifier: identifier;
ansiPortDeclaration:
	(
		portDirection (netOrVarDataType)? // netPortHeader
		| netOrVarDataType // netPortHeader or variablePortHeader
		| (identifier | KW_INTERFACE) (DOT identifier)? // interfacePortHeader
	)? portIdentifier (variableDimension)* (
		ASSIGN constantExpression
	)?
	| (portDirection)? DOT portIdentifier LPAREN (expression)? RPAREN;

/**********************************************************************************************************************/
systemTimingCheck:
	dolarSetupTimingCheck
	| dolarHoldTimingCheck
	| dolarSetupholdTimingCheck
	| dolarRecoveryTimingCheck
	| dolarRemovalTimingCheck
	| dolarRecremTimingCheck
	| dolarSkewTimingCheck
	| dolarTimeskewTimingCheck
	| dolarFullskewTimingCheck
	| dolarPeriodTimingCheck
	| dolarWidthTimingCheck
	| dolarNochangeTimingCheck;
dolarSetupTimingCheck:
	KW_DOLAR_SETUP LPAREN timingCheckEvent COMMA timingCheckEvent COMMA timingCheckLimit (
		COMMA ( notifier)?
	)? RPAREN SEMI;
dolarHoldTimingCheck:
	KW_DOLAR_HOLD LPAREN timingCheckEvent COMMA timingCheckEvent COMMA timingCheckLimit (
		COMMA ( notifier)?
	)? RPAREN SEMI;
dolarSetupholdTimingCheck:
	KW_DOLAR_SETUPHOLD LPAREN timingCheckEvent COMMA timingCheckEvent COMMA timingCheckLimit COMMA
		timingCheckLimit (
		COMMA (notifier)? (
			COMMA (timestampCondition)? (
				COMMA (timecheckCondition)? (
					COMMA (delayedReference)? (
						COMMA ( delayedReference)?
					)?
				)?
			)?
		)?
	)? RPAREN SEMI;
dolarRecoveryTimingCheck:
	KW_DOLAR_RECOVERY LPAREN timingCheckEvent COMMA timingCheckEvent COMMA timingCheckLimit (
		COMMA ( notifier)?
	)? RPAREN SEMI;
dolarRemovalTimingCheck:
	KW_DOLAR_REMOVAL LPAREN timingCheckEvent COMMA timingCheckEvent COMMA timingCheckLimit (
		COMMA ( notifier)?
	)? RPAREN SEMI;
dolarRecremTimingCheck:
	KW_DOLAR_RECREM LPAREN timingCheckEvent COMMA timingCheckEvent COMMA timingCheckLimit COMMA
		timingCheckLimit (
		COMMA (notifier)? (
			COMMA (timestampCondition)? (
				COMMA (timecheckCondition)? (
					COMMA (delayedReference)? (
						COMMA ( delayedReference)?
					)?
				)?
			)?
		)?
	)? RPAREN SEMI;
dolarSkewTimingCheck:
	KW_DOLAR_SKEW LPAREN timingCheckEvent COMMA timingCheckEvent COMMA timingCheckLimit (
		COMMA ( notifier)?
	)? RPAREN SEMI;
dolarTimeskewTimingCheck:
	KW_DOLAR_TIMESKEW LPAREN timingCheckEvent COMMA timingCheckEvent COMMA timingCheckLimit (
		COMMA (notifier)? (
			COMMA (eventBasedFlag)? (COMMA ( remainActiveFlag)?)?
		)?
	)? RPAREN SEMI;
dolarFullskewTimingCheck:
	KW_DOLAR_FULLSKEW LPAREN timingCheckEvent COMMA timingCheckEvent COMMA timingCheckLimit COMMA
		timingCheckLimit (
		COMMA (notifier)? (
			COMMA (eventBasedFlag)? (COMMA ( remainActiveFlag)?)?
		)?
	)? RPAREN SEMI;
dolarPeriodTimingCheck:
	KW_DOLAR_PERIOD LPAREN controlledReferenceEvent COMMA timingCheckLimit (
		COMMA ( notifier)?
	)? RPAREN SEMI;
dolarWidthTimingCheck:
	KW_DOLAR_WIDTH LPAREN controlledReferenceEvent COMMA timingCheckLimit COMMA threshold (
		COMMA ( notifier)?
	)? RPAREN SEMI;
dolarNochangeTimingCheck:
	KW_DOLAR_NOCHANGE LPAREN timingCheckEvent COMMA timingCheckEvent COMMA startEdgeOffset COMMA
		endEdgeOffset (COMMA ( notifier)?)? RPAREN SEMI;
timecheckCondition: mintypmaxExpression;
controlledReferenceEvent: controlledTimingCheckEvent;
delayedReference:
	identifier (
		LSQUARE_BR constantMintypmaxExpression RSQUARE_BR
	)?;
endEdgeOffset: mintypmaxExpression;
eventBasedFlag: constantExpression;
notifier: identifier;
remainActiveFlag: constantMintypmaxExpression;
timestampCondition: mintypmaxExpression;
startEdgeOffset: mintypmaxExpression;
threshold: constantExpression;
timingCheckLimit: expression;
timingCheckEvent:
	(timingCheckEventControl)? specifyTerminalDescriptor (
		TRIPLE_AND timingCheckCondition
	)?;
timingCheckCondition:
	LPAREN scalarTimingCheckCondition RPAREN
	| scalarTimingCheckCondition;
scalarTimingCheckCondition: expression;
controlledTimingCheckEvent:
	timingCheckEventControl specifyTerminalDescriptor (
		TRIPLE_AND timingCheckCondition
	)?;
/**********************************************************************************************************************/
functionDataTypeOrImplicit: dataTypeOrVoid | implicitDataType;
externTfDeclaration:
	KW_EXTERN (KW_FORKJOIN taskPrototype | methodPrototype) SEMI;
functionDeclaration:
	KW_FUNCTION (lifetime)? (functionDataTypeOrImplicit)? taskAndFunctionDeclarationCommon
		KW_ENDFUNCTION (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
taskPrototype: KW_TASK identifier ( LPAREN tfPortList RPAREN)?;
functionPrototype:
	KW_FUNCTION dataTypeOrVoid identifier (
		LPAREN tfPortList RPAREN
	)?;
dpiImportExport:
	(
		KW_IMPORT STRING_LITERAL (
			(dpiFunctionImportProperty)? (
				(C_IDENTIFIER | ESCAPED_IDENTIFIER) ASSIGN
			)? functionPrototype
			| (dpiTaskImportProperty)? (
				(C_IDENTIFIER | ESCAPED_IDENTIFIER) ASSIGN
			)? taskPrototype
		)
		| KW_EXPORT STRING_LITERAL (
			(C_IDENTIFIER | ESCAPED_IDENTIFIER) ASSIGN
		)? (KW_FUNCTION | KW_TASK) identifier
	) SEMI;
dpiFunctionImportProperty: KW_CONTEXT | KW_PURE;
dpiTaskImportProperty: KW_CONTEXT;
taskAndFunctionDeclarationCommon:
	(identifier DOT | classScope)? identifier (
		SEMI ( tfItemDeclaration)*
		| LPAREN tfPortList RPAREN SEMI (blockItemDeclaration)*
	) (statementOrNull)*;
taskDeclaration:
	KW_TASK (lifetime)? taskAndFunctionDeclarationCommon KW_ENDTASK (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
methodPrototype: taskPrototype | functionPrototype;
externConstraintDeclaration:
	(KW_STATIC)? KW_CONSTRAINT classScope identifier constraintBlock;
constraintBlock: LBRACE ( constraintBlockItem)* RBRACE;
checkerPortList: checkerPortItem ( COMMA checkerPortItem)*;
checkerPortItem:
	(attributeInstance)* (checkerPortDirection)? (
		propertyFormalType
	)? identifier (variableDimension)* (ASSIGN propertyActualArg)?;
checkerPortDirection: KW_INPUT | KW_OUTPUT;
checkerDeclaration:
	KW_CHECKER identifier (LPAREN ( checkerPortList)? RPAREN)? SEMI (
		( attributeInstance)* checkerOrGenerateItem
	)* KW_ENDCHECKER (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
classDeclaration:
	(KW_VIRTUAL)? KW_CLASS (lifetime)? identifier (
		parameterPortList
	)? (KW_EXTENDS classType ( LPAREN ( listOfArguments)? RPAREN)?)? (
		KW_IMPLEMENTS interfaceClassType (
			COMMA interfaceClassType
		)*
	)? SEMI (classItem)* KW_ENDCLASS (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
alwaysConstruct: alwaysKeyword statement;
interfaceClassType: psIdentifier ( parameterValueAssignment)?;
interfaceClassDeclaration:
	KW_INTERFACE KW_CLASS identifier (parameterPortList)? (
		KW_EXTENDS interfaceClassType (COMMA interfaceClassType)*
	)? SEMI (interfaceClassItem)* KW_ENDCLASS (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
interfaceClassItem:
	typeDeclaration
	| ( attributeInstance)* interfaceClassMethod
	| (localParameterDeclaration | parameterDeclaration)? SEMI;
interfaceClassMethod: KW_PURE KW_VIRTUAL methodPrototype SEMI;
packageDeclaration:
	(attributeInstance)* KW_PACKAGE (lifetime)? identifier SEMI packageDeclarationBody KW_ENDPACKAGE
		(
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
packageDeclarationBody:
	(timeunitsDeclaration)? (( attributeInstance)* packageItem)*;
packageItem:
	netDeclaration
	| dataDeclaration
	| taskDeclaration
	| functionDeclaration
	| checkerDeclaration
	| dpiImportExport
	| externConstraintDeclaration
	| classDeclaration
	| interfaceClassDeclaration
	| classConstructorDeclaration
	| (localParameterDeclaration | parameterDeclaration)? SEMI
	| covergroupDeclaration
	| propertyDeclaration
	| sequenceDeclaration
	| letDeclaration
	| anonymousProgram
	| packageExportDeclaration
	| timeunitsDeclaration;
programDeclaration:
	KW_EXTERN programHeader
	| (
		(
			programHeader
			| (attributeInstance)* KW_PROGRAM identifier LPAREN DOT MUL RPAREN SEMI
		) (timeunitsDeclaration)? (programItem)*
	) KW_ENDPROGRAM (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
programHeader:
	(attributeInstance)* KW_PROGRAM (lifetime)? identifier (
		packageImportDeclaration
	)* (parameterPortList)? (listOfPortDeclarations)? SEMI;
programItem: nonansiPortDeclaration SEMI | nonPortProgramItem;
nonPortProgramItem:
	(attributeInstance)* (
		continuousAssign
		| (
			defaultClockingOrDissableConstruct
			| localParameterDeclaration
			| parameterDeclaration
		)? SEMI
		| netDeclaration
		| dataDeclaration
		| taskDeclaration
		| functionDeclaration
		| checkerDeclaration
		| dpiImportExport
		| externConstraintDeclaration
		| classDeclaration
		| interfaceClassDeclaration
		| classConstructorDeclaration
		| covergroupDeclaration
		| propertyDeclaration
		| sequenceDeclaration
		| letDeclaration
		| genvarDeclaration
		| clockingDeclaration
		| initialConstruct
		| finalConstruct
		| concurrentAssertionItem
	)
	| timeunitsDeclaration
	| programGenerateItem;
anonymousProgram:
	KW_PROGRAM SEMI (anonymousProgramItem)* KW_ENDPROGRAM;
anonymousProgramItem:
	SEMI
	| taskDeclaration
	| functionDeclaration
	| classDeclaration
	| interfaceClassDeclaration
	| covergroupDeclaration
	| classConstructorDeclaration;
sequenceDeclaration:
	KW_SEQUENCE identifier (LPAREN ( sequencePortList)? RPAREN)? SEMI (
		assertionVariableDeclaration
	)* sequenceExpr (SEMI)? KW_ENDSEQUENCE (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
sequencePortList: sequencePortItem ( COMMA sequencePortItem)*;
sequencePortItem:
	(attributeInstance)* (KW_LOCAL ( sequenceLvarPortDirection)?)? (
		sequenceFormalType
	)? identifier (variableDimension)* (ASSIGN sequenceActualArg)?;
propertyDeclaration:
	KW_PROPERTY identifier (LPAREN ( propertyPortList)? RPAREN)? SEMI (
		assertionVariableDeclaration
	)* propertySpec (SEMI)? KW_ENDPROPERTY (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
propertyPortList: propertyPortItem ( COMMA propertyPortItem)*;
propertyPortItem:
	(attributeInstance)* (KW_LOCAL ( KW_INPUT)?)? (
		propertyFormalType
	)? identifier (variableDimension)* (ASSIGN propertyActualArg)?;

continuousAssign:
	KW_ASSIGN (
		(driveStrength)? (delay3)? listOfVariableAssignments
		| delayControl listOfVariableAssignments
	) SEMI;
checkerOrGenerateItem:
	(KW_RAND)? dataDeclaration
	| moduleOrGenerateOrInterfaceOrCheckerItem
	| ( defaultClockingOrDissableConstruct)? SEMI
	| programGenerateItem;
constraintPrototype:
	(constraintPrototypeQualifier)? (KW_STATIC)? KW_CONSTRAINT identifier SEMI;
classConstraint: constraintPrototype | constraintDeclaration;
constraintDeclaration:
	(KW_STATIC)? KW_CONSTRAINT identifier constraintBlock;
classConstructorDeclaration:
	KW_FUNCTION (classScope)? KW_NEW (LPAREN tfPortList RPAREN)? SEMI (
		blockItemDeclaration
	)* (
		KW_SUPER DOT KW_NEW (LPAREN ( listOfArguments)? RPAREN)? SEMI
	)? (statementOrNull)* KW_ENDFUNCTION (COLON KW_NEW)?;
classProperty:
	KW_CONST (classItemQualifier)* dataType identifier (
		ASSIGN constantExpression
	)? SEMI
	| ( propertyQualifier)* dataDeclaration;
classMethod:
	KW_PURE KW_VIRTUAL (classItemQualifier)* methodPrototype SEMI
	| KW_EXTERN (methodQualifier)* (
		methodPrototype SEMI
		| classConstructorPrototype
	)
	| (methodQualifier)* (
		taskDeclaration
		| functionDeclaration
		| classConstructorDeclaration
	);
classConstructorPrototype:
	KW_FUNCTION KW_NEW (LPAREN tfPortList RPAREN)? SEMI;
classItem:
	(attributeInstance)* (
		classProperty
		| classMethod
		| classConstraint
		| classDeclaration
		| covergroupDeclaration
	)
	| (localParameterDeclaration | parameterDeclaration)? SEMI;
parameterOverride: KW_DEFPARAM listOfDefparamAssignments SEMI;
/************************************************** gate **************************************************************/
gateInstantiation:
	(
		(
			KW_PULLDOWN ( pulldownStrength)?
			| KW_PULLUP ( pullupStrength)?
		) pullGateInstance (COMMA pullGateInstance)*
		| (cmosSwitchtype | mosSwitchtype) (delay3)? enableGateOrMosSwitchOrCmosSwitchInstance (
			COMMA enableGateOrMosSwitchOrCmosSwitchInstance
		)*
		| enableGatetype (driveStrength)? (delay3)? enableGateOrMosSwitchOrCmosSwitchInstance (
			COMMA enableGateOrMosSwitchOrCmosSwitchInstance
		)*
		| nInputGatetype (driveStrength)? (delay2)? nInputGateInstance (
			COMMA nInputGateInstance
		)*
		| nOutputGatetype (driveStrength)? (delay2)? nOutputGateInstance (
			COMMA nOutputGateInstance
		)*
		| passEnSwitchtype (delay2)? passEnableSwitchInstance (
			COMMA passEnableSwitchInstance
		)*
		| passSwitchtype passSwitchInstance (
			COMMA passSwitchInstance
		)*
	) SEMI;
enableGateOrMosSwitchOrCmosSwitchInstance:
	(nameOfInstance)? LPAREN outputTerminal COMMA inputTerminal COMMA expression (
		COMMA expression
	)? RPAREN;
nInputGateInstance:
	(nameOfInstance)? LPAREN outputTerminal (COMMA inputTerminal)+ RPAREN;
nOutputGateInstance:
	(nameOfInstance)? LPAREN outputTerminal (
		COMMA outputTerminal
	)* COMMA inputTerminal RPAREN;
passSwitchInstance:
	(nameOfInstance)? LPAREN inoutTerminal COMMA inoutTerminal RPAREN;
passEnableSwitchInstance:
	(nameOfInstance)? LPAREN inoutTerminal COMMA inoutTerminal COMMA enableTerminal RPAREN;
pullGateInstance:
	(nameOfInstance)? LPAREN outputTerminal RPAREN;
pulldownStrength:
	LPAREN (
		strength0 ( COMMA strength1)?
		| strength1 COMMA strength0
	) RPAREN;
pullupStrength:
	LPAREN (
		strength0 COMMA strength1
		| strength1 ( COMMA strength0)?
	) RPAREN;
enableTerminal: expression;
inoutTerminal: netLvalue;
inputTerminal: expression;
outputTerminal: netLvalue;
// udpInstantiation is designed to match only udpInstantiation which can not match other instantiations
udpInstantiation:
	identifier (
		driveStrength ( delay2)? ( nameOfInstance)?
		| delay2 ( nameOfInstance)?
	)? udpInstanceBody (COMMA udpInstance)* SEMI;
udpInstance: ( nameOfInstance)? udpInstanceBody;
udpInstanceBody:
	LPAREN outputTerminal (COMMA inputTerminal)+ RPAREN;
moduleOrInterfaceOrProgramOrUdpInstantiation:
	identifier (parameterValueAssignment)? hierarchicalInstance (
		COMMA hierarchicalInstance
	)* SEMI;
hierarchicalInstance:
	nameOfInstance LPAREN listOfPortConnections RPAREN;
listOfPortConnections:
	orderedPortConnection (COMMA orderedPortConnection)*
	| namedPortConnection ( COMMA namedPortConnection)*;
orderedPortConnection: ( attributeInstance)* ( expression)?;
namedPortConnection:
	(attributeInstance)* DOT (
		MUL
		| identifier ( LPAREN ( expression)? RPAREN)?
	);
bindDirective:
	KW_BIND (
		identifier ( COLON bindTargetInstanceList)?
		| bindTargetInstance
	) bindInstantiation;
bindTargetInstance: hierarchicalIdentifier ( bitSelect)*;
bindTargetInstanceList:
	bindTargetInstance (COMMA bindTargetInstance)*;
bindInstantiation:
	moduleOrInterfaceOrProgramOrUdpInstantiation
	| checkerInstantiation;
configDeclaration:
	KW_CONFIG identifier SEMI (localParameterDeclaration SEMI)* designStatement (
		configRuleStatement
	)* KW_ENDCONFIG (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
designStatement: KW_DESIGN ( ( identifier DOT)? identifier)* SEMI;
configRuleStatement:
	(
		KW_DEFAULT liblistClause
		| (instClause | cellClause) (liblistClause | useClause)
	) SEMI;
instClause: KW_INSTANCE instName;
instName: identifier ( DOT identifier)*;
cellClause: KW_CELL ( identifier DOT)? identifier;
liblistClause: KW_LIBLIST ( identifier)*;
useClause:
	KW_USE (
		(identifier DOT)? identifier (
			namedParameterAssignment (
				COMMA namedParameterAssignment
			)*
		)?
		| namedParameterAssignment (
			COMMA namedParameterAssignment
		)*
	) (COLON KW_CONFIG)?;
netAlias: KW_ALIAS netLvalue ( ASSIGN netLvalue)+ SEMI;
specifyBlock: KW_SPECIFY ( specifyItem)* KW_ENDSPECIFY;
/****************************************** generate ******************************************************************/
generateRegion: KW_GENERATE ( generateItem)* KW_ENDGENERATE;
genvarExpression: constantExpression;
loopGenerateConstruct:
	KW_FOR LPAREN genvarInitialization SEMI genvarExpression SEMI genvarIteration RPAREN
		generateItem;
genvarInitialization:
	(KW_GENVAR)? identifier ASSIGN constantExpression;
genvarIteration:
	identifier (
		assignmentOperator genvarExpression
		| incOrDecOperator
	)
	| incOrDecOperator identifier;
conditionalGenerateConstruct:
	ifGenerateConstruct
	| caseGenerateConstruct;
ifGenerateConstruct:
	KW_IF LPAREN constantExpression RPAREN generateItem (
		KW_ELSE generateItem
		| {this._input.LA(1) != SystemVerilog2017Parser.KW_ELSE}?
	);
caseGenerateConstruct:
	KW_CASE LPAREN constantExpression RPAREN (caseGenerateItem)+ KW_ENDCASE;
caseGenerateItem:
	(
		KW_DEFAULT ( COLON)?
		| constantExpression (COMMA constantExpression)* COLON
	) generateItem;
generateBeginEndBlock:
	(identifier COLON)? KW_BEGIN (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	) (generateItem)* KW_END (
		COLON identifier
		| {this._input.LA(1) != SystemVerilog2017Parser.COLON}?
	);
generateItem:
	(attributeInstance)* (
		moduleOrGenerateItem
		| externTfDeclaration
	)
	| KW_RAND dataDeclaration
	| generateRegion
	| generateBeginEndBlock;
programGenerateItem:
	loopGenerateConstruct
	| conditionalGenerateConstruct
	| generateRegion
	| elaborationSystemTask;
moduleOrGenerateOrInterfaceOrCheckerItem:
	functionDeclaration
	| checkerDeclaration
	| propertyDeclaration
	| sequenceDeclaration
	| letDeclaration
	| covergroupDeclaration
	| genvarDeclaration
	| clockingDeclaration
	| initialConstruct
	| alwaysConstruct
	| finalConstruct
	| assertionItem
	| continuousAssign;
moduleOrGenerateOrInterfaceItem:
	moduleOrInterfaceOrProgramOrUdpInstantiation
	| (
		defaultClockingOrDissableConstruct
		| localParameterDeclaration
		| parameterDeclaration
	)? SEMI
	| netDeclaration
	| dataDeclaration
	| taskDeclaration
	| moduleOrGenerateOrInterfaceOrCheckerItem
	| dpiImportExport
	| externConstraintDeclaration
	| classDeclaration
	| interfaceClassDeclaration
	| classConstructorDeclaration
	| bindDirective
	| netAlias
	| loopGenerateConstruct
	| conditionalGenerateConstruct
	| elaborationSystemTask;

moduleOrGenerateItem:
	parameterOverride
	| gateInstantiation
	| udpInstantiation
	| moduleOrGenerateOrInterfaceItem;
/**********************************************************************************************************************/
elaborationSystemTask:
	(
		KW_DOLAR_FATAL (
			LPAREN UNSIGNED_NUMBER (COMMA ( listOfArguments)?)? RPAREN
		)?
		| (KW_DOLAR_ERROR | KW_DOLAR_WARNING | KW_DOLAR_INFO) (
			LPAREN ( listOfArguments)? RPAREN
		)?
	) SEMI;
/************************************************* module item  *******************************************************/
moduleItemItem: moduleOrGenerateItem | specparamDeclaration;
moduleItem:
	generateRegion
	| ( attributeInstance)* moduleItemItem
	| specifyBlock
	| programDeclaration
	| moduleDeclaration
	| interfaceDeclaration
	| timeunitsDeclaration
	| nonansiPortDeclaration SEMI;