Class {
	#name : #AutoFeeder,
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
AutoFeeder class >> initialize [
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
AutoFeeder >> clientId [
	^ ubinascii hexlify: machine uniqueId
]

{ #category : #networking }
AutoFeeder >> connectWifi [
	| wlan |
	wlan := WLAN initWifi: #STA_IF.
	wlan active: true.
	wlan isConnected
		ifFalse: [ wlan connect: ESSID password: PASSWORD.
			[ wlan isConnected ] whileFalse: [ time sleepMs: 100 ] ].
	self print: wlan ifconfig
]

{ #category : #'error handling' }
AutoFeeder >> error: aString [
	self print: 'Error:' , aString.
	[ self led: #(128 0 0).
	time sleepMs: 500.
	self led: #(0 0 0).
	time sleepMs: 500 ] repeat
]

{ #category : #private }
AutoFeeder >> feedCount [

	| n hh mm tmp |
	portion > 0 ifTrue: [ 
		tmp := portion.
		portion := 0.
		^ tmp ].
	self isButtonOn ifTrue: [ ^ 1 ].
	n := self now.
	hh := n fourth.
	mm := n fifth.
	(hh = 6 and: [ mm = 20 ]) ifTrue: [ ^ 4 ].
	(hh = 12 and: [ mm = 0 ]) ifTrue: [ ^ 2 ].
	(hh = 18 and: [ mm = 0 ]) ifTrue: [ ^ 4 ].
	"(hh = 0 and: [ mm = 0 ])
		ifTrue: [ self mqttStatus: 'ntp settime'.
			ntptime settime ]."
	^ 0
]

{ #category : #api }
AutoFeeder >> feedPortion: anInteger [

	self print: self now.
	self print: 'feedPortion:' , anInteger asString.
	self motorOn.
	[ self isFeedSwOn ] whileTrue: [ time sleepMs: 100 ].
	anInteger timesRepeat: [ 
		self print: '***'.
		[ self isFeedSwOn ] whileFalse: [ time sleepMs: 100 ].
		[ self isFeedSwOn ] whileTrue: [ time sleepMs: 100 ] ].
	self motorOff.
	self print: 'feed done'
]

{ #category : #initialization }
AutoFeeder >> initialize [
	button := Pin at: BUTTON mode: #IN.
	sw := Pin at: GPIO22 mode: #IN.
	np := NeoPixel initPin: (Pin at: NEOPIXEL) count: 1.
	i2c := SoftI2C initScl: (Pin at: GPIO21) sda: (Pin at: GPIO25) freq: 100000.
	portion := 0
]

{ #category : #testing }
AutoFeeder >> isButtonOn [
	button value = 0
		ifFalse: [ ^ false ].
	time sleepMs: 100.
	^ button value = 0
]

{ #category : #testing }
AutoFeeder >> isFeedSwOn [
	sw value > 0
		ifFalse: [ ^ false ].
	time sleepMs: 100.
	^ sw value > 0
]

{ #category : #api }
AutoFeeder >> led: anArray [
	np at: 0 put: anArray.
	np write
]

{ #category : #api }
AutoFeeder >> main [

	| c |
	self feedPortion: 1.
	[ 
	self led: #( 0 0 0 ).
	c := self feedCount.
	c > 0
		ifTrue: [ 
			self led: #( 0 0 128 ).
			self feedPortion: c.
			self led: #( 128 128 0 ).
			time sleep: 60 ]
		ifFalse: [ 
			time sleep: 5.
			self led: #( 128 128 128 ).
			time sleepMs: 100 ] ] repeat
]

{ #category : #api }
AutoFeeder >> motorOff [
	i2c write: #[0 0] to: 100
]

{ #category : #api }
AutoFeeder >> motorOn [
	i2c write: #[0 253] to: 100
]

{ #category : #api }
AutoFeeder >> now [
	^ time localtime: (time mktime: time localtime) + TZOFFSET
]

{ #category : #private }
AutoFeeder >> opening [
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
AutoFeeder >> setup [

	self led: #( 128 0 0 ).
	self connectWifi.
	self led: #( 0 128 0 ).
	ntptime settime.
	time sleep: 1.
	self led: #( 0 0 128 ).
	(i2c scan includes: 100) ifFalse: [ 
		self error: 'motor is not connected' ].
	self motorOff.
	self print: 'Setup done'.
	time sleep: 1
]

{ #category : #'top level' }
AutoFeeder >> start [
	| a |
	self isTopLevel: true.
	self print: 'Starting ...'.
	a := self class new.
	a opening.
	a setup.
	a main
]
