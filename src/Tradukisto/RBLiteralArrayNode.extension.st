Extension { #name : #RBLiteralArrayNode }

{ #category : #'*Tradukisto' }
RBLiteralArrayNode >> asTranslatorNode [
	^ TrArrayNode new
		contents: (contents collect: #asTranslatorNode);
		isByteArray: isByteArray;
		yourself
]
