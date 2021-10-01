"
This is a sample application using MicroPythonCoder.

M5Atom Lite controls a junk Pet's Auto Feeder when uploaded to the device.

Connection Schema.

M5AtomLite     Auto Feeder
  GPIO22         potion SW
  GPIO21         SCL (i2c motor driver)
  GPIO25         SDL (i2c motor driver)

To upload it.

   MPyTool new
      useSerial;
      upload: AutoFeeder asMicroPython fileNamed: 'main.py';
      reboot

"
Class {
	#name : #AutoFeeder,
	#superclass : #M5AtomLite,
	#instVars : [
		'button',
		'np',
		'sw',
		'i2c',
		'portion'
	],
	#classVars : [
		'ESSID',
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
	TZOFFSET := 9 * 3600
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

{ #category : #networking }
AutoFeeder >> defaultHtml [
	^ '<!DOCTYPE html><html><head><title>M5Atom Lite Auto Feeder</title></head>'
		, '<body><p><a href="?value=1">feed 1 portion</a></p>'
		, '<p><a href="?value=2">feed 2 portion</a></p></body></html>'
]

{ #category : #'error handling' }
AutoFeeder >> error: aString [
	self print: 'Error:' , aString.
	[ self led: #(128 0 0).
	time sleepMs: 500.
	self led: #(0 0 0).
	time sleepMs: 500 ] repeat
]

{ #category : #networking }
AutoFeeder >> executedHtml [
	^ '<!DOCTYPE html><html><head><title>M5Atom Lite Auto Feeder</title></head>'
		, '<body><p>manual feed ' , portion asString , ' portions' , '</p>'
		, '<p><a href="?">Home</a></p></body></html>'
]

{ #category : #private }
AutoFeeder >> feedCount [
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
	(hh = 0 and: [ mm = 0 ])
		ifTrue: [ ntptime settime ].
	^ 0
]

{ #category : #api }
AutoFeeder >> feedPortion: anInteger [
	self motorOn.
	[ self isFeedSwOn ] whileTrue: [ time sleepMs: 100 ].
	anInteger
		timesRepeat: [ [ self isFeedSwOn ] whileFalse: [ time sleepMs: 100 ].
			[ self isFeedSwOn ] whileTrue: [ time sleepMs: 100 ] ].
	self motorOff
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
	[ self led: #(0 0 0).
	c := self feedCount.
	c > 0
		ifTrue: [ self feedPortion: c.
			self led: #(128 128 0).
			time sleep: 60 ]
		ifFalse: [ self isButtonOn
				ifTrue: [ self led: #(0 0 128).
					self feedPortion: 1 ]
				ifFalse: [ time sleep: 5.
					self led: #(128 128 128).
					time sleepMs: 100 ] ] ] repeat
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
	(i2c scan includes: 100)
		ifFalse: [ self error: 'motor is not connected' ].
	self motorOff.
	self led: #(128 0 0).
	self connectWifi.
	ntptime settime.
	self led: #(0 0 128).
	time sleep: 1
]

{ #category : #'top level' }
AutoFeeder >> start [
	| a |
	self isTopLevel: true.
	a := self class new.
	a opening.
	a setup.
	_thread start: a main with: #().
	a webServer
]

{ #category : #networking }
AutoFeeder >> webServer [
	| s ret conn request m response |
	s := socket socket: #AF_INET stream: #SOCK_STREAM.
	s bind: #('' 80).
	s listen: 5.
	[ ret := s accept.
	conn := ret first.
	request := (conn recv: 1024) asString asLowercase.
	response := self defaultHtml.
	m := re search: 'value=(\d*)' from: request.
	m
		ifNotNil: [ portion := (m group: 1) asInteger.
			response := self executedHtml ].
	conn send: response.
	conn close ] repeat
]
