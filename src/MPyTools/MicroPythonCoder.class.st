Class {
	#name : #MicroPythonCoder,
	#superclass : #TrCoder,
	#instVars : [
		'classes'
	],
	#category : #'MPyTools-MicroPython'
}

{ #category : #api }
MicroPythonCoder >> addClass: aClass [
	| newClass |
	newClass := self privAddClass: aClass.
	newClass addVariablesOf: aClass.
	(self trMethodsOf: aClass)
		do: [ :each | newClass addMethod: each ]
]

{ #category : #api }
MicroPythonCoder >> addClass: aClass methodSelector: aSymbol [
	| trClass trMethod |
	trClass := self privAddClass: aClass.
	trMethod := self newMethodFrom: (aClass>>aSymbol) sourceCode.
	trMethod trClass: trClass.
	trClass addMethod: trMethod
]

{ #category : #utilities }
MicroPythonCoder >> camelToUnderScore: aString [
	| r w c last |
	last := nil.
	r := ReadStream on: aString.
	w := WriteStream on: String new.
	[ r atEnd ]
		whileFalse: [ c := r next.
			last
				ifNil: [ w nextPut: c asLowercase ]
				ifNotNil: [ c isUppercase
						ifTrue: [ w nextPut: $_.
							w nextPut: c asLowercase ]
						ifFalse: [ w nextPut: c ] ].
			last := c ].
	^ w contents
]

{ #category : #api }
MicroPythonCoder >> classNamed: aString [
	^ classes detect: [ :each | each name = aString ]
]

{ #category : #accessing }
MicroPythonCoder >> classes [
	^ classes
]

{ #category : #accessing }
MicroPythonCoder >> classes: anObject [
	classes := anObject
]

{ #category : #api }
MicroPythonCoder >> codeString [
	| stream |
	stream := ReadWriteStream on: String new.
	classes do: [ :each | each emitOn: stream coder: self ].
	^ stream contents
]

{ #category : #api }
MicroPythonCoder >> codeStringFromCompiledMethod: aCompiledMethod [
	self addClass: aCompiledMethod classBinding value methodSelector: aCompiledMethod selector.
	^ self codeString
]

{ #category : #'code generation' }
MicroPythonCoder >> emitArray: aNode on: aStream indent: anInteger [
	aNode isByteArray
		ifTrue: [ aStream nextPutAll: 'bytes([' ]
		ifFalse: [ aStream nextPut: $( ].
	aNode contents
		do: [ :each | each emitCode: self on: aStream indent: anInteger ]
		separatedBy: [ aStream nextPut: $, ].
	aNode contents size = 1
		ifTrue: [ aStream nextPut: $, ].
	aNode isByteArray
		ifTrue: [ aStream nextPutAll: '])' ]
		ifFalse: [ aStream nextPut: $) ]
]

{ #category : #'code generation' }
MicroPythonCoder >> emitAssignment: aNode on: aStream indent: anInteger [
	aNode variable emitCode: self on: aStream indent: anInteger.
	aStream nextPutAll: ' = '.
	aNode expression emitCode: self on: aStream indent: anInteger
]

{ #category : #api }
MicroPythonCoder >> emitClass: aTrClass on: aStream [
	aTrClass prepareMethods: self.
	doAssertions
		ifFalse: [ aTrClass removeAssertions ].
	aTrClass renameVariableToShorterName.
	self emitImports: aTrClass allVariables on: aStream.
	self emitFunctions: aTrClass on: aStream indent: 0.
	(aTrClass methodsOf: #isMethod) notEmpty
		ifTrue: [ self emitHeader: aTrClass on: aStream.
			self emitMethods: aTrClass on: aStream indent: 1 ].
	aStream cr.
	self emitTopLevels: aTrClass on: aStream indent: 0
]

{ #category : #'code generation' }
MicroPythonCoder >> emitExpression: aNode on: aStream [
	aNode isLeaf
		ifTrue: [ aNode emitCode: self on: aStream indent: 0 ]
		ifFalse: [ aStream nextPut: $(.
			aNode emitCode: self on: aStream indent: 0.
			aStream nextPut: $) ]
]

{ #category : #'code generation' }
MicroPythonCoder >> emitFunction: aTrMethod on: aStream indent: anInteger [
	targetMethod := aTrMethod.
	self emitFunctionHeader: aTrMethod on: aStream indent: anInteger.
	aTrMethod body emitCode: self on: aStream indent: anInteger + 1.
	aStream cr
]

{ #category : #'code generation' }
MicroPythonCoder >> emitFunctionHeader: aMethod on: aStream indent: anInteger [
	aStream cr.
	self emitIndentLevel: anInteger on: aStream.
	aStream
		nextPutAll: 'def ';
		nextPutAll: (self functionNameFor: aMethod selector);
		nextPut: $(.
	aMethod arguments
		do: [ :arg | aStream nextPutAll: arg ]
		separatedBy: [ aStream nextPut: $, ].
	aStream
		nextPutAll: '):';
		cr
]

{ #category : #'code generation' }
MicroPythonCoder >> emitFunctions: aClass on: aStream indent: anInteger [
	(aClass methodsOf: #isFunction)
		do: [ :m | self emitFunction: m on: aStream indent: anInteger ]
]

{ #category : #'code generation' }
MicroPythonCoder >> emitHeader: aClass on: aStream [
	aStream
		cr;
		nextPutAll: 'class ';
		nextPutAll: aClass name;
		nextPut: $:
]

{ #category : #'code generation' }
MicroPythonCoder >> emitImports: aCollection on: aStream [
	| m |
	m := MicroPythonModules new.
	aCollection
		do: [ :each | targetClass base recordModuleNamed: each into: m ].
	m emitOn: aStream
]

{ #category : #'code generation' }
MicroPythonCoder >> emitMessageArguments: aNode on: aStream indent: level [
	aStream nextPut: $(.
	aNode arguments
		withIndexDo: [ :each :index | 
			each emitCode: self on: aStream indent: level.
			index < aNode arguments size
				ifTrue: [ aStream nextPutAll: ', ' ] ].
	aStream nextPutAll: ')'
]

{ #category : #'code generation' }
MicroPythonCoder >> emitMessageHeader: aNode on: aStream indent: level [
	| m |
	(self isExternalSend: aNode receiver)
		ifTrue: [ aNode receiver receiver emitCode: self on: aStream indent: level.
			^ self ].
	(self isInternalInitializer: aNode)
		ifTrue: [ aNode receiver emitCode: self on: aStream indent: level.
			^ self ].
	aNode receiver isVariable
		ifTrue: [ 'self' = aNode receiver name
				ifTrue:
					[ m := (self classNamed: targetClass name) methodNamed: aNode selector.
					(m notNil
						and: [ m isMethod and: [ targetMethod isTopLevel not ] ])
						ifTrue: [ aStream nextPutAll: 'self.' ] ]
				ifFalse: [ aNode receiver emitCode: self on: aStream indent: level.
					aStream nextPut: $. ] ].
	aStream nextPutAll: (self functionNameFor: aNode selector)
]

{ #category : #'code generation' }
MicroPythonCoder >> emitMessageSend: aNode on: aStream indent: level [
	"Translate this message send into a Python function call.
	If the selector is a built-in construct, translate it and return"

	(self emitBuiltinConstructFor: aNode on: aStream indent: level)
		ifTrue: [ ^ self ].
	self emitMessageHeader: aNode on: aStream indent: level.
	self emitMessageArguments: aNode on: aStream indent: level
]

{ #category : #'code generation' }
MicroPythonCoder >> emitMethod: aTrMethod on: aStream indent: anInteger [
	targetMethod := aTrMethod.
	self emitMethodHeader: aTrMethod on: aStream indent: anInteger.
	aTrMethod body emitCode: self on: aStream indent: anInteger + 1.
	aStream cr
]

{ #category : #'code generation' }
MicroPythonCoder >> emitMethodHeader: aMethod on: aStream indent: anInteger [
	aStream cr.
	self emitIndentLevel: anInteger on: aStream.
	aStream
		nextPutAll: 'def ';
		nextPutAll: (self functionNameFor: aMethod selector);
		nextPut: $(.
	aStream nextPutAll: 'self'.
	aMethod arguments notEmpty
		ifTrue: [ aStream nextPut: $, ].
	aMethod arguments
		do: [ :arg | aStream nextPutAll: arg ]
		separatedBy: [ aStream nextPut: $, ].
	aStream
		nextPutAll: '):';
		cr
]

{ #category : #'code generation' }
MicroPythonCoder >> emitMethods: aClass on: aStream indent: anInteger [
	(aClass methodsOf: #isMethod)
		do: [ :m | self emitMethod: m on: aStream indent: anInteger ]
]

{ #category : #'code generation' }
MicroPythonCoder >> emitReturn: aNode on: aStream indent: anInteger [
	aStream nextPutAll: 'return '.
	aNode expression emitCode: self on: aStream indent: anInteger
]

{ #category : #'code generation' }
MicroPythonCoder >> emitStatementList: aNode on: aStream indent: anInteger [
	aNode statements
		do: [ :s | 
			self emitIndentLevel: anInteger on: aStream.
			s emitCode: self on: aStream indent: anInteger ]
		separatedBy: [ aStream cr ]
]

{ #category : #'code generation' }
MicroPythonCoder >> emitTestBlock: aBlockNode on: aStream [
	aBlockNode statements size > 1
		ifTrue: [ aBlockNode emitCode: self on: aStream indent: 0 ]
		ifFalse:
			[ aBlockNode statements first emitCode: self on: aStream indent: 0 ]
]

{ #category : #'code generation' }
MicroPythonCoder >> emitTopLevel: aTrMethod on: aStream indent: anInteger [
	targetMethod := aTrMethod.
	aTrMethod body emitCode: self on: aStream indent: anInteger.
	aStream cr
]

{ #category : #'code generation' }
MicroPythonCoder >> emitTopLevels: aClass on: aStream indent: anInteger [
	(aClass methodsOf: #isTopLevel)
		do: [ :m | self emitTopLevel: m on: aStream indent: anInteger ]
]

{ #category : #private }
MicroPythonCoder >> functionNameFor: aString [
	| ret |
	(aString beginsWith: 'initialize')
		ifTrue: [ ^ '__init__' ].
	ret := aString copy asString replaceAll: $: with: Character space.
	^ self camelToUnderScore: ret asCamelCase
]

{ #category : #translation }
MicroPythonCoder >> generateAbs: msgNode on: aStream indent: level [
	aStream nextPutAll: 'abs('.
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateAnd: aNode on: aStream indent: level [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' and '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateAsByteArray: aNode on: aStream indent: anInteger [
	(aNode receiver isArray and: [ aNode receiver isByteArray ])
		ifTrue: [ ^ self emitExpression: aNode receiver on: aStream ].
	aStream nextPutAll: 'bytes('.
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateAsCollection: aNode on: aStream indent: anInteger [
	aNode receiver isArray
		ifTrue: [ aStream nextPut: $[.
			aNode receiver contents
				do: [ :each | each emitCode: self on: aStream indent: anInteger ]
				separatedBy: [ aStream nextPut: $, ].
			aStream nextPut: $].
			^ self ].
	aStream nextPutAll: 'list('.
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateAsFloat: aNode on: aStream indent: anInteger [
	aStream nextPutAll: 'float('.
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateAsInteger: aNode on: aStream indent: anInteger [ 
	aStream nextPutAll: 'int('.
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateAsLowercase: aNode on: aStream indent: anInteger [ 
	self generateFunction: 'lower' node: aNode on: aStream indent: anInteger
]

{ #category : #translation }
MicroPythonCoder >> generateAsString: aNode on: aStream indent: anInteger [ 
	aStream nextPutAll: 'str('.
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateAsTuple: aNode on: aStream indent: anInteger [
	(aNode receiver isArray and: [ aNode receiver isByteArray not ])
		ifTrue: [ ^ self emitExpression: aNode receiver on: aStream ].
	aStream nextPutAll: 'tuple('.
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateAt: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: '['.
	msgNode arguments first emitCode: self on: aStream indent: level.
	aStream nextPutAll: ']'
]

{ #category : #translation }
MicroPythonCoder >> generateAtPut: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $[.
	aNode arguments first emitCode: self on: aStream indent: anInteger.
	aStream nextPutAll: '] = '.
	self emitExpression: aNode arguments last on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateBitAnd: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' & '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateBitInvert32: aNode on: aStream indent: level [
	aStream nextPut: $~.
	self emitExpression: aNode receiver on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateBitOr: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' | '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateBitShift: msgNode on: aStream indent: level [
	| arg rcvr |
	arg := msgNode arguments first.
	rcvr := msgNode receiver.
	aStream nextPut: $(.
	self emitExpression: rcvr on: aStream.
	arg isConstant
		ifTrue: [ arg value < 0
				ifTrue: [ aStream
						nextPutAll: ' >> ';
						nextPutAll: arg value negated printString ]
				ifFalse: [ aStream
						nextPutAll: ' << ';
						nextPutAll: arg value printString ] ]
		ifFalse: [ aStream nextPutAll: ' >> -'.
			self emitExpression: arg on: aStream.
			aStream nextPutAll: ') if ('.
			self emitExpression: arg on: aStream.
			aStream nextPutAll: ' < 0) else ('.
			self emitExpression: rcvr on: aStream.
			aStream nextPutAll: ' << '.
			self emitExpression: arg on: aStream ].
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateBitXor: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' ^ '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateComma: aNode on: aStream indent: anInteger [ 
	self generatePlus: aNode on: aStream indent: anInteger
]

{ #category : #translation }
MicroPythonCoder >> generateConditionalIf: aNode then: aNode2 else: aNode3 on: aStream indent: anInteger [
	aNode2 emitCode: self on: aStream indent: 0.
	aStream nextPutAll: ' if '.
	aNode emitCode: self on: aStream indent: 0.
	aStream nextPutAll: ' else '.
	aNode3 emitCode: self on: aStream indent: 0
]

{ #category : #translation }
MicroPythonCoder >> generateDivide: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' / '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateEqual: aNode on: aStream indent: level [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' == '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateFifth: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: '[4]'
]

{ #category : #translation }
MicroPythonCoder >> generateFirst: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: '[0]'
]

{ #category : #translation }
MicroPythonCoder >> generateFourth: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: '[3]'
]

{ #category : #translation }
MicroPythonCoder >> generateFromImport: aNode on: aStream indent: anInteger [ 
	aStream nextPutAll: 'from '.	
	self emitExpression: aNode arguments first on: aStream.
	aStream nextPutAll: ' import '.	
	self emitExpression: aNode arguments second on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateFunction: aString node: aNode on: aStream indent: anInteger [
	self emitExpression: aNode receiver on: aStream.
	aStream
		nextPut: $.;
		nextPutAll: aString;
		nextPut: $(.
	aNode arguments
		do: [ :each | self emitExpression: each on: aStream ]
		separatedBy: [ aStream nextPut: $, ].
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateGreaterThan: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' > '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateGreaterThanOrEqual: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' >= '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateIf: aNode then: aNode2 else: aNode3 on: aStream indent: anInteger [
	| n |
	aStream nextPutAll: 'if '.
	aNode emitCode: self on: aStream indent: anInteger.
	aStream
		nextPut: $:;
		cr.
	aNode2 emitCode: self on: aStream indent: anInteger + 1.
	aStream cr.
	self emitIndentLevel: anInteger on: aStream.
	n := aNode3.
	[ n isCascadingIf ]
		whileTrue: [ n := n statements first.
			aStream nextPutAll: 'elif '.
			n receiver emitCode: self on: aStream indent: anInteger.
			aStream
				nextPut: $:;
				cr.
			n arguments first emitCode: self on: aStream indent: anInteger + 1.
			aStream cr.
			self emitIndentLevel: anInteger on: aStream.
			n := n arguments second ].
	aStream
		nextPutAll: 'else:';
		cr.
	n emitCode: self on: aStream indent: anInteger + 1
]

{ #category : #translation }
MicroPythonCoder >> generateIfFalse: aNode on: aStream indent: anInteger [
	| const |
	const := aNode nilOrBooleanConstantReceiver.
	const
		ifNotNil: [ const
				ifFalse:
					[ aNode arguments first emitCode: self on: aStream indent: anInteger ].
			^ self ].
	aStream nextPutAll: 'if not ('.
	aNode receiver emitCode: self on: aStream indent: anInteger.
	aStream
		nextPutAll: '):';
		cr.
	aNode arguments last emitCode: self on: aStream indent: anInteger + 1
]

{ #category : #translation }
MicroPythonCoder >> generateIfNil: aNode on: aStream indent: anInteger [
	aStream nextPutAll: 'if '.
	aNode receiver emitCode: self on: aStream indent: anInteger.
	aStream
		nextPutAll: ' == ';
		nextPutAll: (self literalFor: nil);
		nextPut: $:;
		cr.
	aNode arguments first emitCode: self on: aStream indent: anInteger + 1
]

{ #category : #translation }
MicroPythonCoder >> generateIfNilIfNotNil: aNode on: aStream indent: anInteger [
	aStream nextPutAll: 'if '.
	aNode receiver emitCode: self on: aStream indent: anInteger.
	aStream
		nextPutAll: ' == ';
		nextPutAll: (self literalFor: nil);
		nextPut: $:;
		cr.
	aNode arguments first
		emitCode: self
		on: aStream
		indent: anInteger + 1.
	aStream cr.
	self emitIndentLevel: anInteger on: aStream.
	aStream
		nextPutAll: 'else:';
		cr.
	aNode arguments last emitCode: self on: aStream indent: anInteger + 1
]

{ #category : #translation }
MicroPythonCoder >> generateIfNotNil: aNode on: aStream indent: anInteger [
	aStream nextPutAll: 'if '.
	aNode receiver emitCode: self on: aStream indent: anInteger.
	aStream
		nextPutAll: ' != ';
		nextPutAll: (self literalFor: nil);
		nextPut: $:;
		cr.
	aNode arguments first emitCode: self on: aStream indent: anInteger + 1
]

{ #category : #translation }
MicroPythonCoder >> generateIfTrue: aNode on: aStream indent: anInteger [ 
	| const |
	const := aNode nilOrBooleanConstantReceiver.
	const
		ifNotNil: [ const
				ifTrue:
					[ aNode arguments first emitCode: self on: aStream indent: anInteger ].
			^ self ].
	aStream nextPutAll: 'if '.
	aNode receiver emitCode: self on: aStream indent: anInteger.
	aStream
		nextPut: $:;
		cr.
	aNode arguments last emitCode: self on: aStream indent: anInteger + 1
]

{ #category : #translation }
MicroPythonCoder >> generateIncludes: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode arguments first on: aStream.
	aStream nextPutAll: ' in '.
	self emitExpression: aNode receiver on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateInlineDirective: aNode on: aStream indent: level [
	aStream
		nextPutAll: '// inline: ';
		nextPutAll: aNode arguments first value asString
]

{ #category : #translation }
MicroPythonCoder >> generateIsNil: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream
		nextPutAll: ' == ';
		nextPutAll: (self literalFor: nil)
]

{ #category : #translation }
MicroPythonCoder >> generateLast: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: '[-1]'
]

{ #category : #translation }
MicroPythonCoder >> generateLessThan: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' < '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateLessThanOrEqual: aNode on: aStream indent: level [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' <= '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateMax: aNode on: aStream indent: anInteger [ 
	aStream nextPutAll: 'max('.
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $,.
	self emitExpression: aNode arguments first on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateMin: aNode on: aStream indent: anInteger [ 
	aStream nextPutAll: 'min('.
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $,.
	self emitExpression: aNode arguments first on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateMinus: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' - '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateModulo: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' % '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateNew: aNode on: aStream indent: anInteger [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: '()'
]

{ #category : #translation }
MicroPythonCoder >> generateNewWithAll: aNode on: aStream indent: anInteger [ 
	aStream nextPut: $(.
	self emitExpression: aNode arguments second on: aStream.
	aStream nextPutAll: ',)*'.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateNinth: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: '[8]'
]

{ #category : #translation }
MicroPythonCoder >> generateNot: aNode on: aStream indent: anInteger [ 
	aStream nextPutAll: 'not ('.
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateNotEqual: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' != '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateNotNil: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream
		nextPutAll: ' != ';
		nextPutAll: (self literalFor: nil)
]

{ #category : #translation }
MicroPythonCoder >> generateOr: aNode on: aStream indent: level [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' or '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generatePlus: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' + '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateRepeat: aNode on: aStream indent: anInteger [
	| rcvr |
	rcvr := aNode receiver.
	rcvr isStatementList
		ifFalse: [ self error ].
	aStream
		nextPutAll: 'while True:';
		cr.
	rcvr statements isEmpty
		ifTrue: [ self emitIndentLevel: anInteger + 1 on: aStream.
			aStream nextPutAll: 'pass' ]
		ifFalse:
			[ aNode receiver emitCode: self on: aStream indent: anInteger + 1 ]
]

{ #category : #translation }
MicroPythonCoder >> generateSearchFrom: aNode on: aStream indent: anInteger [ 
	self generateFunction: 'search' node: aNode on: aStream indent: anInteger
]

{ #category : #translation }
MicroPythonCoder >> generateSecond: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: '[1]'
]

{ #category : #translation }
MicroPythonCoder >> generateSequentialAnd: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' and ('.
	self emitTestBlock: aNode arguments first on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateSequentialOr: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' or ('.
	self emitTestBlock: aNode arguments first on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicroPythonCoder >> generateSeventh: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: '[6]'
]

{ #category : #translation }
MicroPythonCoder >> generateShiftLeft: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' << '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateShiftRight: aNode on: aStream indent: anInteger [ 
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: ' >> '.
	self emitExpression: aNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateSixth: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: '[5]'
]

{ #category : #translation }
MicroPythonCoder >> generateTenth: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: '[9]'
]

{ #category : #translation }
MicroPythonCoder >> generateThird: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: '[2]'
]

{ #category : #translation }
MicroPythonCoder >> generateTimes: msgNode on: aStream indent: level [
	self emitExpression: msgNode receiver on: aStream.
	aStream nextPutAll: ' * '.
	self emitExpression: msgNode arguments first on: aStream
]

{ #category : #translation }
MicroPythonCoder >> generateTimesRepeat: aNode on: aStream indent: anInteger [
	aStream nextPutAll: 'for _ in range(0,'.
	aNode receiver emitCode: self on: aStream indent: 0.
	aStream
		nextPutAll: '):';
		cr.
	aNode emptyArguments
		ifTrue: [ self emitIndentLevel: anInteger + 1 on: aStream.
			aStream nextPutAll: 'pass' ]
		ifFalse: [ aNode arguments first
				emitCode: self
				on: aStream
				indent: anInteger + 1 ]
]

{ #category : #translation }
MicroPythonCoder >> generateToByDo: aNode on: aStream indent: anInteger [
	| iterationVar offset |
	aNode arguments last arguments size = 1
		ifFalse: [ self error: 'wrong number of block arguments' ].
	offset := '+1'.
	aNode arguments second isConstant
		ifTrue: [ offset := (aNode arguments second value > 0
				ifTrue: [ '+' ]
				ifFalse: [ '' ]) , aNode arguments second value sign asString ].
	iterationVar := aNode arguments last arguments first.
	aStream
		nextPutAll: 'for ';
		nextPutAll: iterationVar;
		nextPutAll: ' in range('.
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $,.
	self emitExpression: aNode arguments first on: aStream.
	aStream
		nextPutAll: offset;
		nextPut: $,.
	self emitExpression: aNode arguments second on: aStream.
	aStream
		nextPutAll: '):';
		cr.
	aNode arguments last emitCode: self on: aStream indent: anInteger + 1
]

{ #category : #translation }
MicroPythonCoder >> generateToDo: aNode on: aStream indent: anInteger [
	| iterationVar |
	aNode arguments last arguments size = 1
		ifFalse: [ self error: 'wrong number of block arguments' ].
	iterationVar := aNode arguments last arguments first.
	aStream
		nextPutAll: 'for ';
		nextPutAll: iterationVar;
		nextPutAll: ' in range('.
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $,.
	self emitExpression: aNode arguments first on: aStream.
	aStream
		nextPutAll: '+1):';
		cr.
	aNode arguments last emitCode: self on: aStream indent: anInteger + 1
]

{ #category : #translation }
MicroPythonCoder >> generateWhileFalse: aNode on: aStream indent: anInteger [
	aStream nextPutAll: 'while not ('.
	self emitTestBlock: aNode receiver on: aStream.
	aStream
		nextPutAll: '):';
		cr.
	aNode emptyArguments
		ifTrue: [ self emitIndentLevel: anInteger + 1 on: aStream.
			aStream nextPutAll: 'pass' ]
		ifFalse: [ aNode arguments first
				emitCode: self
				on: aStream
				indent: anInteger + 1 ]
]

{ #category : #translation }
MicroPythonCoder >> generateWhileTrue: aNode on: aStream indent: anInteger [
	aStream nextPutAll: 'while '.
	self emitTestBlock: aNode receiver on: aStream.
	aStream
		nextPut: $:;
		cr.
	aNode emptyArguments
		ifTrue: [ self emitIndentLevel: anInteger + 1 on: aStream.
			aStream nextPutAll: 'pass' ]
		ifFalse: [ aNode arguments first
				emitCode: self
				on: aStream
				indent: anInteger + 1 ]
]

{ #category : #initialization }
MicroPythonCoder >> initialize [
	super initialize.
	classes := OrderedCollection new
]

{ #category : #testing }
MicroPythonCoder >> isExternalSend: aNode [
	| recv |
	aNode isSend
		ifFalse: [ ^ false ].
	recv := aNode receiver.
	recv isVariable
		ifFalse: [ ^ false ].
	(Smalltalk globals includesKey: recv name)
		ifFalse: [ ^ false ].
	^ #(new basicNew) includes: aNode selector
]

{ #category : #testing }
MicroPythonCoder >> isInternalInitializer: aNode [
	| recv |
	aNode isSend
		ifFalse: [ ^ false ].
	recv := aNode receiver.
	recv isVariable
		ifFalse: [ ^ false ].
	(targetClass base classVarNames includes: recv name)
		ifFalse: [ ^ false ].
	^ aNode selector beginsWith: 'init'
]

{ #category : #utilities }
MicroPythonCoder >> literalFor: anObject [
	anObject isNumber
		ifTrue: [ ^ anObject printString ].
	anObject isSymbol
		ifTrue: [ ^ anObject ].
	anObject isString
		ifTrue: [ ^ self stringLiteralFor: anObject ].
	anObject ifNil: [ ^ 'None' ].
	anObject == true
		ifTrue: [ ^ 'True' ].	"ikp"
	anObject == false
		ifTrue: [ ^ 'False' ].	"ikp"
	self
		error:
			'Warning: A Smalltalk literal could not be translated into a MicroPython constant: '
				, anObject printString.	"ikp"
	^ '"XXX UNTRANSLATABLE CONSTANT XXX"'
]

{ #category : #private }
MicroPythonCoder >> methodClass [
	^ MicroPythonMethod
]

{ #category : #private }
MicroPythonCoder >> privAddClass: aClass [
	| newClass |
	classes
		detect: [ :each | each name = aClass name ]
		ifFound: [ :cl | ^ cl ].
	newClass := MicroPythonClass new
		setupFrom: aClass;
		yourself.
	classes add: newClass.
	newClass addVariablesOf: aClass.
	^ newClass
]

{ #category : #utilities }
MicroPythonCoder >> stringLiteralFor: aString [
	| r w c |
	r := ReadStream on: aString.
	w := WriteStream on: String new.
	w nextPut: $".
	[ r atEnd ]
		whileFalse: [ c := r next.
			c
				caseOf:
					{([ $" ] -> [ w nextPutAll: '\"' ]).
					([ Character cr ]
						-> [ w
								nextPutAll: '\n" \';
								nextPut: Character cr;
								nextPut: $" ])}
				otherwise: [ w nextPut: c ] ].
	w nextPut: $".
	^ w contents
]

{ #category : #private }
MicroPythonCoder >> translationPair [
	^ super translationPair
		,
			#(
	#, #generateComma:on:indent:
	#includes: #generateIncludes:on:indent:
	#whileTrue #generateWhileTrue:on:indent:
	#whileFalse #generateWhileFalse:on:indent:
	#repeat #generateRepeat:on:indent:
	#timesRepeat: #generateTimesRepeat:on:indent:
	#asTuple #generateAsTuple:on:indent:
	#asCollection #generateAsCollection:on:indent:
	#asString #generateAsString:on:indent:
	#asByteArray #generateAsByteArray:on:indent:
	#new:withAll: #generateNewWithAll:on:indent:
	#new #generateNew:on:indent:
	#first #generateFirst:on:indent:
	#second #generateSecond:on:indent:
	#third #generateThird:on:indent:
	#fourth #generateFourth:on:indent:
	#fifth #generateFifth:on:indent:
	#seventh #generateSeventh:on:indent:
	#eighth #generateEighth:on:indent:
	#ninth #generateNinth:on:indent:
	#tenth #generateTenth:on:indent:
	#last #generateLast:on:indent:
	#search:from: #generateSearchFrom:on:indent:
	#asLowercase #generateAsLowercase:on:indent:
	#ifNil:ifNotNil: #generateIfNilIfNotNil:on:indent:
	#ifNil: #generateIfNil:on:indent:
	#ifNotNil: #generateIfNotNil:on:indent:
	#from:import: #generateFromImport:on:indent:
	#abs #generateAbs:on:indent:
			)
]

{ #category : #api }
MicroPythonCoder >> variableFor: aString [
	| s |
	s := super variableFor: aString.
	(targetClass notNil
		and: [ targetClass instVarNames includes: aString ])
		ifTrue: [ ^ 'self.' , s ].
	^ s
]
