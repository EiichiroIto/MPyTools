Class {
	#name : #MicrobitCoder,
	#superclass : #MicroPythonCoder,
	#category : #'MPyTools-MicroPython'
}

{ #category : #translation }
MicrobitCoder >> generateAt: msgNode on: aStream indent: level [
	| rcvr |
	rcvr := msgNode receiver.
	(rcvr isVariable and: [ rcvr name = 'Image' ])
		ifTrue: [ aStream nextPutAll: 'Image.'.
			msgNode arguments first emitCode: self on: aStream indent: level.
			^ self ].
	super generateAt: msgNode on: aStream indent: level
]

{ #category : #translation }
MicrobitCoder >> generateGetPixelXY: aNode on: aStream indent: anInteger [
	self generateFunction: 'get_pixel' node: aNode on: aStream indent: anInteger
]

{ #category : #translation }
MicrobitCoder >> generateReadFrom: aNode on: aStream indent: anInteger [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: '.read('.
	self emitExpression: aNode arguments second on: aStream.
	aStream nextPut: $,.
	self emitExpression: aNode arguments first on: aStream.
	aStream nextPut: $)
]

{ #category : #translation }
MicrobitCoder >> generateSetPixelXYTo: aNode on: aStream indent: anInteger [
	self generateFunction: 'set_pixel' node: aNode on: aStream indent: anInteger
]

{ #category : #translation }
MicrobitCoder >> generateWriteTo: aNode on: aStream indent: anInteger [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: '.write('.
	self emitExpression: aNode arguments second on: aStream.
	aStream nextPut: $,.
	self emitExpression: aNode arguments first on: aStream.
	aStream nextPut: $)
]

{ #category : #private }
MicrobitCoder >> translationPair [
	^ super translationPair
		,
			#(
		#getPixelX:y: #generateGetPixelXY:on:indent:
		#setPixelX:y:to: #generateSetPixelXYTo:on:indent:
		#write:to: #generateWriteTo:on:indent:
		#read:from: #generateReadFrom:on:indent:
			)
]
