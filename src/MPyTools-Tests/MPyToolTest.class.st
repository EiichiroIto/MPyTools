"
A MPyToolTest is a test class for testing the behavior of MPyTool
"
Class {
	#name : #MPyToolTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
MPyToolTest >> newTool [
	^ MPyTool new
]

{ #category : #test }
MPyToolTest >> testAutoOpen [
	| t c ret |
	t := self newTool.
	self should: [ t autoOpen ] raise: Error.
	c := DummyComm new.
	t proxy comm: c.
	self deny: t isConnected.
	c whenPutDo: [ c sends add: '>>> ' asByteArray ].
	t autoOpen.
	self assert: t isConnected.
	ret := c receives.
	self assert: ret size equals: 1.
	self assertCollection: ret first equals: #[3]
]

{ #category : #test }
MPyToolTest >> testBreak [
	self testAutoOpen
]

{ #category : #test }
MPyToolTest >> testClose [
	self testIsConnected
]

{ #category : #test }
MPyToolTest >> testDefaultBaudRate [
	| t |
	t := self newTool.
	self assert: t defaultBaudRate isInteger.
	self assert: t defaultBaudRate > 0
]

{ #category : #test }
MPyToolTest >> testInitialize [
	| t |
	t := self newTool.
	self assert: (t proxy isKindOf: MPyProxy).
	self deny: t showProgress
]

{ #category : #test }
MPyToolTest >> testIsConnected [
	| t c |
	t := self newTool.
	self deny: t isConnected.
	c := DummyComm new.
	t proxy comm: c.
	self deny: t isConnected.
	c open.
	self assert: t isConnected.
	t close.
	self deny: t isConnected
]

{ #category : #test }
MPyToolTest >> testProxy [
	| t |
	t := self newTool.
	self assert: (t proxy isKindOf: MPyProxy).
	t proxy: nil.
	self assert: t proxy isNil
]

{ #category : #test }
MPyToolTest >> testShowProgress [
	| p |
	p := self newTool.
	self deny: p showProgress.
	p showProgress: true.
	self assert: p showProgress.
	p showProgress: false.
	self deny: p showProgress
]

{ #category : #test }
MPyToolTest >> testTimeout [
	| t |
	t := self newTool.
	self assert: t timeout equals: t proxy defaultTimeout.
	t timeout: 123.
	self assert: t timeout equals: 123
]

{ #category : #test }
MPyToolTest >> testWriteQuotedStringOn [
	| t s |
	t := self newTool.
	s := WriteStream on: String new.
	t writeQuotedString: 'abc' on: s.
	self assert: s contents equals: '_=_s.write("abc\n")' , String cr.
	s := WriteStream on: String new.
	t writeQuotedString: 'abc' , String cr , 'def' on: s.
	self
		assert: s contents
		equals: '_=_s.write("abc\n")' , String cr , '_=_s.write("def\n")' , String cr.
	s := WriteStream on: String new.
	t writeQuotedString: 'ab"c' on: s.
	self assert: s contents equals: '_=_s.write("ab\"c\n")' , String cr.
]
