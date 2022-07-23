Class {
	#name : #TrNode,
	#superclass : #Object,
	#category : #'Tradukisto-Nodes'
}

{ #category : #api }
TrNode >> allCalls [
	"Answer a collection of selectors for the messages sent in this parse tree."

	| calls |
	calls := Set new: 100.
	self
		nodesDo: [ :node | 
			node isSend
				ifTrue: [ calls add: node selector value ] ].
	^ calls
]

{ #category : #private }
TrNode >> allVariablesInto: aSet [
	"do nothing"
]

{ #category : #api }
TrNode >> bindVariableUsesIn: aDictionary [
	"Bind uses of all variables in the given dictionary, but do not change variables that appear on the left-hand-side of an assignment statement."

	^ self
]

{ #category : #api }
TrNode >> bindVariablesIn: aDictionary [
	^ self
]

{ #category : #copying }
TrNode >> copyTree [
	self subclassResponsibility
]

{ #category : #translate }
TrNode >> emitCode: aCoder on: aStream indent: anInteger [
	self subclassResponsibility
]

{ #category : #api }
TrNode >> inlineMethodsUsing: aDictionary [
	self
]

{ #category : #testing }
TrNode >> isAssertion [
	^ false
]

{ #category : #testing }
TrNode >> isAssignment [
	^ false
]

{ #category : #testing }
TrNode >> isCaseStatement [
	^ false
]

{ #category : #testing }
TrNode >> isComment [
	^ false
]

{ #category : #testing }
TrNode >> isConstant [
	^ false
]

{ #category : #testing }
TrNode >> isGoTo [
	^ false
]

{ #category : #testing }
TrNode >> isLabel [
	^ false
]

{ #category : #testing }
TrNode >> isLeaf [
	^ false
]

{ #category : #testing }
TrNode >> isReturn [
	^ false
]

{ #category : #testing }
TrNode >> isSend [
	^ false
]

{ #category : #testing }
TrNode >> isStatementList [
	^ false
]

{ #category : #testing }
TrNode >> isVariable [
	^ false
]

{ #category : #api }
TrNode >> nodeCount [
	"Answer the number of nodes in this parseTree (a rough measure of its size)."

	| cnt |
	cnt := 0.
	self nodesDo: [ :n | cnt := cnt + 1 ].
	^ cnt
]

{ #category : #enumerating }
TrNode >> nodesDo: aBlock [
	aBlock value: self
]

{ #category : #printing }
TrNode >> printOn: aStream [ 
	"Append a description of the receiver onto the given stream."

	self printOn: aStream level: 0
]

{ #category : #printing }
TrNode >> printOn: aStream level: anInteger [ 
	"Typically overridden. If control actually gets here, avoid recursion loop by sending to super."

	super printOn: aStream
]

{ #category : #api }
TrNode >> removeAssertions [
	"default: do nothing"
]

{ #category : #api }
TrNode >> replaceNodesIn: aDictionary [

	^ aDictionary at: self ifAbsent: [self]
]
