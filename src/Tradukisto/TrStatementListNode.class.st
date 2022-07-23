Class {
	#name : #TrStatementListNode,
	#superclass : #TrNode,
	#instVars : [
		'arguments',
		'statements'
	],
	#category : #'Tradukisto-Nodes'
}

{ #category : #private }
TrStatementListNode >> allVariablesInto: aSet [
	statements do: [ :each | each allVariablesInto: aSet ]
]

{ #category : #accessing }
TrStatementListNode >> arguments [
	^ arguments
]

{ #category : #accessing }
TrStatementListNode >> arguments: anObject [
	arguments := anObject
]

{ #category : #api }
TrStatementListNode >> bindVariableUsesIn: aDictionary [
	statements := statements collect: [ :s | s bindVariableUsesIn: aDictionary ]
]

{ #category : #api }
TrStatementListNode >> bindVariablesIn: aDictionary [
	statements := statements collect: [ :s | s bindVariablesIn: aDictionary ]
]

{ #category : #copying }
TrStatementListNode >> copyTree [
	^ self class new
		arguments: arguments copy;
		statements: (statements collect: [ :s | s copyTree ]);
		yourself
]

{ #category : #translate }
TrStatementListNode >> emitCode: aCoder on: aStream indent: anInteger [
	aCoder emitStatementList: self on: aStream indent: anInteger
]

{ #category : #api }
TrStatementListNode >> inlineMethodsUsing: aDictionary [
	statements do: [ :s | s inlineMethodsUsing: aDictionary ]
]

{ #category : #testing }
TrStatementListNode >> isCascadingIf [
	| s |
	statements size = 1
		ifFalse: [ ^ false ].
	s := statements first.
	s isSend
		ifFalse: [ ^ false ].
	^ s selector value = #ifTrue:ifFalse:
]

{ #category : #testing }
TrStatementListNode >> isStatementList [
	^ true
]

{ #category : #api }
TrStatementListNode >> nilOrBooleanConstantReceiver [
	^ nil
]

{ #category : #enumerating }
TrStatementListNode >> nodesDo: aBlock [
	statements do: [ :s | s nodesDo: aBlock ].
	aBlock value: self
]

{ #category : #printing }
TrStatementListNode >> printOn: aStream level: level [
	aStream nextPut: $[.
	arguments size > 0
		ifTrue: [ arguments
				do: [ :arg | 
					aStream
						nextPutAll: ' :';
						nextPutAll: arg ].
			aStream nextPutAll: ' | ' ].
	self printStatementsOn: aStream level: level.
	aStream nextPut: $]
]

{ #category : #printing }
TrStatementListNode >> printStatementsOn: aStream level: level [
	statements size > 1
		ifTrue: [ aStream crtab: level + 1 ].
	statements
		withIndexDo: [ :each :i | 
			each printOn: aStream level: level.
			i = statements size
				ifTrue: [ statements size > 1
						ifTrue: [ aStream crtab: level ] ]
				ifFalse: [ aStream
						nextPut: $.;
						crtab: level + 1 ] ]
]

{ #category : #api }
TrStatementListNode >> removeAssertions [
	| newStatements |
	newStatements := OrderedCollection new: statements size.
	statements
		do: [ :stmt | 
			stmt isAssertion
				ifFalse: [ newStatements
						add:
							(stmt
								removeAssertions;
								yourself) ] ].
	statements := newStatements
]

{ #category : #api }
TrStatementListNode >> replaceNodesIn: aDictionary [
	^ aDictionary
		at: self
		ifAbsent: [ statements := statements
				collect: [ :s | s replaceNodesIn: aDictionary ].
			self ]
]

{ #category : #accessing }
TrStatementListNode >> statements [
	^ statements
]

{ #category : #accessing }
TrStatementListNode >> statements: anObject [
	statements := anObject
]
