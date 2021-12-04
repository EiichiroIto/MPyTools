"
A TrMethodTest is a test class for testing the behavior of TrMethod
"
Class {
	#name : #TrMethodTest,
	#superclass : #TestCase,
	#category : #'Tradukisto-Tests-Core'
}

{ #category : #private }
TrMethodTest >> fooBarAbs [
	^ OpalCompiler new parse: (TrFooBar>>#abs:) sourceCode
]

{ #category : #private }
TrMethodTest >> fooBarAssertEven [
	^ OpalCompiler new parse: (TrFooBar>>#assertEven) sourceCode
]

{ #category : #private }
TrMethodTest >> fooBarCount [
	^ OpalCompiler new parse: (TrFooBar>>#counter) sourceCode
]

{ #category : #private }
TrMethodTest >> fooBarInitialize [
	^ OpalCompiler new parse: (TrFooBar>>#initialize) sourceCode
]

{ #category : #private }
TrMethodTest >> fooBarPartialReturn [
	^ OpalCompiler new parse: (TrFooBar>>#partialReturn:) sourceCode
]

{ #category : #private }
TrMethodTest >> fooBarPlusAnd [
	^ OpalCompiler new parse: (TrFooBar>>#plus:and:) sourceCode
]

{ #category : #private }
TrMethodTest >> fooBarSelfReturn [
	^ OpalCompiler new parse: (TrFooBar>>#selfReturn) sourceCode
]

{ #category : #private }
TrMethodTest >> fooBarSum [
	^ OpalCompiler new parse: (TrFooBar>>#sum) sourceCode
]

{ #category : #private }
TrMethodTest >> newClass [
	^ TrClass new
]

{ #category : #private }
TrMethodTest >> newMethod [
	^ TrMethod new
]

{ #category : #test }
TrMethodTest >> testAllCalls [
	| m |
	m := self newMethod.
	m setupFrom: self fooBarCount.
	self assertCollection: m allCalls asSortedCollection asArray equals: #(+).
	m := self newMethod.
	m setupFrom: self fooBarSum.
	self assertCollection: m allCalls asSortedCollection asArray equals: #(+ to:do:)
]

{ #category : #test }
TrMethodTest >> testArguments [
	| m a |
	m := self newMethod.
	self assert: m arguments isNil.
	a := #(1 2 3).
	m arguments: a.
	self assert: m arguments identicalTo: a
]

{ #category : #test }
TrMethodTest >> testBody [
	| m |
	m := self newMethod.
	self assert: m body isNil.
	m body: 123.
	self assert: m body equals: 123
]

{ #category : #test }
TrMethodTest >> testComplete [
	| m |
	m := self newMethod.
	self deny: m complete.
	m complete: true.
	self assert: m complete.
	m complete: false.
	self deny: m complete
]

{ #category : #test }
TrMethodTest >> testEndsWithReturn [
	| m |
	m := self newMethod.
	m setupFrom: self fooBarCount.
	m setup.
	self assert: m endsWithReturn.
	m := self newMethod.
	m setupFrom: self fooBarSum.
	m setup.
	self assert: m endsWithReturn.
	m := self newMethod.
	m setupFrom: self fooBarInitialize.
	m setup.
	self deny: m endsWithReturn.
	m := self newMethod.
	m setupFrom: self fooBarSelfReturn.
	m setup.
	self deny: m endsWithReturn
]

{ #category : #test }
TrMethodTest >> testHasReturn [
	| m |
	m := self newMethod.
	m setupFrom: self fooBarCount.
	self assert: m hasReturn.
	m := self newMethod.
	m setupFrom: self fooBarAbs.
	self assert: m hasReturn.
	m := self newMethod.
	m setupFrom: self fooBarPartialReturn.
	self assert: m hasReturn.
	m := self newMethod.
	m setupFrom: self fooBarInitialize.
	self deny: m hasReturn
]

{ #category : #test }
TrMethodTest >> testIsAssertion [
	| m |
	m := self newMethod.
	m setupFrom: self fooBarAssertEven.
	self assert: m isAssertion.
	m := self newMethod.
	m setupFrom: self fooBarCount.
	self deny: m isAssertion.
	m := self newMethod.
	m setupFrom: self fooBarAbs.
	self deny: m isAssertion
]

{ #category : #test }
TrMethodTest >> testIsFunctional [
	| m |
	m := self newMethod.
	m setupFrom: self fooBarCount.
	self assert: m isFunctional.
	m := self newMethod.
	m setupFrom: self fooBarPlusAnd.
	self assert: m isFunctional.
	m := self newMethod.
	m setupFrom: self fooBarAbs.
	self deny: m isFunctional.
	m := self newMethod.
	m setupFrom: self fooBarPartialReturn.
	self deny: m isFunctional.
	m := self newMethod.
	m setupFrom: self fooBarInitialize.
	self deny: m isFunctional
]

{ #category : #test }
TrMethodTest >> testIsMethod [
	| m |
	m := self newMethod.
	self assert: m isMethod
]

{ #category : #test }
TrMethodTest >> testLocals [
	| m a |
	m := self newMethod.
	self assert: m locals isNil.
	a := #(a b c).
	m locals: a.
	self assert: m locals identicalTo: a
]

{ #category : #test }
TrMethodTest >> testName [
	| m |
	m := self newMethod.
	m selector: #abc.
	self assert: m name equals: #abc.
	m selector: #abc:def:.
	self assert: m name equals: #abcdef
]

{ #category : #test }
TrMethodTest >> testPossibleSideEffectsCache [
	| m |
	m := self newMethod.
	self assert: m possibleSideEffectsCache isNil
]

{ #category : #test }
TrMethodTest >> testPrintOn [
	| m s |
	m := self newMethod.
	m selector: #abc.
	s := WriteStream on: String new.
	m printOn: s.
	self assert: s contents equals: 'TrMethod(abc)'
]

{ #category : #test }
TrMethodTest >> testRemoveFinalSelfReturn [
	| m |
	m := self newMethod.
	m body: self fooBarSelfReturn body asTranslatorNode.
	self assert: m body statements size equals: 3.
	m removeFinalSelfReturn.
	self assert: m body statements size equals: 2.
	m := self newMethod.
	m body: self fooBarCount body asTranslatorNode.
	self assert: m body statements size equals: 1.
	m removeFinalSelfReturn.
	self assert: m body statements size equals: 1
]

{ #category : #test }
TrMethodTest >> testSelector [
	| m |
	m := self newMethod.
	self assert: m selector isNil.
	m selector: #abc.
	self assert: m selector equals: #abc.
	m selector: #abc:def:.
	self assert: m selector equals: #abc:def:
]

{ #category : #test }
TrMethodTest >> testSetupFrom [
	| m |
	m := self newMethod.
	m setupFrom: self fooBarCount.
	self assert: m selector equals: #counter.
	self assert: m arguments isEmpty.
	self assert: m locals isEmpty.
	self assert: m body isStatementList
]

{ #category : #test }
TrMethodTest >> testTrClass [
	| m c |
	m := self newMethod.
	self assert: m trClass isNil.
	c := self newClass.
	m trClass: c.
	self assert: m trClass identicalTo: c
]
