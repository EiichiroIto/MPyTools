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
MicrobitCoder >> generateReadFrom: aNode on: aStream indent: anInteger [
	self emitExpression: aNode receiver on: aStream.
	aStream nextPutAll: '.read('.
	self emitExpression: aNode arguments second on: aStream.
	aStream nextPut: $,.
	self emitExpression: aNode arguments first on: aStream.
	aStream nextPut: $)
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
MicrobitCoder >> simpleTranslationPair [
	^ super simpleTranslationPair
		,
			#(
		#getPixelX:y: #get_pixel
		#setPixelX:y:to: #set_pixel
			)
]

{ #category : #private }
MicrobitCoder >> translationPair [
	^ super translationPair
		,
			#(
		#write:to: #generateWriteTo:on:indent:
		#read:from: #generateReadFrom:on:indent:
			)
]
