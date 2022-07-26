Class {
	#name : #MicrobitSample,
	#superclass : #MicrobitBase,
	#category : #'MPyTools-Samples'
}

{ #category : #samples }
MicrobitSample >> buttonTest1 [
	self isFunction: true.
	microbit sleep: 10000.
	display scroll: (button_a getPresses) asString
]

{ #category : #samples }
MicrobitSample >> buttonTest2 [
	self isFunction: true.
	[ button_a isPressed
		ifTrue: [ display show: (Image at: #HAPPY) ]
		ifFalse: [ button_b isPressed
				ifTrue: [ #break ]
				ifFalse: [ display show: (Image at: #SAD) ] ] ] repeat.
	display clear
]

{ #category : #samples }
MicrobitSample >> compassTest [
	| needle |
	self isFunction: true.
	compass calibrate.
	[ time sleepMs: 100.
	needle := ((15 - compass heading) // 30 \\ 12) asInteger.
	display show: ((Image at: #ALL_CLOCKS) at: needle) ] repeat
]

{ #category : #samples }
MicrobitSample >> extModuleTest1 [
	| h |
	self isFunction: true.
	self from: #hcsr04 import: MicrobitHCSR04.
	h := MicrobitHCSR04 new initializeTrigger: pin1 echo: pin2.
	[ self print: h distance ] repeat
]

{ #category : #samples }
MicrobitSample >> hello [
	self isTopLevel: true.
	display scroll: 'Hello!!'.
	display show: (Image at: #HAPPY).
	time sleep: 1.
	self buttonTest2
]
