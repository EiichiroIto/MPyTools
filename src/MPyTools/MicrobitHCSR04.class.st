"
This is a sample module for HC-SR04 ultra sonic sensor.
This will be saved as a module file on micro:bit.

Preparation:

MPyTool new
	useSerial;
	uploadClass: MicrobitHCSR04.

Usage:
	self from: #hcsr04 import: MicrobitHCSR04.
	h := MicrobitHCSR04 new initializeTrigger: pin1 echo: pin2.
	[ self print: h distance ] repeat.

"
Class {
	#name : #MicrobitHCSR04,
	#superclass : #MicrobitBase,
	#instVars : [
		'trigger',
		'echo'
	],
	#category : #'MPyTools-Samples'
}

{ #category : #accessing }
MicrobitHCSR04 class >> filename [
	^ 'hcsr04.py'
]

{ #category : #api }
MicrobitHCSR04 >> distance [
	| t |
	t := self usGetecho.
	^ (340.0 * t / 20000) asInteger
]

{ #category : #initialization }
MicrobitHCSR04 >> initializeTrigger: triggerPin echo: echoPin [
	trigger := triggerPin.
	echo := echoPin
]

{ #category : #private }
MicrobitHCSR04 >> usGetecho [
	| count t1 t2 |
	count := 0.
	trigger writeDigital: 1.
	trigger writeDigital: 0.
	[ echo readDigital = 0 ]
		whileTrue: [ time sleepUs: 1.
			count := count + 1.
			count > 1000
				ifTrue: [ ^ 0 ] ].
	t1 := time ticksUs.
	count := 0.
	[ echo readDigital > 0 ]
		whileTrue: [ time sleepUs: 1.
			count := count + 1.
			count > 1000
				ifTrue: [ ^ 0 ] ].
	t2 := time ticksUs.
	^ time ticks: t2 diff: t1
]
