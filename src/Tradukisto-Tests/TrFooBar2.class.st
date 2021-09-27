Class {
	#name : #TrFooBar2,
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
TrFooBar2 class >> example2 [
	self asSLang inspect
]

{ #category : #'class initialization' }
TrFooBar2 class >> initialize [
	"TrFooBar initialize"
	DispatchTable := Array new: 3.
	DispatchTable at: 1 put: #dispatch1.
	DispatchTable at: 2 put: #dispatch2.
	DispatchTable at: 3 put: #dispatch3
]

{ #category : #private }
TrFooBar2 >> dispatch1 [
	| cntx val |
	cntx := self sender.
	val := #receiver.
	self returnValue: val to: cntx
]

{ #category : #private }
TrFooBar2 >> dispatch2 [
	| cntx val |
	cntx := self sender.
	val := #trueObj.
	self returnValue: val to: cntx
]

{ #category : #private }
TrFooBar2 >> dispatch3 [
	| cntx val |
	cntx := self sender.
	val := #falseObj.
	self returnValue: val to: cntx.

]

{ #category : #private }
TrFooBar2 >> interpret [
	self dispatchOn: counter in: DispatchTable
]

{ #category : #private }
TrFooBar2 >> returnValue: resultObj to: returnContext [
	| nilOop thisCntx |
	self inline: true.
	"self sharedCodeNamed: 'commonReturn' inCase: 0."
	nilOop := #nilObj.	"keep in a register"
	thisCntx := #activeContext.
	nilOop > 0 ifTrue: [ ^ self ].
	counter := nilOop - thisCntx
]

{ #category : #private }
TrFooBar2 >> sender [
	^ #sender
]
