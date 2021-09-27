Class {
	#name : #TrVariableNode,
	#superclass : #TrNode,
	#instVars : [
		'name'
	],
	#category : #'Tradukisto-Nodes'
}

{ #category : #private }
TrVariableNode >> allVariablesInto: aSet [
	aSet add: name
]

{ #category : #api }
TrVariableNode >> bindVariableUsesIn: aDictionary [
	| newNode |
	newNode := aDictionary at: name asSymbol ifAbsent: [ ^ self ].
	^ newNode copyTree
]

{ #category : #api }
TrVariableNode >> bindVariablesIn: aDictionary [
	| newNode |
	newNode := aDictionary at: name asSymbol ifAbsent: [ ^ self ].
	^ newNode copyTree
]

{ #category : #copying }
TrVariableNode >> copyTree [
	^ self class new
		name: name;
		yourself
]

{ #category : #translate }
TrVariableNode >> emitCode: aCoder on: aStream indent: anInteger [
	aCoder emitVariable: self on: aStream indent: anInteger
]

{ #category : #testing }
TrVariableNode >> isLeaf [
	^ true
]

{ #category : #testing }
TrVariableNode >> isVariable [
	^ true
]

{ #category : #accessing }
TrVariableNode >> name [
	^ name
]

{ #category : #accessing }
TrVariableNode >> name: anObject [
	name := anObject
]

{ #category : #printing }
TrVariableNode >> printOn: aStream level: level [
	aStream nextPutAll: name
]
