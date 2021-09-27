Extension { #name : #RBBlockNode }

{ #category : #'*Tradukisto' }
RBBlockNode >> asTranslatorNode [

	| statementList newS |
	statementList := OrderedCollection new.
	body do: [:s |
		newS := s asTranslatorNode.
		newS isStatementList
			ifTrue: [
				"inline the statement list returned when a CascadeNode is translated"
				statementList addAll: newS statements]
			ifFalse: [
				statementList add: newS]].

	^ TrStatementListNode new
		arguments: (arguments asArray collect: [:arg | arg name]);
		statements: statementList
]
