"
A MicroPythonMethodPropertiesTest is a test class for testing the behavior of MicroPythonMethodProperties
"
Class {
	#name : #MicroPythonMethodTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
MicroPythonMethodTest >> newMethod [
	^ MicroPythonMethod new
]

{ #category : #private }
MicroPythonMethodTest >> newMethod: aCompiledMethod [
	^ MicroPythonMethod new
		setupFrom: (OpalCompiler new parse: aCompiledMethod sourceCode);
		setup;
		yourself
]

{ #category : #test }
MicroPythonMethodTest >> testInitialize [
	| p |
	p := self newMethod.
	self assert: p type equals: #method
]

{ #category : #test }
MicroPythonMethodTest >> testIsFunction [
	| p |
	p := self newMethod.
	self deny: p isFunction.
	p isFunction: true.
	self assert: p isFunction.
	p isFunction: false.
	self deny: p isFunction
]

{ #category : #test }
MicroPythonMethodTest >> testIsMethod [
	| p |
	p := self newMethod.
	self assert: p isMethod.
	p isTopLevel: true.
	self deny: p isMethod.
	p := self newMethod.
	self assert: p isMethod.
	p isFunction: true.
	self deny: p isMethod
]

{ #category : #test }
MicroPythonMethodTest >> testIsTopLevel [
	| p |
	p := self newMethod.
	self deny: p isTopLevel.
	p isTopLevel: true.
	self assert: p isTopLevel.
	p isTopLevel: false.
	self deny: p isTopLevel
]

{ #category : #test }
MicroPythonMethodTest >> testRenameVariablesUsing [
	self newMethod renameVariablesUsing: self
]

{ #category : #test }
MicroPythonMethodTest >> testSetupFrom [
	| m |
	m := self newMethod: MicroPythonSample >> #error.
	self assert: m isFunction.
	m := self newMethod: MicroPythonSample >> #gpioTest1.
	self deny: m isFunction
]

{ #category : #test }
MicroPythonMethodTest >> testType [
	| p |
	p := self newMethod.
	self assert: p type equals: #method.
	p type: #function.
	self assert: p type equals: #function
]
