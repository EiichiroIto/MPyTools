"
A MicroPythonModulesTest is a test class for testing the behavior of MicroPythonModules
"
Class {
	#name : #MicroPythonModulesTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
MicroPythonModulesTest >> newModules [
	^ MicroPythonModules new
]

{ #category : #test }
MicroPythonModulesTest >> testEmitOn [
	| m s |
	m := self newModules.
	m import: #a.
	m import: #b as: #c.
	m from: #d import: #e.
	s := WriteStream on: String new.
	m emitOn: s.
	self
		assert: s contents
		equals:
			'import a' , String cr , 'import b as c' , String cr
				, 'from d import e' , String cr
]

{ #category : #test }
MicroPythonModulesTest >> testFromImport [
	| m |
	m := self newModules.
	m from: 'a' import: 'b'.
	m from: 'b' import: 'c'.
	m from: 'a' import: 'd'.
	self assert: m fromImports size equals: 2.
	self assert: (m fromImports at: #a) size equals: 2.
	self assert: ((m fromImports at: #a) includes: #b).
	self assert: ((m fromImports at: #a) includes: #d).
	self assert: (m fromImports at: #b) size equals: 1.
	self assert: ((m fromImports at: #b) includes: #c)
]

{ #category : #test }
MicroPythonModulesTest >> testFromImports [
	| m |
	m := self newModules.
	self assert: (m fromImports isKindOf: Dictionary).
	self assert: m fromImports isEmpty
]

{ #category : #test }
MicroPythonModulesTest >> testImport [
	| m |
	m := self newModules.
	self assert: (m imports isKindOf: Set).
	self assert: m imports isEmpty
]

{ #category : #test }
MicroPythonModulesTest >> testImportAs [
	| m |
	m := self newModules.
	self assert: (m importAs isKindOf: Dictionary).
	self assert: m importAs isEmpty.
	m import: #a as: #b.
	m import: #c as: #d.
	self assert: (m importAs at: #a) equals: #b.
	self assert: (m importAs at: #c) equals: #d.
	self should: [ m import: #a as: #e ] raise: Error
]

{ #category : #test }
MicroPythonModulesTest >> testImports [
	| m |
	m := self newModules.
	m import: #a.
	m import: #b.
	m import: 'c'.
	m import: 'a'.
	self assert: m imports size equals: 3.
	self assert: (m imports includes: #a).
	self assert: (m imports includes: #b).
	self assert: (m imports includes: #c).
	
]

{ #category : #test }
MicroPythonModulesTest >> testInitialize [
	| m |
	m := self newModules.
	self assert: (m fromImports isKindOf: Dictionary).
	self assert: (m imports isKindOf: Set).
	self assert: m fromImports isEmpty.
	self assert: m imports isEmpty.
	self assert: (m importAs isKindOf: Dictionary).
	self assert: m importAs isEmpty
]

{ #category : #test }
MicroPythonModulesTest >> testPrintOn [
	| m s |
	m := self newModules.
	s := WriteStream on: String new.
	m printOn: s.
	self assert: s contents equals: 'MicroPythonModules(0,0,0)'.
	m import: #a.
	m import: #b.
	m from: #c import: #d.
	m import: #x as: #y.
	m import: #y as: #w.
	m import: #z as: #v.
	s := WriteStream on: String new.
	m printOn: s.
	self assert: s contents equals: 'MicroPythonModules(2,3,1)'
]
