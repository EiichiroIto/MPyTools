"
This is abstract base class for ESP8266/ESP32 devices.
This class defines ESP8266/ESP32 related modules and available methods.
Subclasses should be applications for ESP8266/ESP32 devices.

All the methods defined in this classes are dummy.

Instance Variables
	_thread:		<Object>
	esp:		<Object>
	machine:		<Object>
	ntptime:		<Object>
	os:		<Object>
	random:		<Object>
	socket:		<Object>
	time:		<Object>
	wdt:		<Object>


    Implementation Points
"
Class {
	#name : #ESP8266Base,
	#superclass : #MicroPythonBase,
	#instVars : [
		'machine',
		'esp',
		'time',
		'os',
		'wdt',
		'ntptime',
		'random',
		'socket',
		'_thread'
	],
	#classVars : [
		'ADC',
		'MQTTClient',
		'NeoPixel',
		'PWM',
		'Pin',
		'RTC',
		'SoftI2C',
		'SoftSPI',
		'UART',
		'WLAN'
	],
	#category : #'MPyTools-MicroPython'
}

{ #category : #accessing }
ESP8266Base class >> coderClass [
	^ ESP8266Coder
]

{ #category : #utilities }
ESP8266Base class >> recordModuleNamed: aString into: aModules [
	(#('ADC' 'SoftI2C' 'Pin' 'RTC' 'PWM' 'SoftSPI' 'UART')
		includes: aString)
		ifTrue: [ ^ aModules from: 'machine' import: aString ].
	aString = 'MQTTClient'
		ifTrue: [ ^ aModules from: 'umqtt.robust' import: aString ].
	aString = 'WLAN'
		ifTrue: [ ^ aModules import: 'network' ].
	aString = 'NeoPixel'
		ifTrue: [ ^ aModules from: 'neopixel' import: aString ].
	super recordModuleNamed: aString into: aModules
]

{ #category : #accessing }
ESP8266Base >> at: anInteger mode: aSymbol [
	self shouldBeImplemented
]

{ #category : #networking }
ESP8266Base >> bind: anArray [
	self shouldBeImplemented
]

{ #category : #mqtt }
ESP8266Base >> checkMsg [
	self shouldBeImplemented
]

{ #category : #mqtt }
ESP8266Base >> connect [
	self shouldBeImplemented
]

{ #category : #networking }
ESP8266Base >> connect: aString password: aString2 [
	self shouldBeImplemented
]

{ #category : #accessing }
ESP8266Base >> datetime [
	self shouldBeImplemented
]

{ #category : #accessing }
ESP8266Base >> datetime: anArray [
	self shouldBeImplemented
]

{ #category : #mqtt }
ESP8266Base >> disconnect [
	self shouldBeImplemented
]

{ #category : #networking }
ESP8266Base >> ifconfig [
	self shouldBeImplemented
]

{ #category : #mqtt }
ESP8266Base >> initMqtt: aString ipaddr: aString2 [
	self shouldBeImplemented
]

{ #category : #neopixel }
ESP8266Base >> initPin: aPin count: anInteger [
	self shouldBeImplemented
]

{ #category : #i2c }
ESP8266Base >> initScl: aPin sda: aPin2 freq: anInteger [
	self shouldBeImplemented
]

{ #category : #uart }
ESP8266Base >> initUart: anInteger baudRate: anInteger2 tx: anInteger3 rx: anInteger4 [
	self shouldBeImplemented
]

{ #category : #networking }
ESP8266Base >> initWifi: aSymbol [
	self shouldBeImplemented
]

{ #category : #networking }
ESP8266Base >> listen: anInteger [
	self shouldBeImplemented
]

{ #category : #mqtt }
ESP8266Base >> publish: aString msg: aString2 [
	self shouldBeImplemented
]

{ #category : #i2c }
ESP8266Base >> read: anInteger from: anInteger2 [
	self shouldBeImplemented
]

{ #category : #networking }
ESP8266Base >> recv: anInteger [
	self shouldBeImplemented
]

{ #category : #networking }
ESP8266Base >> send: aString [
	self shouldBeImplemented
]

{ #category : #mqtt }
ESP8266Base >> setCallback: aSymbol [
	self shouldBeImplemented
]

{ #category : #accessing }
ESP8266Base >> settime [
	self shouldBeImplemented
]

{ #category : #networking }
ESP8266Base >> socket: aSymbol stream: aSymbol2 [
	self shouldBeImplemented
]

{ #category : #misc }
ESP8266Base >> start: anObject with: anArray [
	self shouldBeImplemented
]

{ #category : #mqtt }
ESP8266Base >> subscribe: aString [
	self shouldBeImplemented
]

{ #category : #mqtt }
ESP8266Base >> waitMsg [
	self shouldBeImplemented
]

{ #category : #i2c }
ESP8266Base >> write: aByteArray to: anInteger [
	self shouldBeImplemented
]
