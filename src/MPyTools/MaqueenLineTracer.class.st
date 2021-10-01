"
This is a sample line tracing rover application.
This will be saved as a module file on micro:bit with Micro Maqueen.

This class expects the Micro Maqueen to have a ultra sonic sensor.

Micro Maqueen should have HCSR04 ultra sonic sensor.

Preparation:

MPyTool new
	useSerial;
	uploadClass: MicrobitHCSR04;
	uploadClass: MicroMaqueen;
	uploadClass: MaqueenLineTracer;
	reboot

"
Class {
	#name : #MaqueenLineTracer,
	#superclass : #MicrobitBase,
	#instVars : [
		'maqueen'
	],
	#category : #'MPyTools-Samples'
}

{ #category : #initialization }
MaqueenLineTracer >> initialize [
	self from: #maqueen import: MicroMaqueen.
	maqueen := MicroMaqueen new.
	maqueen useUsonic
]

{ #category : #api }
MaqueenLineTracer >> lightOff [
	maqueen ledLeft: false.
	maqueen ledRight: false
]

{ #category : #api }
MaqueenLineTracer >> lightOn [
	maqueen ledLeft: true.
	maqueen ledRight: true
]

{ #category : #api }
MaqueenLineTracer >> run [
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
			maqueen motorRight: 100.
			self lightOff ].
	[ maqueen distance < 10 ]
		whileTrue: [ maqueen motorLeft: 0.
			maqueen motorRight: 0.
			self lightOn ] ] repeat
]

{ #category : #api }
MaqueenLineTracer >> start [
	| app |
	self isTopLevel: true.
	display scroll: 'Press A'.
	app := MaqueenLineTracer new.
	app lightOn.
	app waitForButtonAPressed.
	app run
]

{ #category : #api }
MaqueenLineTracer >> waitForButtonAPressed [
	[ button_a isPressed ] whileTrue.
	[ button_a isPressed ] whileFalse.
	[ button_a isPressed ] whileTrue
]
