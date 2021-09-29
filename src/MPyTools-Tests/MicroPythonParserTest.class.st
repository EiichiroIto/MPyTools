"
A MicroPythonParserTest is a test class for testing the behavior of MicroPythonParser
"
Class {
	#name : #MicroPythonParserTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
MicroPythonParserTest >> newParser [
	^ MicroPythonParser new
]

{ #category : #test }
MicroPythonParserTest >> testParseData [
	| p |
	p := self newParser.
	self assert: (p parseData: '123') equals: 123.
	p := self newParser.
	self assert: (p parseData: '''abc''') equals: 'abc'.
	p := self newParser.
	self assert: (p parseData: '') equals: nil
]

{ #category : #test }
MicroPythonParserTest >> testParseList [
	| p s r |
	s := ReadStream on: '[]'.
	p := self newParser.
	p stream: s.
	r := p parseList.
	self assert: r isCollection.
	self assert: r isEmpty.
	s := ReadStream on: '[1 , 2,3 ]'.
	p := self newParser.
	p stream: s.
	r := p parseList.
	self assertCollection: r equals: #(1 2 3) asOrderedCollection
]

{ #category : #test }
MicroPythonParserTest >> testParseNumber [
	| p s |
	s := ReadStream on: '123'.
	p := self newParser.
	p stream: s.
	self assert: p parseNumber equals: 123.
	s := ReadStream on: '-45'.
	p := self newParser.
	p stream: s.
	self assert: p parseNumber equals: -45.
	s := ReadStream on: '4.5'.
	p := self newParser.
	p stream: s.
	self assert: p parseNumber equals: 4.5.
	s := ReadStream on: '.7'.
	p := self newParser.
	p stream: s.
	self assert: p parseNumber equals: 0.7.
	s := ReadStream on: '-.7'.
	p := self newParser.
	p stream: s.
	self assert: p parseNumber equals: -0.7.
	s := ReadStream on: '1e3'.
	p := self newParser.
	p stream: s.
	self assert: p parseNumber equals: 1000.
	s := ReadStream on: '3e+2'.
	p := self newParser.
	p stream: s.
	self assert: p parseNumber equals: 300.
	s := ReadStream on: '5e-2'.
	p := self newParser.
	p stream: s.
	self assert: p parseNumber equals: 0.05
]

{ #category : #test }
MicroPythonParserTest >> testParseSequentialUpTo [
	| p s r |
	s := ReadStream on: '<>'.
	p := self newParser.
	p stream: s.
	r := p parseSequential: Array new upTo: $>.
	self assert: r isArray.
	self assert: r isEmpty.
	s := ReadStream on: '<1 , 2,3 >'.
	p := self newParser.
	p stream: s.
	r := p parseSequential: Array new upTo: $>.
	self assertCollection: r equals: #(1 2 3)
]

{ #category : #test }
MicroPythonParserTest >> testParseString [
	| p s |
	s := ReadStream on: '''123''X'.
	p := self newParser.
	p stream: s.
	self assert: p parseString equals: '123'.
	self assert: p stream next equals: $X.
	s := ReadStream on: '''12"34'''.
	p := self newParser.
	p stream: s.
	self assert: p parseString equals: '12"34'.
	s := ReadStream on: '"12''34"'.
	p := self newParser.
	p stream: s.
	self assert: p parseString equals: '12''34'.
	s := ReadStream on: '''12\''34'''.
	p := self newParser.
	p stream: s.
	self assert: p parseString equals: '12''34'.
	s := ReadStream on: '"12\"34"'.
	p := self newParser.
	p stream: s.
	self assert: p parseString equals: '12"34'.
	s := ReadStream on: '"12\\34"'.
	p := self newParser.
	p stream: s.
	self assert: p parseString equals: '12\34'
]

{ #category : #test }
MicroPythonParserTest >> testParseTuple [
	| p s r |
	s := ReadStream on: '()'.
	p := self newParser.
	p stream: s.
	r := p parseTuple.
	self assert: r isArray.
	self assert: r isEmpty.
	s := ReadStream on: '(1 , 2,3 )'.
	p := self newParser.
	p stream: s.
	r := p parseTuple.
	self assertCollection: r equals: #(1 2 3)
]

{ #category : #test }
MicroPythonParserTest >> testStream [
	| p s |
	p := self newParser.
	self assert: p stream isNil.
	s := ReadStream on: 'abc'.
	p stream: s.
	self assert: p stream identicalTo: s
]
