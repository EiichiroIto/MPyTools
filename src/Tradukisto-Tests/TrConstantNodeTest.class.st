"
A TrConstantNodeTest is a test class for testing the behavior of TrConstantNode
"
Class {
	#name : #TrConstantNodeTest,
	#superclass : #TestCase,
	#category : #'Tradukisto-Tests-Nodes'
}

{ #category : #private }
TrConstantNodeTest >> newNode [
	^ TrConstantNode new
]

{ #category : #test }
TrConstantNodeTest >> testIsConstant [
	self assert: self newNode isConstant
]

{ #category : #test }
TrConstantNodeTest >> testIsLeaf [
	self assert: self newNode isLeaf
]

{ #category : #test }
TrConstantNodeTest >> testValue [
	| n |
	n := self newNode.
	self assert: n value isNil.
	n value: 1.
	self assert: n value equals: 1.
	n value: 'abc'.
	self assert: n value equals: 'abc'
]
