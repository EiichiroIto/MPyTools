Class {
	#name : #MPyTool,
	#superclass : #Object,
	#instVars : [
		'proxy',
		'showProgress',
		'closeConnection'
	],
	#category : #'MPyTools-Core'
}

{ #category : #private }
MPyTool >> autoClose [

	closeConnection ifTrue: [ self close ]
]

{ #category : #private }
MPyTool >> autoConnectIfFail: aBlock [

	proxy isReady ifTrue: [ ^ self ]. 
	self connectIfFail: aBlock.
	proxy break.
	proxy waitPromptIfError: aBlock
]

{ #category : #api }
MPyTool >> break [

	proxy isIdle ifTrue: [ ^ self ].
	proxy isNotConnected ifTrue: [ 
		proxy open ifFalse: [ 
			self error: 'cannot open:' localized , proxy comm portName ] ].
	proxy break.
	proxy waitPromptIfError: [ :text | self error: text ]
]

{ #category : #api }
MPyTool >> chdir: aString [

	| cmd |
	cmd := 'import os' , String cr
		,
			((aString isNil or: [ aString isEmpty ])
				ifTrue: [ 'os.chdir("/")' ]
				ifFalse: [ 'os.chdir("' , aString , '")' ]).
	self execute: cmd
]

{ #category : #api }
MPyTool >> close [

	proxy close
]

{ #category : #accessing }
MPyTool >> closeConnection [

	^ closeConnection
]

{ #category : #accessing }
MPyTool >> closeConnection: anObject [

	closeConnection := anObject
]

{ #category : #private }
MPyTool >> connectIfFail: aBlock [

	proxy isIdle ifTrue: [ ^ aBlock cull: 'Port not yet specified' localized ].
	proxy isNotConnected ifTrue: [ 
		proxy open ifFalse: [ 
			^ aBlock cull: 'cannot open:' localized , proxy comm portName ] ]
]

{ #category : #private }
MPyTool >> defaultBaudRate [

	^ 115200
]

{ #category : #api }
MPyTool >> downloadFileNamed: aString [

	"MPyTool new downloadFileNamed: 'boot.py'."

	| ret |
	self autoConnectIfFail: [ :text | self error: text ].
	ret := proxy
		       downloadFileNamed: aString
		       ifError: [ :text | self error: text ].
	^ MicroPythonParser new parse: ret
]

{ #category : #api }
MPyTool >> evaluate: aString [

	| ret |
	self autoConnectIfFail: [ :text | self error: text ].
	proxy flush.
	ret := proxy
		       evaluate: aString lines
		       ifError: [ :text | self error: text ].
	self autoClose.
	^ MicroPythonParser new parse: ret
]

{ #category : #api }
MPyTool >> execute: aString [

	self autoConnectIfFail: [ :msg | self error: msg ].
	proxy flush.
	proxy execute: aString lines.
	proxy waitCompleteSendIfError: [ :msg | self error: msg ].
	self autoClose
]

{ #category : #api }
MPyTool >> fileNames [

	^ self evaluate: 'import os
os.listdir()'
]

{ #category : #initialization }
MPyTool >> initialize [

	proxy := MicroPythonProxy new.
	showProgress := false.
	closeConnection := true
]

{ #category : #testing }
MPyTool >> isConnected [

	^ proxy isConnected
]

{ #category : #private }
MPyTool >> newSerial [

	^ SerialComm new
]

{ #category : #printing }
MPyTool >> printOn: aStream [

	aStream
		nextPutAll: self class name;
		nextPut: $(.
	proxy printOn: aStream.
	showProgress ifTrue: [ aStream nextPutAll: ',showProgress' ].
	closeConnection ifTrue: [ aStream nextPutAll: ',closeConnection' ].
	aStream nextPut: $)
]

{ #category : #accessing }
MPyTool >> proxy [

	^ proxy
]

{ #category : #accessing }
MPyTool >> proxy: anObject [

	proxy := anObject
]

{ #category : #api }
MPyTool >> reboot [

	self autoConnectIfFail: [ :msg | self error: msg ].
	proxy restart
]

{ #category : #api }
MPyTool >> removeAll [

	| files |
	self autoConnectIfFail: [ :text | self error: text ].
	files := self fileNames.
	files isEmpty ifTrue: [ ^ self ].
	self autoConnectIfFail: [ :text | self error: text ].
	files do: [ :each | 
		proxy deleteFileNamed: each.
		proxy waitPromptIfError: [ :msg | self error: msg ] ].

	self autoClose
]

{ #category : #api }
MPyTool >> removeFileNamed: aString [

	self autoConnectIfFail: [ :text | self error: text ].
	proxy deleteFileNamed: aString.
	proxy waitPromptIfError: [ :msg | self error: msg ].
	self autoClose
]

{ #category : #api }
MPyTool >> responseString [

	(proxy isConnected or: [ proxy open ])
		ifFalse: [ self error ].
	proxy step.
	^ proxy responseString
]

{ #category : #accessing }
MPyTool >> showProgress [

	^ showProgress
]

{ #category : #accessing }
MPyTool >> showProgress: anObject [

	showProgress := anObject
]

{ #category : #accessing }
MPyTool >> timeout [

	^ proxy timeout
]

{ #category : #accessing }
MPyTool >> timeout: anInteger [

	proxy timeout: anInteger
]

{ #category : #api }
MPyTool >> upload: aString fileNamed: aString2 [

	self autoConnectIfFail: [ :text | self error: text ].
	proxy upload: aString fileNamed: aString2.
	proxy waitCompleteSendIfError: [ :msg | self error: msg ].
	self autoClose
]

{ #category : #api }
MPyTool >> uploadClass: aClass [

	self upload: aClass asMicroPython fileNamed: aClass filename
]

{ #category : #api }
MPyTool >> useSerial [

	| list ret c |
	c := self newSerial.
	list := c portNames.
	ret := UIManager default chooseFrom: list.
	ret = 0
		ifTrue: [ ^ self ].
	c baudRate: self defaultBaudRate.
	proxy comm: c.
	proxy portName: (list at: ret).
	proxy close
]

{ #category : #api }
MPyTool >> useWebRepl [

	| c list addr |
	c := WebRepl new.
	list := c recentAddresses.
	addr := UIManager default
		        chooseOrRequestFrom: list
		        title: 'choose or enter IP address'.
	addr ifNil: [ ^ self ].
	c address: addr.
	proxy close.
	proxy comm: c.
	closeConnection := false
]

{ #category : #utilities }
MPyTool >> writeQuotedString: aString on: aStream [
	aString
		linesDo: [ :each | 
			aStream nextPutAll: '_=_s.write("'.
			each
				do: [ :c | 
					c = $\
						ifTrue: [ aStream nextPut: $\ ].
					c = $"
						ifTrue: [ aStream nextPut: $\ ].
					aStream nextPut: c ].
			aStream
				nextPutAll: '\n")';
				cr ]
]
