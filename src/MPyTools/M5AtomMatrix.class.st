Class {
	#name : #M5AtomMatrix,
	#superclass : #ESP8266Base,
	#classVars : [
		'BUTTON',
		'GPIO19',
		'GPIO22',
		'GPIO23',
		'GPIO26',
		'GPIO32',
		'GPIO33',
		'IR',
		'NEOPIXEL',
		'SCL',
		'SDA'
	],
	#category : #'MPyTools-Samples'
}

{ #category : #examples }
M5AtomMatrix class >> example1 [
	self asMicroPython inspect
]

{ #category : #'class initialization' }
M5AtomMatrix class >> initialize [
	"self initialize"
	BUTTON := 39.
	NEOPIXEL := 27.
	GPIO19 := 19.
	SCL := 21.
	GPIO22 := 22.
	GPIO23 := 23.
	SDA := 25.
	GPIO26 := 26.
	GPIO32 := 32.
	GPIO33 := 33.
	IR := 12
]

{ #category : #samples }
M5AtomMatrix >> buttonTest1 [
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
M5AtomMatrix >> buttonTest2 [
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
M5AtomMatrix >> i2cTest1 [
	| i2c |
	self isFunction: true.
	i2c := SoftI2C initScl: (Pin at: SCL) sda: (Pin at: SDA) freq: 100000.
	self print: i2c scan
]

{ #category : #samples }
M5AtomMatrix >> neopixelTest [
	"(M5AtomMatrix >> #neopixelTest2) asMicroPython inspect"

	| pin np |
	self isFunction: true.
	pin := Pin at: NEOPIXEL.
	np := NeoPixel initPin: pin count: 25.
	255 to: 0 by: -10 do: [ :each | 
		0 to: 24 do: [ :each2 | np at: each2 put: (Array new: 3 withAll: each) ].
		np write.
		time sleepMs: 50 ].
	0 to: 24 do: [ :each | np at: each put: #(0 0 0) ].
	np write
]

{ #category : #samples }
M5AtomMatrix >> start [
	"(M5AtomMatrix >> #neopixelTest2) asMicroPython inspect"

	self isTopLevel: true.
	self neopixelTest
]
