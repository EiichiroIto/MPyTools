Class {
	#name : #NativeSerial,
	#superclass : #Object,
	#instVars : [
		'port',
		'portName',
		'baudRate'
	],
	#category : #'MPyTools-Comm'
}

{ #category : #api }
NativeSerial class >> closeAll [
	self allInstancesDo: #close
]

{ #category : #private }
NativeSerial class >> inputFlowControlType [
	^ 0
]

{ #category : #private }
NativeSerial class >> outputFlowControlType [
	^ 0
]

{ #category : #accessing }
NativeSerial >> baudRate [
	^ baudRate
]

{ #category : #accessing }
NativeSerial >> baudRate: anInteger [
	baudRate := anInteger
]

{ #category : #api }
NativeSerial >> close [
	self isConnected
		ifFalse: [ ^ self ].
	port close.
	port := nil
]

{ #category : #api }
NativeSerial >> get [
	| ret |
	self isConnected
		ifFalse: [ ^ nil ].
	ret := port readByteArray.
	ret isEmpty
		ifTrue: [ ^ nil ].
	^ ret
]

{ #category : #testing }
NativeSerial >> isConnected [
	^ port notNil
]

{ #category : #testing }
NativeSerial >> isWebRepl [
	^ false
]

{ #category : #api }
NativeSerial >> open [
	self isConnected
		ifTrue: [ ^ true ].
	portName ifNil: [ ^ false ].
	port := SerialPort new.
	port
		baudRate: self baudRate;
		dataBits: 8;
		parityType: 0;
		outputFlowControlType: self class outputFlowControlType;
		inputFlowControlType: self class inputFlowControlType.
	[ port openPort: portName ]
		on: Error
		do: [ :err | 
			self inform: err asString.
			port := nil.
			^ false ].
	^ true
]

{ #category : #accessing }
NativeSerial >> options [
	^ #(portName baudRate)
]

{ #category : #accessing }
NativeSerial >> optionsNamed: aSymbol [
	aSymbol = #baudRate
		ifTrue: [ ^ #(2400 4800 9600 19200 38400 76800 115200) ].
	aSymbol = #portName
		ifTrue: [ ^ self portNames ].
	^ #()
]

{ #category : #private }
NativeSerial >> osxPortNames [
	^ self unixPortNames
]

{ #category : #accessing }
NativeSerial >> port [
	^ port
]

{ #category : #accessing }
NativeSerial >> portName [
	^ portName
]

{ #category : #accessing }
NativeSerial >> portName: aString [
	portName := aString
]

{ #category : #accessing }
NativeSerial >> portNames [
	Smalltalk os isUnix
		ifTrue: [ ^ self portNamesDo: [ self unixPortNames ] ].
	Smalltalk os isWin32
		ifTrue: [ ^ self portNamesDo: [ self win32PortNames ] ].
	Smalltalk os isMacOSX
		ifTrue: [ ^ self portNamesDo: [ self osxPortNames ] ].
	^ #()
]

{ #category : #private }
NativeSerial >> portNamesDo: aBlock [
	^ aBlock
		ifError:
			[ {(UIManager default request: 'Enter COM port (like COM3)')} ]
]

{ #category : #printing }
NativeSerial >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPut: $(.
	self isConnected
		ifTrue: [ aStream nextPut: $* ].
	aStream
		nextPutAll: self portName asString;
		nextPut: $,;
		nextPutAll: self baudRate asString;
		nextPut: $)
]

{ #category : #api }
NativeSerial >> put: aByteArray [
	self isConnected
		ifFalse: [ ^ 0 ].
	^ port nextPutAll: aByteArray
]

{ #category : #accessing }
NativeSerial >> setOption: aString to: anObject [
	aString = #portName
		ifTrue: [ ^ self portName: anObject asString ].
	aString = #baudRate
		ifTrue: [ ^ self baudRate: anObject asInteger ]
]

{ #category : #private }
NativeSerial >> unixPortNames [
	| dir list |
	dir := '/dev/' asFileReference.
	list := dir fileNames.
	list := list
				select: [:each | (each beginsWith: 'ttyUSB')
						or: [each beginsWith: 'ttyACM']].
	^ list collect: [:each | (dir / each) pathString ]
]

{ #category : #private }
NativeSerial >> win32PortNames [
	^ (1 to: 20) collect: [ :each | 'COM' , each asString ]
]
