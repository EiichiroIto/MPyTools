"
An IdentifierGeneratorTest is a test class for testing the behavior of IdentifierGenerator
"
Class {
	#name : #IdentifierGeneratorTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
IdentifierGeneratorTest >> newGenerator [
	^ IdentifierGenerator new
]

{ #category : #test }
IdentifierGeneratorTest >> testNext [
	| g |
	g := self newGenerator.
	self assert: g next equals: 'a'.
	self assert: g next equals: 'b'.
	self assert: g next equals: 'c'.
	g current: 'y'.
	self assert: g next equals: 'z'.
	self assert: g next equals: 'aa'.
	self assert: g next equals: 'ab'
]
