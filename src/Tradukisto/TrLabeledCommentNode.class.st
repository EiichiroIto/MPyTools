Class {
	#name : #TrLabeledCommentNode,
	#superclass : #TrNode,
	#instVars : [
		'label',
		'comment'
	],
	#category : #'Tradukisto-Nodes'
}

{ #category : #accessing }
TrLabeledCommentNode >> comment [
	^ comment
]

{ #category : #accessing }
TrLabeledCommentNode >> comment: anObject [
	comment := anObject
]

{ #category : #copying }
TrLabeledCommentNode >> copyTree [
	^ self class new
		label: label;
		comment: comment;
		yourself
]

{ #category : #translate }
TrLabeledCommentNode >> emitCode: aCoder on: aStream indent: anInteger [
	aCoder emitLabeledComment: self on: aStream indent: anInteger
]

{ #category : #testing }
TrLabeledCommentNode >> isComment [
	"Answer true if the receiver is just a comment (i.e., it has no label)."

	^ label isNil
]

{ #category : #testing }
TrLabeledCommentNode >> isLabel [
	^ true
]

{ #category : #testing }
TrLabeledCommentNode >> isLeaf [
	^ true
]

{ #category : #accessing }
TrLabeledCommentNode >> label [
	^ label
]

{ #category : #accessing }
TrLabeledCommentNode >> label: anObject [
	label := anObject
]

{ #category : #printing }
TrLabeledCommentNode >> printOn: aStream level: level [
	self printOptionalLabelOn: aStream.
	aStream
		nextPut: $";
		nextPutAll: comment;
		nextPut: $"
]

{ #category : #printing }
TrLabeledCommentNode >> printOptionalLabelOn: aStream [
	label
		ifNotNil: [ self unindentOneTab: aStream.
			aStream
				nextPutAll: label;
				nextPut: $:;
				tab ]
]

{ #category : #private }
TrLabeledCommentNode >> unindentOneTab: aStream [
	"Remove the last tab from the given stream if possible."

	(aStream isKindOf: ReadWriteStream)
		ifFalse: [ ^ self ].
	aStream position > 0
		ifFalse: [ ^ self ].
	aStream position: aStream position - 1.
	"restore stream position if previous char was not a tab"
	aStream peek = Character tab
		ifFalse: [ aStream next ]
]
