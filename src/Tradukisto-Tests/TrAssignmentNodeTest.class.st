"
A TrAssignmentNodeTest is a test class for testing the behavior of TrAssignmentNode
"
Class {
	#name : #TrAssignmentNodeTest,
	#superclass : #TestCase,
	#category : #'Tradukisto-Tests-Nodes'
}

{ #category : #private }
TrAssignmentNodeTest >> newNode [
	^ TrAssignmentNode new
]

{ #category : #test }
TrAssignmentNodeTest >> testIsAssignment [
	self assert: self newNode isAssignment
]

{ #category : #test }
TrAssignmentNodeTest >> testVariable [
	| n |
	n := self newNode.
	self assert: n variable isNil.
	n variable: 'abc'.
	self assert: n variable equals: 'abc'.
	n variable: 'def'.
	self assert: n variable equals: 'def'
]
