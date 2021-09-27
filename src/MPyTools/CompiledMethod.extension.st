Extension { #name : #CompiledMethod }

{ #category : #'*MPyTools' }
CompiledMethod >> asMicroPython [
	^ self classBinding value coderClass new codeStringFromCompiledMethod: self
]
