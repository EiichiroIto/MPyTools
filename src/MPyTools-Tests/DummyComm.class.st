Class {
	#name : #DummyComm,
	#superclass : #Object,
	#instVars : [
		'portName',
		'baudRate',
		'sends',
		'receives',
		'isConnected',
		'whenPutDo'
	],
	#category : #'MPyTools-Tests'
}

{ #category : #accessing }
DummyComm >> baudRate [
	^ baudRate
]

{ #category : #accessing }
DummyComm >> baudRate: anObject [
	baudRate := anObject
]

{ #category : #api }
DummyComm >> close [
	isConnected := false
]

{ #category : #api }
DummyComm >> get [
	sends isEmpty
		ifTrue: [ ^ nil ].
	^ sends removeFirst
]

{ #category : #initialization }
DummyComm >> initialize [
	isConnected := false.
	sends := OrderedCollection new.
	receives := OrderedCollection new
]

{ #category : #accessing }
DummyComm >> isConnected [
	^ isConnected
]

{ #category : #accessing }
DummyComm >> isConnected: anObject [
	isConnected := anObject
]

{ #category : #api }
DummyComm >> open [
	isConnected := true.
	^ true
]

{ #category : #accessing }
DummyComm >> options [
	^ #()
]

{ #category : #accessing }
DummyComm >> optionsNamed: aString [ 
	^ #()
]

{ #category : #accessing }
DummyComm >> portName [
	^ portName
]

{ #category : #accessing }
DummyComm >> portName: anObject [
	portName := anObject
]

{ #category : #api }
DummyComm >> put: aByteArray [
	receives add: aByteArray.
	whenPutDo ifNotNil: [ whenPutDo cull: aByteArray ]
]

{ #category : #accessing }
DummyComm >> receives [
	^ receives
]

{ #category : #accessing }
DummyComm >> receives: anObject [
	receives := anObject
]

{ #category : #accessing }
DummyComm >> sends [
	^ sends
]

{ #category : #accessing }
DummyComm >> sends: anObject [
	sends := anObject
]

{ #category : #accessing }
DummyComm >> setOption: aString to: aString2 [ 
	"do nothing"
]

{ #category : #accessing }
DummyComm >> whenPutDo [
	^ whenPutDo
]

{ #category : #accessing }
DummyComm >> whenPutDo: anObject [
	whenPutDo := anObject
]
