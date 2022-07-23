Class {
	#name : #MPyToolTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
MPyToolTest >> newComm [
	^ DummyComm new
]

{ #category : #private }
MPyToolTest >> newTool [
	^ MPyTool new
]

{ #category : #test }
MPyToolTest >> testAutoClose [

	| t c |
	t := self newTool.
	c := self newComm.
	t proxy comm: c.
	self deny: c isConnected.
	t proxy
		portName: 'dummy';
		open.
	self assert: c isConnected.
	t autoClose.
	self deny: c isConnected.
	t closeConnection: false.
	c isConnected: true.
	t autoClose.
	self assert: c isConnected
]

{ #category : #test }
MPyToolTest >> testClose [
	self testIsConnected
]

{ #category : #test }
MPyToolTest >> testCloseConnection [
	| t |
	t := self newTool.
	self assert: t closeConnection.
	t closeConnection: false.
	self deny: t closeConnection
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
	self assert: (t proxy isKindOf: MicroPythonProxy).
	self deny: t showProgress
]

{ #category : #test }
MPyToolTest >> testIsConnected [
	| t c |
	t := self newTool.
	self deny: t isConnected.
	c := self newComm.
	t proxy comm: c.
	self deny: t isConnected.
	t proxy
		portName: 'dummy';
		open.
	self assert: t isConnected.
	t close.
	self deny: t isConnected
]

{ #category : #test }
MPyToolTest >> testProxy [
	| t |
	t := self newTool.
	self assert: (t proxy isKindOf: MicroPythonProxy).
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
