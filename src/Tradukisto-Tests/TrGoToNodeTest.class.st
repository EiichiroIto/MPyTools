"
A TrGoToNodeTest is a test class for testing the behavior of TrGoToNode
"
Class {
	#name : #TrGoToNodeTest,
	#superclass : #TestCase,
	#category : #'Tradukisto-Tests-Nodes'
}

{ #category : #private }
TrGoToNodeTest >> newNode [
	^ TrGoToNode new
]

{ #category : #test }
TrGoToNodeTest >> testIsGoTo [
	self assert: self newNode isGoTo
]

{ #category : #test }
TrGoToNodeTest >> testLabel [
	| n |
	n := self newNode.
	self assert: n label isNil.
	n label: 'abc'.
	self assert: n label equals: 'abc'.
	n label: 'def'.
	self assert: n label equals: 'def'
]
