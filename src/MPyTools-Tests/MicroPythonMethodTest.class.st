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

{ #category : #private }
MicroPythonMethodTest >> newMethod: aCompiledMethod ofClass: aClass [
	^ (self newMethod: aClass >> aCompiledMethod)
		trClass: (MicroPythonClass new setupFrom: aClass);
		yourself
]

{ #category : #test }
MicroPythonMethodTest >> testBuildRenameVariableTableReserved [
	| m r |
	m := self newMethod: #connectWifi:password: ofClass: ESP8266Sample.
	r := m buildRenameVariableTableReserved: #(_thread esp machine ntptime os random re self socket super time value wdt).
	self assert: r isDictionary.
	self assert: r size equals: 3.
	self
		assertCollection: r keys asArray sorted
		equals: #(aString aString2 wlan).
	self assertCollection: r values asArray sorted equals: #(a b c)
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
