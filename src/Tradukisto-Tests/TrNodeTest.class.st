"
A TrNodeTest is a test class for testing the behavior of TrNode
"
Class {
	#name : #TrNodeTest,
	#superclass : #TestCase,
	#category : #'Tradukisto-Tests-Nodes'
}

{ #category : #private }
TrNodeTest >> newNode [
	^ TrNode new
]

{ #category : #test }
TrNodeTest >> testIsAssertion [
	self deny: self newNode isAssertion
]

{ #category : #test }
TrNodeTest >> testIsAssignment [
	self deny: self newNode isAssignment
]

{ #category : #test }
TrNodeTest >> testIsCaseStatement [
	self deny: self newNode isCaseStatement
]

{ #category : #test }
TrNodeTest >> testIsComment [
	self deny: self newNode isComment
]

{ #category : #test }
TrNodeTest >> testIsConstant [
	self deny: self newNode isConstant
]

{ #category : #test }
TrNodeTest >> testIsGoTo [
	self deny: self newNode isGoTo
]

{ #category : #test }
TrNodeTest >> testIsLabel [
	self deny: self newNode isLabel
]

{ #category : #test }
TrNodeTest >> testIsLeaf [
	self deny: self newNode isLeaf
]

{ #category : #test }
TrNodeTest >> testIsReturn [
	self deny: self newNode isReturn
]

{ #category : #test }
TrNodeTest >> testIsSend [
	self deny: self newNode isSend
]

{ #category : #test }
TrNodeTest >> testIsStatementList [
	self deny: self newNode isStatementList
]

{ #category : #test }
TrNodeTest >> testIsVariable [
	self deny: self newNode isVariable
]
