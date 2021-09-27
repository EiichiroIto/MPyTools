"
A TrCaseStatementNodeTest is a test class for testing the behavior of TrCaseStatementNode
"
Class {
	#name : #TrCaseStatementNodeTest,
	#superclass : #TestCase,
	#category : #'Tradukisto-Tests-Nodes'
}

{ #category : #private }
TrCaseStatementNodeTest >> newNode [
	^ TrCaseStatementNode new
]

{ #category : #test }
TrCaseStatementNodeTest >> testIsCaseStatement [
	self assert: self newNode isCaseStatement
]
