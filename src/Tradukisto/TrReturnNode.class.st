Class {
	#name : #TrReturnNode,
	#superclass : #TrNode,
	#instVars : [
		'expression'
	],
	#category : #'Tradukisto-Nodes'
}

{ #category : #private }
TrReturnNode >> allVariablesInto: aSet [
	expression allVariablesInto: aSet
]

{ #category : #api }
TrReturnNode >> bindVariableUsesIn: aDictionary [
	expression := expression bindVariableUsesIn: aDictionary
]

{ #category : #api }
TrReturnNode >> bindVariablesIn: aDictionary [
	expression := expression bindVariablesIn: aDictionary
]

{ #category : #copying }
TrReturnNode >> copyTree [
	^ self class new
		expression: expression copyTree;
		yourself
]

{ #category : #translate }
TrReturnNode >> emitCode: aCoder on: aStream indent: anInteger [
	aCoder emitReturn: self on: aStream indent: anInteger
]

{ #category : #accessing }
TrReturnNode >> expression [
	^ expression
]

{ #category : #accessing }
TrReturnNode >> expression: anObject [
	expression := anObject
]

{ #category : #api }
TrReturnNode >> inlineMethodsUsing: aDictionary [
	expression := expression inlineMethodsUsing: aDictionary
]

{ #category : #testing }
TrReturnNode >> isReturn [
	^ true
]

{ #category : #enumerating }
TrReturnNode >> nodesDo: aBlock [
	expression nodesDo: aBlock.
	aBlock value: self
]

{ #category : #printing }
TrReturnNode >> printOn: aStream level: level [
	aStream nextPut: $^.
	expression printOn: aStream level: level
]

{ #category : #api }
TrReturnNode >> removeAssertions [
	expression removeAssertions
]

{ #category : #api }
TrReturnNode >> replaceNodesIn: aDictionary [
	^ aDictionary
		at: self
		ifAbsent: [ expression := expression replaceNodesIn: aDictionary.
			self ]
]
