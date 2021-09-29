Class {
	#name : #MicrobitPCA9685,
	#superclass : #MicrobitBase,
	#category : #'MPyTools-Samples'
}

{ #category : #private }
MicrobitPCA9685 >> i2cRead: addr reg: reg [
	| ret |
	i2c write: { reg } to: addr.
	ret := i2c read: 1 from: addr.
	^ ret first
]

{ #category : #private }
MicrobitPCA9685 >> i2cWrite: addr reg: reg value: val [
	i2c
		write:
			{reg.
			val} asByteArray
		to: addr
]

{ #category : #initialization }
MicrobitPCA9685 >> initialize [
	| oldmode newmode |
	self i2cWrite: 64 reg: 0 value: 0.
	oldmode := self i2cRead:64 reg: 0.
	newmode := (oldmode bitAnd: 127) bitOr: 16.
	self i2cWrite: 64 reg: 0 value: newmode.
	self i2cWrite: 64 reg: 254 value: 121.
	self i2cWrite: 64 reg: 0 value: oldmode.
	time sleepUs: 5000.
	self i2cWrite: 64 reg: 0 value: (oldmode bitOr: 161)
]

{ #category : #api }
MicrobitPCA9685 >> motor: index at: speed [
	| sp dp dn ch |
	(index < 1 or: [ index > 4 ])
		ifTrue: [ ^ self ].
	ch := (4 - index) * 2.
	sp := speed * 16.
	sp >= 4096
		ifTrue: [ sp := 4095 ].
	sp <= -4096
		ifTrue: [ sp := -4095 ].
	dp := sp.
	dn := 0.
	sp < 0
		ifTrue: [ dp := 0.
			dn := sp negated ].
	self setPwm: ch + 1 val: dp.
	self setPwm: ch val: dn
]

{ #category : #api }
MicrobitPCA9685 >> servo: ch degree: deg [
	| v |
	v := (deg * 10 + 600) * 4095 // 20000.
	self setPwm: 16 - ch val: v
]

{ #category : #private }
MicrobitPCA9685 >> setPwm: channel val: off [
	| buf |
	(channel < 0 or: [ channel > 15 ])
		ifTrue: [ ^ self ].
	buf := {(4 * channel + 6).
	0.
	0.
	(off bitAnd: 255).
	(off >> 8 bitAnd: 255)}.
	i2c write: buf to: 64
]
