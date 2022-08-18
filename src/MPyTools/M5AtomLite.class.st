Class {
	#name : #M5AtomLite,
	#superclass : #ESP8266Base,
	#classVars : [
		'BUTTON',
		'GPIO19',
		'GPIO21',
		'GPIO22',
		'GPIO23',
		'GPIO25',
		'GPIO26',
		'GPIO32',
		'GPIO33',
		'IR',
		'NEOPIXEL'
	],
	#category : #'MPyTools-Samples'
}

{ #category : #'class initialization' }
M5AtomLite class >> initialize [
	"self initialize"
	BUTTON := 39.
	NEOPIXEL := 27.
	GPIO19 := 19.
	GPIO21 := 21.
	GPIO22 := 22.
	GPIO23 := 23.
	GPIO25 := 25.
	GPIO26 := 26.
	GPIO32 := 32.
	GPIO33 := 33.
	IR := 12
]

{ #category : #samples }
M5AtomLite >> buttonTest1 [
	"(M5AtomLite >> #buttonTest1) asMicroPython inspect"

	| np button |
	self isFunction: true.
	button := Pin at: BUTTON mode: #IN.
	np := NeoPixel initPin: (Pin at: NEOPIXEL) count: 1.
	[ button value = 0
		ifTrue: [ np at: 0 put: #(255 255 255) ]
		ifFalse: [ np at: 0 put: #(0 0 0) ].
	np write.
	time sleepMs: 100 ] repeat
]

{ #category : #samples }
M5AtomLite >> buttonTest2 [
	"(M5AtomLite >> #buttonTest2) asMicroPython inspect"

	| np button |
	self isFunction: true.
	button := Pin at: BUTTON mode: #IN.
	np := NeoPixel initPin: (Pin at: NEOPIXEL) count: 1.
	[ np
		at: 0
		put:
			(button value = 0
				ifTrue: [ #(255 255 255) ]
				ifFalse: [ #(0 0 0) ]).
	np write.
	time sleepMs: 100 ] repeat
]

{ #category : #samples }
M5AtomLite >> gpioTest1 [
	"(M5AtomLite >> #gpioTest1) asMicroPython inspect"

	| np button |
	self isFunction: true.
	button := Pin at: GPIO22 mode: #IN.
	np := NeoPixel initPin: (Pin at: NEOPIXEL) count: 1.
	[ np
		at: 0
		put:
			(button value = 0
				ifTrue: [ #(0 0 0) ]
				ifFalse: [ #(255 255 255) ]).
	np write.
	time sleepMs: 100 ] repeat
]

{ #category : #samples }
M5AtomLite >> neopixelTest [
	"(M5AtomLite >> #neopixelTest1) asMicroPython inspect"

	| pin np |
	self isFunction: true.
	pin := Pin at: NEOPIXEL.
	np := NeoPixel initPin: pin count: 1.
	255 to: 0 by: -10 do: [ :each | 
		np at: 0 put: (Array new: 3 withAll: each).
		np write.
		time sleepMs: 50 ].
	np at: 0 put: #(0 0 0).
	np write
]

{ #category : #'top level' }
M5AtomLite >> start [
	self isTopLevel: true.
	self neopixelTest.
	"self buttonTest1"
	self gpioTest1
]
