"
An AutoFeederTest is a test class for testing the behavior of AutoFeeder
"
Class {
	#name : #AutoFeederTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
AutoFeederTest >> mpCodeFor: aSymbol [
	^ (AutoFeeder >> aSymbol) asMicroPython
]

{ #category : #test }
AutoFeederTest >> testClientId [
	| r |
	r := self mpCodeFor: #clientId.
	self
		assert: r
		equals:
			'import ubinascii,machine

class AutoFeeder:
  def client_id(self):
    return ubinascii.hexlify(machine.unique_id())

'
]

{ #category : #test }
AutoFeederTest >> testConnectWifi [
	| r |
	r := self mpCodeFor: #connectWifi.
	self
		assert: r
		equals:
			'import time,network

class AutoFeeder:
  def connect_wifi(self):
    a = network.WLAN(network.STA_IF)
    a.active(True)
    if not (a.isconnected()):
      a.connect("itolab","12345678")
      while not (a.isconnected()):
        time.sleep_ms(100)
    print(a.ifconfig())

'
]

{ #category : #test }
AutoFeederTest >> testError [
	| r |
	r := self mpCodeFor: #error:.
	self
		assert: r
		equals:
			'import time

class AutoFeeder:
  def error(self,a):
    print("Error:" + a)
    while True:
      led((128,0,0))
      time.sleep_ms(500)
      led((0,0,0))
      time.sleep_ms(500)

'
]

{ #category : #test }
AutoFeederTest >> testFeedCount [
	| r |
	r := self mpCodeFor: #feedCount.
	self
		assert: r
		equals:
      '
class AutoFeeder:
  def feed_count(self):
    if self.portion > 0:
      c = self.portion
      self.portion = 0
      return c
    if is_button_on():
      return 1
    n = now()
    a = n[3]
    b = n[4]
    if (a == 6) and (b == 20):
      return 4
    if (a == 12) and (b == 0):
      return 2
    if (a == 18) and (b == 0):
      return 4
    return 0

'
]

{ #category : #test }
AutoFeederTest >> testFeedPortion [
	| r |
	r := self mpCodeFor: #feedPortion:.
	self
		assert: r
		equals:
      'import time

class AutoFeeder:
  def feed_portion(self,a):
    print(now())
    print("feedPortion:" + (str(a)))
    motor_on()
    while is_feed_sw_on():
      time.sleep_ms(100)
    for _ in range(0,a):
      print("***")
      while not (is_feed_sw_on()):
        time.sleep_ms(100)
      while is_feed_sw_on():
        time.sleep_ms(100)
    motor_off()
    print("feed done")

'
]

{ #category : #test }
AutoFeederTest >> testInitialize [
	| r |
	r := self mpCodeFor: #initialize.
	self
		assert: r
		equals:
      'from machine import Pin,SoftI2C
from neopixel import NeoPixel

class AutoFeeder:
  def __init__(self):
    self.button = Pin(39,Pin.IN)
    self.sw = Pin(22,Pin.IN)
    self.np = NeoPixel(Pin(27), 1)
    self.i2c = SoftI2C(scl=(Pin(21)),sda=(Pin(25)),freq=100000)
    self.portion = 0

'
]

{ #category : #test }
AutoFeederTest >> testIsButtonOn [
	| r |
	r := self mpCodeFor: #isButtonOn.
	self
		assert: r
		equals:
      'import time

class AutoFeeder:
  def is_button_on(self):
    if not ((self.button.value()) == 0):
      return False
    time.sleep_ms(100)
    return (self.button.value()) == 0

'
]

{ #category : #test }
AutoFeederTest >> testIsFeedSwOn [
	| r |
	r := self mpCodeFor: #isFeedSwOn.
	self
		assert: r
		equals:
      'import time

class AutoFeeder:
  def is_feed_sw_on(self):
    if not ((self.sw.value()) > 0):
      return False
    time.sleep_ms(100)
    return (self.sw.value()) > 0

'
]

{ #category : #test }
AutoFeederTest >> testLed [
	| r |
	r := self mpCodeFor: #led:.
	self
		assert: r
		equals:
      '
class AutoFeeder:
  def led(self,a):
    self.np[0] = a
    self.np.write()

'
]

{ #category : #test }
AutoFeederTest >> testMain [
	| r |
	r := self mpCodeFor: #main.
	self
		assert: r
		equals:
      'import time

class AutoFeeder:
  def main(self):
    feed_portion(1)
    while True:
      led((0,0,0))
      c = feed_count()
      if c > 0:
        led((0,0,128))
        feed_portion(c)
        led((128,128,0))
        time.sleep(60)
      else:
        time.sleep(5)
        led((128,128,128))
        time.sleep_ms(100)

'
]

{ #category : #test }
AutoFeederTest >> testMotorOff [
	| r |
	r := self mpCodeFor: #motorOff.
	self
		assert: r
		equals:
      '
class AutoFeeder:
  def motor_off(self):
    self.i2c.writeto(100,bytes([0,0]))

'
]

{ #category : #test }
AutoFeederTest >> testMotorOn [
	| r |
	r := self mpCodeFor: #motorOn.
	self
		assert: r
		equals:
			'
class AutoFeeder:
  def motor_on(self):
    self.i2c.writeto(100,bytes([0,253]))

'
]

{ #category : #test }
AutoFeederTest >> testNow [
	| r |
	r := self mpCodeFor: #now.
	self
		assert: r
		equals:
      'import time

class AutoFeeder:
  def now(self):
    return time.localtime((time.mktime(time.localtime())) + 32400)

'
]

{ #category : #test }
AutoFeederTest >> testOpening [
	| r |
	r := self mpCodeFor: #opening.
	self
		assert: r
		equals:
      'import random,time

class AutoFeeder:
  def opening(self):
    for _ in range(0,20):
      a = (random.randrange(256),random.randrange(256),random.randrange(256))
      led(a)
      time.sleep_ms(100)
    led((0,0,0))

'
]

{ #category : #test }
AutoFeederTest >> testSetup [
	| r |
	r := self mpCodeFor: #setup.
	self
		assert: r
		equals:
      'import time,ntptime

class AutoFeeder:
  def setup(self):
    led((128,0,0))
    connect_wifi()
    led((0,128,0))
    ntptime.settime()
    time.sleep(1)
    led((0,0,128))
    if not (100 in (self.i2c.scan())):
      error("motor is not connected")
    motor_off()
    print("Setup done")
    time.sleep(1)

'
]

{ #category : #test }
AutoFeederTest >> testStart [
	| r |
	r := self mpCodeFor: #start.
	self
		assert: r
		equals:
			'
print("Starting ...")
a = AutoFeeder()
a.opening()
a.setup()
a.main()
'
]
