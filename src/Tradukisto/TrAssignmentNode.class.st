Class {
	#name : #TrAssignmentNode,
	#superclass : #TrNode,
	#instVars : [
		'variable',
		'expression'
	],
	#category : #'Tradukisto-Nodes'
}

{ #category : #private }
TrAssignmentNode >> allVariablesInto: aSet [
	variable allVariablesInto: aSet.
	expression allVariablesInto: aSet
]

{ #category : #api }
TrAssignmentNode >> bindVariableUsesIn: aDictionary [
	"Do NOT bind the variable on the left-hand-side of an assignment statement."

	expression := expression bindVariablesIn: aDictionary
]

{ #category : #api }
TrAssignmentNode >> bindVariablesIn: aDictionary [

	variable := variable bindVariablesIn: aDictionary.
	expression := expression bindVariablesIn: aDictionary
]

{ #category : #copying }
TrAssignmentNode >> copyTree [
	^ self class new
		variable: variable copyTree;
		expression: expression copyTree;
		yourself
]

{ #category : #translate }
TrAssignmentNode >> emitCode: aCoder on: aStream indent: anInteger [
	aCoder emitAssignment: self on: aStream indent: anInteger
]

{ #category : #accessing }
TrAssignmentNode >> expression [
	^ expression
]

{ #category : #accessing }
TrAssignmentNode >> expression: anObject [
	expression := anObject
]

{ #category : #api }
TrAssignmentNode >> inlineMethodsUsing: aDictionary [
	variable inlineMethodsUsing: aDictionary.
	expression inlineMethodsUsing: aDictionary
]

{ #category : #testing }
TrAssignmentNode >> isAssignment [
	^ true
]

{ #category : #testing }
TrAssignmentNode >> isVariableUpdatingAssignment [
	"Return true if this assignment statement is of one of the forms:
		var = var + ...
		var = var - ...
	Such assignments statements can exploit the C updating assignment operators. For example, 'x += 4' can be generated instead of 'x = x + 4'. This produces better code under some C compilers, most notably the CodeWarrior 68K compiler."

	(expression isSend and: [ expression receiver isVariable ])
		ifFalse: [ ^ false ].
	^ expression receiver name = variable name
		and: [ #(#+ #-) includes: expression selector value ]
]

{ #category : #enumerating }
TrAssignmentNode >> nodesDo: aBlock [
	variable nodesDo: aBlock.
	expression nodesDo: aBlock.
	aBlock value: self
]

{ #category : #printing }
TrAssignmentNode >> printOn: aStream level: level [
	variable printOn: aStream level: level.
	aStream nextPutAll: ' := '.
	expression printOn: aStream level: level + 2
]

{ #category : #api }
TrAssignmentNode >> removeAssertions [
	expression removeAssertions
]

{ #category : #api }
TrAssignmentNode >> replaceNodesIn: aDictionary [
	^ aDictionary
		at: self
		ifAbsent: [ variable := variable replaceNodesIn: aDictionary.
			expression := expression replaceNodesIn: aDictionary.
			self ]
]

{ #category : #accessing }
TrAssignmentNode >> variable [
	^ variable
]

{ #category : #accessing }
TrAssignmentNode >> variable: anObject [
	variable := anObject
]
