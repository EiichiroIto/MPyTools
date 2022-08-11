Class {
	#name : #AutoFeederNoMqtt,
	#superclass : #ESP8266Base,
	#instVars : [
		'button',
		'np',
		'sw',
		'i2c',
		'portion',
		'sub',
		'pub'
	],
	#classVars : [
		'BUTTON',
		'ESSID',
		'GPIO19',
		'GPIO21',
		'GPIO22',
		'GPIO23',
		'GPIO25',
		'GPIO26',
		'GPIO32',
		'GPIO33',
		'IR',
		'NEOPIXEL',
		'PASSWORD',
		'TZOFFSET'
	],
	#category : #'MPyTools-Samples'
}

{ #category : #'class initialization' }
AutoFeederNoMqtt class >> initialize [
	"self initialize"
	"ESSID := 'AIBONET2'."
	ESSID := 'itolab'.
	PASSWORD := '12345678'.
	TZOFFSET := 9 * 3600.
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

{ #category : #private }
AutoFeederNoMqtt >> clientId [
	^ ubinascii hexlify: machine uniqueId
]

{ #category : #networking }
AutoFeederNoMqtt >> connectWifi [
	| wlan |
	wlan := WLAN initWifi: #STA_IF.
	wlan active: true.
	wlan isConnected
		ifFalse: [ wlan connect: ESSID password: PASSWORD.
			[ wlan isConnected ] whileFalse: [ time sleepMs: 100 ] ].
	self print: wlan ifconfig
]

{ #category : #'error handling' }
AutoFeederNoMqtt >> error: aString [
	self print: 'Error:' , aString.
	[ self led: #(128 0 0).
	time sleepMs: 500.
	self led: #(0 0 0).
	time sleepMs: 500 ] repeat
]

{ #category : #private }
AutoFeederNoMqtt >> feedCount [
	| n hh mm tmp |
	portion > 0
		ifTrue: [ tmp := portion.
			portion := 0.
			^ tmp ].
	n := self now.
	hh := n fourth.
	mm := n fifth.
	(hh = 6 and: [ mm = 20 ])
		ifTrue: [ ^ 4 ].
	(hh = 12 and: [ mm = 0 ])
		ifTrue: [ ^ 2 ].
	(hh = 18 and: [ mm = 0 ])
		ifTrue: [ ^ 4 ].
	"(hh = 0 and: [ mm = 0 ])
		ifTrue: [ self mqttStatus: 'ntp settime'.
			ntptime settime ]."
	^ 0
]

{ #category : #api }
AutoFeederNoMqtt >> feedPortion: anInteger [
	self motorOn.
	[ self isFeedSwOn ] whileTrue: [ time sleepMs: 100 ].
	anInteger
		timesRepeat: [ [ self isFeedSwOn ] whileFalse: [ time sleepMs: 100 ].
			[ self isFeedSwOn ] whileTrue: [ time sleepMs: 100 ] ].
	self motorOff
]

{ #category : #initialization }
AutoFeederNoMqtt >> initialize [
	button := Pin at: BUTTON mode: #IN.
	sw := Pin at: GPIO22 mode: #IN.
	np := NeoPixel initPin: (Pin at: NEOPIXEL) count: 1.
	i2c := SoftI2C initScl: (Pin at: GPIO21) sda: (Pin at: GPIO25) freq: 100000.
	portion := 0
]

{ #category : #testing }
AutoFeederNoMqtt >> isButtonOn [
	button value = 0
		ifFalse: [ ^ false ].
	time sleepMs: 100.
	^ button value = 0
]

{ #category : #testing }
AutoFeederNoMqtt >> isFeedSwOn [
	sw value > 0
		ifFalse: [ ^ false ].
	time sleepMs: 100.
	^ sw value > 0
]

{ #category : #api }
AutoFeederNoMqtt >> led: anArray [
	np at: 0 put: anArray.
	np write
]

{ #category : #api }
AutoFeederNoMqtt >> main [
	| c |
	self feedPortion: 1.
	[ self led: #(0 0 0).
	c := self feedCount.
	c > 0
		ifTrue: [ self feedPortion: c.
			self led: #(128 128 0).
			time sleep: 60.
			portion := 0 ]
		ifFalse: [ self isButtonOn
				ifTrue: [ self led: #(0 0 128).
					self feedPortion: 1 ]
				ifFalse: [ time sleep: 5.
					self led: #(128 128 128).
					time sleepMs: 100 ] ] ] repeat
]

{ #category : #api }
AutoFeederNoMqtt >> motorOff [
	i2c write: #[0 0] to: 100
]

{ #category : #api }
AutoFeederNoMqtt >> motorOn [
	i2c write: #[0 253] to: 100
]

{ #category : #api }
AutoFeederNoMqtt >> now [
	^ time localtime: (time mktime: time localtime) + TZOFFSET
]

{ #category : #private }
AutoFeederNoMqtt >> opening [
	| rgb |
	20
		timesRepeat: [ rgb := {(random randrange: 256).
			(random randrange: 256).
			(random randrange: 256)}.
			self led: rgb.
			time sleepMs: 100 ].
	self led: #(0 0 0)
]

{ #category : #api }
AutoFeederNoMqtt >> setup [

	self led: #( 128 0 0 ).
	self connectWifi.
	ntptime settime.
	self led: #( 0 128 0 ).
	self led: #( 0 0 128 ).
	(i2c scan includes: 100) ifFalse: [ 
		self error: 'motor is not connected' ].
	self motorOff.
	time sleep: 1
]

{ #category : #'top level' }
AutoFeederNoMqtt >> start [
	| a |
	self isTopLevel: true.
	a := self class new.
	a opening.
	a setup.
	a main
]
