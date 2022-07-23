Extension { #name : #RBMessageNode }

{ #category : #'*Tradukisto' }
RBMessageNode >> asTranslatorNode [
	"Selector is sometimes a Symbol, sometimes a SelectorNode!! On top of this, numArgs is needed due to the (truly grody) use of arguments as a place to store the extra expressions needed to generate code for in-line to:by:do:, etc. See below, where it is used."

	| args |
	args := arguments collect: #asTranslatorNode.
	(selector = #to:by:do:
		and: [ arguments size = 7 and: [ (arguments at: 7) notNil ] ])
		ifTrue:
			[ "Restore limit expr that got moved by transformToDo:" args at: 1 put: (arguments at: 7) value asTranslatorNode ].
	(selector = #or:
		and: [ arguments size = 2 and: [ (arguments at: 2) notNil ] ])
		ifTrue:
			[ "Restore argument block that got moved by transformOr:" args at: 1 put: (arguments at: 2) asTranslatorNode ].
	(selector = #ifFalse:
		and: [ arguments size = 2 and: [ (arguments at: 2) notNil ] ])
		ifTrue:
			[ "Restore argument block that got moved by transformIfFalse:" args at: 1 put: (arguments at: 2) asTranslatorNode ].
	^ TrSendNode new
		selector: selector value;
		receiver: (receiver ifNil: [ nil ] ifNotNil: [ receiver asTranslatorNode ]);
		arguments: args;
		yourself
]
