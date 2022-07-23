Class {
	#name : #TrCoder,
	#superclass : #Object,
	#instVars : [
		'translationDict',
		'inlineList',
		'verbose',
		'doInlining',
		'doAssertions',
		'targetClass',
		'targetMethod'
	],
	#category : #'Tradukisto-Core'
}

{ #category : #api }
TrCoder >> addClass: arg1 [ 
	^ self subclassResponsibility
]

{ #category : #api }
TrCoder >> addClass: aClass methodSelector: aString [ 
	self subclassResponsibility
]

{ #category : #private }
TrCoder >> buildTranslationDictionary [
	"Initialize the dictionary mapping message names to actions for C code generation."

	| dictionary |
	dictionary := Dictionary new.
	self translationPair pairsDo: [ :a :b | dictionary at: a put: b ].
	^ dictionary
]

{ #category : #testing }
TrCoder >> builtin: sel [
	"Answer true if the given selector is one of the builtin selectors."

	(#(#longAt: #longAt:put: #error: #byteAt: #byteAt:put:) includes: sel)
		ifTrue: [ ^ true ].
	^ self isKeyword: sel
]

{ #category : #private }
TrCoder >> classClass [
	^ TrClass
]

{ #category : #api }
TrCoder >> codeString [
	self subclassResponsibility
]

{ #category : #api }
TrCoder >> codeStringOf: anObject [
	| stream |
	stream := ReadWriteStream on: String new.
	anObject emitOn: stream coder: self.
	^ stream contents
]

{ #category : #accessing }
TrCoder >> doAssertions [
	^ doAssertions
]

{ #category : #accessing }
TrCoder >> doAssertions: anObject [
	doAssertions := anObject
]

{ #category : #accessing }
TrCoder >> doInlining [
	^ doInlining
]

{ #category : #accessing }
TrCoder >> doInlining: anObject [
	doInlining := anObject
]

{ #category : #'code generation' }
TrCoder >> emitAssignment: aNode on: aStream indent: anInteger [
	self subclassResponsibility
]

{ #category : #'code generation' }
TrCoder >> emitBuiltinConstructFor: msgNode on: aStream indent: level [
	"If the given selector is in the translation dictionary, translate it into a target code construct and return true. Otherwise, do nothing and return false."

	| action |
	action := translationDict at: msgNode selector value ifAbsent: [ ^ false ].
	self
		perform: action
		with: msgNode
		with: aStream
		with: level.
	^ true
]

{ #category : #api }
TrCoder >> emitClass: aClass on: aStream [
	self subclassResponsibility
]

{ #category : #'code generation' }
TrCoder >> emitExpression: aNode on: aStream [
	self subclassResponsibility
]

{ #category : #'code generation' }
TrCoder >> emitHeader: aClass on: aStream [
	self subclassResponsibility
]

{ #category : #'code generation' }
TrCoder >> emitIndentLevel: anInteger on: aStream [
	anInteger timesRepeat: [ aStream tab ]
]

{ #category : #'code generation' }
TrCoder >> emitMessageSend: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #api }
TrCoder >> emitMethod: aTrMethod on: aStream [
	self emitMethod: aTrMethod on: aStream indent: 0
]

{ #category : #'code generation' }
TrCoder >> emitMethod: aTrMethod on: aStream indent: anInteger [
	self subclassResponsibility
]

{ #category : #'code generation' }
TrCoder >> emitMethods: aClass on: aStream indent: anInteger [
	| methods |
	methods := aClass methods
		asSortedCollection: [ :m1 :m2 | m1 selector value < m2 selector value ].
	methods do: [ :m | self emitMethod: m on: aStream indent: anInteger ]
]

{ #category : #'code generation' }
TrCoder >> emitReturn: aNode on: aStream indent: anInteger [
	self subclassResponsibility
]

{ #category : #'code generation' }
TrCoder >> emitStatementList: aNode on: aStream indent: anInteger [
	self subclassResponsibility
]

{ #category : #'code generation' }
TrCoder >> emitTestBlock: aBlockNode on: aStream [
	self subclassResponsibility
]

{ #category : #'code generation' }
TrCoder >> emitVariable: aNode on: aStream indent: anInteger [
	aNode name = 'nil'
		ifTrue: [ aStream nextPutAll: (self literalFor: nil) ]
		ifFalse: [ aStream nextPutAll: (self variableFor: aNode name) ]
]

{ #category : #private }
TrCoder >> functionNameFor: aString [
	^ aString copyWithout: $:
]

{ #category : #translation }
TrCoder >> generateAnd: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateAsFloat: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateAsInteger: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateAt: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateAtPut: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateBitAnd: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateBitInvert32: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateBitOr: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateBitShift: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateBitXor: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateConditionalIf: aNode then: aNode2 else: aNode3 on: aStream indent: anInteger [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateDivide: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateEqual: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateGreaterThan: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateGreaterThanOrEqual: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateIf: aNode then: aNode2 else: aNode3 on: aStream indent: anInteger [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateIfFalse: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateIfFalseIfTrue: aNode on: aStream indent: anInteger [
	| const |
	const := aNode nilOrBooleanConstantReceiver.
	const
		ifNotNil: [ const
				ifTrue: [ aNode arguments last emitCode: self on: aStream indent: anInteger ]
				ifFalse: [ aNode arguments first emitCode: self on: aStream indent: anInteger ].
			^ self ].
	aNode isSimpleArguments
		ifTrue: [ ^ self
				generateConditionalIf: aNode receiver
				then: aNode arguments last
				else: aNode arguments first
				on: aStream
				indent: anInteger ].
	self
		generateIf: aNode receiver
		then: aNode arguments last
		else: aNode arguments first
		on: aStream
		indent: anInteger
]

{ #category : #translation }
TrCoder >> generateIfTrue: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateIfTrueIfFalse: aNode on: aStream indent: anInteger [
	| const |
	const := aNode nilOrBooleanConstantReceiver.
	const
		ifNotNil: [ const
				ifTrue: [ aNode arguments first emitCode: self on: aStream indent: anInteger ]
				ifFalse: [ aNode arguments last emitCode: self on: aStream indent: anInteger ].
			^ self ].
	aNode isSimpleArguments
		ifTrue: [ ^ self
				generateConditionalIf: aNode receiver
				then: aNode arguments first
				else: aNode arguments last
				on: aStream
				indent: anInteger ].
	self
		generateIf: aNode receiver
		then: aNode arguments first
		else: aNode arguments last
		on: aStream
		indent: anInteger
]

{ #category : #translation }
TrCoder >> generateInlineDirective: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateIsNil: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateLessThan: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateLessThanOrEqual: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateMax: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateMin: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateMinus: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateModulo: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateNot: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateNotEqual: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateNotNil: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateOr: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generatePlus: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateSequentialAnd: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateSequentialOr: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateShiftLeft: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateShiftRight: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateTimes: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateToByDo: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateToDo: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateWhileFalse: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #translation }
TrCoder >> generateWhileTrue: aNode on: aStream indent: level [
	self subclassResponsibility
]

{ #category : #initialization }
TrCoder >> initialize [
	translationDict := self buildTranslationDictionary.
	verbose := true.
	doInlining := false.
	doAssertions := false
]

{ #category : #accessing }
TrCoder >> inlineList [
	^ inlineList
]

{ #category : #accessing }
TrCoder >> inlineList: anObject [
	inlineList := anObject
]

{ #category : #testing }
TrCoder >> isKeyword: aSymbol [
	^ translationDict includesKey: aSymbol
]

{ #category : #api }
TrCoder >> literalFor: anObject [
	self subclassResponsibility
]

{ #category : #testing }
TrCoder >> mayInline: sel [
	"Answer true if the method with the given selector may be inlined."

	^ inlineList includes: sel
]

{ #category : #private }
TrCoder >> methodClass [
	self subclassResponsibility
]

{ #category : #private }
TrCoder >> newMethodFrom: aString [
	^ self methodClass new
		setupFrom: (OpalCompiler new parse: aString);
		setup;
		yourself
]

{ #category : #accessing }
TrCoder >> targetClass [
	^ targetClass
]

{ #category : #accessing }
TrCoder >> targetClass: anObject [
	targetClass := anObject
]

{ #category : #accessing }
TrCoder >> targetMethod [
	^ targetMethod
]

{ #category : #accessing }
TrCoder >> targetMethod: anObject [
	targetMethod := anObject
]

{ #category : #private }
TrCoder >> trMethodsOf: aClass [
	^ aClass methods
		collect: [ :each | self newMethodFrom: each sourceCode ]
]

{ #category : #accessing }
TrCoder >> translationDict [
	^ translationDict
]

{ #category : #private }
TrCoder >> translationPair [
	^ #(
	#& #generateAnd:on:indent:
	#| #generateOr:on:indent:
	#and: #generateSequentialAnd:on:indent:
	#or: #generateSequentialOr:on:indent:
	#not #generateNot:on:indent:
	#+ #generatePlus:on:indent:
	#- #generateMinus:on:indent:
	#* #generateTimes:on:indent:
	#/ #generateDivide:on:indent:
	#// #generateDivide:on:indent:
	#\\ #generateModulo:on:indent:
	#<< #generateShiftLeft:on:indent:
	#>> #generateShiftRight:on:indent:
	#min: #generateMin:on:indent:
	#max: #generateMax:on:indent:
	#bitAnd: #generateBitAnd:on:indent:
	#bitOr: #generateBitOr:on:indent:
	#bitXor: #generateBitXor:on:indent:
	#bitShift: #generateBitShift:on:indent:
	#bitInvert32 #generateBitInvert32:on:indent:
	#< #generateLessThan:on:indent:
	#<= #generateLessThanOrEqual:on:indent:
	#= #generateEqual:on:indent:
	#> #generateGreaterThan:on:indent:
	#>= #generateGreaterThanOrEqual:on:indent:
	#~= #generateNotEqual:on:indent:
	#== #generateEqual:on:indent:
	#~~ #generateNotEqual:on:indent:
	#isNil #generateIsNil:on:indent:
	#notNil #generateNotNil:on:indent:
	#whileTrue: #generateWhileTrue:on:indent:
	#whileFalse: #generateWhileFalse:on:indent:
	#to:do: #generateToDo:on:indent:
	#to:by:do: #generateToByDo:on:indent:
	#ifTrue: #generateIfTrue:on:indent:
	#ifFalse: #generateIfFalse:on:indent:
	#ifTrue:ifFalse: #generateIfTrueIfFalse:on:indent:
	#ifFalse:ifTrue: #generateIfFalseIfTrue:on:indent:
	#at: #generateAt:on:indent:
	#at:put: #generateAtPut:on:indent:
	#basicAt: #generateAt:on:indent:
	#basicAt:put: #generateAtPut:on:indent:
	#asFloat #generateAsFloat:on:indent:
	#asInteger #generateAsInteger:on:indent:)
]

{ #category : #api }
TrCoder >> variableFor: anObject [
	^ anObject asString
]

{ #category : #accessing }
TrCoder >> verbose [
	^ verbose
]

{ #category : #accessing }
TrCoder >> verbose: anObject [
	verbose := anObject
]
