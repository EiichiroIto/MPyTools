"
A MicrobitHCSR04Test is a test class for testing the behavior of MicrobitHCSR04
"
Class {
	#name : #MicrobitHCSR04Test,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #test }
MicrobitHCSR04Test >> testDistance [
	| r |
	r := (MicrobitHCSR04 >> #distance) asMicroPython.
	self
		assert: r
		equals:
			'
class MicrobitHCSR04:
	def distance(self):
		t = us_getecho()
		return int(((340.0 * t) / 20000))

'
]

{ #category : #test }
MicrobitHCSR04Test >> testInitializeTriggerEcho [
	| r |
	r := (MicrobitHCSR04 >> #initializeTrigger:echo:) asMicroPython.
	self
		assert: r
		equals:
			'
class MicrobitHCSR04:
	def __init__(self,b,a):
		self.trigger = b
		self.echo = a

'
]

{ #category : #test }
MicrobitHCSR04Test >> testUsGetecho [
	| r |
	r := (MicrobitHCSR04 >> #usGetecho) asMicroPython.
	self
		assert: r
		equals:
			'import time

class MicrobitHCSR04:
	def us_getecho(self):
		a = 0
		self.trigger.write_digital(1)
		self.trigger.write_digital(0)
		while (self.echo.read_digital()) == 0:
			time.sleep_us(1)
			a = a + 1
			if a > 1000:
				return 0
		b = time.ticks_us()
		a = 0
		while (self.echo.read_digital()) > 0:
			time.sleep_us(1)
			a = a + 1
			if a > 1000:
				return 0
		c = time.ticks_us()
		return time.ticks_diff(c, b)

'
]
