"
This is a sample line tracing rover application.
This will be saved as a module file on micro:bit with Micro Maqueen.

Preparation:

MPyTool new
	useSerial;
	uploadClass: MicrobitHCSR04;
	uploadClass: MicroMaqueen;
	uploadClass: MicrobitLineTracer;
	reboot;
	close

"
Class {
	#name : #MicrobitLineTracer,
	#superclass : #MicrobitBase,
	#instVars : [
		'maqueen'
	],
	#category : #'MPyTools-Samples'
}

{ #category : #accessing }
MicrobitLineTracer class >> filename [
	^ 'main.py'
]

{ #category : #initialization }
MicrobitLineTracer >> initialize [
	self from: #maqueen import: MicroMaqueen.
	maqueen := MicroMaqueen new.
	maqueen useUsonic
]

{ #category : #api }
MicrobitLineTracer >> run [
	[ (maqueen isLineLeft and: [ maqueen isLineRight ])
		ifTrue: [ #pass ].
	(maqueen isLineLeft and: [ maqueen isLineRight not ])
		ifTrue: [ maqueen motorLeft: 100.
			maqueen motorRight: 0 ].
	(maqueen isLineLeft not and: [ maqueen isLineRight ])
		ifTrue: [ maqueen motorLeft: 0.
			maqueen motorRight: 100 ].
	(maqueen isLineLeft not and: [ maqueen isLineRight not ])
		ifTrue: [ maqueen motorLeft: 100.
			maqueen motorRight: 100 ].
	[ maqueen distance < 10 ]
		whileTrue: [ maqueen motorLeft: 0.
			maqueen motorRight: 0 ] ] repeat
]

{ #category : #api }
MicrobitLineTracer >> start [
	| app |
	self isTopLevel: true.
	display scroll: 'Press A'.
	app := MicrobitLineTracer new.
	app waitForButtonAPressed.
	app run
]

{ #category : #api }
MicrobitLineTracer >> waitForButtonAPressed [
	[ button_a isPressed ] whileTrue.
	[ button_a isPressed ] whileFalse.
	[ button_a isPressed ] whileTrue
]
