"
A TrCoderTest is a test class for testing the behavior of TrCoder
"
Class {
	#name : #TrCoderTest,
	#superclass : #TestCase,
	#category : #'Tradukisto-Tests-Core'
}

{ #category : #private }
TrCoderTest >> newCoder [
	^ TrCoder new
]

{ #category : #test }
TrCoderTest >> testBuildTranslationDictionary [
	| c d |
	c := self newCoder.
	d := c buildTranslationDictionary.
	self assert: (d isKindOf: Dictionary).
	self assert: d notEmpty
]

{ #category : #test }
TrCoderTest >> testBuiltin [
	| c |
	c := self newCoder.
	self assert: (c builtin: #+).
	self deny: (c builtin: #counter).
	self assert: (c builtin: #longAt:)
]

{ #category : #test }
TrCoderTest >> testDoAssertions [
	| c |
	c := self newCoder.
	self deny: c doAssertions.
	c doAssertions: true.
	self assert: c doAssertions
]

{ #category : #test }
TrCoderTest >> testDoInlining [
	| c |
	c := self newCoder.
	self deny: c doInlining.
	c doInlining: true.
	self assert: c doInlining
]

{ #category : #test }
TrCoderTest >> testEmitIndentLevelOn [
	| n s |
	n := self newCoder.
	s := WriteStream on: String new.
	n emitIndentLevel: 0 on: s.
	self assert: s contents isEmpty.
	n emitIndentLevel: 2 on: s.
	self assert: s contents equals: String tab , String tab
]

{ #category : #test }
TrCoderTest >> testFunctionNameFor [
	| c |
	c := self newCoder.
	self assert: (c functionNameFor: #abc) equals: #abc.
	self assert: (c functionNameFor: #abc:def:) equals: #abcdef
]

{ #category : #test }
TrCoderTest >> testInitialize [
	| c |
	c := self newCoder.
	self assert: (c translationDict isKindOf: Dictionary).
	self assert: c verbose
]

{ #category : #test }
TrCoderTest >> testInlineList [
	| c a |
	c := self newCoder.
	self assert: c inlineList isNil.
	a := #(1 2 3).
	c inlineList: a.
	self assert: c inlineList identicalTo: a
]

{ #category : #test }
TrCoderTest >> testIsKeyword [
	| c |
	c := self newCoder.
	self assert: (c isKeyword: #+).
	self deny: (c isKeyword: #counter).
	self deny: (c isKeyword: #longAt:)
]

{ #category : #test }
TrCoderTest >> testMayInline [
	| c |
	c := self newCoder.
	c inlineList: #(a b c).
	self assert: (c mayInline: #a).
	self assert: (c mayInline: #b).
	self assert: (c mayInline: #c).
	self deny: (c mayInline: #d)
]

{ #category : #test }
TrCoderTest >> testTargetClass [
	| c |
	c := self newCoder.
	self assert: c targetClass isNil.
	c targetClass: Object.
	self assert: c targetClass equals: Object
]

{ #category : #test }
TrCoderTest >> testTargetMethod [
	| c m |
	c := self newCoder.
	self assert: c targetMethod isNil.
	m := TrMethod new.
	c targetMethod: m.
	self assert: c targetMethod identicalTo: m
]

{ #category : #test }
TrCoderTest >> testTranslationDict [
	| c |
	c := self newCoder.
	self assert: (c translationDict isKindOf: Dictionary)
]

{ #category : #test }
TrCoderTest >> testTranslationPair [
	| c p |
	c := self newCoder.
	p := c translationPair.
	self assert: p isArray.
	self assert: p size \\ 2 equals: 0
]

{ #category : #test }
TrCoderTest >> testVariableFor [
	| c |
	c := self newCoder.
	self assert: (c variableFor: 'abc') equals: 'abc'.
	self assert: (c variableFor: 'def') equals: 'def'
]

{ #category : #test }
TrCoderTest >> testVerbose [
	| c |
	c := self newCoder.
	self assert: c verbose.
	c verbose: false.
	self deny: c verbose
]
