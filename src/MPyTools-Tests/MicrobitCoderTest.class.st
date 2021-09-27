"
A MicrobitCoderTest is a test class for testing the behavior of MicrobitCoder
"
Class {
	#name : #MicrobitCoderTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
MicrobitCoderTest >> newCoder [
	^ MicrobitCoder new
]

{ #category : #test }
MicrobitCoderTest >> testGenerateAtOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'Image'.
	n2 := TrConstantNode new value: #ABC.
	n3 := TrSendNode new
		receiver: n1;
		arguments:
			{n2}.
	c := self newCoder.
	c generateAt: n3 on: s indent: 0.
	self assert: s contents equals: 'Image.ABC'.
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
MicrobitCoderTest >> testGenerateGetPixelXYOnIndent [
	| c n1 n2 n3 n4 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'display'.
	n2 := TrConstantNode new value: 5.
	n3 := TrConstantNode new value: 10.
	n4 := TrSendNode new
		receiver: n1;
		arguments:
			{n2.
			n3}.
	c := self newCoder.
	c generateGetPixelXY: n4 on: s indent: 0.
	self assert: s contents equals: 'display.get_pixel(5,10)'
]

{ #category : #test }
MicrobitCoderTest >> testGenerateReadFromOnIndent [
	| c n1 n2 n3 n4 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'i2c'.
	n2 := TrConstantNode new value: 100.
	n3 := TrConstantNode new value: 2.
	n4 := TrSendNode new
		receiver: n1;
		arguments:
			{n3.
			n2}.
	c := self newCoder.
	c generateReadFrom: n4 on: s indent: 0.
	self assert: s contents equals: 'i2c.read(100,2)'
]

{ #category : #test }
MicrobitCoderTest >> testGenerateSetPixelXYToOnIndent [
	| c n1 n2 n3 n4 n5 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'display'.
	n2 := TrConstantNode new value: 5.
	n3 := TrConstantNode new value: 10.
	n4 := TrConstantNode new value: 15.
	n5 := TrSendNode new
		receiver: n1;
		arguments:
			{n2.
			n3.
			n4}.
	c := self newCoder.
	c generateSetPixelXYTo: n5 on: s indent: 0.
	self assert: s contents equals: 'display.set_pixel(5,10,15)'
]

{ #category : #test }
MicrobitCoderTest >> testGenerateWriteToOnIndent [
	| c n1 n2 n3 n4 n5 n6 n7 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'i2c'.
	n2 := TrConstantNode new value: 1.
	n3 := TrConstantNode new value: 2.
	n4 := TrConstantNode new value: 3.
	n5 := TrArrayNode new
		contents:
			{n2.
			n3.
			n4};
		isByteArray: true.
	n6 := TrConstantNode new value: 100.
	n7 := TrSendNode new
		receiver: n1;
		arguments:
			{n5.
			n6}.
	c := self newCoder.
	c generateWriteTo: n7 on: s indent: 0.
	self assert: s contents equals: 'i2c.write(100,bytes([1,2,3]))'
]

{ #category : #test }
MicrobitCoderTest >> testTranslationPair [
	| c |
	c := self newCoder.
	self assert: c translationPair isCollection.
	self assert: c translationPair notEmpty
]
