Extension { #name : #RBReturnNode }

{ #category : #'*Tradukisto' }
RBReturnNode >> asTranslatorNode [
	^ TrReturnNode new
		expression: value asTranslatorNode;
		yourself
]
