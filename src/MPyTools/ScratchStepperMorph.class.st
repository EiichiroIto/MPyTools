Class {
	#name : #ScratchStepperMorph,
	#superclass : #Morph,
	#instVars : [
		'block',
		'stepTime'
	],
	#category : #'MPyTools-GUI'
}

{ #category : #private }
ScratchStepperMorph >> defaultStepTime [
	^ 100
]

{ #category : #'stepping and presenter' }
ScratchStepperMorph >> step [
	block ifNil: [ ^ self ].
	block value
]

{ #category : #stepping }
ScratchStepperMorph >> stepTime [
	^ stepTime ifNil: [ self defaultStepTime ]
]

{ #category : #stepping }
ScratchStepperMorph >> stepTime: anInteger [
	stepTime := anInteger
]

{ #category : #'stepping and presenter' }
ScratchStepperMorph >> wantsSteps [
	^ true
]

{ #category : #accessing }
ScratchStepperMorph >> whenStepsDo: aBlock [
	block := aBlock
]
