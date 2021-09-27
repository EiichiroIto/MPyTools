"
A TrClassTest is a test class for testing the behavior of TrClass
"
Class {
	#name : #TrClassTest,
	#superclass : #TestCase,
	#category : #'Tradukisto-Tests-Core'
}

{ #category : #private }
TrClassTest >> fooBarAbs [
	^ OpalCompiler new parse: (TrFooBar>>#abs:) sourceCode
]

{ #category : #private }
TrClassTest >> newClass [
	^ TrClass new
]

{ #category : #test }
TrClassTest >> testAddMethod [
	| c m |
	c := self newClass.
	self assert: c methods isEmpty.
	m := TrMethod new
		setupFrom: self fooBarAbs;
		yourself.
	c addMethod: m.
	self assert: (c methods at: #abs:) identicalTo: m.
	self should: [ c addMethod: m ] raise: Error
]

{ #category : #test }
TrClassTest >> testConstantAtPut [
	| c |
	c := self newClass.
	self assert: c constants isEmpty.
	c constantAt: #a put: 10.
	c constantAt: #b put: 20.
	c constantAt: #c put: 30.
	self assert: c constants size equals: 3.
	self assert: (c constants at: #a) equals: 10.
	self assert: (c constants at: #b) equals: 20.
	self assert: (c constants at: #c) equals: 30
]

{ #category : #test }
TrClassTest >> testConstants [
	| c |
	c := self newClass.
	self assert: c constants isCollection.
	self assert: c constants isEmpty
]

{ #category : #test }
TrClassTest >> testGlobalsAsSet [
	| c |
	c := self newClass.
	c variables: #(a b c).
	self assert: (c globalsAsSet isKindOf: Set).
	self assert: c globalsAsSet size equals: 3.
	#(a b c) do: [ :each | self assert: (c globalsAsSet includes: each) ]
]

{ #category : #test }
TrClassTest >> testInitialize [
	| c |
	c := self newClass.
	self assert: c variables isCollection.
	self assert: c variables isEmpty.
	self assert: c constants isCollection.
	self assert: c constants isEmpty.
	self assert: (c methods isKindOf: Dictionary).
	self assert: c methods isEmpty
]

{ #category : #test }
TrClassTest >> testMethodNamed [
	| c m |
	c := self newClass.
	self assert: (c methodNamed: #abs:) isNil.
	m := TrMethod new
		setupFrom: self fooBarAbs;
		yourself.
	c addMethod: m.
	self assert: (c methodNamed: #abs:) identicalTo: m
]

{ #category : #test }
TrClassTest >> testMethods [
	| c |
	c := self newClass.
	self assert: (c methods isKindOf: Dictionary).
	self assert: c methods isEmpty
]

{ #category : #test }
TrClassTest >> testName [
	| c |
	c := self newClass.
	self assert: c name isNil.
	c setupFrom: TrFooBar.
	self assert: c name equals: #TrFooBar
]

{ #category : #test }
TrClassTest >> testOriginalClass [
	| c |
	c := self newClass.
	self assert: c originalClass isNil.
	c originalClass: TrFooBar.
	self assert: c originalClass equals: TrFooBar
]

{ #category : #test }
TrClassTest >> testPrintOn [
	| c s m |
	c := self newClass.
	c setupFrom: TrFooBar.
	m := TrMethod new
		setupFrom: self fooBarAbs;
		yourself.
	c addMethod: m.
	s := WriteStream on: String new.
	c printOn: s.
	self assert: s contents equals: 'TrFooBar(1 methods)'
]

{ #category : #test }
TrClassTest >> testSetupFrom [
	| c |
	c := self newClass.
	c setupFrom: TrFooBar.
	self assert: c name equals: 'TrFooBar'.
	self assertCollection: c variables equals: #(counter) asOrderedCollection.
	self assert: c originalClass equals: TrFooBar
]

{ #category : #test }
TrClassTest >> testVariables [
	| c |
	c := self newClass.
	self assert: c variables isCollection.
	self assert: c variables isEmpty.
	c setupFrom: TrFooBar.
	self assertCollection: c variables equals: #(counter) asOrderedCollection
]

{ #category : #test }
TrClassTest >> testVariablesSetCache [
	| c |
	c := self newClass.
	self assert: c variablesSetCache isNil.
	c setupFrom: TrFooBar.
	c globalsAsSet.
	self assert: (c variablesSetCache isKindOf: Set).
	self assert: (c variablesSetCache includes: #counter)
]
