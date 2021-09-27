"
A TrLabeledCommentNodeTest is a test class for testing the behavior of TrLabeledCommentNode
"
Class {
	#name : #TrLabeledCommentNodeTest,
	#superclass : #TestCase,
	#category : #'Tradukisto-Tests-Nodes'
}

{ #category : #private }
TrLabeledCommentNodeTest >> newNode [
	^ TrLabeledCommentNode new
]

{ #category : #test }
TrLabeledCommentNodeTest >> testComment [
	| n |
	n := self newNode.
	self assert: n comment isNil.
	n comment: 'abc'.
	self assert: n comment equals: 'abc'.
	n comment: 'def'.
	self assert: n comment equals: 'def'
]

{ #category : #test }
TrLabeledCommentNodeTest >> testIsComment [
	| n |
	n := self newNode.
	self assert: n isComment.
	n label: 'abc'.
	self deny: n isComment
]

{ #category : #test }
TrLabeledCommentNodeTest >> testIsLabel [
	self assert: self newNode isLabel
]

{ #category : #test }
TrLabeledCommentNodeTest >> testIsLeaf [
	self assert: self newNode isLeaf
]

{ #category : #test }
TrLabeledCommentNodeTest >> testLabel [
	| n |
	n := self newNode.
	self assert: n label isNil.
	n label: 'abc'.
	self assert: n label equals: 'abc'.
	n label: 'def'.
	self assert: n label equals: 'def'
]
