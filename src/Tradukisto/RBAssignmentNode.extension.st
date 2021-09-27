Extension { #name : #RBAssignmentNode }

{ #category : #'*Tradukisto' }
RBAssignmentNode >> asTranslatorNode [
	^ TrAssignmentNode new
		variable: variable asTranslatorNode;
		expression: value asTranslatorNode;
		yourself
]
