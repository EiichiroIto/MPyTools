"
A MPyProxyTest is a test class for testing the behavior of MPyProxy
"
Class {
	#name : #MPyProxyTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
MPyProxyTest >> newComm [
	^ DummyComm new
]

{ #category : #private }
MPyProxyTest >> newProxy [
	^ MPyProxy new
]

{ #category : #test }
MPyProxyTest >> testAsString [
	| p r |
	p := self newProxy.
	r := p
		asString:
			{#[13].
			#[13].
			'abc' asByteArray.
			#[13].
			'def' asByteArray.
			'gh' asByteArray , #[13]}.
	self
		assertCollection: r
		equals: String cr , String cr , 'abc' , String cr , 'defgh' , String cr
]

{ #category : #test }
MPyProxyTest >> testAsStringWithoutCrs [
	| p r |
	p := self newProxy.
	r := p
		asStringWithoutCrs:
			{#[13].
			(#[13] , 'x' asByteArray).
			'abc' asByteArray.
			#[13].
			'def' asByteArray.
			('gh' asByteArray , #[13])}.
	self assertCollection: r equals: 'xabc' , String cr , 'defgh'
]

{ #category : #test }
MPyProxyTest >> testBreak [
	| p c |
	p := self newProxy.
	p timeout: 0.
	c := self newComm.
	c open.
	p comm: c.
	c whenPutDo: [ c sends add: '>>> ' asByteArray ].
	p break.
	self assert: c receives size equals: 1.
	self assertCollection: c receives first equals: #[3]
]

{ #category : #test }
MPyProxyTest >> testCheckEnterPasteMode [
	| p |
	p := self newProxy.
	p receiveQueue flush.
	self deny: p checkEnterPasteMode.
	p receiveQueue received: MPyProxy pasteStartResponse.
	self deny: p checkEnterPasteMode.
	p receiveQueue received: MPyProxy pastePrompt.
	self assert: p checkEnterPasteMode
]

{ #category : #test }
MPyProxyTest >> testCheckEnterRawMode [
	| p |
	p := self newProxy.
	p receiveQueue flush.
	self deny: p checkEnterRawMode.
	p receiveQueue received: MPyProxy rawResponse.
	self deny: p checkEnterRawMode.
	p receiveQueue received: MPyProxy rawPrompt.
	self assert: p checkEnterRawMode
]

{ #category : #test }
MPyProxyTest >> testCheckPasteSent [
	| p |
	p := self newProxy.
	p receiveQueue flush.
	self deny: (p checkPasteSent: #[1 2 3 13]).
	p receiveQueue received: #[1 2 3 13].
	self deny: (p checkPasteSent: #[1 2 3 13]).
	p receiveQueue received: MPyProxy pastePrompt.
	self assert: (p checkPasteSent: #[1 2 3 13]).
]

{ #category : #test }
MPyProxyTest >> testCheckPrompt [
	| p |
	p := self newProxy.
	p receiveQueue flush.
	self deny: p checkPrompt.
	p receiveQueue received: MPyProxy prompt.
	self assert: p checkPrompt
]

{ #category : #test }
MPyProxyTest >> testCheckRawPrompt [
	| p |
	p := self newProxy.
	p receiveQueue flush.
	self deny: p checkRawPrompt.
	p receiveQueue received: MPyProxy rawPrompt.
	self assert: p checkRawPrompt
]

{ #category : #test }
MPyProxyTest >> testCheckRawSent [
	| p |
	p := self newProxy.
	p receiveQueue flush.
	self deny: p checkRawSent.
	p receiveQueue received: MPyProxy rawSentResponse.
	self assert: p checkRawSent
]

{ #category : #test }
MPyProxyTest >> testClose [
	| p |
	p := self newProxy.
	p close.
	self deny: p isConnected
]

{ #category : #test }
MPyProxyTest >> testComm [
	| p c |
	p := self newProxy.
	self assert: p comm isNil.
	c := NativeSerial new.
	p comm: c.
	self assert: p comm identicalTo: c
]

{ #category : #test }
MPyProxyTest >> testCommOptionTo [
	| p |
	p := self newProxy.
	p comm: self newComm.
	p commOption: #portName to: 9600
]

{ #category : #test }
MPyProxyTest >> testCommOptions [
	| p |
	p := self newProxy.
	p comm: self newComm.
	self assert: p commOptions isArray.
	self assert: p commOptions identicalTo: p comm options
]

{ #category : #test }
MPyProxyTest >> testCommOptionsNamed [
	| p |
	p := self newProxy.
	p comm: self newComm.
	self assert: (p commOptionsNamed: #portName) isArray.
	self assert: (p commOptionsNamed: #baudRate) isEmpty
]

{ #category : #test }
MPyProxyTest >> testDefaultTimeout [
	| p |
	p := self newProxy.
	self assert: p defaultTimeout isInteger
]

{ #category : #test }
MPyProxyTest >> testEnterPasteMode [
	| p c |
	p := self newProxy.
	p timeout: 0.
	c := self newComm.
	c open.
	p comm: c.
	c
		whenPutDo: [ c sends
				add: 'paste mode; Ctrl-C to cancel, Ctrl-D to finish' asByteArray , #[13].
			c sends add: '=== ' asByteArray ].
	p enterPasteMode.
	self assert: c receives size equals: 1.
	self assertCollection: c receives first equals: #[5].
	self deny: p receiveQueue isEmpty
]

{ #category : #test }
MPyProxyTest >> testEnterRawMode [
	| p c |
	p := self newProxy.
	p timeout: 0.
	c := self newComm.
	c open.
	p comm: c.
	c
		whenPutDo: [ c sends
				add: 'raw REPL; CTRL-B to exit' asByteArray , #[13].
			c sends add: '>' asByteArray ].
	p enterRawMode.
	self assert: c receives size equals: 1.
	self assertCollection: c receives first equals: #[1].
	self deny: p receiveQueue isEmpty
]

{ #category : #test }
MPyProxyTest >> testExitPasteMode [
	| p c |
	p := self newProxy.
	p timeout: 0.
	c := self newComm.
	c open.
	p comm: c.
	c whenPutDo: [ c sends add: '>>> ' asByteArray ].
	p exitPasteMode.
	self assert: c receives size equals: 1.
	self assertCollection: c receives first equals: #[4].
	self deny: p receiveQueue isEmpty
]

{ #category : #test }
MPyProxyTest >> testExitPasteModeNonBlocking [
	| p c |
	p := self newProxy.
	p timeout: 0.
	c := self newComm.
	c open.
	p comm: c.
	c whenPutDo: [ c sends add: '>>> ' asByteArray ].
	p exitPasteModeNonBlocking.
	self assert: c receives size equals: 1.
	self assertCollection: c receives first equals: #[4].
	self assert: p receiveQueue isEmpty.
	p step.
	self deny: p receiveQueue isEmpty
]

{ #category : #test }
MPyProxyTest >> testExitRawMode [
	| p c |
	p := self newProxy.
	p timeout: 0.
	c := self newComm.
	c open.
	p comm: c.
	c whenPutDo: [ c sends add: '>>> ' asByteArray ].
	p exitRawMode.
	self assert: c receives size equals: 1.
	self assertCollection: c receives first equals: #[2].
	self deny: p receiveQueue isEmpty
]

{ #category : #test }
MPyProxyTest >> testFirstNotCrIndexOf [
	| p r |
	p := self newProxy.
	r := p
		firstNotCrIndexOf: String cr , String cr , 'abc' , String cr , 'defgh' , String cr.
	self assertCollection: r equals: 3.
	r := p firstNotCrIndexOf: 'abc'.
	self assertCollection: r equals: 1.
	r := p firstNotCrIndexOf: String cr.
	self assertCollection: r equals: 0
]

{ #category : #test }
MPyProxyTest >> testFlush [
	| p c |
	p := self newProxy.
	c := self newComm.
	c open.
	p comm: c.
	c sends add: #[1 2 3].
	p receiveQueue received: #[7 8 9 10 11 12 13 14 15].
	self deny: c sends isEmpty.
	self deny: p receiveQueue queue isEmpty.
	self deny: p receiveQueue pending isEmpty.
	p flush.
	self assert: c sends isEmpty.
	self assert: p receiveQueue queue isEmpty.
	self assert: p receiveQueue pending isEmpty
]

{ #category : #test }
MPyProxyTest >> testInitialize [
	| p |
	p := self newProxy.
	self assert: p comm isNil.
	self assert: (p receiveQueue isKindOf: ReceiveQueue).
	self assert: p timeout equals: p defaultTimeout
]

{ #category : #test }
MPyProxyTest >> testIsConnected [
	| p c |
	p := self newProxy.
	self deny: p isConnected.
	c := self newComm.
	p comm: c.
	self deny: p isConnected.
	c isConnected: true.
	self assert: p isConnected
]

{ #category : #test }
MPyProxyTest >> testLastNotCrIndexOf [
	| p r |
	p := self newProxy.
	r := p
		lastNotCrIndexOf: String cr , String cr , 'abc' , String cr , 'defgh' , String cr.
	self assertCollection: r equals: 11.
	r := p lastNotCrIndexOf: 'abc'.
	self assertCollection: r equals: 3.
	r := p lastNotCrIndexOf: String cr.
	self assertCollection: r equals: 0
]

{ #category : #test }
MPyProxyTest >> testOpen [
	| p c |
	p := self newProxy.
	c := self newComm.
	p comm: c.
	p receiveQueue received: #[1 2 3].
	self deny: p receiveQueue isEmpty.
	self deny: c isConnected.
	self assert: p open.
	self assert: p receiveQueue isEmpty.
	self assert: c isConnected	
]

{ #category : #test }
MPyProxyTest >> testPut [
	| p c |
	p := self newProxy.
	p put: #[1 2 3].
	c := self newComm.
	p comm: c.
	p put: #[1 2 3].
	self assert: c receives isEmpty.
	c isConnected: true.
	p put: #[1 2 3].
	self assert: c receives size equals: 1.
	self assertCollection: c receives first equals: #[1 2 3]
]

{ #category : #test }
MPyProxyTest >> testRawString [
	| p |
	p := self newProxy.
	p receiveQueue received: #[13].
	p receiveQueue received: 'abc' asByteArray , #[13].
	p receiveQueue received: 'def' asByteArray , #[13].
	p receiveQueue received: 'ghi' asByteArray , #[13].
	p receiveQueue received: #[13].
	self
		assert: p rawString
		equals: String cr , 'abc' , String cr , 'def' , String cr , 'ghi' , String cr , String cr
]

{ #category : #test }
MPyProxyTest >> testReboot [
	| p c |
	p := self newProxy.
	p timeout: 0.
	c := self newComm.
	c open.
	p comm: c.
	c whenPutDo: [ c sends add: '>>> ' asByteArray ].
	p reboot.
	self assert: c receives size equals: 1.
	self assertCollection: c receives first equals: #[4]
]

{ #category : #test }
MPyProxyTest >> testReceiveQueue [
	| p |
	p := self newProxy.
	self assert: (p receiveQueue isKindOf: ReceiveQueue)
]

{ #category : #test }
MPyProxyTest >> testResponseString [
	| p |
	p := self newProxy.
	p receiveQueue received: #[13].
	p receiveQueue received: 'abc' asByteArray , #[13].
	p receiveQueue received: 'def' asByteArray , #[13].
	p receiveQueue received: 'ghi' asByteArray , #[13].
	p receiveQueue received: #[13].
	self assert: p responseString equals: 'abc' , String cr , 'def' , String cr , 'ghi'
]

{ #category : #test }
MPyProxyTest >> testSendThenWaitUntil [
	| p c ret |
	p := self newProxy.
	p timeout: 0.
	c := self newComm.
	c open.
	p comm: c.
	self should: [ p send: #[1 2 3] thenWaitUntil: [ false ] ] raise: Error.
	self assert: c receives size equals: 1.
	self assertCollection: c receives first equals: #[1 2 3].
	c := self newComm.
	c open.
	p comm: c.
	c whenPutDo: [ c sends add: #[4 5 6] ].
	p send: #[1 2 3] thenWaitUntil: [ true ].
	self assert: c receives size equals: 1.
	self assertCollection: c receives first equals: #[1 2 3].
	ret := p receiveQueue getAll.
	self assert: ret size equals: 1.
	self assertCollection: ret first equals: #[4 5 6]
]

{ #category : #test }
MPyProxyTest >> testStep [
	| p c ret |
	p := self newProxy.
	p timeout: 0.
	c := self newComm.
	c open.
	p comm: c.
	p step.
	self assert: p receiveQueue getAll size equals: 0.
	c sends add: #[1 2 3].
	c sends add: #[4 5 6].
	p step.
	ret := p receiveQueue getAll.
	self assert: ret size equals: 1.
	self assertCollection: ret first equals: #[1 2 3 4 5 6]
]

{ #category : #test }
MPyProxyTest >> testTimeout [
	| p |
	p := self newProxy.
	self assert: p timeout equals: p defaultTimeout.
	p timeout: 123.
	self assert: p timeout equals: 123
]

{ #category : #test }
MPyProxyTest >> testTrimCrs [
	| p r |
	p := self newProxy.
	r := p
		trimCrs: String cr , String cr , 'abc' , String cr , 'defgh' , String cr.
	self assertCollection: r equals: 'abc' , String cr , 'defgh'
]
