Class {
	#name : #TrGoToNode,
	#superclass : #TrNode,
	#instVars : [
		'label'
	],
	#category : #'Tradukisto-Nodes'
}

{ #category : #copying }
TrGoToNode >> copyTree [
	^ self class new
		label: label;
		yourself
]

{ #category : #translate }
TrGoToNode >> emitCode: aCoder on: aStream indent: anInteger [
	aCoder emitGoTo: self on: aStream indent: anInteger
]

{ #category : #testing }
TrGoToNode >> isGoTo [
	^ true
]

{ #category : #accessing }
TrGoToNode >> label [
	^ label
]

{ #category : #accessing }
TrGoToNode >> label: anObject [
	label := anObject
]

{ #category : #printing }
TrGoToNode >> printOn: aStream level: level [
	aStream
		nextPutAll: 'goto ';
		nextPutAll: label
]
