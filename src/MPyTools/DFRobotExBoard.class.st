"
This is a sample module for DF-Robot Driver Expansion Board.
This will be saved as a module file on micro:bit.

Preparation:

MPyTool new
	useSerial;
	uploadClass: DFRobotExBoard.

Usage:
	self from: #exboard import: DFRobotExBoard.
	ex := DFRobotExBoard new.
	ex motor: 1 speed: 100.
	ex motor: 2 speed: 100.
	time sleep: 3.
	ex motor: 1 speed: 0.
	ex motor: 2 speed: 0.
	time sleep: 3.
	ex motor: 1 speed: -100.
	ex motor: 2 speed: -100.
	time sleep: 3.
	ex motor: 1 speed: 0.
	ex motor: 2 speed: 0.
	time sleep: 3.
	ex servo: 1 degree: 0.
	time sleep: 1.
	ex servo: 1 degree: 180.
	time sleep: 1.
	ex servo: 1 degree: 90.
"
Class {
	#name : #DFRobotExBoard,
	#superclass : #MicrobitBase,
	#category : #'MPyTools-Samples'
}

{ #category : #accessing }
DFRobotExBoard class >> filename [
	^ 'exboard.py'
]

{ #category : #private }
DFRobotExBoard >> ch: channel pwm: off [
	| buf |
	(channel < 0 or: [ channel > 15 ])
		ifTrue: [ ^ self ].
	buf := {(4 * channel + 6).
	0.
	0.
	(off bitAnd: 255).
	(off >> 8 bitAnd: 255)}.
	i2c write: buf asByteArray to: 64
]

{ #category : #initialization }
DFRobotExBoard >> initialize [
	| oldmode newmode |
	i2c write: #[0 0] to: 64.
	oldmode := (i2c read: 1 from: 64) at: 0.
	newmode := (oldmode bitAnd: 127) bitOr: 16.
	i2c
		write:
			{0.
			newmode} asByteArray
		to: 64.
	i2c write: #[254 121] to: 64.
	i2c
		write:
			{0.
			oldmode} asByteArray
		to: 64.
	time sleepUs: 5000.
	i2c
		write:
			{0.
			(oldmode bitOr: 161)} asByteArray
		to: 64
]

{ #category : #api }
DFRobotExBoard >> motor: index speed: speed [
	| dp dn ch |
	(index < 1 or: [ index > 4 ])
		ifTrue: [ ^ self ].
	dn := 0.
	dp := speed * 16 min: 4095.
	dp := dp max: -4095.
	dp < 0
		ifTrue: [ dn := dp negated.
			dp := 0 ].
	ch := (4 - index) * 2.
	self ch: ch + 1 pwm: dp.
	self ch: ch pwm: dn
]

{ #category : #api }
DFRobotExBoard >> servo: ch degree: deg [
	| v |
	v := (deg * 10 + 600) * 4095 // 20000.
	self ch: 16 - ch pwm: v asInteger
]
