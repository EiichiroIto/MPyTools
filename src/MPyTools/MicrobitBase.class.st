"
This is abstract base class for micro:bit devices.
This class defines micro:bit related modules and available methods.
Subclasses should be applications for micro:bit.

All the methods defined in this classes are dummy.

Instance Variables
	accelerometer:		<Object>
	audio:		<Object>
	button_a:		<Object>
	button_b:		<Object>
	compass:		<Object>
	display:		<Object>
	i2c:		<Object>
	microbit:		<Object>
	pin0:		<Object>
	pin1:		<Object>
	pin10:		<Object>
	pin11:		<Object>
	pin12:		<Object>
	pin13:		<Object>
	pin14:		<Object>
	pin15:		<Object>
	pin16:		<Object>
	pin19:		<Object>
	pin2:		<Object>
	pin20:		<Object>
	pin3:		<Object>
	pin4:		<Object>
	pin5:		<Object>
	pin6:		<Object>
	pin7:		<Object>
	pin8:		<Object>
	pin9:		<Object>
	radio:		<Object>
	time:		<Object>
	uart:		<Object>


    Implementation Points
"
Class {
	#name : #MicrobitBase,
	#superclass : #MicroPythonBase,
	#instVars : [
		'microbit',
		'audio',
		'button_a',
		'button_b',
		'display',
		'pin0',
		'pin1',
		'pin2',
		'pin3',
		'pin4',
		'pin5',
		'pin6',
		'pin7',
		'pin8',
		'pin9',
		'pin10',
		'pin11',
		'pin12',
		'pin13',
		'pin14',
		'pin15',
		'pin16',
		'pin19',
		'pin20',
		'accelerometer',
		'compass',
		'i2c',
		'uart',
		'radio',
		'time',
		'music'
	],
	#classVars : [
		'Image',
		'NeoPixel'
	],
	#category : #'MPyTools-MicroPython'
}

{ #category : #accessing }
MicrobitBase class >> coderClass [
	^ MicrobitCoder
]

{ #category : #utilities }
MicrobitBase class >> recordModuleNamed: aString into: aModules [
	(#('button_a' 'button_b' 'display' 'pin0' 'pin1' 'pin2' 'pin3' 'pin4' 'pin5' 'pin6' 'pin7' 'pin8' 'pin9' 'pin10' 'pin11' 'pin12' 'pin13' 'pin14' 'pin15' 'pin16' 'pin19' 'pin20' 'accelerometer' 'compass' 'i2c' 'uart' 'Image')
		includes: aString)
		ifTrue: [ ^ aModules from: 'microbit' import: aString ].
	aString = 'NeoPixel'
		ifTrue: [ ^ aModules from: 'neopixel' import: aString ].
	super recordModuleNamed: aString into: aModules
]

{ #category : #compass }
MicrobitBase >> calibrate [
	self shouldBeImplemented
]

{ #category : #display }
MicrobitBase >> clear [
	self shouldBeImplemented
]

{ #category : #compass }
MicrobitBase >> clearCalibration [
	self shouldBeImplemented
]

{ #category : #accelerometer }
MicrobitBase >> currentGesture [
	self shouldBeImplemented
]

{ #category : #compass }
MicrobitBase >> getFieldStrength [
	self shouldBeImplemented
]

{ #category : #accelerometer }
MicrobitBase >> getGestures [
	self shouldBeImplemented
]

{ #category : #display }
MicrobitBase >> getPixelX: anInteger y: anInteger2 [
	self shouldBeImplemented
]

{ #category : #button }
MicrobitBase >> getPresses [
	self shouldBeImplemented
]

{ #category : #accelerometer }
MicrobitBase >> getValues [
	self shouldBeImplemented
]

{ #category : #accelerometer }
MicrobitBase >> getX [
	self shouldBeImplemented
]

{ #category : #accelerometer }
MicrobitBase >> getY [
	self shouldBeImplemented
]

{ #category : #accelerometer }
MicrobitBase >> getZ [
	self shouldBeImplemented
]

{ #category : #compass }
MicrobitBase >> heading [
	self shouldBeImplemented
]

{ #category : #neopixel }
MicrobitBase >> initPin: aPin count: anInteger [
	self shouldBeImplemented
]

{ #category : #compass }
MicrobitBase >> isCalibrated [
	self shouldBeImplemented
]

{ #category : #accelerometer }
MicrobitBase >> isGesture: aSymbol [
	self shouldBeImplemented
]

{ #category : #display }
MicrobitBase >> isOn [
	self shouldBeImplemented
]

{ #category : #button }
MicrobitBase >> isPressed [
	self shouldBeImplemented
]

{ #category : #display }
MicrobitBase >> off [
	self shouldBeImplemented
]

{ #category : #display }
MicrobitBase >> on [
	self shouldBeImplemented
]

{ #category : #gpio }
MicrobitBase >> readDigital [
	self shouldBeImplemented
]

{ #category : #display }
MicrobitBase >> scroll: aString [
	self shouldBeImplemented
]

{ #category : #display }
MicrobitBase >> setPixelX: anInteger y: anInteger2 to: anInteger3 [
	self shouldBeImplemented
]

{ #category : #display }
MicrobitBase >> show: aString [
	self shouldBeImplemented
]

{ #category : #accelerometer }
MicrobitBase >> wasGesture: aString [
	self shouldBeImplemented
]

{ #category : #button }
MicrobitBase >> wasPressed [
	self shouldBeImplemented
]

{ #category : #gpio }
MicrobitBase >> writeDigital: anInteger [
	self shouldBeImplemented
]
