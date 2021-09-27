Class {
	#name : #MPyProxy,
	#superclass : #Object,
	#instVars : [
		'comm',
		'receiveQueue',
		'timeout'
	],
	#category : #'MPyTools-Comm'
}

{ #category : #constants }
MPyProxy class >> breakRequest [
	^ #[3]
]

{ #category : #constants }
MPyProxy class >> crRequest [
	^ #[13]
]

{ #category : #constants }
MPyProxy class >> crResponse [
	^ #[13]
]

{ #category : #examples }
MPyProxy class >> example1 [
	| p |
	p := self new.
	p
		comm: NativeSerial new;
		commOption: #portName to: '/dev/ttyUSB0';
		commOption: #baudRate to: 115200.
	p open
		ifFalse: [ self error ].
	[ p
		paste: 'def test(a,b):' , String crlf , String tab , 'return a*b'.
	self inform: (p raw: 'print(test(2,3))').
	self inform: (p oneLiner: 'test(20,30)') ]
		ensure: [ p close ]
]

{ #category : #constants }
MPyProxy class >> pastePrompt [
	^ '=== ' asByteArray
]

{ #category : #constants }
MPyProxy class >> pasteRequest [
	^ #[5]
]

{ #category : #constants }
MPyProxy class >> pasteStartResponse [
	^ ('paste mode; Ctrl-C to cancel, Ctrl-D to finish' , String cr) asByteArray
]

{ #category : #constants }
MPyProxy class >> prompt [
	^ '>>> ' asByteArray
]

{ #category : #constants }
MPyProxy class >> quitPasteRequest [
	^ #[4]
]

{ #category : #constants }
MPyProxy class >> quitRawRequest [
	^ #[2]
]

{ #category : #constants }
MPyProxy class >> rawNextPrompt [
	^ #[4 4 62]
]

{ #category : #constants }
MPyProxy class >> rawPrompt [
	^ #[62]
]

{ #category : #constants }
MPyProxy class >> rawRequest [
	^ #[1]
]

{ #category : #constants }
MPyProxy class >> rawResponse [
	^ ('raw REPL; CTRL-B to exit' , String cr) asByteArray
]

{ #category : #constants }
MPyProxy class >> rawSent [
	^ #[4]
]

{ #category : #constants }
MPyProxy class >> rawSentResponse [
	^ 'OK' asByteArray
]

{ #category : #constants }
MPyProxy class >> rebootRequest [
	^ #[4]
]

{ #category : #utilities }
MPyProxy >> asString: aCollection [
	| s |
	s := WriteStream on: String new.
	aCollection do: [ :each | s nextPutAll: each asString ].
	^ s contents
]

{ #category : #utilities }
MPyProxy >> asStringWithoutCrs: aCollection [
	^ self trimCrs: (self asString: aCollection)
]

{ #category : #api }
MPyProxy >> break [
	| ret |
	self
		send: self class breakRequest
		thenWaitUntil: [ self checkPrompt ].
	ret := receiveQueue getAll.
	ret removeLast.
	^ self asStringWithoutCrs: ret
]

{ #category : #testing }
MPyProxy >> checkEnterPasteMode [
	| msg |
	msg := receiveQueue allReceived.
	msg := msg reject: [ :each | each = #[13] ].
	msg size >= 2
		ifFalse: [ ^ false ].
	(msg at: msg size - 1) = self class pasteStartResponse
		ifFalse: [ ^ false ].
	msg last = self class pastePrompt
		ifFalse: [ ^ false ].
	^ true
]

{ #category : #testing }
MPyProxy >> checkEnterRawMode [
	| msg |
	msg := receiveQueue allReceived.
	msg size >= 2
		ifFalse: [ ^ false ].
	(msg at: msg size - 1) = self class rawResponse
		ifFalse: [ ^ false ].
	msg last = self class rawPrompt
		ifFalse: [ ^ false ].
	^ true
]

{ #category : #testing }
MPyProxy >> checkPasteSent: aByteArray [
	| msg |
	msg := receiveQueue allReceived.
	msg size >= 2
		ifFalse: [ ^ false ].
	msg first = aByteArray
		ifFalse: [ ^ false ].
	msg last = self class pastePrompt
		ifFalse: [ ^ false ].
	^ true
]

{ #category : #testing }
MPyProxy >> checkPrompt [
	| msg |
	msg := receiveQueue allReceived.
	msg isEmpty
		ifTrue: [ ^ false ].
	msg last = self class prompt
		ifFalse: [ ^ false ].
	^ true
]

{ #category : #testing }
MPyProxy >> checkRawPrompt [
	| msg |
	msg := receiveQueue allReceived.
	msg notEmpty
		ifFalse: [ ^ false ].
	(msg last endsWith: self class rawNextPrompt)
		ifFalse: [ ^ false ].
	^ true
]

{ #category : #testing }
MPyProxy >> checkRawSent [
	| msg |
	msg := receiveQueue allReceived.
	msg notEmpty
		ifFalse: [ ^ false ].
	(msg first beginsWith: self class rawSentResponse)
		ifFalse: [ ^ false ].
	^ true
]

{ #category : #api }
MPyProxy >> close [
	comm ifNil: [ ^ self ].
	comm close
]

{ #category : #accessing }
MPyProxy >> comm [
	^ comm
]

{ #category : #accessing }
MPyProxy >> comm: aComm [
	comm := aComm
]

{ #category : #api }
MPyProxy >> commOption: aString to: anObject [
	comm ifNil: [ ^ self ].
	comm setOption: aString to: anObject
]

{ #category : #api }
MPyProxy >> commOptions [
	comm ifNil: [ ^ #() ].
	^ comm options
]

{ #category : #api }
MPyProxy >> commOptionsNamed: aSymbol [
	comm ifNil: [ ^ #() ].
	^ comm optionsNamed: aSymbol
]

{ #category : #private }
MPyProxy >> defaultTimeout [
	^ 1000
]

{ #category : #private }
MPyProxy >> enterPasteMode [
	self
		send: self class pasteRequest
		thenWaitUntil: [ self checkEnterPasteMode ]
]

{ #category : #private }
MPyProxy >> enterRawMode [
	self
		send: self class rawRequest
		thenWaitUntil: [ self checkEnterRawMode ]
]

{ #category : #private }
MPyProxy >> exitPasteMode [
	self
		send: self class quitPasteRequest
		thenWaitUntil: [ self checkPrompt ]
]

{ #category : #private }
MPyProxy >> exitPasteModeNonBlocking [
	self put: self class quitPasteRequest
]

{ #category : #private }
MPyProxy >> exitRawMode [
	self
		send: self class quitRawRequest
		thenWaitUntil: [ self checkPrompt ]
]

{ #category : #utilities }
MPyProxy >> firstNotCrIndexOf: aString [
	aString
		withIndexDo: [ :each :index | 
			each = Character cr
				ifFalse: [ ^ index ] ].
	^ 0
]

{ #category : #api }
MPyProxy >> flush [
	receiveQueue flush.
	comm ifNotNil: [ [ comm get notNil ] whileTrue ]
]

{ #category : #initialization }
MPyProxy >> initialize [
	receiveQueue := ReceiveQueue new.
	timeout := self defaultTimeout
]

{ #category : #testing }
MPyProxy >> isConnected [
	comm ifNil: [ ^ false ].
	^ comm isConnected
]

{ #category : #utilities }
MPyProxy >> lastNotCrIndexOf: aString [
	aString
		reverseWithIndexDo: [ :each :index | 
			each = Character cr
				ifFalse: [ ^ index ] ].
	^ 0
]

{ #category : #api }
MPyProxy >> nonBlock: aString [
	^ self nonBlock: aString during: [ :x |  ]
]

{ #category : #api }
MPyProxy >> nonBlock: aString during: aBlock [
	| count total |
	aBlock cull: 0.
	self enterPasteMode.
	receiveQueue flush.
	count := 0.
	total := aString lines size.
	aString
		linesDo: [ :each | 
			aBlock cull: count * 98 // total + 1.
			count := count + 1.
			self pasteLine: each.
			receiveQueue flush ].
	aBlock cull: 100.
	self exitPasteModeNonBlocking
]

{ #category : #api }
MPyProxy >> oneLiner: aString [
	| ret |
	self flush.
	self
		send: aString asByteArray , self class crRequest
		thenWaitUntil: [ self checkPrompt ].
	ret := receiveQueue getAll.
	ret removeFirst.
	ret removeLast.
	^ self asStringWithoutCrs: ret
]

{ #category : #api }
MPyProxy >> open [
	| ret |
	ret := comm open.
	ret ifFalse: [ ^ false ].
	self flush.
	^ true
]

{ #category : #api }
MPyProxy >> paste: aString [
	^ self paste: aString during: [ :x |  ]
]

{ #category : #api }
MPyProxy >> paste: aString during: aBlock [
	| count total ret |
	aBlock cull: 0.
	self enterPasteMode.
	receiveQueue flush.
	count := 0.
	total := aString lines size.
	aString
		linesDo: [ :each | 
			aBlock cull: count * 98 // total + 1.
			count := count + 1.
			self pasteLine: each.
			receiveQueue flush ].
	aBlock cull: 100.
	self exitPasteMode.
	ret := receiveQueue getAll.
	ret removeLast.
	^ self asStringWithoutCrs: ret
]

{ #category : #private }
MPyProxy >> pasteLine: aString [
	self
		send: aString asByteArray , self class crRequest
		thenWaitUntil: [ self checkPasteSent: aString asByteArray , self class crResponse ]
]

{ #category : #printing }
MPyProxy >> printOn: aStream [
	aStream nextPutAll: 'MPy('.
	self isConnected
		ifTrue: [ aStream nextPutAll: 'connected, ' ].
	aStream
		nextPutAll: receiveQueue lineCount asString;
		nextPutAll: ' lines)'
]

{ #category : #private }
MPyProxy >> put: aByteArray [
	self isConnected ifFalse: [ ^ self ].
	comm put: aByteArray asByteArray
]

{ #category : #api }
MPyProxy >> raw: aString [
	^ self raw: aString during: [ :x |  ]
]

{ #category : #api }
MPyProxy >> raw: aString during: aBlock [
	| s count total |
	aBlock cull: 0.
	self enterRawMode.
	receiveQueue flush.
	s := WriteStream on: String new.
	count := 0.
	total := aString lines size.
	aString
		linesDo: [ :each | 
			aBlock cull: count * 98 // total + 1.
			count := count + 1.
			s nextPutAll: (self rawLine: each) ].
	aBlock cull: 100.
	self exitRawMode.
	receiveQueue flush.
	^ s contents
]

{ #category : #private }
MPyProxy >> rawLine: aString [
	| ret s |
	self
		send: aString , self class rawSent
		thenWaitUntil: [ self checkRawSent and: [ self checkRawPrompt ] ].
	ret := receiveQueue getAll.
	ret at: 1 put: (ret first copyFrom: 3 to: ret first size).
	ret at: ret size put: (ret last copyFrom: 1 to: ret last size - 1).
	ret
		withIndexDo: [ :each :index | ret at: index put: (each copyWithout: 4) ].
	s := WriteStream on: String new.
	ret do: [ :each | s nextPutAll: each asString ].
	^ s contents
]

{ #category : #api }
MPyProxy >> rawString [
	^ self asString: receiveQueue getAll
]

{ #category : #api }
MPyProxy >> reboot [
	self put: self class rebootRequest
]

{ #category : #accessing }
MPyProxy >> receiveQueue [
	^ receiveQueue
]

{ #category : #api }
MPyProxy >> responseString [
	^ self asStringWithoutCrs: receiveQueue getAll
]

{ #category : #private }
MPyProxy >> send: aByteArray thenWaitUntil: aBlock [
	| until |
	self put: aByteArray.
	until := Time millisecondClockValue + timeout.
	[ Time millisecondClockValue > until
		ifTrue: [ ^ self error: 'timeout' ].
	self step.
	aBlock value ] whileFalse
]

{ #category : #private }
MPyProxy >> step [
	| msg |
	[ msg := comm get.
		msg notNil ]
			whileTrue: [ receiveQueue received: msg ]
]

{ #category : #accessing }
MPyProxy >> timeout [
	^ timeout
]

{ #category : #accessing }
MPyProxy >> timeout: anObject [
	timeout := anObject
]

{ #category : #utilities }
MPyProxy >> trimCrs: aString [
	| from to |
	from := self firstNotCrIndexOf: aString.
	from = 0
		ifTrue: [ ^ '' ].
	to := self lastNotCrIndexOf: aString.
	^ aString copyFrom: from to: to
]
