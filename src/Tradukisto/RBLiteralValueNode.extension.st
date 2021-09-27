Extension { #name : #RBLiteralValueNode }

{ #category : #'*Tradukisto' }
RBLiteralValueNode >> asTranslatorNode [
	^ TrConstantNode new
		value: value;
		yourself
]
