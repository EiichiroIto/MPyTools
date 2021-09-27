Extension { #name : #RBVariableNode }

{ #category : #'*Tradukisto' }
RBVariableNode >> asTranslatorNode [
	name = 'true'
		ifTrue: [ ^ TrConstantNode new
				value: true;
				yourself ].
	name = 'false'
		ifTrue: [ ^ TrConstantNode new
				value: false;
				yourself ].
	^ TrVariableNode new
		name: name;
		yourself
]
