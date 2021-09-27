Class {
	#name : #MicroPythonParser,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'MPyTools-MicroPython'
}

{ #category : #private }
MicroPythonParser >> parseData [
	| c |
	stream skipSeparators.
	stream atEnd
		ifTrue: [ ^ nil ].
	c := stream peek.
	c = $[
		ifTrue: [ ^ self parseList ].
	c = $(
		ifTrue: [ ^ self parseTuple ].
	('''"' includes: c)
		ifTrue: [ ^ self parseString ].
	(c isDigit or: [ c = $- ])
		ifTrue: [ ^ self parseNumber ].
	self error
]

{ #category : #api }
MicroPythonParser >> parseData: aString [
	stream := ReadStream on: aString.
	^ self parseData
]

{ #category : #private }
MicroPythonParser >> parseList [
	^ self parseSequential: OrderedCollection new upTo: $]
]

{ #category : #private }
MicroPythonParser >> parseNumber [
	| mode c w exitBlock |
	mode := nil.
	w := WriteStream on: String new.
	exitBlock := [ ^ w contents asNumber ].
	[ stream atEnd ]
		whileFalse: [ c := stream next.
			mode
				caseOf:
					{([ nil ]
						-> [ c = $-
								ifTrue: [ mode := #minus.
									w nextPut: c ].
							c = $.
								ifTrue: [ mode := #float.
									w contents isEmpty
										ifTrue: [ w nextPut: $0 ].
									w nextPut: c ].
							c isDigit
								ifTrue: [ w nextPut: c ].
							('-.0123456789' includes: c)
								ifFalse: [ stream back.
									exitBlock value ] ]).
					([ #minus ]
						-> [ c = $.
								ifTrue: [ mode := #float.
									w contents size < 2
										ifTrue: [ w nextPut: $0 ].
									w nextPut: c ].
							c isDigit
								ifTrue: [ w nextPut: c ].
							('.0123456789' includes: c)
								ifFalse: [ stream back.
									exitBlock value ] ]).
					([ #float ]
						-> [ c isDigit
								ifTrue: [ w nextPut: c ].
							c = 'e'
								ifTrue: [ mode := #exp.
									w nextPut: c ].
							('e0123456789' includes: c)
								ifFalse: [ stream back.
									exitBlock value ] ]).
					([ #exp ] -> [ self shouldBeImplemented ])} ].
	exitBlock value
]

{ #category : #private }
MicroPythonParser >> parseSequential: anObject upTo: aCharacter [
	| c w exitBlock |
	stream next.
	w := WriteStream on: anObject.
	exitBlock := [ ^ w contents ].
	[ stream atEnd ]
		whileFalse: [ stream skipSeparators.
			c := stream peek.
			c = aCharacter
				ifTrue: [ stream next.
					exitBlock value ].
			w nextPut: self parseData.
			stream skipSeparators.
			stream peek = $,
				ifTrue: [ stream next ] ].
	^ w contents
]

{ #category : #private }
MicroPythonParser >> parseString [
	| mode c w exitBlock end |
	end := stream next.
	mode := nil.
	w := WriteStream on: String new.
	exitBlock := [ ^ w contents ].
	[ stream atEnd ]
		whileFalse: [ c := stream next.
			mode
				caseOf:
					{([ nil ]
						-> [ c = end
								ifTrue: [ exitBlock value ].
							c = $\
								ifTrue: [ mode := #quote ]
								ifFalse: [ w nextPut: c ] ]).
					([ #quote ]
						-> [ w nextPut: c.
							mode := nil ])} ].
	^ exitBlock value
]

{ #category : #private }
MicroPythonParser >> parseTuple [
	^ self parseSequential: Array new upTo: $)
]

{ #category : #accessing }
MicroPythonParser >> stream [
	^ stream
]

{ #category : #accessing }
MicroPythonParser >> stream: anObject [
	stream := anObject
]
