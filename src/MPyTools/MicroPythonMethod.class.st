Class {
	#name : #MicroPythonMethod,
	#superclass : #TrMethod,
	#instVars : [
		'type'
	],
	#category : #'MPyTools-MicroPython'
}

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
MicroPythonMethod >> renameVariablesUsing: aDictionary [
	"do nothing"
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
