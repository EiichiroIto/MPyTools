Class {
	#name : #IdentifierGenerator,
	#superclass : #Object,
	#instVars : [
		'current'
	],
	#category : #'MPyTools-MicroPython'
}

{ #category : #accessing }
IdentifierGenerator >> current [
	^ current
]

{ #category : #accessing }
IdentifierGenerator >> current: anObject [
	current := anObject
]

{ #category : #api }
IdentifierGenerator >> next [
	| tmp |
	current ifNil: [ ^ current := 'a' ].
	current last = $z
		ifFalse: [ tmp := current asByteArray.
			tmp atLast: 1 put: (tmp atLast: 1) + 1.
			^ current := tmp asString ].
	^ current := (ByteArray new: current size + 1 withAll: $a asciiValue)
		asString
]
