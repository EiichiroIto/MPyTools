"
This is a sample module for Micro Maqueen.
This will be saved as a module file on micro:bit.

Preparation:

MPyTool new
	useSerial;
	uploadClass: MicrobitMaqueen;
	close.

Usage:

	self from: #maqueen import: MicrobitMaqueen.
	h := MicrobitMaqueen new.
	h motorLeft: 100.
	h motorRight: 100.
	time sleep: 3.
	h motorLeft: 0.
	h motorRight: 0
"
Class {
	#name : #MicroMaqueen,
	#superclass : #MicrobitBase,
	#instVars : [
		'usonic',
		'np'
	],
	#category : #'MPyTools-Samples'
}

{ #category : #accessing }
MicroMaqueen class >> filename [
	^ 'maqueen.py'
]

{ #category : #api }
MicroMaqueen >> distance [
	^ usonic distance
]

{ #category : #initialization }
MicroMaqueen >> initialize [
	i2c init.
	np := NeoPixel initPin: pin15 count: 4
]

{ #category : #testing }
MicroMaqueen >> isLineLeft [
	^ pin13 readDigital > 0
]

{ #category : #testing }
MicroMaqueen >> isLineRight [
	^ pin14 readDigital > 0
]

{ #category : #api }
MicroMaqueen >> ledLeft: anBoolean [
	pin8 writeDigital: (anBoolean ifTrue: [ 1 ] ifFalse: [ 0 ])
]

{ #category : #api }
MicroMaqueen >> ledRight: anBoolean [
	pin12 writeDigital: (anBoolean ifTrue: [ 1 ] ifFalse: [ 0 ])
]

{ #category : #api }
MicroMaqueen >> motorLeft: anInteger [
	i2c
		write:
			{0.
			(anInteger > 0
				ifTrue: [ 2 ]
				ifFalse: [ 1 ]).
			anInteger abs} asByteArray
		to: 16
]

{ #category : #api }
MicroMaqueen >> motorRight: anInteger [
	i2c
		write:
			{2.
			(anInteger > 0
				ifTrue: [ 2 ]
				ifFalse: [ 1 ]).
			anInteger abs} asByteArray
		to: 16
]

{ #category : #api }
MicroMaqueen >> neopixelAt: anInteger put: anArray [
	np at: anInteger put: anArray.
	np show
]

{ #category : #api }
MicroMaqueen >> playMusic: aString [
	music play: aString
]

{ #category : #api }
MicroMaqueen >> useUsonic [
	self from: #hcsr04 import: MicrobitHCSR04.
	usonic := MicrobitHCSR04 new initializeTrigger: pin1 echo: pin2
]
