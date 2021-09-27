"
A MicroPythonBaseTest is a test class for testing the behavior of MicroPythonBase
"
Class {
	#name : #MicroPythonBaseTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #tests }
MicroPythonBaseTest >> testIsBase [
	self assert: MicroPythonBase isBase.
	self assert: ESP8266Base isBase.
	self assert: MicrobitBase isBase.
	self deny: M5AtomLite isBase.
	self deny: M5AtomMatrix isBase.
	self deny: MicroPythonSample isBase.
	self deny: MicrobitSample isBase
]
