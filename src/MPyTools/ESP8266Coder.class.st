Class {
	#name : #ESP8266Coder,
	#superclass : #MicroPythonCoder,
	#category : #'MPyTools-MicroPython'
}

{ #category : #translation }
ESP8266Coder >> generateAt: msgNode on: aStream indent: level [
	| rcvr |
	rcvr := msgNode receiver.
	(rcvr isVariable and: [ rcvr name = 'Pin' ])
		ifTrue: [ aStream nextPutAll: 'Pin('.
			msgNode arguments first emitCode: self on: aStream indent: level.
			aStream nextPut: $).
			^ self ].
	super generateAt: msgNode on: aStream indent: level
]

{ #category : #translation }
ESP8266Coder >> generateAtMode: aNode on: aStream indent: anInteger [
	aStream nextPutAll: 'Pin('.
	aNode arguments first emitCode: self on: aStream indent: anInteger.
	aStream nextPutAll: ',Pin.'.
	aNode arguments second emitCode: self on: aStream indent: anInteger.
	aStream nextPut: $)
]

{ #category : #translation }
ESP8266Coder >> generateInitI2C: aNode on: aStream indent: anInteger [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: '(scl='.
	self emitExpression: aNode arguments first on: aStream.
	aStream nextPutAll: ',sda='.
	self emitExpression: aNode arguments second on: aStream.
	aStream nextPutAll: ',freq='.
	self emitExpression: aNode arguments third on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
ESP8266Coder >> generateInitUartBaudRateTxRx: aNode on: aStream indent: anInteger [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPut: $(.
	self emitExpression: aNode arguments first on: aStream.
	aStream nextPutAll: ',baudrate='.
	self emitExpression: aNode arguments second on: aStream.
	aStream nextPutAll: ',tx='.
	self emitExpression: aNode arguments third on: aStream.
	aStream nextPutAll: ',rx='.
	self emitExpression: aNode arguments fourth on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
ESP8266Coder >> generateInitWifi: aNode on: aStream indent: anInteger [
	| rcvr |
	rcvr := aNode receiver.
	(rcvr isVariable and: [ rcvr name = 'WLAN' ])
		ifFalse: [ self error ].
	aStream nextPutAll: 'network.WLAN(network.'.
	aNode arguments first emitCode: self on: aStream indent: anInteger.
	aStream nextPut: $)
]

{ #category : #translation }
ESP8266Coder >> generateReadFrom: aNode on: aStream indent: anInteger [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: '.readfrom('.
	self emitExpression: aNode arguments second on: aStream.
	aStream nextPut: $,.
	self emitExpression: aNode arguments first on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
ESP8266Coder >> generateSocketStream: aNode on: aStream indent: anInteger [
	| rcvr |
	rcvr := aNode receiver.
	(rcvr isVariable and: [ rcvr name = 'socket' ])
		ifFalse: [ self error ].
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: '.socket('.
	aNode arguments
		do: [ :each | 
			aStream nextPutAll: 'socket.'.
			self emitExpression: each on: aStream ]
		separatedBy: [ aStream nextPut: $, ].
	aStream nextPut: $)
]

{ #category : #translation }
ESP8266Coder >> generateStartWith: aNode on: aStream indent: anInteger [
	| rcvr |
	rcvr := aNode receiver.
	(rcvr isVariable and: [ rcvr name = '_thread' ])
		ifFalse: [ self error ].
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: '.start_new_thread('.
	self emitMessageHeader: aNode arguments first on: aStream indent: anInteger.
	aStream nextPut: $,.
	self emitExpression: aNode arguments last on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
ESP8266Coder >> generateWriteTo: aNode on: aStream indent: anInteger [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: '.writeto('.
	self emitExpression: aNode arguments second on: aStream.
	aStream nextPut: $,.
	self emitExpression: aNode arguments first on: aStream.
	aStream nextPut: $)
]

{ #category : #private }
ESP8266Coder >> simpleTranslationPair [
	^ super simpleTranslationPair
		,
			#(
		#connect:password: #connect
		#initMqtt:ipaddr: ''
		#isConnected #isconnected
		#publish:message: #publish
			)
]

{ #category : #private }
ESP8266Coder >> translationPair [
	^ super translationPair
		,
			#(
		#at: #generateAt:on:indent:
		#at:mode: #generateAtMode:on:indent:
		#initWifi: #generateInitWifi:on:indent:
		#socket:stream: #generateSocketStream:on:indent:
		#initScl:sda:freq: #generateInitI2C:on:indent:
		#write:to: #generateWriteTo:on:indent:
		#read:from: #generateReadFrom:on:indent:
		#start:with: #generateStartWith:on:indent:

			)
]
