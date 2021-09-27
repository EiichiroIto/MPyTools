Class {
	#name : #TrConstantNode,
	#superclass : #TrNode,
	#instVars : [
		'value'
	],
	#category : #'Tradukisto-Nodes'
}

{ #category : #copying }
TrConstantNode >> copyTree [
	^ self class new
		value: value;
		yourself
]

{ #category : #translate }
TrConstantNode >> emitCode: aCoder on: aStream indent: anInteget [
	"Emit a literal."

	aStream nextPutAll: (aCoder literalFor: value)
]

{ #category : #testing }
TrConstantNode >> isConstant [
	^ true
]

{ #category : #testing }
TrConstantNode >> isLeaf [
	^ true
]

{ #category : #printing }
TrConstantNode >> printOn: aStream level: level [
	value storeOn: aStream
]

{ #category : #accessing }
TrConstantNode >> value [
	^ value
]

{ #category : #accessing }
TrConstantNode >> value: anObject [
	value := anObject
]
