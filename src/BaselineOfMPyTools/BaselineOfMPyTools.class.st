Class {
	#name : #BaselineOfMPyTools,
	#superclass : #BaselineOf,
	#category : #BaselineOfMPyTools
}

{ #category : #baselines }
BaselineOfMPyTools >> baseline: spec [
	spec
		for: #common
		do: [ spec
				package: 'MPyTools';
				package: 'MPyTools-Tests'
					with: [ spec requires: #('Tradukisto' 'Tradukisto-Tests') ] ]
]

{ #category : #accessing }
BaselineOfMPyTools >> projectClass [
    ^ MetacelloCypressBaselineProject
]
