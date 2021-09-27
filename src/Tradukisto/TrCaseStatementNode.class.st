Class {
	#name : #TrCaseStatementNode,
	#superclass : #TrNode,
	#instVars : [
		'expression',
		'firsts',
		'lasts',
		'cases'
	],
	#category : #'Tradukisto-Nodes'
}

{ #category : #private }
TrCaseStatementNode >> allVariablesInto: aSet [
	expression allVariablesInto: aSet
]

{ #category : #api }
TrCaseStatementNode >> bindVariableUsesIn: aDictionary [
	expression := expression bindVariableUsesIn: aDictionary.
	cases := cases collect: [ :c | c bindVariableUsesIn: aDictionary ]
]

{ #category : #api }
TrCaseStatementNode >> bindVariablesIn: aDictionary [
	expression := expression bindVariablesIn: aDictionary.
	cases := cases collect: [ :c | c bindVariablesIn: aDictionary ]
]

{ #category : #accessing }
TrCaseStatementNode >> cases [
	^ cases
]

{ #category : #accessing }
TrCaseStatementNode >> cases: anObject [
	cases := anObject
]

{ #category : #enumerating }
TrCaseStatementNode >> casesDo: aBlock [
	cases
		withIndexDo:
			[ :each :index | aBlock cull: each cull: (firsts at: index) cull: (lasts at: index) ]
]

{ #category : #copying }
TrCaseStatementNode >> copyTree [
	^ self class new
		expression: expression copyTree;
		firsts: firsts copy;
		lasts: lasts copy;
		cases: (cases collect: [ :case | case copyTree ])
]

{ #category : #private }
TrCaseStatementNode >> customizeCase: caseParseTree forVar: varName from: firstIndex to: lastIndex [
	"Return a collection of copies of the given parse tree, each of which has the value of the case index substituted for the given variable."

	| newCases dict newCase |
	newCases := OrderedCollection new.
	firstIndex to: lastIndex do: [ :caseIndex | 
		dict := Dictionary new.
		dict at: varName put: (TrConstantNode new value: caseIndex).
		newCase := caseParseTree copyTree bindVariableUsesIn: dict.
		self fixSharedCodeBlocksForCase: caseIndex in: newCase.
		newCases addLast: newCase ].
	^ newCases
]

{ #category : #private }
TrCaseStatementNode >> customizeShortCasesForDispatchVar: varName [
	"Make customized versions of a short bytecode methods, substituting a constant having the case index value for the given variable. This produces better code for short bytecodes such as instance variable pushes that encode the index of the instance variable in the bytecode."

	| newFirsts newLasts newCases expanded |
	newFirsts := OrderedCollection new.
	newLasts := OrderedCollection new.
	newCases := OrderedCollection new.
	self
		casesDo: [ :case :f :l | 
			expanded := false.
			l - f > 1
				ifTrue: [ "case code covers multiple cases"
					case nodeCount < 60
						ifTrue: [ newFirsts addAll: (f to: l).
							newLasts addAll: (f to: l).
							newCases
								addAll:
									(self
										customizeCase: case
										forVar: varName
										from: f
										to: l).
							expanded := true ] ].
			expanded
				ifFalse: [ self fixSharedCodeBlocksForCase: f in: case.
					newFirsts addLast: f.
					newLasts addLast: l.
					newCases addLast: case ] ].
	firsts := newFirsts asArray.
	lasts := newLasts asArray.
	cases := newCases asArray
]

{ #category : #translate }
TrCaseStatementNode >> emitCode: aCoder on: aStream indent: anInteger [
	aCoder emitCaseStatement: self on: aStream indent: anInteger
]

{ #category : #accessing }
TrCaseStatementNode >> expression [
	^ expression
]

{ #category : #accessing }
TrCaseStatementNode >> expression: anObject [
	expression := anObject
]

{ #category : #api }
TrCaseStatementNode >> expression: aNode selectors: selectorList [
	"Initialize the node from the given set of selectors."

	"Note: Each case is a statement list with containing one statement, a send to self of a selector from the given selector list. Having statement list nodes makes inlining easier later."

	| selfNode stmt lastSel firstInRun |
	expression := aNode.
	selfNode := TrVariableNode new name: 'self'.
	firsts := OrderedCollection new: 400.
	lasts := OrderedCollection new: 400.
	cases := OrderedCollection new: 400.
	lastSel := selectorList first.
	firstInRun := 0.
	selectorList
		withIndexDo: [ :sel :i | 
			sel ~= lastSel
				ifTrue: [ firsts add: firstInRun.
					lasts add: i - 2.
					stmt := TrSendNode new
						selector: lastSel;
						receiver: selfNode;
						arguments: #().
					cases
						add:
							(TrStatementListNode new
								arguments: #();
								statements: (Array with: stmt)).
					lastSel := sel.
					firstInRun := i - 1 ] ].
	firsts add: firstInRun.
	lasts add: selectorList size - 1.
	stmt := TrSendNode new
		selector: lastSel;
		receiver: selfNode;
		arguments: #().
	cases
		add:
			(TrStatementListNode new
				arguments: #();
				statements: (Array with: stmt))
]

{ #category : #accessing }
TrCaseStatementNode >> firsts [
	^ firsts
]

{ #category : #accessing }
TrCaseStatementNode >> firsts: anObject [
	firsts := anObject
]

{ #category : #private }
TrCaseStatementNode >> fixSharedCodeBlocksForCase: caseIndex in: caseParseTree [
	"Process 'sharedCode' directives in the given parse tree. The sharedCode directive allows code replicated in different arms of a case statement to be shared. The replicated code must be the final code of the case so that it ends with a break out of the case statement. The replicated code will be generated in exactly one arm of the case statement; other instances of the shared code will be replaced by branches to that single instance of the code."

	"NOTE: I have made this work for the nested case (ie several shared entry points in the same case, but it does not really work for methods with arguments.  A mechanism coud be added that would add a preamble of the form,
	innerSharedTemp = outerTemp;
when they differed.  There should at least be a test here."

	| copying oldStmts newStmts codeBlockName |
	caseParseTree
		nodesDo: [ :node | 
			node isStatementList
				ifTrue: [ copying := true.
					oldStmts := node statements asArray.
					newStmts := nil.	"becomes an OrderedCollection if sharedCode block is found"
					oldStmts
						withIndexDo: [ :stmt :i | 
							copying
								ifTrue: [ (stmt isSend and: [ stmt selector = #sharedCodeNamed:inCase: ])
										ifTrue: [ newStmts
												ifNil: [ newStmts := (oldStmts copyFrom: 1 to: i - 1) asOrderedCollection ]
												ifNotNil: [ newStmts removeLast	"preserve any prior shared entry points - di" ].
											codeBlockName := stmt arguments first value.
											stmt arguments last value = caseIndex
												ifTrue: [ newStmts
														add:
															(TrLabeledCommentNode new
																label: codeBlockName;
																comment: '') ]
												ifFalse: [ newStmts add: (TrGoToNode new label: codeBlockName; yourself).
													copying := false	"don't copy remaining statements" ] ]
										ifFalse: [ newStmts ifNotNil: [ newStmts add: stmt ] ] ]
								ifFalse: [ "ikp: this permits explicit returns before 'goto aSharedCodeLabel'"
									(stmt isLabel and: [ stmt label notNil ])
										ifTrue: [ newStmts add: stmt ] ] ].
					newStmts
						ifNotNil: [ node statements: newStmts asOrderedCollection ] ] ]
]

{ #category : #api }
TrCaseStatementNode >> inlineMethodsUsing: aDictionary [
	expression inlineMethodsUsing: aDictionary.
	cases do: [ :c | c inlineMethodsUsing: aDictionary ]
]

{ #category : #testing }
TrCaseStatementNode >> isCaseStatement [
	^ true
]

{ #category : #accessing }
TrCaseStatementNode >> lasts [
	^ lasts
]

{ #category : #accessing }
TrCaseStatementNode >> lasts: anObject [
	lasts := anObject
]

{ #category : #enumerating }
TrCaseStatementNode >> nodesDo: aBlock [
	expression nodesDo: aBlock.
	cases do: [ :c | c nodesDo: aBlock ].
	aBlock value: self
]

{ #category : #printing }
TrCaseStatementNode >> printOn: aStream level: level [
	aStream
		crtab: level;
		nextPutAll: 'select '.
	expression printOn: aStream level: level.
	aStream nextPutAll: ' in'.
	self
		casesDo: [ :case :first :last | 
			first to: last do: [ :caseIndex | 
				aStream
					crtab: level;
					nextPutAll: 'case ';
					nextPutAll: caseIndex printString;
					nextPutAll: ':' ].
			aStream crtab: level + 1.
			case printOn: aStream level: level + 1 ].
	aStream
		crtab: level;
		nextPutAll: 'end select'
]

{ #category : #api }
TrCaseStatementNode >> removeAssertions [
	expression removeAssertions.
	cases do: [ :case | case removeAssertions ]
]

{ #category : #api }
TrCaseStatementNode >> replaceNodesIn: aDictionary [
	^ aDictionary
		at: self
		ifAbsent: [ expression := expression replaceNodesIn: aDictionary.
			cases := cases collect: [ :c | c replaceNodesIn: aDictionary ].
			self ]
]
