Extension { #name : #RBSequenceNode }

{ #category : #'*Tradukisto' }
RBSequenceNode >> asTranslatorNode [
	^ TrStatementListNode new
		arguments: #();
		statements: (statements collect: [ :each | each asTranslatorNode ]);
		yourself
]
