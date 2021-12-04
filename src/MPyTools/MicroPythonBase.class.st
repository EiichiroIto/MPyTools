"
This is abstract base class for MicroPython application.
This class defines MicroPython modules and available methods.
Subclasses should be applications or device specific abstract classes.

All the methods defined in this classes are dummy.

Instance Variables
	re:		It represents a regular expression module

"
Class {
	#name : #MicroPythonBase,
	#superclass : #Object,
	#instVars : [
		're'
	],
	#category : #'MPyTools-MicroPython'
}

{ #category : #converting }
MicroPythonBase class >> asMicroPython [
	^ self coderClass new
		addClass: self;
		codeString
]

{ #category : #accessing }
MicroPythonBase class >> base [
	self isBase
		ifTrue: [ ^ self ].
	^ superclass base
]

{ #category : #accessing }
MicroPythonBase class >> coderClass [
	^ MicroPythonCoder
]

{ #category : #examples }
MicroPythonBase class >> example [
	"M5AtomLite example"

	| t |
	t := MPyTool new.
	t showProgress: true.
	t useSerial.
	t execute: self asMicroPython.
	t close
]

{ #category : #accessing }
MicroPythonBase class >> filename [
	^ 'main.py'
]

{ #category : #testing }
MicroPythonBase class >> isBase [
	^ self name endsWith: 'Base'
]

{ #category : #utilities }
MicroPythonBase class >> recordModuleNamed: aString into: aModules [
	| s |
	s := aString asSymbol.
	(self allInstVarNames includes: s)
		ifFalse: [ ^ self ].
	aModules import: s
]

{ #category : #misc }
MicroPythonBase >> asFunctionName [
	self shouldBeImplemented
]

{ #category : #misc }
MicroPythonBase >> from: aSymbol import: aClass [
	self shouldBeImplemented
]

{ #category : #misc }
MicroPythonBase >> group: anInteger [
	self shouldBeImplemented
]

{ #category : #accessing }
MicroPythonBase >> isFunction: aBoolean [
	self shouldBeImplemented
]

{ #category : #accessing }
MicroPythonBase >> isTopLevel: aBoolean [
	self shouldBeImplemented
]

{ #category : #time }
MicroPythonBase >> localtime [
	self shouldBeImplemented
]

{ #category : #time }
MicroPythonBase >> localtime: anObject [
	self shouldBeImplemented
]

{ #category : #time }
MicroPythonBase >> mktime: anObject [
	self shouldBeImplemented
]

{ #category : #misc }
MicroPythonBase >> print: anObject [
	self shouldBeImplemented
]

{ #category : #accessing }
MicroPythonBase >> randrange: anInteger [
	self shouldBeImplemented
]

{ #category : #misc }
MicroPythonBase >> search: aString from: aString2 [
	self shouldBeImplemented
]

{ #category : #time }
MicroPythonBase >> sleep: anInteger [
	self shouldBeImplemented
]

{ #category : #time }
MicroPythonBase >> sleepMs: anInteger [
	self shouldBeImplemented
]

{ #category : #time }
MicroPythonBase >> sleepUs: anInteger [
	self shouldBeImplemented
]

{ #category : #time }
MicroPythonBase >> ticks: anInteger diff: anInteger2 [
	self shouldBeImplemented
]

{ #category : #time }
MicroPythonBase >> ticksMs [
	self shouldBeImplemented
]

{ #category : #time }
MicroPythonBase >> ticksUs [
	self shouldBeImplemented
]

{ #category : #misc }
MicroPythonBase >> unpack [
	self shouldBeImplemented
]
