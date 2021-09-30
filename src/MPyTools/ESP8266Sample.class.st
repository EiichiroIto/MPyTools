Class {
	#name : #ESP8266Sample,
	#superclass : #ESP8266Base,
	#instVars : [
		'value'
	],
	#classVars : [
		'ESSID',
		'PASSWORD',
		'TZOFFSET'
	],
	#category : #'MPyTools-Samples'
}

{ #category : #examples }
ESP8266Sample class >> example1 [
	self asMicroPython inspect
]

{ #category : #'class initialization' }
ESP8266Sample class >> initialize [
	"self initialize"
	ESSID := 'AIBONET2'.
	"ESSID := 'itolab'."
	PASSWORD := '12345678'.
	TZOFFSET := 9 * 3600
]

{ #category : #samples }
ESP8266Sample >> connectWifi [
	self connectWifi: ESSID password: PASSWORD
]

{ #category : #samples }
ESP8266Sample >> connectWifi: aString password: aString2 [
	| wlan |
	self isFunction: true.
	wlan := WLAN initWifi: #STA_IF.
	wlan active: true.
	wlan isConnected
		ifFalse: [ wlan connect: aString password: aString2.
			[ wlan isConnected ] whileFalse: [ time sleepMs: 100 ] ].
	self print: wlan ifconfig
]

{ #category : #samples }
ESP8266Sample >> error [
	self isFunction: true.
	[  ] repeat
]

{ #category : #samples }
ESP8266Sample >> error: aString [
	self isFunction: true.
	self print: aString.
	self error
]

{ #category : #initialization }
ESP8266Sample >> initialize [
	value := nil
]

{ #category : #samples }
ESP8266Sample >> motorTest1 [
	| i2c |
	i2c := SoftI2C initScl: (Pin at: 5) sda: (Pin at: 8) freq: 100000.
	(i2c scan includes: 100)
		ifFalse: [ self error: 'motor is not connected' ].
	i2c write: #[0 102] to: 100.
	time sleepMs: 1000.
	i2c write: #[0 100] to: 100
]

{ #category : #samples }
ESP8266Sample >> now [
	self isFunction: true.
	^ time localtime: (time mktime: time localtime) + TZOFFSET
]

{ #category : #samples }
ESP8266Sample >> ntpTest [
	| rtc |
	rtc := RTC new.
	self connectWifi.
	ntptime settime.
	self print: rtc datetime
]

{ #category : #samples }
ESP8266Sample >> rtcTest [
	| rtc |
	rtc := RTC new.
	rtc datetime: #(2021 9 15 20 33 45 0 0).
	self print: rtc datetime
]

{ #category : #samples }
ESP8266Sample >> stars [
	self print: 'start stars'.
	[ value
		ifNotNil: [ self print: '*' * value.
			value := nil ].
	time sleep: 5 ] repeat
]

{ #category : #samples }
ESP8266Sample >> startStars [
	_thread start: self stars with: #()
]

{ #category : #samples }
ESP8266Sample >> webServer [
	| s ret conn request m response |
	s := socket socket: #AF_INET stream: #SOCK_STREAM.
	s bind: #('' 80).
	s listen: 5.
	[ ret := s accept.
	conn := ret first.
	request := (conn recv: 1024) asString asLowercase.
	response := '?value=<integer>'.
	m := re search: 'value=(\d*)' from: request.
	m
		ifNotNil: [ value := (m group: 1) asInteger.
			response := 'Value=' , value asString ].
	conn send: response.
	conn close ] repeat
]
