Class {
	#name : #TrMethod,
	#superclass : #Object,
	#instVars : [
		'selector',
		'locals',
		'body',
		'complete',
		'possibleSideEffectsCache',
		'trClass',
		'arguments'
	],
	#category : #'Tradukisto-Core'
}

{ #category : #utilities }
TrMethod class >> checkSuccessExpr [
	"Return the parse tree for an expression that aborts the primitive if the successFlag is not true."

	| expr |
	expr := 'successFlag ifFalse: [^ nil ]'.
	^ self statementsFor: expr varName: ''
]

{ #category : #utilities }
TrMethod class >> popArgsExpr: argCount [
	"Return the parse tree for an expression that pops the given number of arguments from the stack."

	| expr |
	expr := 'self pop: ' , argCount printString.
	^ self statementsFor: expr varName: ''
]

{ #category : #utilities }
TrMethod class >> statementsFor: sourceText varName: varName [
	"Return the parse tree for the given expression. The result is the statements list of the method parsed from the given source text."

	"Details: Various variables are declared as locals to avoid Undeclared warnings from the parser."

	| s m |
	s := WriteStream on: ''.
	s
		nextPutAll: 'temp';
		cr;
		cr;
		tab;
		nextPutAll: '| rcvr stackPointer successFlag ';
		nextPutAll: varName;
		nextPutAll: ' |';
		cr.
	s nextPutAll: sourceText.
	m := TrMethod new.
	m setupFrom: (OpalCompiler new parse: s contents).
	m setup.
	^ m statements
]

{ #category : #utilities }
TrMethod class >> unusedNamePrefixedBy: aString avoiding: usedNames [
	"Choose a unique variable or label name with the given string as a prefix, avoiding the names in the given collection. The selected name is added to usedNames."

	| n newVarName |
	n := 1.
	newVarName := aString , n printString.
	[ usedNames includes: newVarName ]
		whileTrue: [ n := n + 1.
			newVarName := aString , n printString ].
	usedNames add: newVarName.
	^ newVarName
]

{ #category : #private }
TrMethod >> addVarsDeclarationsAndLabelsOf: methodToBeInlined [
	"Prepare to inline the body of the given method into the receiver by making the args and locals of the argument to the receiver be locals of the receiver. Record any type declarations for these variables. Record labels. Assumes that the variables have already be renamed to avoid name clashes."

	methodToBeInlined arguments , methodToBeInlined locals
		do: [ :v | 
			(locals includes: v)
				ifFalse: [ locals addLast: v ] ]
]

{ #category : #api }
TrMethod >> allCalls [
	"Answer a collection of selectors for the messages sent by this method."

	^ body allCalls
]

{ #category : #api }
TrMethod >> allVariables [
	| s |
	s := Set new.
	self allVariablesInto: s.
	^ s
]

{ #category : #api }
TrMethod >> allVariablesInto: aSet [
	body allVariablesInto: aSet
]

{ #category : #accessing }
TrMethod >> arguments [
	^ arguments
]

{ #category : #accessing }
TrMethod >> arguments: anObject [
	arguments := anObject
]

{ #category : #api }
TrMethod >> bindClassVariablesIn: constantDictionary [
	"Class variables are used as constants. This method replaces all references to class variables in the body of this method with the corresponding constant looked up in the class pool dictionary of the source class. The source class class variables should be initialized before this method is called."

	body := body bindVariablesIn: constantDictionary
]

{ #category : #accessing }
TrMethod >> body [
	^ body
]

{ #category : #accessing }
TrMethod >> body: anObject [
	body := anObject
]

{ #category : #private }
TrMethod >> buildCaseStatement: aSendNode [
	"Build a case statement node for the given send of dispatchOn:in:."

	"Note: the first argument is the variable to be dispatched on. The second argument is a constant node holding an array of unary selectors, which will be turned into sends to self."

	(aSendNode arguments size = 2
		and: [ aSendNode arguments last isConstant
				and: [ aSendNode arguments last value class = Array ] ])
		ifFalse: [ self error: 'wrong node structure for a case statement' ].
	^ TrCaseStatementNode new
		expression: aSendNode arguments first
		selectors: aSendNode arguments last value
]

{ #category : #accessing }
TrMethod >> complete [
	^ complete
]

{ #category : #accessing }
TrMethod >> complete: anObject [
	complete := anObject
]

{ #category : #copying }
TrMethod >> copy [
	"Make a deep copy of this TMethod."

	^ self class basicNew
		selector: selector;
		arguments: arguments copy;
		locals: locals copy;
		body: body copyTree;
		complete: complete;
		yourself
]

{ #category : #api }
TrMethod >> emitOn: aStream coder: aCoder [
	aCoder targetClass: trClass originalClass.
	aCoder emitMethod: self on: aStream
]

{ #category : #testing }
TrMethod >> endsWithReturn [
	"Answer true if the last statement of this method is a return."

	^ body statements last isReturn
]

{ #category : #private }
TrMethod >> extractDirective: aSymbol [
	"Scan the top-level statements for an inlining directive of the form:

		self export: <boolean>

	 and remove the directive from the method body. Return the argument of the directive or false if there is no export directive."

	| result newStatements |
	result := false.
	newStatements := OrderedCollection new: body statements size.
	body statements
		do: [ :stmt | 
			(stmt isSend and: [ stmt selector value = aSymbol ])
				ifTrue: [ result := stmt arguments first value ]
				ifFalse: [ newStatements add: stmt ] ].
	body statements: newStatements asArray.
	^ result
]

{ #category : #api }
TrMethod >> freeVariableReferences [
	"Answer a collection of variables referenced this method, excluding locals, arguments, and pseudovariables."

	| refs |
	refs := Set new.
	body
		nodesDo: [ :node | 
			node isVariable
				ifTrue: [ refs add: node name asString ] ].
	arguments do: [ :var | refs remove: var asString ifAbsent: [  ] ].
	locals do: [ :var | refs remove: var asString ifAbsent: [  ] ].
	#('self' 'nil' 'true' 'false')
		do: [ :var | refs remove: var ifAbsent: [  ] ].
	^ refs asSortedCollection
]

{ #category : #testing }
TrMethod >> hasReturn [
	"Answer true if this method contains a return statement."

	body
		nodesDo: [ :n | 
			n isReturn
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #initialization }
TrMethod >> initialize [
	complete := false
]

{ #category : #testing }
TrMethod >> isAssertion [
	^ (selector beginsWith: 'assert')
		or: [ selector beginsWith: 'verify' ]
]

{ #category : #testing }
TrMethod >> isFunctional [
	"Answer true if the receiver is a functional method. That is, if it consists of a single return statement of an expression that contains no other returns."

	(body statements size = 1 and: [ body statements last isReturn ])
		ifFalse: [ ^ false ].
	body statements last expression
		nodesDo: [ :n | 
			n isReturn
				ifTrue: [ ^ false ] ].
	^ true
]

{ #category : #testing }
TrMethod >> isMethod [
	^ true
]

{ #category : #accessing }
TrMethod >> locals [
	^ locals
]

{ #category : #accessing }
TrMethod >> locals: anObject [
	locals := anObject
]

{ #category : #api }
TrMethod >> name [
	^ selector copyWithout: $:
]

{ #category : #api }
TrMethod >> nodeCount [
	"Answer the number of nodes in this method's parseTree (a rough measure of its size)."

	| cnt |
	cnt := 0.
	body nodesDo: [ :n | cnt := cnt + 1 ].
	^ cnt
]

{ #category : #accessing }
TrMethod >> possibleSideEffectsCache [
	^ possibleSideEffectsCache
]

{ #category : #api }
TrMethod >> prepareMethodIn: aCodeGen [
	"Record sends of builtin operators and replace sends of the special selector dispatchOn:in: with case statement nodes.
	Note: Only replaces top-level sends of dispatchOn:in:. Case statements must be top-level statements; they cannot appear in expressions."

	| stmts stmt |
	body
		nodesDo: [ :node | 
			node isSend
				ifTrue: [ "record sends of builtin operators"
					(aCodeGen builtin: node selector value)
						ifTrue: [ node isBuiltinOperator: true ] ].
			node isStatementList
				ifTrue: [ "replace dispatchOn:in: with case statement node"
					stmts := node statements.
					1 to: stmts size do: [ :i | 
						stmt := stmts at: i.
						(stmt isSend and: [ stmt selector = #dispatchOn:in: ])
							ifTrue: [ stmts at: i put: (self buildCaseStatement: stmt) ] ] ] ]
]

{ #category : #printing }
TrMethod >> printOn: aStream [

	aStream
		nextPutAll: self class name;
		nextPut: $(;
		nextPutAll: selector;
		nextPut: $)
]

{ #category : #api }
TrMethod >> removeAssertions [
	body removeAssertions
]

{ #category : #private }
TrMethod >> removeFinalSelfReturn [
	"The Smalltalk parser automatically adds the statement '^self' to the end of methods without explicit returns. This method removes such statements, since the generated code has no notion of 'self' anyway."

	| stmtList lastStmt |
	stmtList := body statements asOrderedCollection.
	stmtList isEmpty ifTrue: [ ^ self ].
	lastStmt := stmtList last.
	(lastStmt isReturn
		and: [ lastStmt expression isVariable
				and: [ 'self' = lastStmt expression name ] ])
		ifFalse: [ ^ self ].
	stmtList removeLast.
	body statements: stmtList
]

{ #category : #private }
TrMethod >> renameLabelsUsing: aDictionary [
	"Rename all labels according to the old->new mappings of the given dictionary."

	body
		nodesDo: [ :node | 
			(node isGoTo and: [ aDictionary includesKey: node label ])
				ifTrue: [ node label: (aDictionary at: node label) ].
			(node isLabel and: [ aDictionary includesKey: node label ])
				ifTrue: [ node label: (aDictionary at: node label) ] ]
]

{ #category : #api }
TrMethod >> renameVariablesUsing: aDictionary [
	"Rename all variables according to old->new mappings of the given dictionary.
	map args and locals"

	arguments := arguments
		collect: [ :arg | 
			(aDictionary includesKey: arg)
				ifTrue: [ aDictionary at: arg ]
				ifFalse: [ arg ] ].
	locals := locals
		collect: [ :v | 
			(aDictionary includesKey: v)
				ifTrue: [ aDictionary at: v ]
				ifFalse: [ v ] ].
	"map variable names in parse tree"
	body
		nodesDo: [ :node | 
			(node isVariable and: [ aDictionary includesKey: node name ])
				ifTrue: [ node name: (aDictionary at: node name) ].
			(node isStatementList and: [ node arguments notEmpty ])
				ifTrue: [ node
						arguments:
							(node arguments
								collect: [ :arg | 
									(aDictionary includesKey: arg)
										ifTrue: [ aDictionary at: arg ]
										ifFalse: [ arg ] ]) ] ]
]

{ #category : #accessing }
TrMethod >> selector [
	^ selector
]

{ #category : #accessing }
TrMethod >> selector: anObject [
	selector := anObject
]

{ #category : #api }
TrMethod >> setup [
	self removeFinalSelfReturn
]

{ #category : #api }
TrMethod >> setupFrom: aMethod [
	selector := aMethod selector value.
	arguments := aMethod argumentNames.
	locals := aMethod body allDefinedVariables removeDuplicates.
	body := aMethod body asTranslatorNode
]

{ #category : #api }
TrMethod >> statements [
	body isStatementList
		ifFalse: [ self error: 'expected method parse tree to be a TStmtListNode' ].
	(body arguments isNil or: [ body arguments isEmpty ])
		ifFalse: [ self error: 'expected method parse tree to have no args' ].
	^ body statements
]

{ #category : #accessing }
TrMethod >> trClass [
	^ trClass
]

{ #category : #accessing }
TrMethod >> trClass: anObject [
	trClass := anObject
]

{ #category : #private }
TrMethod >> unusedNamePrefixedBy: aString avoiding: usedNames [
	"Choose a unique variable or label name with the given string as a prefix, avoiding the names in the given collection. The selected name is added to usedNames."

	| n newVarName |
	n := 1.
	newVarName := aString , n printString.
	[ usedNames includes: newVarName ]
		whileTrue: [ n := n + 1.
			newVarName := aString , n printString ].
	usedNames add: newVarName.
	^ newVarName
]

{ #category : #api }
TrMethod >> variablesAssignedTo [
	"Answer a collection of variables assigned to by this method."

	| refs |
	refs := Set new.
	body
		nodesDo: [ :node | 
			node isAssignment
				ifTrue: [ refs add: node variable name ] ].
	^ refs
]
