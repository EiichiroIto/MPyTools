Class {
	#name : #MPyTool,
	#superclass : #Object,
	#instVars : [
		'proxy',
		'showProgress'
	],
	#category : #'MPyTools-Core'
}

{ #category : #private }
MPyTool >> autoOpen [
	(proxy isConnected or: [ proxy open ])
		ifFalse: [ self error ].
	^ proxy break
]

{ #category : #api }
MPyTool >> break [
	^ self autoOpen
]

{ #category : #api }
MPyTool >> chdir: aString [
	| cmd |
	self autoOpen.
	cmd := 'import os' , String cr
		,
			((aString isNil or: [ aString isEmpty ])
				ifTrue: [ 'os.chdir("/")' ]
				ifFalse: [ 'os.chdir("' , aString , '")' ]).
	^ self raw: cmd
]

{ #category : #api }
MPyTool >> close [
	proxy close
]

{ #category : #private }
MPyTool >> defaultBaudRate [
	^ 115200
]

{ #category : #api }
MPyTool >> downloadFileNamed: aString [
	"MPyTool new downloadFileNamed: 'boot.py'."

	| s |
	self autoOpen.
	s := WriteStream on: String new.
	s
		nextPutAll: '_s=open("';
		nextPutAll: aString;
		nextPutAll: '","r")';
		cr;
		nextPutAll: 'print(_s.read())';
		cr;
		nextPutAll: '_s.close()'.
	^ self raw: s contents
]

{ #category : #api }
MPyTool >> evaluate: aString [
	| ret |
	aString isEmpty
		ifTrue: [ ^ '' ].
	self autoOpen.
	aString lines size = 1
		ifTrue: [ ^ proxy oneLiner: aString ].
	ret := nil.
	showProgress
		ifTrue: [ UIManager default
				displayProgress: 'Transferring ...'
				from: 1
				to: 100
				during:
					[ :bar | ret := proxy paste: aString during: [ :x | bar value: x ] ] ]
		ifFalse: [ ret := proxy paste: aString ].
	^ ret
]

{ #category : #api }
MPyTool >> execute: aString [
	aString isEmpty
		ifTrue: [ ^ '' ].
	self autoOpen.
	showProgress
		ifTrue: [ UIManager default
				displayProgress: 'Transferring ...'
				from: 1
				to: 100
				during:
					[ :bar | proxy nonBlock: aString during: [ :x | bar value: x ] ] ]
		ifFalse: [ proxy nonBlock: aString ]
]

{ #category : #api }
MPyTool >> fileNames [
	| ret |
	self autoOpen.
	ret := proxy paste: 'import os' , String cr , 'os.listdir()'.
	^ MicroPythonParser new parseData: ret
]

{ #category : #initialization }
MPyTool >> initialize [
	proxy := MPyProxy new.
	showProgress := false
]

{ #category : #testing }
MPyTool >> isConnected [
	^ proxy isConnected
]

{ #category : #accessing }
MPyTool >> proxy [
	^ proxy
]

{ #category : #accessing }
MPyTool >> proxy: anObject [
	proxy := anObject
]

{ #category : #private }
MPyTool >> raw: aString [
	| ret |
	aString isEmpty
		ifTrue: [ ^ '' ].
	self autoOpen.
	aString lines size = 1
		ifTrue: [ ^ proxy oneLiner: aString ].
	ret := nil.
	showProgress
		ifTrue: [ UIManager default
				displayProgress: 'Transferring ...'
				from: 1
				to: 100
				during:
					[ :bar | ret := proxy raw: aString during: [ :x | bar value: x ] ] ]
		ifFalse: [ ret := proxy raw: aString ].
	^ ret
]

{ #category : #api }
MPyTool >> rawString [
	(proxy isConnected or: [ proxy open ])
		ifFalse: [ self error ].
	proxy step.
	^ proxy rawString
]

{ #category : #api }
MPyTool >> reboot [
	self autoOpen.
	^ proxy reboot
]

{ #category : #api }
MPyTool >> removeAll [
	self fileNames do: [ :each | self removeFileNamed: each ]
]

{ #category : #api }
MPyTool >> removeFileNamed: aString [
	self autoOpen.
	^ self
		raw: 'import os' , String cr , 'os.remove("' , aString , '")'
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
	| s |
	self autoOpen.
	s := WriteStream on: String new.
	s
		nextPutAll: '_s=open("';
		nextPutAll: aString2;
		nextPutAll: '","w")';
		cr.
	self writeQuotedString: aString on: s.
	s nextPutAll: '_s.close()'.
	^ self raw: s contents
]

{ #category : #api }
MPyTool >> uploadClass: aClass [
	self upload: aClass asMicroPython fileNamed: aClass filename
]

{ #category : #api }
MPyTool >> useSerial [
	| list ret c |
	c := NativeSerial new.
	list := c portNames.
	ret := UIManager default chooseFrom: list.
	ret = 0
		ifTrue: [ ^ self ].
	c portName: (list at: ret).
	c baudRate: self defaultBaudRate.
	proxy close.
	proxy comm: c
]

{ #category : #api }
MPyTool >> useWebRepl [
	self shouldBeImplemented
]

{ #category : #private }
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