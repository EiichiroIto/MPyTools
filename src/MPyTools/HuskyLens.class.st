Class {
	#name : #HuskyLens,
	#superclass : #MicrobitBase,
	#classVars : [
		'BarcodeRecognition',
		'ColorRecognition',
		'FaceRecognition',
		'I2CAddr',
		'LineTracking',
		'ObjectClassification',
		'ObjectRecognition',
		'ObjectTracking',
		'QrCodeRecognition',
		'TagRecognition'
	],
	#category : #'MPyTools-Samples'
}

{ #category : #'class initialization' }
HuskyLens class >> initialize [
	"self initialize"

	I2CAddr := 50.
	FaceRecognition := 0.
	ObjectTracking := 1.
	ObjectRecognition := 2.
	LineTracking := 3.
	ColorRecognition := 4.
	TagRecognition := 5.
	ObjectClassification := 6.
	QrCodeRecognition := 7.
	BarcodeRecognition := 8
]

{ #category : #api }
HuskyLens >> arrows [
	| cmd |
	self isFunction: true.
	cmd := self header , #[16r00 16r22 16r32].
	i2c write: cmd to: I2CAddr.
	^ self processReturnData
]

{ #category : #api }
HuskyLens >> blocks [
	| cmd |
	self isFunction: true.
	cmd := self header , #[16r00 16r21 16r31].
	i2c write: cmd to: I2CAddr.
	^ self processReturnData
]

{ #category : #private }
HuskyLens >> checksumOf: aByteArray [
	| total |
	self isFunction: true.
	total := 0.
	aByteArray do: [ :each | total := total + each ].
	^ total bitAnd: 255
]

{ #category : #private }
HuskyLens >> convertToClassObject: aCollection isBlock: aBoolean [
	| tmp obj |
	self isFunction: true.
	tmp := OrderedCollection new.
	aCollection
		do: [ :i | 
			obj := aBoolean
				ifTrue: [ {'block'.
					(i at: 0).
					(i at: 1).
					(i at: 2).
					(i at: 3).
					(i at: 4)} ]
				ifFalse: [ {'arrow'.
					(i at: 0).
					(i at: 1).
					(i at: 2).
					(i at: 3).
					(i at: 4)} ].
			tmp append: obj ].
	^ tmp
]

{ #category : #samples }
HuskyLens >> detectFace [
	| ret |
	self isFunction: true.
	self selectAlgorithm: FaceRecognition.
	[ ret := self blocks.
	ret isEmpty
		ifTrue: [ display clear ]
		ifFalse: [ display scroll: ret size asString ].
	time sleepMs: 100 ] repeat
]

{ #category : #private }
HuskyLens >> getBlockOrArrowCommand [
	| byteString commandSplit isBlock |
	self isFunction: true.
	byteString := i2c read: 5 from: I2CAddr.
	byteString := byteString
		, (i2c read: (byteString at: 3) + 1 from: I2CAddr).
	commandSplit := self splitCommandToParts: byteString.
	isBlock := (commandSplit at: 3) = 16r2A.
	^ {(commandSplit at: 4).
	isBlock}
]

{ #category : #private }
HuskyLens >> header [
	self isFunction: true.
	^ #[16r55 16rAA 16r11]
]

{ #category : #api }
HuskyLens >> knock [
	self isFunction: true.
	i2c write: self header , #[16r00 16r2c 16r3c] to: I2CAddr.
	^ self processReturnData
]

{ #category : #private }
HuskyLens >> processReturnData [
	| r1 r2 commandSplit returnData numberOfBlocksOrArrow tmp isBlock finalData val high low |
	self isFunction: true.
	r1 := i2c read: 5 from: I2CAddr.
	"self print: r1."
	r2 := i2c read: (r1 at: 3) + 1 from: I2CAddr.
	"self print: r2."
	commandSplit := self splitCommandToParts: r1 , r2.
	"self print: commandSplit."
	(commandSplit at: 3) = 16r2E
		ifTrue: [ ^ {'knockReceived'} ].
	tmp := commandSplit at: 4.
	tmp size < 2
		ifTrue: [ ^ #() asOrderedCollection ].
	numberOfBlocksOrArrow := (tmp at: 1) * 256 + (tmp at: 0).
	"numberOfIDLearned := (tmp at: 3) * 256 + (tmp at: 2)."
	"frameNumber := (tmp at: 5) * 256 + (tmp at: 4)."
	isBlock := true.
	returnData := OrderedCollection new.
	numberOfBlocksOrArrow
		timesRepeat: [ tmp := self getBlockOrArrowCommand.
			isBlock := tmp second.
			returnData add: tmp first ].
	finalData := OrderedCollection new.
	returnData
		do: [ :i | 
			tmp := OrderedCollection new.
			0 to: i size - 1 by: 2 do: [ :q | 
				low := i at: q.
				high := i at: q + 1.
				val := low.
				high > 0
					ifTrue: [ low + 255 + high ].
				tmp add: val ].
			finalData add: tmp ].
	^ self convertToClassObject: finalData isBlock: isBlock
]

{ #category : #api }
HuskyLens >> requestAll [
	| cmd |
	self isFunction: true.
	cmd := self header , #[16r00 16r20 16r30].
	i2c write: cmd to: I2CAddr.
	^ self processReturnData
]

{ #category : #api }
HuskyLens >> selectAlgorithm: anInteger [
	| cmd csum |
	self isFunction: true.
	(anInteger between: 0 and: 8)
		ifFalse: [ ^ self ].
	cmd := self header , #[16r02 16r2d] , { anInteger . 0 } asByteArray.
	csum := (self checksumOf: cmd).
	cmd := cmd , {csum} asByteArray.
	i2c write: cmd to: I2CAddr.
	time sleepMs: 100.
	^ self processReturnData
]

{ #category : #private }
HuskyLens >> splitCommandToParts: aByteArray [
	| headers address dataLength command checkSum data |
	self isFunction: true.
	headers := (aByteArray at: 0) * 256 + (aByteArray at: 1).
	address := aByteArray at: 2.
	dataLength := aByteArray at: 3.
	command := aByteArray at: 4.
	dataLength > 0
		ifTrue: [ data := aByteArray copyFrom: 5 to: 5 + dataLength - 1 ]
		ifFalse: [ data := OrderedCollection new ].
	checkSum := aByteArray at: 5 + dataLength.
	^ {headers.
	address.
	dataLength.
	command.
	data.
	checkSum}
]
