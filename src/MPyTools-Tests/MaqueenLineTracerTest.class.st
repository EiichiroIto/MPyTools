"
A MaqueenLineTracerTest is a test class for testing the behavior of MaqueenLineTracer
"
Class {
	#name : #MaqueenLineTracerTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #test }
MaqueenLineTracerTest >> testInitialize [
	| r |
	r := (MaqueenLineTracer >> #initialize) asMicroPython.
	self
		assert: r
		equals:
			'
class MaqueenLineTracer:
  def __init__(self):
    from maqueen import MicroMaqueen
    self.maqueen = MicroMaqueen()
    self.maqueen.use_usonic()

'
]

{ #category : #test }
MaqueenLineTracerTest >> testLightOff [
	| r |
	r := (MaqueenLineTracer >> #lightOff) asMicroPython.
	self
		assert: r
		equals:
			'
class MaqueenLineTracer:
  def light_off(self):
    self.maqueen.led_left(False)
    self.maqueen.led_right(False)

'
]

{ #category : #test }
MaqueenLineTracerTest >> testLightOn [
	| r |
	r := (MaqueenLineTracer >> #lightOn) asMicroPython.
	self
		assert: r
		equals:
			'
class MaqueenLineTracer:
  def light_on(self):
    self.maqueen.led_left(True)
    self.maqueen.led_right(True)

'
]

{ #category : #test }
MaqueenLineTracerTest >> testRun [
	| r |
	r := (MaqueenLineTracer >> #run) asMicroPython.
	self
		assert: r
		equals:
			'
class MaqueenLineTracer:
  def run(self):
    while True:
      if (self.maqueen.is_line_left()) and (self.maqueen.is_line_right()):
        pass
      if (self.maqueen.is_line_left()) and (not ((self.maqueen.is_line_right()))):
        self.maqueen.motor_left(100)
        self.maqueen.motor_right(0)
      if (not ((self.maqueen.is_line_left()))) and (self.maqueen.is_line_right()):
        self.maqueen.motor_left(0)
        self.maqueen.motor_right(100)
      if (not ((self.maqueen.is_line_left()))) and (not ((self.maqueen.is_line_right()))):
        self.maqueen.motor_left(100)
        self.maqueen.motor_right(100)
        light_off()
      while (self.maqueen.distance()) < 10:
        self.maqueen.motor_left(0)
        self.maqueen.motor_right(0)
        light_on()

'
]

{ #category : #test }
MaqueenLineTracerTest >> testStart [
	| r |
	r := (MaqueenLineTracer >> #start) asMicroPython.
	self
		assert: r
		equals:
			'from microbit import display

display.scroll("PressA")
a = MaqueenLineTracer()
a.light_on()
a.wait_for_button_a_pressed()
a.run()
'
]

{ #category : #test }
MaqueenLineTracerTest >> testWaitForButtonAPressed [
	| r |
	r := (MaqueenLineTracer >> #waitForButtonAPressed) asMicroPython.
	self
		assert: r
		equals:
      'from microbit import button_a

class MaqueenLineTracer:
  def wait_for_button_a_pressed(self):
    while button_a.is_pressed():
      pass
    while not (button_a.is_pressed()):
      pass
    while button_a.is_pressed():
      pass

'
]
