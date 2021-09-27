Extension { #name : #RBArrayNode }

{ #category : #'*Tradukisto' }
RBArrayNode >> asTranslatorNode [
	^ TrArrayNode new
		contents: (statements collect: #asTranslatorNode);
		isByteArray: false;
		yourself
]
