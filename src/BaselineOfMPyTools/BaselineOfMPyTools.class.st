Class {
	#name : #BaselineOfMPyTools,
	#superclass : #BaselineOf,
	#category : #BaselineOfMPyTools
}

{ #category : #baselines }
BaselineOfMPyTools >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec
			package: 'Tradukisto';
			package: 'Tradukisto-Tests'
			with: [ spec requires: #( 'Tradukisto' ) ];
			package: 'MicroPythonProxy';
			package: 'MPyTools'
			with: [ spec requires: #( 'Tradukisto' 'MicroPythonProxy' ) ];
			package: 'MPyTools-Tests'
			with: [ 
				spec requires: #( 'Tradukisto' 'MPyTools' 'MicroPythonProxy' ) ] ]
]

{ #category : #accessing }
BaselineOfMPyTools >> projectClass [
    ^ MetacelloCypressBaselineProject
]
