Class {
	#name : #MicroPythonMethod,
	#superclass : #TrMethod,
	#instVars : [
		'type'
	],
	#category : #'MPyTools-MicroPython'
}

{ #category : #private }
MicroPythonMethod >> buildRenameVariableTableReserved: aCollection [
	| set reserved gen v |
	set := Set new.
	self allVariablesInto: set.
	set := set reject: [ :each | each first isUppercase ].
	set removeAllFoundIn: aCollection.
	reserved := aCollection asOrderedCollection.
	reserved addAll: (set select: [ :each | each size = 1 ]).
	set := set reject: [ :each | each size = 1 ].
	gen := IdentifierGenerator new.
	^ (set asArray sorted
		collect: [ :each | 
			[ v := gen next.
			reserved includes: v ] whileTrue.
			reserved add: v.
			each -> v ]) asDictionary
]

{ #category : #initialization }
MicroPythonMethod >> initialize [
	super initialize.
	type := #method
]

{ #category : #testing }
MicroPythonMethod >> isFunction [
	^ type = #function
]

{ #category : #testing }
MicroPythonMethod >> isFunction: anObject [
	type := anObject
		ifTrue: [ #function ]
		ifFalse: [ #method ]
]

{ #category : #testing }
MicroPythonMethod >> isMethod [
	^ type = #method
]

{ #category : #testing }
MicroPythonMethod >> isTopLevel [
	^ type = #topLevel
]

{ #category : #testing }
MicroPythonMethod >> isTopLevel: anObject [
	type := anObject
		ifTrue: [ #topLevel ]
		ifFalse: [ #method ]
]

{ #category : #api }
MicroPythonMethod >> setupFrom: aMethod [
	super setupFrom: aMethod.
	(self extractDirective: #isFunction:)
		ifTrue: [ ^ self isFunction: true ].
	(self extractDirective: #isTopLevel:)
		ifTrue: [ ^ self isTopLevel: true ]
]

{ #category : #accessing }
MicroPythonMethod >> type [
	^ type
]

{ #category : #accessing }
MicroPythonMethod >> type: anObject [
	type := anObject
]
