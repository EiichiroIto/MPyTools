"
An ESP8266CoderTest is a test class for testing the behavior of ESP8266Coder
"
Class {
	#name : #ESP8266CoderTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
ESP8266CoderTest >> newCoder [
	^ ESP8266Coder new
]

{ #category : #test }
ESP8266CoderTest >> testEmitBuiltinConstructForOnIndent [
	| c n1 n2 n3 n4 s r |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'wlan'.
	n2 := TrConstantNode new value: 'ESSID'.
	n3 := TrConstantNode new value: 'PASSWORD'.
	n4 := TrSendNode new
		receiver: n1;
		selector: #connect:password:;
		arguments:
			{n2.
			n3}.
	c := self newCoder.
	r := c emitBuiltinConstructFor: n4 on: s indent: 0.
	self assert: r.
	self assert: s contents equals: 'wlan.connect("ESSID","PASSWORD")'.
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'MQTTClient'.
	n2 := TrConstantNode new value: 'test'.
	n3 := TrConstantNode new value: '192.168.254.123'.
	n4 := TrSendNode new
		receiver: n1;
		selector: #initMqtt:ipaddr:;
		arguments:
			{n2.
			n3}.
	c := self newCoder.
	r := c emitBuiltinConstructFor: n4 on: s indent: 0.
	self assert: r.
	self
		assert: s contents
		equals: 'MQTTClient("test","192.168.254.123")'.
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'wlan'.
	n2 := TrSendNode new
		receiver: n1;
		selector: #isConnected;
		arguments: {}.
	c := self newCoder.
	r := c emitBuiltinConstructFor: n2 on: s indent: 0.
	self assert: r.
	self assert: s contents equals: 'wlan.isconnected()'.
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'client'.
	n2 := TrConstantNode new value: 'test'.
	n3 := TrConstantNode new value: 'message'.
	n4 := TrSendNode new
		receiver: n1;
		selector: #publish:msg:;
		arguments:
			{n2.
			n3}.
	c := self newCoder.
	r := c emitBuiltinConstructFor: n4 on: s indent: 0.
	self assert: r.
	self assert: s contents equals: 'client.publish("test","message")'
]

{ #category : #test }
ESP8266CoderTest >> testGenerateAtModeOnIndent [
	| c n1 n2 n3 n4 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'Pin'.
	n2 := TrConstantNode new value: 5.
	n3 := TrConstantNode new value: #IN.
	n4 := TrSendNode new
		receiver: n1;
		arguments:
			{n2.
			n3}.
	c := self newCoder.
	c generateAtMode: n4 on: s indent: 0.
	self assert: s contents equals: 'Pin(5,Pin.IN)'
]

{ #category : #test }
ESP8266CoderTest >> testGenerateAtOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'Pin'.
	n2 := TrConstantNode new value: 5.
	n3 := TrSendNode new
		receiver: n1;
		arguments:
			{n2}.
	c := self newCoder.
	c generateAt: n3 on: s indent: 0.
	self assert: s contents equals: 'Pin(5)'.
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrConstantNode new value: 5.
	n3 := TrSendNode new
		receiver: n1;
		arguments:
			{n2}.
	c := self newCoder.
	c generateAt: n3 on: s indent: 0.
	self assert: s contents equals: 'x[5]'
]

{ #category : #test }
ESP8266CoderTest >> testGenerateInitI2COnIndent [
	| c n1 n2 n3 n4 n5 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'I2C'.
	n2 := TrConstantNode new value: 10.
	n3 := TrConstantNode new value: 20.
	n4 := TrConstantNode new value: 10000.
	n5 := TrSendNode new
		receiver: n1;
		arguments:
			{n2.
			n3.
			n4}.
	c := self newCoder.
	c generateInitI2C: n5 on: s indent: 0.
	self assert: s contents equals: 'I2C(scl=10,sda=20,freq=10000)'
]

{ #category : #test }
ESP8266CoderTest >> testGenerateInitUartBaudRateTxRxOnIndent [
	| c n1 n2 n3 n4 n5 n6 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'UART'.
	n2 := TrConstantNode new value: 1.
	n3 := TrConstantNode new value: 9600.
	n4 := TrConstantNode new value: 33.
	n5 := TrConstantNode new value: 32.
	n6 := TrSendNode new
		receiver: n1;
		arguments:
			{n2.
			n3.
			n4.
			n5}.
	c := self newCoder.
	c generateInitUartBaudRateTxRx: n6 on: s indent: 0.
	self assert: s contents equals: 'UART(1,baudrate=9600,tx=33,rx=32)'
]

{ #category : #test }
ESP8266CoderTest >> testGenerateInitWifiOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'WLAN'.
	n2 := TrConstantNode new value: #STA_IF.
	n3 := TrSendNode new
		receiver: n1;
		arguments:
			{n2}.
	c := self newCoder.
	c generateInitWifi: n3 on: s indent: 0.
	self assert: s contents equals: 'network.WLAN(network.STA_IF)'
]

{ #category : #test }
ESP8266CoderTest >> testGenerateReadFromOnIndent [
	| c n1 n2 n3 n4 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'i2c'.
	n2 := TrConstantNode new value: 20.
	n3 := TrConstantNode new value: 100.
	n4 := TrSendNode new
		receiver: n1;
		arguments:
			{n2.
			n3}.
	c := self newCoder.
	c generateReadFrom: n4 on: s indent: 0.
	self assert: s contents equals: 'i2c.readfrom(100,20)'
]

{ #category : #test }
ESP8266CoderTest >> testGenerateSocketStreamOnIndent [
	| c n1 n2 n3 n4 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'socket'.
	n2 := TrConstantNode new value: #AF_INET.
	n3 := TrConstantNode new value: #SOCK_STREAM.
	n4 := TrSendNode new
		receiver: n1;
		arguments:
			{n2.
			n3}.
	c := self newCoder.
	c generateSocketStream: n4 on: s indent: 0.
	self assert: s contents equals: 'socket.socket(socket.AF_INET,socket.SOCK_STREAM)'
]

{ #category : #test }
ESP8266CoderTest >> testGenerateStartWithOnIndent [
	| c n1 n2 n3 n4 n5 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: '_thread'.
	n2 := TrVariableNode new name: 'self'.
	n3 := TrSendNode new
		receiver: n2;
		selector: #now;
		arguments: {}.
	n4 := TrArrayNode new
		contents: #();
		isByteArray: false.
	n5 := TrSendNode new
		receiver: n1;
		arguments:
			{n3.
			n4}.
	c := self newCoder.
	c privAddClass: ESP8266Sample.
	c targetClass: ESP8266Sample.
	c generateStartWith: n5 on: s indent: 0.
	self assert: s contents equals: '_thread.start_new_thread(now,())'
]

{ #category : #test }
ESP8266CoderTest >> testGenerateWriteToOnIndent [
	| c n1 n2 n3 n4 n5 n6 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'i2c'.
	n2 := TrConstantNode new value: 1.
	n3 := TrConstantNode new value: 2.
	n4 := TrArrayNode new
		contents:
			{n2.
			n3};
		isByteArray: true.
	n5 := TrConstantNode new value: 100.
	n6 := TrSendNode new
		receiver: n1;
		arguments:
			{n4.
			n5}.
	c := self newCoder.
	c generateWriteTo: n6 on: s indent: 0.
	self assert: s contents equals: 'i2c.writeto(100,bytes([1,2]))'
]

{ #category : #test }
ESP8266CoderTest >> testSimpleTranslationPair [
	| c p |
	c := self newCoder.
	p := c simpleTranslationPair.
	self assert: p isArray.
	self assert: p size \\ 2 equals: 0
]

{ #category : #test }
ESP8266CoderTest >> testTranslationPair [
	| c |
	c := self newCoder.
	self assert: c translationPair isCollection.
	self assert: c translationPair notEmpty
]
