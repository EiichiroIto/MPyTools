"
A TrArrayNodeTest is a test class for testing the behavior of TrArrayNode
"
Class {
	#name : #TrArrayNodeTest,
	#superclass : #TestCase,
	#category : #'Tradukisto-Tests-Nodes'
}

{ #category : #private }
TrArrayNodeTest >> newNode [
	^ TrArrayNode new
]

{ #category : #test }
TrArrayNodeTest >> testContents [
	| n a |
	n := self newNode.
	self assert: n contents isNil.
	a := #(1 2 3).
	n contents: a.
	self assert: n contents identicalTo: a.
	self assertCollection: n contents equals: #(1 2 3)
]

{ #category : #test }
TrArrayNodeTest >> testIsArray [
	self assert: self newNode isArray
]

{ #category : #test }
TrArrayNodeTest >> testIsByteArray [
	| n |
	n := self newNode.
	self assert: n isByteArray isNil.
	n isByteArray: true.
	self assert: n isByteArray.
	n isByteArray: false.
	self deny: n isByteArray
]

{ #category : #test }
TrArrayNodeTest >> testIsLeaf [
	| n |
	n := self newNode.
	self assert: n isLeaf
]
