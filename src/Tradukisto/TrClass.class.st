Class {
	#name : #TrClass,
	#superclass : #Object,
	#instVars : [
		'name',
		'methods',
		'constants',
		'variables',
		'variablesSetCache',
		'originalClass'
	],
	#category : #'Tradukisto-Core'
}

{ #category : #api }
TrClass >> addClassVarsFor: aClass [
	"Add the class variables for the given class (and its superclasses) to the code base as constants."

	| allClasses |
	allClasses := aClass allSuperclasses asOrderedCollection.
	allClasses add: aClass.
	allClasses
		do: [ :c | 
			c classPool
				associationsDo:
					[ :assoc | constants at: assoc key put: (TrConstantNode new value: assoc value) ] ]
]

{ #category : #api }
TrClass >> addMethod: aMethod [
	"Add the given method to the code base."

	(methods includesKey: aMethod selector value)
		ifTrue: [ self error: 'Method name conflict: ' , aMethod selector ].
	methods at: aMethod selector put: aMethod.
	aMethod trClass: self
]

{ #category : #api }
TrClass >> addVariablesOf: aClass [
	aClass instVarNames do: [ :each | variables addIfNotPresent: each ].
	aClass classPool
		associationsDo: [ :assoc | 
			self
				constantAt: assoc key
				put: (TrConstantNode new value: assoc value) ]
]

{ #category : #api }
TrClass >> allVariables [
	| s |
	s := Set new.
	methods do: [ :each | each allVariablesInto: s ].
	^ s
]

{ #category : #api }
TrClass >> constantAt: aSymbol put: anObject [
	constants at: aSymbol put: anObject
]

{ #category : #accessing }
TrClass >> constants [
	^ constants
]

{ #category : #api }
TrClass >> emitOn: aStream coder: aCoder [
	aCoder targetClass: originalClass.
	aCoder emitClass: self on: aStream
]

{ #category : #api }
TrClass >> globalsAsSet [
	"Used by the inliner to avoid name clashes with global variables."

	(variablesSetCache isNil
		or: [ variablesSetCache size ~= variables size ])
		ifTrue: [ variablesSetCache := variables asSet ].
	^ variablesSetCache
]

{ #category : #initialization }
TrClass >> initialize [
	constants := Dictionary new: 100.
	variables := OrderedCollection new: 100.
	methods := Dictionary new: 500
]

{ #category : #testing }
TrClass >> isMethod: aSymbol [
	| m |
	m := methods at: aSymbol ifAbsent: [ ^ false ].
	^ m isMethod
]

{ #category : #api }
TrClass >> methodNamed: selector [
	"Answer the method in the code base with the given selector."

	^ methods at: selector ifAbsent: [ nil ]
]

{ #category : #accessing }
TrClass >> methods [
	^ methods
]

{ #category : #api }
TrClass >> methodsOf: aBlockOrSymbol [
	| list |
	list := methods values.
	list := list select: aBlockOrSymbol.
	list := list
		asSortedCollection: [ :m1 :m2 | m1 selector value < m2 selector value ].
	^ list
]

{ #category : #accessing }
TrClass >> name [
	^ name
]

{ #category : #accessing }
TrClass >> originalClass [
	^ originalClass
]

{ #category : #accessing }
TrClass >> originalClass: anObject [
	originalClass := anObject
]

{ #category : #api }
TrClass >> prepareMethods: aCoder [
	| globals methodNames |
	globals := self globalsAsSet.
	methodNames := methods keys.
	methods
		do: [ :each | 
			(each locals, each arguments)
				do: [ :var | 
					(globals includes: var)
						ifTrue: [ self
								error: 'Local variable name may mask global when inlining: ' , var ].
					(methodNames includes: var)
						ifTrue: [ self
								error: 'Local variable name may mask method when inlining: ' , var ] ].
			each bindClassVariablesIn: constants.
			each prepareMethodIn: aCoder ]
]

{ #category : #printing }
TrClass >> printOn: aStream [
	aStream
		nextPutAll: name asString;
		nextPut: $(;
		nextPutAll: methods size asString;
		nextPutAll: ' methods)'
]

{ #category : #api }
TrClass >> removeAssertions [
	"Remove all assertions in method bodies.  This is for the benefit of inlining, which
	fails to recognise and disregard empty method bodies when checking the inlinability
	of sends."

	| newMethods |
	newMethods := Dictionary new.
	methods
		do: [ :m | 
			m isAssertion
				ifFalse: [ newMethods at: m selector value put: m.
					m removeAssertions ] ].
	methods := newMethods
]

{ #category : #api }
TrClass >> removeMethodNamed: aSymbol [
	"Remove the given method from the code base."

	methods removeKey: aSymbol ifAbsent: []
]

{ #category : #api }
TrClass >> removeMethodsReferingToGlobals: varList except: methodName [
	"Remove any methods (presumably inlined) that still contain references to the given obsolete global variables."

	| varListAsStrings removeIt mVars |
	varListAsStrings := varList collect: [ :sym | sym asString ].
	methods keys copy
		do: [ :sel | 
			removeIt := false.
			mVars := (self methodNamed: sel) freeVariableReferences asSet.
			varListAsStrings
				do: [ :v | 
					(mVars includes: v)
						ifTrue: [ removeIt := true ] ].
			(removeIt and: [ sel ~= methodName ])
				ifTrue: [ methods removeKey: sel ifAbsent: [  ] ] ]
]

{ #category : #api }
TrClass >> setupFrom: aClass [
	name := aClass name.
	variables := aClass instVarNames asOrderedCollection.
	originalClass := aClass
]

{ #category : #accessing }
TrClass >> variables [
	^ variables
]

{ #category : #accessing }
TrClass >> variables: anObject [
	variables := anObject
]

{ #category : #accessing }
TrClass >> variablesSetCache [
	^ variablesSetCache
]
