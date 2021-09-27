"
A TrVariableNodeTest is a test class for testing the behavior of TrVariableNode
"
Class {
	#name : #TrVariableNodeTest,
	#superclass : #TestCase,
	#category : #'Tradukisto-Tests-Nodes'
}

{ #category : #private }
TrVariableNodeTest >> newNode [
	^ TrVariableNode new
]

{ #category : #test }
TrVariableNodeTest >> testIsLeaf [
	self assert: self newNode isLeaf
]

{ #category : #test }
TrVariableNodeTest >> testIsVariable [
	self assert: self newNode isVariable
]

{ #category : #test }
TrVariableNodeTest >> testName [
	| n |
	n := self newNode.
	self assert: n name isNil.
	n name: 'abc'.
	self assert: n name equals: 'abc'.
	n name: 'def'.
	self assert: n name equals: 'def'
]
