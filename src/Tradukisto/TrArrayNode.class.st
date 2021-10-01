Class {
	#name : #TrArrayNode,
	#superclass : #TrNode,
	#instVars : [
		'contents',
		'isByteArray'
	],
	#category : #'Tradukisto-Nodes'
}

{ #category : #private }
TrArrayNode >> allVariablesInto: aSet [
	contents do: [:each | each allVariablesInto: aSet]
]

{ #category : #accessing }
TrArrayNode >> contents [
	^ contents
]

{ #category : #accessing }
TrArrayNode >> contents: anObject [
	contents := anObject
]

{ #category : #copying }
TrArrayNode >> copyTree [
	^ self class new
		contents: contents copy;
		isByteArray: isByteArray;
		yourself
]

{ #category : #translate }
TrArrayNode >> emitCode: aCoder on: aStream indent: anInteger [ 
	aCoder emitArray: self on: aStream indent: anInteger
]

{ #category : #testing }
TrArrayNode >> isArray [
	^ true
]

{ #category : #accessing }
TrArrayNode >> isByteArray [
	^ isByteArray
]

{ #category : #accessing }
TrArrayNode >> isByteArray: anObject [
	isByteArray := anObject
]

{ #category : #testing }
TrArrayNode >> isLeaf [
	^ true
]

{ #category : #enumerating }
TrArrayNode >> nodesDo: aBlock [
	contents do: [ :each | each nodesDo: aBlock ].
	aBlock value: self
]

{ #category : #printing }
TrArrayNode >> printOn: aStream level: level [
	aStream
		nextPut: $#;
		nextPut:
			(isByteArray
				ifTrue: [ $[ ]
				ifFalse: [ $( ]).
	contents
		do: [ :each | each printOn: aStream level: level ]
		separatedBy: [ aStream nextPut: Character space ].
	aStream
		nextPut:
			(isByteArray
				ifTrue: [ $] ]
				ifFalse: [ $) ])
]
