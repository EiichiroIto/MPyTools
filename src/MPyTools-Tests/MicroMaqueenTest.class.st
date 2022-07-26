"
A MicroMaqueenTest is a test class for testing the behavior of MicroMaqueen
"
Class {
	#name : #MicroMaqueenTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #test }
MicroMaqueenTest >> testDistance [
	| r |
	r := (MicroMaqueen >> #distance) asMicroPython.
	self
		assert: r
		equals:
			'
class MicroMaqueen:
  def distance(self):
    return self.usonic.distance()

'
]

{ #category : #test }
MicroMaqueenTest >> testInitialize [
	| r |
	r := (MicroMaqueen >> #initialize) asMicroPython.
	self
		assert: r
		equals:
      'from neopixel import NeoPixel
from microbit import i2c,pin15

class MicroMaqueen:
  def __init__(self):
    i2c.init()
    self.np = NeoPixel(pin15, 4)

'
]

{ #category : #test }
MicroMaqueenTest >> testIsLineLeft [
	| r |
	r := (MicroMaqueen >> #isLineLeft) asMicroPython.
	self
		assert: r
		equals:
      'from microbit import pin13

class MicroMaqueen:
  def is_line_left(self):
    return (pin13.read_digital()) > 0

'
]

{ #category : #test }
MicroMaqueenTest >> testIsLineRight [
	| r |
	r := (MicroMaqueen >> #isLineRight) asMicroPython.
	self
		assert: r
		equals:
      'from microbit import pin14

class MicroMaqueen:
  def is_line_right(self):
    return (pin14.read_digital()) > 0

'
]

{ #category : #test }
MicroMaqueenTest >> testLedLeft [
	| r |
	r := (MicroMaqueen >> #ledLeft:) asMicroPython.
	self
		assert: r
		equals:
      'from microbit import pin8

class MicroMaqueen:
  def led_left(self,a):
    pin8.write_digital(1 if a else 0)

'
]

{ #category : #test }
MicroMaqueenTest >> testLedRight [
	| r |
	r := (MicroMaqueen >> #ledRight:) asMicroPython.
	self
		assert: r
		equals:
      'from microbit import pin12

class MicroMaqueen:
  def led_right(self,a):
    pin12.write_digital(1 if a else 0)

'
]

{ #category : #test }
MicroMaqueenTest >> testMotorLeft [
	| r |
	r := (MicroMaqueen >> #motorLeft:) asMicroPython.
	self
		assert: r
		equals:
      'from microbit import i2c

class MicroMaqueen:
  def motor_left(self,a):
    i2c.write(16,(bytes((0,2 if a > 0 else 1,abs(a)))))

'
]

{ #category : #test }
MicroMaqueenTest >> testMotorRight [
	| r |
	r := (MicroMaqueen >> #motorRight:) asMicroPython.
	self
		assert: r
		equals:
      'from microbit import i2c

class MicroMaqueen:
  def motor_right(self,a):
    i2c.write(16,(bytes((2,2 if a > 0 else 1,abs(a)))))

'
]

{ #category : #test }
MicroMaqueenTest >> testNeopixelAtPut [
	| r |
	r := (MicroMaqueen >> #neopixelAt:put:) asMicroPython.
	self
		assert: r
		equals:
      '
class MicroMaqueen:
  def neopixel_at_put(self,b,a):
    self.np[b] = a
    self.np.show()

'
]

{ #category : #test }
MicroMaqueenTest >> testPlayMusic [
	| r |
	r := (MicroMaqueen >> #playMusic:) asMicroPython.
	self
		assert: r
		equals:
      'import music

class MicroMaqueen:
  def play_music(self,a):
    music.play(a)

'
]

{ #category : #test }
MicroMaqueenTest >> testUseUsonic [
	| r |
	r := (MicroMaqueen >> #useUsonic) asMicroPython.
	self
		assert: r
		equals:
      'from microbit import pin2,pin1

class MicroMaqueen:
  def use_usonic(self):
    from hcsr04 import MicrobitHCSR04
    self.usonic = MicrobitHCSR04(pin1, pin2)

'
]
