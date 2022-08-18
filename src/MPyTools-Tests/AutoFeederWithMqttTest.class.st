Class {
	#name : #AutoFeederWithMqttTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
AutoFeederWithMqttTest >> mpCodeFor: aSymbol [
	^ (AutoFeederWithMqtt >> aSymbol) asMicroPython
]

{ #category : #test }
AutoFeederWithMqttTest >> testClientId [
	| r |
	r := self mpCodeFor: #clientId.
	self
		assert: r
		equals:
			'import ubinascii,machine

class AutoFeederWithMqtt:
  def client_id(self):
    return ubinascii.hexlify(machine.unique_id())

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testConnectWifi [
	| r |
	r := self mpCodeFor: #connectWifi.
	self
		assert: r
		equals:
			'import time,network

class AutoFeederWithMqtt:
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
AutoFeederWithMqttTest >> testError [
	| r |
	r := self mpCodeFor: #error:.
	self
		assert: r
		equals:
			'import time

class AutoFeederWithMqtt:
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
AutoFeederWithMqttTest >> testFeedCount [
	| r |
	r := self mpCodeFor: #feedCount.
	self
		assert: r
		equals:
      '
class AutoFeederWithMqtt:
  def feed_count(self):
    if self.portion > 0:
      c = self.portion
      self.portion = 0
      return c
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
AutoFeederWithMqttTest >> testFeedPortion [
	| r |
	r := self mpCodeFor: #feedPortion:.
	self
		assert: r
		equals:
      'import time

class AutoFeederWithMqtt:
  def feed_portion(self,a):
    motor_on()
    while is_feed_sw_on():
      time.sleep_ms(100)
    for _ in range(0,a):
      while not (is_feed_sw_on()):
        time.sleep_ms(100)
      while is_feed_sw_on():
        time.sleep_ms(100)
    motor_off()
    mqtt_status(("feed " + (str(a))) + " portions")

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testInitialize [
	| r |
	r := self mpCodeFor: #initialize.
	self
		assert: r
		equals:
      'from machine import Pin,SoftI2C
from neopixel import NeoPixel

class AutoFeederWithMqtt:
  def __init__(self):
    self.button = Pin(39,Pin.IN)
    self.sw = Pin(22,Pin.IN)
    self.np = NeoPixel(Pin(27), 1)
    self.i2c = SoftI2C(scl=(Pin(21)),sda=(Pin(25)),freq=100000)
    self.portion = 0

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testIsButtonOn [
	| r |
	r := self mpCodeFor: #isButtonOn.
	self
		assert: r
		equals:
      'import time

class AutoFeederWithMqtt:
  def is_button_on(self):
    if not ((self.button.value()) == 0):
      return False
    time.sleep_ms(100)
    return (self.button.value()) == 0

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testIsFeedSwOn [
	| r |
	r := self mpCodeFor: #isFeedSwOn.
	self
		assert: r
		equals:
      'import time

class AutoFeederWithMqtt:
  def is_feed_sw_on(self):
    if not ((self.sw.value()) > 0):
      return False
    time.sleep_ms(100)
    return (self.sw.value()) > 0

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testLed [
	| r |
	r := self mpCodeFor: #led:.
	self
		assert: r
		equals:
      '
class AutoFeederWithMqtt:
  def led(self,a):
    self.np[0] = a
    self.np.write()

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testMain [
	| r |
	r := self mpCodeFor: #main.
	self
		assert: r
		equals:
      'import time

class AutoFeederWithMqtt:
  def main(self):
    feed_portion(1)
    while True:
      led((0,0,0))
      c = feed_count()
      if c > 0:
        feed_portion(c)
        led((128,128,0))
        time.sleep(60)
        self.portion = 0
      elif is_button_on():
        led((0,0,128))
        feed_portion(1)
      else:
        time.sleep(5)
        led((128,128,128))
        time.sleep_ms(100)

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testMotorOff [
	| r |
	r := self mpCodeFor: #motorOff.
	self
		assert: r
		equals:
      '
class AutoFeederWithMqtt:
  def motor_off(self):
    self.i2c.writeto(100,bytes([0,0]))

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testMotorOn [
	| r |
	r := self mpCodeFor: #motorOn.
	self
		assert: r
		equals:
			'
class AutoFeederWithMqtt:
  def motor_on(self):
    self.i2c.writeto(100,bytes([0,253]))

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testMqttCommand [
	| r |
	r := self mpCodeFor: #mqtt:command:.
	self
		assert: r
		equals: '
class AutoFeederWithMqtt:
  def mqtt_command(self,aTopic,a):
    print("command received")
    self.portion = int(a)

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testMqttStatus [
	| r |
	r := self mpCodeFor: #mqttStatus:.
	self
		assert: r
		equals:
			'
class AutoFeederWithMqtt:
  def mqtt_status(self,a):
    c = now()
    b = "{}/{}/{} {}:{}:{} ".format(*c)
    self.pub.publish("/home/autofeeder1/status",(b + a))

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testMqttSubscriber [
	| r |
	r := self mpCodeFor: #mqttSubscriber.
	self
		assert: r
		equals: '
class AutoFeederWithMqtt:
  def mqtt_subscriber(self):
    print("subscriver start")
    while True:
      self.pub.wait_msg()

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testNow [
	| r |
	r := self mpCodeFor: #now.
	self
		assert: r
		equals:
      'import time

class AutoFeederWithMqtt:
  def now(self):
    return time.localtime((time.mktime(time.localtime())) + 32400)

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testOpening [
	| r |
	r := self mpCodeFor: #opening.
	self
		assert: r
		equals:
      'import random,time

class AutoFeederWithMqtt:
  def opening(self):
    for _ in range(0,20):
      a = (random.randrange(256),random.randrange(256),random.randrange(256))
      led(a)
      time.sleep_ms(100)
    led((0,0,0))

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testSetup [
	| r |
	r := self mpCodeFor: #setup.
	self
		assert: r
		equals:
      'import time,ntptime

class AutoFeederWithMqtt:
  def setup(self):
    led((128,0,0))
    connect_wifi()
    ntptime.settime()
    led((0,128,0))
    setup_mqtt()
    led((0,0,128))
    if not (100 in (self.i2c.scan())):
      mqtt_status("motor is not connected")
      error("motor is not connected")
    motor_off()
    time.sleep(1)
    mqtt_status("start")

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testSetupMqtt [
	| r |
	r := self mpCodeFor: #setupMqtt.
	self
		assert: r
		equals:
      'from umqtt.robust import MQTTClient

class AutoFeederWithMqtt:
  def setup_mqtt(self):
    self.pub = MQTTClient((client_id()),"219.94.240.178")
    self.pub.connect()
    self.pub.set_callback(mqtt_command)
    self.pub.subscribe("/home/autofeeder1/command")

'
]

{ #category : #test }
AutoFeederWithMqttTest >> testStart [
	| r |
	r := self mpCodeFor: #start.
	self
		assert: r
		equals:
			'import _thread

a = AutoFeederWithMqtt()
a.opening()
a.setup()
_thread.start_new_thread(a.mqtt_subscriber,())
a.main()
'
]
