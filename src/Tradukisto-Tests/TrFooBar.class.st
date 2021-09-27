Class {
	#name : #TrFooBar,
	#superclass : #Object,
	#instVars : [
		'counter'
	],
	#classVars : [
		'DispatchTable'
	],
	#category : #'Tradukisto-Tests-Samples'
}

{ #category : #examples }
TrFooBar class >> example2 [
	self asSLang inspect
]

{ #category : #'class initialization' }
TrFooBar class >> initialize [
	"TrFooBar initialize"
	DispatchTable := Array new: 3.
	DispatchTable at: 1 put: #dispatch1.
	DispatchTable at: 2 put: #dispatch2.
	DispatchTable at: 3 put: #dispatch3
]

{ #category : #accessing }
TrFooBar >> abs: aNumber [
	aNumber >= 0
		ifTrue: [ ^ aNumber ].
	^ aNumber negated
]

{ #category : #private }
TrFooBar >> assertEven [
	self assert: (counter \\ 2) == 0
]

{ #category : #accessing }
TrFooBar >> counter [
	^ counter + 1
]

{ #category : #initialization }
TrFooBar >> initialize [
	counter := 0
]

{ #category : #private }
TrFooBar >> partialReturn: x [
	(self abs: x) > 10
		ifTrue: [ ^ self ].
	self initialize
]

{ #category : #private }
TrFooBar >> plus: a and: b [
	^ a + b
]

{ #category : #accessing }
TrFooBar >> selfReturn [
	self initialize.
	self counter.
	^ self
]

{ #category : #private }
TrFooBar >> sender [
	^ #sender
]

{ #category : #private }
TrFooBar >> sum [
	| a |
	a := 1.
	1 to: 10 do: [ :each | a := a + each ].
	^ a
]

{ #category : #private }
TrFooBar >> sumFrom: x [
	| a |
	a := x.
	1 to: 10 do: [ :each | a := a + each ].
	^ a
]
