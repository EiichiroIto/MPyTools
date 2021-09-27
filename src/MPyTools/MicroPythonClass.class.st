Class {
	#name : #MicroPythonClass,
	#superclass : #TrClass,
	#category : #'MPyTools-MicroPython'
}

{ #category : #api }
MicroPythonClass >> addVariablesOf: aClass [
	| cl |
	aClass instVarNames do: [ :each | variables addIfNotPresent: each ].
	cl := aClass.
	[ cl = Object ]
		whileFalse: [ cl classPool
				associationsDo: [ :assoc | 
					assoc value
						ifNotNil: [ self
								constantAt: assoc key
								put: (TrConstantNode new value: assoc value) ] ].
			cl := cl superclass ]
]
