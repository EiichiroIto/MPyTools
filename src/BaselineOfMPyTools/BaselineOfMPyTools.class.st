Class {
	#name : #BaselineOfMPyTools,
	#superclass : #BaselineOf,
	#category : #BaselineOfMPyTools
}

{ #category : #baselines }
BaselineOfMPyTools >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				package: 'Tradukisto';
				package: 'Tradukisto-Tests'
					with: [ spec requires: #('Tradukisto') ];
				package: 'MPyTools'
					with: [ spec requires: #('Tradukisto') ];
				package: 'MPyTools-Tests'
					with: [ spec requires: #('Tradukisto' 'MPyTools') ] ]
]

{ #category : #accessing }
BaselineOfMPyTools >> projectClass [
    ^ MetacelloCypressBaselineProject
]
