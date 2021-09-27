Extension { #name : #RBCascadeNode }

{ #category : #'*Tradukisto' }
RBCascadeNode >> asTranslatorNode [

	^ TrStatementListNode new
		arguments: #();
		statements:
			(messages collect: [:msg |
				msg asTranslatorNode receiver: self receiver asTranslatorNode])
]
