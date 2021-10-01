Class {
	#name : #TrSendNode,
	#superclass : #TrNode,
	#instVars : [
		'selector',
		'receiver',
		'arguments',
		'isBuiltinOperator'
	],
	#category : #'Tradukisto-Nodes'
}

{ #category : #private }
TrSendNode >> allVariablesInto: aSet [
	receiver allVariablesInto: aSet.
	arguments do: [ :each | each allVariablesInto: aSet ]
]

{ #category : #accessing }
TrSendNode >> arguments [
	^ arguments
]

{ #category : #accessing }
TrSendNode >> arguments: anObject [
	arguments := anObject
]

{ #category : #api }
TrSendNode >> bindVariableUsesIn: aDictionary [
	receiver := receiver bindVariableUsesIn: aDictionary.
	arguments := arguments collect: [ :a | a bindVariableUsesIn: aDictionary ]
]

{ #category : #api }
TrSendNode >> bindVariablesIn: aDictionary [
	receiver := receiver bindVariablesIn: aDictionary.
	arguments := arguments collect: [ :a | a bindVariablesIn: aDictionary ]
]

{ #category : #copying }
TrSendNode >> copyTree [
	^ self class new
		selector: selector;
		receiver: receiver copyTree;
		arguments: (arguments collect: [ :arg | arg copyTree ]);
		isBuiltinOperator: isBuiltinOperator;
		yourself
]

{ #category : #translate }
TrSendNode >> emitCode: aCoder on: aStream indent: anInteger [
	aCoder emitMessageSend: self on: aStream indent: anInteger
]

{ #category : #testing }
TrSendNode >> emptyArguments [
	| node |
	arguments isEmpty
		ifTrue: [ ^ true ].
	node := arguments first.
	(node isStatementList and: [ node statements isEmpty ])
		ifTrue: [ ^ true ].
	^ false
]

{ #category : #initialization }
TrSendNode >> initialize [
	super initialize.
	isBuiltinOperator := false
]

{ #category : #api }
TrSendNode >> inlineMethodsUsing: aDictionary [
	arguments := arguments
		collect: [ :arg | arg inlineMethodsUsing: aDictionary ]
]

{ #category : #testing }
TrSendNode >> isAssertion [
	^ (selector beginsWith: 'assert')
		or: [ selector beginsWith: 'verify' ]
]

{ #category : #accessing }
TrSendNode >> isBuiltinOperator [
	^ isBuiltinOperator
]

{ #category : #accessing }
TrSendNode >> isBuiltinOperator: anObject [
	isBuiltinOperator := anObject
]

{ #category : #testing }
TrSendNode >> isLeaf [
	"for #class message"
	^ selector = #class
]

{ #category : #testing }
TrSendNode >> isSend [
	^ true
]

{ #category : #testing }
TrSendNode >> isSimpleArguments [
	arguments size = 2
		ifFalse: [ ^ false ].
	^ arguments
		allSatisfy: [ :each | 
			each isStatementList
				and: [ each statements size = 1 and: [ each statements first isLeaf ] ] ]
]

{ #category : #api }
TrSendNode >> nilOrBooleanConstantReceiver [
	"Answer nil or the boolean constant that is the receiver of the given message send. Used to suppress conditional code when the condition is a translation-time constant."

	| val |
	receiver isConstant
		ifTrue: [ val := receiver value.
			(val == true or: [ val == false ])
				ifTrue: [ ^ val ] ].
	^ nil
]

{ #category : #enumerating }
TrSendNode >> nodesDo: aBlock [
	receiver nodesDo: aBlock.
	arguments do: [ :arg | arg nodesDo: aBlock ].
	aBlock value: self
]

{ #category : #printing }
TrSendNode >> printOn: aStream level: level [
	receiver printOn: aStream level: level.
	arguments isEmpty
		ifTrue: [ aStream
				space;
				nextPutAll: selector.
			^ self ].
	selector keywords
		withIndexCollect: [ :each :index | 
			aStream
				space;
				nextPutAll: each;
				space.
			(arguments at: index) printOn: aStream level: level + 1 ]
]

{ #category : #accessing }
TrSendNode >> receiver [
	^ receiver
]

{ #category : #accessing }
TrSendNode >> receiver: anObject [
	receiver := anObject
]

{ #category : #api }
TrSendNode >> removeAssertions [
	receiver removeAssertions.
	arguments do: [:arg | arg removeAssertions]
]

{ #category : #api }
TrSendNode >> replaceNodesIn: aDictionary [
	^ aDictionary
		at: self
		ifAbsent: [ receiver := receiver replaceNodesIn: aDictionary.
			arguments := arguments
				collect: [ :a | a replaceNodesIn: aDictionary ].
			self ]
]

{ #category : #accessing }
TrSendNode >> selector [
	^ selector
]

{ #category : #accessing }
TrSendNode >> selector: anObject [
	selector := anObject
]
