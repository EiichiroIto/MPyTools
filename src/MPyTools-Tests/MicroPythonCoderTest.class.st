"
A MicroPythonCoderTest is a test class for testing the behavior of MicroPythonCoder
"
Class {
	#name : #MicroPythonCoderTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
MicroPythonCoderTest >> newCoder [
	^ MicroPythonCoder new
]

{ #category : #test }
MicroPythonCoderTest >> testAddClass [
	| g |
	g := self newCoder.
	self assert: g classes isEmpty.
	g addClass: TrFooBar.
	self assert: g classes size equals: 1.
	self assert: (g classes first isKindOf: TrClass)
]

{ #category : #test }
MicroPythonCoderTest >> testCamelToUnderScore [
	| c |
	c := self newCoder.
	self assert: (c camelToUnderScore: '') equals: ''.
	self assert: (c camelToUnderScore: 'abc') equals: 'abc'.
	self assert: (c camelToUnderScore: '123') equals: '123'.
	self assert: (c camelToUnderScore: 'ABC') equals: 'a_b_c'.
	self assert: (c camelToUnderScore: 'List') equals: 'list'.
	self assert: (c camelToUnderScore: 'isPressed') equals: 'is_pressed'.
	self assert: (c camelToUnderScore: 'wasPressed') equals: 'was_pressed'
]

{ #category : #test }
MicroPythonCoderTest >> testClasses [
	| c |
	c := self newCoder.
	self assert: c classes isCollection.
	self assert: c classes isEmpty
]

{ #category : #test }
MicroPythonCoderTest >> testEmitArrayOnIndent [
	| c n s |
	c := self newCoder.
	n := TrArrayNode new
		contents: (#(5) collect: [ :each | TrConstantNode new value: each ]);
		isByteArray: false;
		yourself.
	s := WriteStream on: String new.
	c emitArray: n on: s indent: 0.
	self assert: s contents equals: '(5,)'.
	n := TrArrayNode new
		contents: (#(1 2 3) collect: [ :each | TrConstantNode new value: each ]);
		isByteArray: false;
		yourself.
	s := WriteStream on: String new.
	c emitArray: n on: s indent: 0.
	self assert: s contents equals: '(1,2,3)'.
	n := TrArrayNode new
		contents: (#(1 2 3) collect: [ :each | TrConstantNode new value: each ]);
		isByteArray: true;
		yourself.
	s := WriteStream on: String new.
	c emitArray: n on: s indent: 0.
	self assert: s contents equals: 'bytes([1,2,3])'.
	n := TrArrayNode new
		contents: #();
		isByteArray: true;
		yourself.
	s := WriteStream on: String new.
	c emitArray: n on: s indent: 0.
	self assert: s contents equals: 'bytes([])'
]

{ #category : #test }
MicroPythonCoderTest >> testFunctionNameFor [
	| c |
	c := self newCoder.
	c addClass: MicroPythonSample.
	c targetClass: c classes first.
	self assert: (c functionNameFor: 'error') equals: 'error'.
	self assert: (c functionNameFor: 'error:') equals: 'error'.
	self assert: (c functionNameFor: 'a:b:c:') equals: 'a_b_c'.
	self assert: (c functionNameFor: 'isPressed:') equals: 'is_pressed'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateAndOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: true.
	n2 := TrConstantNode new value: false.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateAnd: n3 on: s indent: 0.
	self assert: s contents equals: 'True and False'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateAsCollectionOnIndent [
	| c s n1 n2 |
	c := self newCoder.
	n1 := TrArrayNode new
		contents: (#(1 2 3) collect: [ :each | TrConstantNode new value: each ]);
		isByteArray: false.
	n2 := TrSendNode new receiver: n1.
	s := WriteStream on: String new.
	c generateAsCollection: n2 on: s indent: 0.
	self assert: s contents equals: '[1,2,3]'.
	n1 := TrArrayNode new
		contents: (#(1 2 3) collect: [ :each | TrConstantNode new value: each ]);
		isByteArray: true.
	n2 := TrSendNode new receiver: n1.
	s := WriteStream on: String new.
	c generateAsCollection: n2 on: s indent: 0.
	self assert: s contents equals: '[1,2,3]'.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrSendNode new receiver: n1.
	s := WriteStream on: String new.
	c generateAsCollection: n2 on: s indent: 0.
	self assert: s contents equals: 'list(a)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateAsFloatOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 50.
	n2 := TrSendNode new receiver: n1.
	c := self newCoder.
	c generateAsFloat: n2 on: s indent: 0.
	self assert: s contents equals: 'float(50)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateAsIntegerOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 12.3.
	n2 := TrSendNode new receiver: n1.
	c := self newCoder.
	c generateAsInteger: n2 on: s indent: 0.
	self assert: s contents equals: 'int(12.3)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateAsLowercaseOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 'ABC'.
	n2 := TrSendNode new
		receiver: n1;
		arguments: #();
		yourself.
	c := self newCoder.
	c generateAsLowercase: n2 on: s indent: 0.
	self assert: s contents equals: '"ABC".lower()'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateAsStringOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 12.3.
	n2 := TrSendNode new receiver: n1.
	c := self newCoder.
	c generateAsString: n2 on: s indent: 0.
	self assert: s contents equals: 'str(12.3)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateAsTupleOnIndent [
	| c s n1 n2 |
	c := self newCoder.
	n1 := TrArrayNode new
		contents: (#(1 2 3) collect: [ :each | TrConstantNode new value: each ]);
		isByteArray: false.
	n2 := TrSendNode new receiver: n1.
	s := WriteStream on: String new.
	c generateAsTuple: n2 on: s indent: 0.
	self assert: s contents equals: '(1,2,3)'.
	n1 := TrArrayNode new
		contents: (#(1 2 3) collect: [ :each | TrConstantNode new value: each ]);
		isByteArray: true.
	n2 := TrSendNode new receiver: n1.
	s := WriteStream on: String new.
	c generateAsTuple: n2 on: s indent: 0.
	self assert: s contents equals: 'tuple(bytes([1,2,3]))'.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrSendNode new receiver: n1.
	s := WriteStream on: String new.
	c generateAsTuple: n2 on: s indent: 0.
	self assert: s contents equals: 'tuple(a)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateAtOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrConstantNode new value: 5.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateAt: n3 on: s indent: 0.
	self assert: s contents equals: 'x[5]'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateAtPutOnIndent [
	| c n1 n2 n3 n4 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrConstantNode new value: 5.
	n3 := TrConstantNode new value: true.
	n4 := TrSendNode new
		receiver: n1;
		arguments: {n2. n3}.
	c := self newCoder.
	c generateAtPut: n4 on: s indent: 0.
	self assert: s contents equals: 'x[5] = True'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateBitAndOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 3.
	n2 := TrConstantNode new value: 6.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateBitAnd: n3 on: s indent: 0.
	self assert: s contents equals: '3 & 6'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateBitInvert32OnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 50.
	n2 := TrSendNode new receiver: n1.
	c := self newCoder.
	c generateBitInvert32: n2 on: s indent: 0.
	self assert: s contents equals: '~50'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateBitOrOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 3.
	n2 := TrConstantNode new value: 6.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateBitOr: n3 on: s indent: 0.
	self assert: s contents equals: '3 | 6'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateBitShiftOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 2.
	n2 := TrConstantNode new value: 3.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateBitShift: n3 on: s indent: 0.
	self assert: s contents equals: '(2 << 3)'.
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 3.
	n2 := TrConstantNode new value: -2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateBitShift: n3 on: s indent: 0.
	self assert: s contents equals: '(3 >> 2)'.
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateBitShift: n3 on: s indent: 0.
	self assert: s contents equals: '(a >> -b) if (b < 0) else (a << b)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateBitXorOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 3.
	n2 := TrConstantNode new value: 6.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateBitXor: n3 on: s indent: 0.
	self assert: s contents equals: '3 ^ 6'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateCommaOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 'a'.
	n2 := TrConstantNode new value: 'b'.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateComma: n3 on: s indent: 0.
	self assert: s contents equals: '"a" + "b"'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateConditionalIfThenElseOnIndent [
	| c s n1 n2 n3 n4 n5 |
	s := ReadWriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrStatementListNode new statements: {n2}.
	n4 := TrVariableNode new name: 'd'.
	n5 := TrStatementListNode new statements: {n4}.
	c := self newCoder.
	c
		generateConditionalIf: n1
		then: n3
		else: n5
		on: s
		indent: 0.
	self assert: s contents equals: 'b if a else d'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateDivideOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrConstantNode new value: 3.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateDivide: n3 on: s indent: 0.
	self assert: s contents equals: 'a / 3'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateEqualOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 1.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateEqual: n3 on: s indent: 0.
	self assert: s contents equals: '1 == 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateFifthOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new
		receiver: n1;
		arguments: {}.
	c := self newCoder.
	c generateFifth: n2 on: s indent: 0.
	self assert: s contents equals: 'x[4]'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateFirstOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new
		receiver: n1;
		arguments: {}.
	c := self newCoder.
	c generateFirst: n2 on: s indent: 0.
	self assert: s contents equals: 'x[0]'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateFourthOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new
		receiver: n1;
		arguments: {}.
	c := self newCoder.
	c generateFourth: n2 on: s indent: 0.
	self assert: s contents equals: 'x[3]'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateFunctionNodeOnIndent [
	| c n1 n2 n3 n4 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrConstantNode new value: 5.
	n4 := TrSendNode new receiver: n1; arguments: { n2. n3 }.
	c := self newCoder.
	c generateFunction: 'sample' node: n4 on: s indent: 0.
	self assert: s contents equals: 'a.sample(b,5)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateGreaterThanOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 1.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateGreaterThan: n3 on: s indent: 0.
	self assert: s contents equals: '1 > 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateGreaterThanOrEqualOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 1.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateGreaterThanOrEqual: n3 on: s indent: 0.
	self assert: s contents equals: '1 >= 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateIfFalseIfTrueOnIndent [
	| c n1 n2 n3 n4 n5 n6 n7 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrVariableNode new name: 'c'.
	n4 := TrStatementListNode new
		statements:
			{n2.
			n3}.
	n5 := TrVariableNode new name: 'd'.
	n6 := TrStatementListNode new statements: {n5}.
	n7 := TrSendNode new
		receiver: n1;
		arguments:
			{n4.
			n6}.
	c := self newCoder.
	c generateIfFalseIfTrue: n7 on: s indent: 0.
	self
		assert: s contents
		equals:
			'if a:' , String cr , String tab , 'd' , String cr , 'else:'
				, String cr , String tab , 'b' , String cr , String tab , 'c'.
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: true.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrVariableNode new name: 'c'.
	n4 := TrStatementListNode new
		statements:
			{n2.
			n3}.
	n5 := TrVariableNode new name: 'd'.
	n6 := TrStatementListNode new statements: {n5}.
	n7 := TrSendNode new
		receiver: n1;
		arguments:
			{n4.
			n6}.
	c := self newCoder.
	c generateIfFalseIfTrue: n7 on: s indent: 0.
	self assert: s contents equals: 'd'.
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: false.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrVariableNode new name: 'c'.
	n4 := TrStatementListNode new
		statements:
			{n2.
			n3}.
	n5 := TrVariableNode new name: 'd'.
	n6 := TrStatementListNode new statements: {n5}.
	n7 := TrSendNode new
		receiver: n1;
		arguments:
			{n4.
			n6}.
	c := self newCoder.
	c generateIfFalseIfTrue: n7 on: s indent: 0.
	self assert: s contents equals: 'b' , String cr , 'c'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateIfFalseOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: false.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateIfFalse: n3 on: s indent: 0.
	self assert: s contents equals: '2'.
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: true.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateIfFalse: n3 on: s indent: 0.
	self assert: s contents isEmpty.
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrConstantNode new value: 3.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateIfFalse: n3 on: s indent: 0.
	self assert: s contents equals: 'if not (a):' , String cr , '3'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateIfNilIfNotNilOnIndent [
	| c n1 n2 n3 n4 n5 n6 n7 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrVariableNode new name: 'c'.
	n4 := TrStatementListNode new
		statements:
			{n2.
			n3}.
	n5 := TrVariableNode new name: 'd'.
	n6 := TrStatementListNode new statements: {n5}.
	n7 := TrSendNode new
		receiver: n1;
		arguments:
			{n4.
			n6}.
	c := self newCoder.
	c generateIfNilIfNotNil: n7 on: s indent: 0.
	self
		assert: s contents
		equals:
			'if a == None:' , String cr , String tab , 'b' , String cr , String tab , 'c'
				, String cr , 'else:' , String cr , String tab , 'd'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateIfNilOnIndent [
	| c n1 n2 n3 n4 n5 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrVariableNode new name: 'c'.
	n4 := TrStatementListNode new
		statements:
			{n2.
			n3}.
	n5 := TrSendNode new
		receiver: n1;
		arguments:
			{n4}.
	c := self newCoder.
	c generateIfNil: n5 on: s indent: 0.
	self
		assert: s contents
		equals:
			'if a == None:' , String cr , String tab , 'b' , String cr , String tab , 'c'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateIfNotNilOnIndent [
	| c n1 n2 n3 n4 n5 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrVariableNode new name: 'c'.
	n4 := TrStatementListNode new
		statements:
			{n2.
			n3}.
	n5 := TrSendNode new
		receiver: n1;
		arguments:
			{n4}.
	c := self newCoder.
	c generateIfNotNil: n5 on: s indent: 0.
	self
		assert: s contents
		equals:
			'if a != None:' , String cr , String tab , 'b' , String cr , String tab , 'c'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateIfThenElseOnIndent [
	| c n1 n2 n3 n4 n5 n6 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrVariableNode new name: 'c'.
	n4 := TrStatementListNode new
		statements:
			{n2.
			n3}.
	n5 := TrVariableNode new name: 'd'.
	n6 := TrStatementListNode new statements: {n5}.
	c := self newCoder.
	c
		generateIf: n1
		then: n4
		else: n6
		on: s
		indent: 0.
	self
		assert: s contents
		equals:
			'if a:' , String cr , String tab , 'b' , String cr , String tab , 'c'
				, String cr , 'else:' , String cr , String tab , 'd'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateIfTrueIfFalseOnIndent [
	| c n1 n2 n3 n4 n5 n6 n7 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrVariableNode new name: 'c'.
	n4 := TrStatementListNode new
		statements:
			{n2.
			n3}.
	n5 := TrVariableNode new name: 'd'.
	n6 := TrStatementListNode new statements: {n5}.
	n7 := TrSendNode new
		receiver: n1;
		arguments:
			{n4.
			n6}.
	c := self newCoder.
	c generateIfTrueIfFalse: n7 on: s indent: 0.
	self
		assert: s contents
		equals:
			'if a:' , String cr , String tab , 'b' , String cr , String tab , 'c'
				, String cr , 'else:' , String cr , String tab , 'd'.
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: true.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrVariableNode new name: 'c'.
	n4 := TrStatementListNode new
		statements:
			{n2.
			n3}.
	n5 := TrVariableNode new name: 'd'.
	n6 := TrStatementListNode new statements: {n5}.
	n7 := TrSendNode new
		receiver: n1;
		arguments:
			{n4.
			n6}.
	c := self newCoder.
	c generateIfTrueIfFalse: n7 on: s indent: 0.
	self assert: s contents equals: 'b' , String cr , 'c'.
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: false.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrVariableNode new name: 'c'.
	n4 := TrStatementListNode new
		statements:
			{n2.
			n3}.
	n5 := TrVariableNode new name: 'd'.
	n6 := TrStatementListNode new statements: {n5}.
	n7 := TrSendNode new
		receiver: n1;
		arguments:
			{n4.
			n6}.
	c := self newCoder.
	c generateIfTrueIfFalse: n7 on: s indent: 0.
	self assert: s contents equals: 'd'.
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrStatementListNode new statements: {n2}.
	n4 := TrVariableNode new name: 'd'.
	n5 := TrStatementListNode new statements: {n4}.
	n6 := TrSendNode new
		receiver: n1;
		arguments:
			{n3.
			n5}.
	c := self newCoder.
	c generateIfTrueIfFalse: n6 on: s indent: 0.
	self assert: s contents equals: 'b if a else d'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateIfTrueOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: false.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateIfTrue: n3 on: s indent: 0.
	self assert: s contents isEmpty.
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: true.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateIfTrue: n3 on: s indent: 0.
	self assert: s contents equals: '2'.
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrConstantNode new value: 3.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateIfTrue: n3 on: s indent: 0.
	self assert: s contents equals: 'if a:' , String cr , '3'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateIncludesOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrConstantNode new value: 5.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateIncludes: n3 on: s indent: 0.
	self assert: s contents equals: '5 in a'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateInlineDirectiveOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'self'.
	n2 := TrConstantNode new value: true.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateInlineDirective: n3 on: s indent: 0.
	self assert: s contents equals: '// inline: true'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateIsNilOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new receiver: n1.
	c := self newCoder.
	c generateIsNil: n2 on: s indent: 0.
	self assert: s contents equals: 'x == None'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateLastOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new
		receiver: n1;
		arguments: {}.
	c := self newCoder.
	c generateLast: n2 on: s indent: 0.
	self assert: s contents equals: 'x[-1]'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateLessThanOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 1.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateLessThan: n3 on: s indent: 0.
	self assert: s contents equals: '1 < 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateLessThanOrEqualOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 1.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateLessThanOrEqual: n3 on: s indent: 0.
	self assert: s contents equals: '1 <= 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateMaxOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 1.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateMax: n3 on: s indent: 0.
	self assert: s contents equals: 'max(1,2)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateMinOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 1.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateMin: n3 on: s indent: 0.
	self assert: s contents equals: 'min(1,2)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateMinusOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 1.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateMinus: n3 on: s indent: 0.
	self assert: s contents equals: '1 - 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateModuloOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateModulo: n3 on: s indent: 0.
	self assert: s contents equals: 'a % 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateNewOnIndent [
	| c s n1 n2 |
	c := self newCoder.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrSendNode new receiver: n1.
	s := WriteStream on: String new.
	c generateNew: n2 on: s indent: 0.
	self assert: s contents equals: 'a()'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateNewWithAllOnIndent [
	| c n1 n2 n3 n4 s |
	c := self newCoder.
	n1 := TrConstantNode new value: 1.
	n2 := TrVariableNode new name: 'a'.
	n3 := TrVariableNode new name: 'b'.
	n4 := TrSendNode new
		receiver: n1;
		arguments:
			{n2.
			n3}.
	s := WriteStream on: String new.
	c generateNewWithAll: n4 on: s indent: 0.
	self assert: s contents equals: '(b,)*a'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateNinthOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new
		receiver: n1;
		arguments: {}.
	c := self newCoder.
	c generateNinth: n2 on: s indent: 0.
	self assert: s contents equals: 'x[8]'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateNotEqualOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 1.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateNotEqual: n3 on: s indent: 0.
	self assert: s contents equals: '1 != 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateNotNilOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new receiver: n1.
	c := self newCoder.
	c generateNotNil: n2 on: s indent: 0.
	self assert: s contents equals: 'x != None'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateNotOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new receiver: n1.
	c := self newCoder.
	c generateNot: n2 on: s indent: 0.
	self assert: s contents equals: 'not (x)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateOrOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: true.
	n2 := TrConstantNode new value: false.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateOr: n3 on: s indent: 0.
	self assert: s contents equals: 'True or False'
]

{ #category : #test }
MicroPythonCoderTest >> testGeneratePlusOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 1.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generatePlus: n3 on: s indent: 0.
	self assert: s contents equals: '1 + 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateRepeatOnIndent [
	| c n1 n2 n3 n4 s |
	s := ReadWriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrStatementListNode new
		statements: {n1. n2}.
	n4 := TrSendNode new
		receiver: n3;
		arguments: #().
	c := self newCoder.
	c generateRepeat: n4 on: s indent: 0.
	self
		assert: s contents
		equals:
			'while True:' , String cr , String tab , 'a' , String cr , String tab , 'b'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateSearchFromOnIndent [
	| c n1 n2 n3 n4 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 're'.
	n2 := TrConstantNode new value: 'abc'.
	n3 := TrConstantNode new value: 'def'.
	n4 := TrSendNode new receiver: n1; arguments: { n2. n3 }.
	c := self newCoder.
	c generateSearchFrom: n4 on: s indent: 0.
	self assert: s contents equals: 're.search("abc","def")'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateSecondOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new
		receiver: n1;
		arguments: {}.
	c := self newCoder.
	c generateSecond: n2 on: s indent: 0.
	self assert: s contents equals: 'x[1]'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateSequentialAndOnIndent [
	| c n1 n2 n3 n4 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrStatementListNode new statements: {n2}.
	n4 := TrSendNode new
		receiver: n1;
		arguments: {n3}.
	c := self newCoder.
	c generateSequentialAnd: n4 on: s indent: 0.
	self assert: s contents equals: 'a and (b)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateSequentialOrOnIndent [
	| c n1 n2 n3 n4 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrStatementListNode new statements: {n2}.
	n4 := TrSendNode new
		receiver: n1;
		arguments: {n3}.
	c := self newCoder.
	c generateSequentialOr: n4 on: s indent: 0.
	self assert: s contents equals: 'a or (b)'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateSeventhOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new
		receiver: n1;
		arguments: {}.
	c := self newCoder.
	c generateSeventh: n2 on: s indent: 0.
	self assert: s contents equals: 'x[6]'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateShiftLeftOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateShiftLeft: n3 on: s indent: 0.
	self assert: s contents equals: 'a << 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateShiftRightOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new
		receiver: n1;
		arguments: {n2}.
	c := self newCoder.
	c generateShiftRight: n3 on: s indent: 0.
	self assert: s contents equals: 'a >> 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateSixthOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new
		receiver: n1;
		arguments: {}.
	c := self newCoder.
	c generateSixth: n2 on: s indent: 0.
	self assert: s contents equals: 'x[5]'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateTenthOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new
		receiver: n1;
		arguments: {}.
	c := self newCoder.
	c generateTenth: n2 on: s indent: 0.
	self assert: s contents equals: 'x[9]'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateThirdOnIndent [
	| c n1 n2 s |
	s := WriteStream on: String new.
	n1 := TrVariableNode new name: 'x'.
	n2 := TrSendNode new
		receiver: n1;
		arguments: {}.
	c := self newCoder.
	c generateThird: n2 on: s indent: 0.
	self assert: s contents equals: 'x[2]'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateTimesOnIndent [
	| c n1 n2 n3 s |
	s := WriteStream on: String new.
	n1 := TrConstantNode new value: 1.
	n2 := TrConstantNode new value: 2.
	n3 := TrSendNode new receiver: n1; arguments: { n2 }.
	c := self newCoder.
	c generateTimes: n3 on: s indent: 0.
	self assert: s contents equals: '1 * 2'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateTimesRepeatOnIndent [
	| c n1 n2 n3 n4 s |
	n1 := TrConstantNode new value: 9.
	n2 := TrVariableNode new name: 'b'.
	n3 := TrStatementListNode new
		statements: {n2}.
	n4 := TrSendNode new
		receiver: n1;
		arguments: {n3}.
	s := ReadWriteStream on: String new.
	c := self newCoder.
	c generateTimesRepeat: n4 on: s indent: 0.
	self
		assert: s contents
		equals:
			'for _ in range(0,9):' , String cr , String tab , 'b'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateToByDoOnIndent [
	| c n1 n2 n3 n4 n5 n6 s |
	s := ReadWriteStream on: String new.
	n1 := TrConstantNode new value: 2.
	n2 := TrConstantNode new value: 9.
	n3 := TrVariableNode new name: 'a'.
	n4 := TrConstantNode new value: 3.
	n5 := TrStatementListNode new
		statements: {n3};
		arguments: #(b).
	n6 := TrSendNode new
		receiver: n1;
		arguments:
			{n2.
			n4.
			n5}.
	c := self newCoder.
	c generateToByDo: n6 on: s indent: 0.
	self
		assert: s contents
		equals:
			'for b in range(2,9+1,3):' , String cr , String tab , 'a'.
	s := ReadWriteStream on: String new.
	n1 := TrConstantNode new value: 5.
	n2 := TrConstantNode new value: 2.
	n3 := TrVariableNode new name: 'a'.
	n4 := TrConstantNode new value: -1.
	n5 := TrStatementListNode new
		statements: {n3};
		arguments: #(b).
	n6 := TrSendNode new
		receiver: n1;
		arguments:
			{n2.
			n4.
			n5}.
	c := self newCoder.
	c generateToByDo: n6 on: s indent: 0.
	self
		assert: s contents
		equals:
			'for b in range(5,2-1,-1):' , String cr , String tab , 'a'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateToDoOnIndent [
	| c n1 n2 n3 n4 n5 s |
	s := ReadWriteStream on: String new.
	n1 := TrConstantNode new value: 2.
	n2 := TrConstantNode new value: 5.
	n3 := TrVariableNode new name: 'a'.
	n4 := TrStatementListNode new
		statements: {n3};
		arguments: #(b).
	n5 := TrSendNode new
		receiver: n1;
		arguments:
			{n2.
			n4}.
	c := self newCoder.
	c generateToDo: n5 on: s indent: 0.
	self
		assert: s contents
		equals:
			'for b in range(2,5+1):' , String cr , String tab , 'a'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateWhileFalseOnIndent [
	| c n1 n2 n3 n4 n5 s |
	s := ReadWriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrStatementListNode new
		statements: {n1}.
	n3 := TrVariableNode new name: 'b'.
	n4 := TrStatementListNode new
		statements: {n3}.
	n5 := TrSendNode new
		receiver: n2;
		arguments: {n4}.
	c := self newCoder.
	c generateWhileFalse: n5 on: s indent: 0.
	self
		assert: s contents
		equals:
			'while not (a):' , String cr , String tab , 'b'
]

{ #category : #test }
MicroPythonCoderTest >> testGenerateWhileTrueOnIndent [
	| c n1 n2 n3 n4 n5 s |
	s := ReadWriteStream on: String new.
	n1 := TrVariableNode new name: 'a'.
	n2 := TrStatementListNode new
		statements: {n1}.
	n3 := TrVariableNode new name: 'b'.
	n4 := TrStatementListNode new
		statements: {n3}.
	n5 := TrSendNode new
		receiver: n2;
		arguments: {n4}.
	c := self newCoder.
	c generateWhileTrue: n5 on: s indent: 0.
	self
		assert: s contents
		equals:
			'while a:' , String cr , String tab , 'b'
]

{ #category : #test }
MicroPythonCoderTest >> testInitialize [
	| c |
	c := self newCoder.
	self assert: c classes isCollection
]

{ #category : #test }
MicroPythonCoderTest >> testLiteralFor [
	| c |
	c := self newCoder.
	self assert: (c literalFor: 12345) equals: '12345'.
	self assert: (c literalFor: 1234567890123) equals: '1234567890123'.
	self assert: (c literalFor: 1.5) equals: '1.5'.
	self assert: (c literalFor: 'abc') equals: '"abc"'.
	self assert: (c literalFor: nil) equals: 'None'.
	self assert: (c literalFor: true) equals: 'True'.
	self assert: (c literalFor: false) equals: 'False'.
	self should: [ c literalFor: #() ] raise: Error
]

{ #category : #test }
MicroPythonCoderTest >> testMethodClass [
	| c |
	c := self newCoder.
	self assert: c methodClass identicalTo: MicroPythonMethod
]

{ #category : #test }
MicroPythonCoderTest >> testStringLiteralFor [
	| c |
	c := self newCoder.
	self assert: (c stringLiteralFor: '') equals: '""'.
	self assert: (c stringLiteralFor: 'abc') equals: '"abc"'.
	self
		assert: (c stringLiteralFor: 'abc' , String cr , 'def')
		equals: '"abc\n" \' , String cr , '"def"'.
	self assert: (c stringLiteralFor: 'ab"c') equals: '"ab\"c"'
]

{ #category : #test }
MicroPythonCoderTest >> testTranslationPair [
	| c |
	c := self newCoder.
	self assert: c translationPair isCollection.
	self assert: c translationPair notEmpty
]

{ #category : #test }
MicroPythonCoderTest >> testVariableFor [
	| c |
	c := self newCoder.
	c targetClass: MicroPythonSample.
	self assert: (c variableFor: 'abc') equals: 'abc'.
	self assert: (c variableFor: 'def') equals: 'def'.
	self assert: (c variableFor: 'a') equals: 'self.a'
]
