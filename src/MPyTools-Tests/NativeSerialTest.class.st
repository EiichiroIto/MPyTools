"
A NativeSerialTest is a test class for testing the behavior of NativeSerial
"
Class {
	#name : #NativeSerialTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
NativeSerialTest >> newComm [
	^ NativeSerial new
]

{ #category : #test }
NativeSerialTest >> testBaudRate [
	| c |
	c := self newComm.
	self assert: c baudRate isNil.
	c baudRate: 9600.
	self assert: c baudRate equals: 9600.
	c baudRate: 115200.
	self assert: c baudRate equals: 115200
]

{ #category : #test }
NativeSerialTest >> testClose [
	| c |
	c := self newComm.
	c close.
	self assert: c port isNil
]

{ #category : #test }
NativeSerialTest >> testIsConnected [
	| c |
	c := self newComm.
	self deny: c isConnected
]

{ #category : #test }
NativeSerialTest >> testOptions [
	| c |
	c := self newComm.
	self assertCollection: c options equals: #(portName baudRate)
]

{ #category : #test }
NativeSerialTest >> testOptionsNamed [
	| c |
	c := self newComm.
	self assert: (c optionsNamed: #portName) isArray.
	self assert: (c optionsNamed: #portName) notEmpty.
	self assert: (c optionsNamed: #baudRate) isArray.
	self assert: (c optionsNamed: #baudRate) notEmpty.
	self assert: (c optionsNamed: #none) isArray.
	self assert: (c optionsNamed: #none) isEmpty
]

{ #category : #test }
NativeSerialTest >> testPort [
	| c |
	c := self newComm.
	self assert: c port isNil
]

{ #category : #test }
NativeSerialTest >> testPortName [
	| c |
	c := self newComm.
	self assert: c portName isNil.
	c portName: '/dev/ttyUSB0'.
	self assert: c portName equals: '/dev/ttyUSB0'.
	c portName: '/dev/ttyUSB1'.
	self assert: c portName equals: '/dev/ttyUSB1'
]

{ #category : #test }
NativeSerialTest >> testPortNames [
	| c |
	c := self newComm.
	self assert: c portNames isArray
]

{ #category : #test }
NativeSerialTest >> testPrintOn [
	| c s |
	c := self newComm.
	s := WriteStream on: String new.
	c printOn: s.
	self assert: s contents equals: 'NativeSerial(nil,nil)'.
	c portName: '/dev/ttyUSB0'.
	c baudRate: 9600.
	s := WriteStream on: String new.
	c printOn: s.
	self assert: s contents equals: 'NativeSerial(/dev/ttyUSB0,9600)'
]

{ #category : #test }
NativeSerialTest >> testSetOptionTo [
	| c |
	c := self newComm.
	self assert: c portName isNil.
	self assert: c baudRate isNil.
	c setOption: #portName to: '/dev/ttyUSB0'.
	c setOption: #baudRate to: 9600.
	self assert: c portName equals: '/dev/ttyUSB0'.
	self assert: c baudRate equals: 9600
]
