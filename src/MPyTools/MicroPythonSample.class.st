Class {
	#name : #MicroPythonSample,
	#superclass : #ESP8266Base,
	#instVars : [
		'a'
	],
	#category : #'MPyTools-Samples'
}

{ #category : #examples }
MicroPythonSample class >> example1 [
	self asMicroPython inspect
]

{ #category : #samples }
MicroPythonSample >> cascadingIfTest1 [
	a := 1.
	a = 1
		ifTrue: [ self print: 1 ]
		ifFalse: [ a = 2
				ifTrue: [ self print: 2 ]
				ifFalse: [ a = 3
						ifTrue: [ self print: 3 ]
						ifFalse: [ self print: 4 ] ] ]
]

{ #category : #samples }
MicroPythonSample >> cascadingIfTest2 [
	a := 1.
	a = 1
		ifTrue: [ self print: 1 ]
		ifFalse: [ a = 2
				ifTrue: [ self print: 2 ]
				ifFalse: [ a = 3
						ifTrue: [ self print: 3 ]
						ifFalse: [ self print: 4 ].
					self print: 5 ] ]
]

{ #category : #samples }
MicroPythonSample >> conditionalIf [
	self isFunction: true.
	^ a == 2 ifTrue: [ 3 ] ifFalse: [ 4 ]
]

{ #category : #samples }
MicroPythonSample >> double: anInteger [
	self isFunction: true.
	^ anInteger * 2
]

{ #category : #samples }
MicroPythonSample >> error [
	self isFunction: true.
	[  ] repeat
]

{ #category : #samples }
MicroPythonSample >> error: aString [
	self isFunction: true.
	self print: aString.
	self error
]

{ #category : #samples }
MicroPythonSample >> gpioTest1 [
	| p0 v |
	p0 := Pin at: 0 mode: #OUT.
	p0 on.
	time sleepMs: 1000.
	p0 off.
	time sleepMs: 1000.
	v := 0.
	[ p0 value: v.
	time sleepMs: 1000.
	v := 1 - v ] repeat
]

{ #category : #initialization }
MicroPythonSample >> initialize [
	a := 123
]

{ #category : #initialization }
MicroPythonSample >> initialize: anInteger [
	a := anInteger
]

{ #category : #samples }
MicroPythonSample >> printTest [
	self print: self quotedString
]

{ #category : #samples }
MicroPythonSample >> quotedString [
	^ 'abc
d"ef'
]
