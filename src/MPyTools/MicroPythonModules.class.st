Class {
	#name : #MicroPythonModules,
	#superclass : #Object,
	#instVars : [
		'imports',
		'fromImports',
		'importAs'
	],
	#category : #'MPyTools-MicroPython'
}

{ #category : #printing }
MicroPythonModules >> emitOn: aStream [
	imports notEmpty
		ifTrue: 
	[aStream nextPutAll: 'import '.
	imports
		do: [ :each | aStream nextPutAll: each ]
		separatedBy: [ aStream nextPut: $, ].
	aStream cr].
	importAs
		keysAndValuesDo: [ :key :value | 
			aStream
				nextPutAll: 'import ';
				nextPutAll: key;
				nextPutAll: ' as ';
				nextPutAll: value;
				cr ].
	fromImports
		keysAndValuesDo: [ :key :value | 
			aStream
				nextPutAll: 'from ';
				nextPutAll: key;
				space;
				nextPutAll: 'import '.
			value
				do: [ :each | aStream nextPutAll: each ]
				separatedBy: [ aStream nextPut: $, ].
			aStream cr ]
]

{ #category : #api }
MicroPythonModules >> from: aString import: aString2 [
	| m c |
	m := aString asSymbol.
	c := aString2 asSymbol.
	(fromImports at: m ifAbsentPut: [ Set new ]) add: c
]

{ #category : #accessing }
MicroPythonModules >> fromImports [
	^ fromImports
]

{ #category : #api }
MicroPythonModules >> import: aString [
	imports add: aString asSymbol
]

{ #category : #api }
MicroPythonModules >> import: aString as: aString2 [
	| m a |
	m := aString asSymbol.
	a := aString2 asSymbol.
	importAs
		at: m
		ifPresent: [ :x | 
			x = a
				ifFalse: [ self error ].
			^ self ].
	importAs at: m put: a
]

{ #category : #accessing }
MicroPythonModules >> importAs [
	^ importAs
]

{ #category : #accessing }
MicroPythonModules >> imports [
	^ imports
]

{ #category : #initialization }
MicroPythonModules >> initialize [
	imports := Set new.
	fromImports := Dictionary new.
	importAs := Dictionary new
]

{ #category : #printing }
MicroPythonModules >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		nextPut: $(;
		nextPutAll: imports size asString;
		nextPut: $,;
		nextPutAll: importAs size asString;
		nextPut: $,;
		nextPutAll: fromImports size asString;
		nextPut: $)
]
