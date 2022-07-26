"
A DFRobotExBoardTest is a test class for testing the behavior of DFRobotExBoard
"
Class {
	#name : #DFRobotExBoardTest,
	#superclass : #TestCase,
	#category : #'MPyTools-Tests'
}

{ #category : #private }
DFRobotExBoardTest >> mpCodeFor: aSymbol [
	^ (DFRobotExBoard >> aSymbol) asMicroPython
]

{ #category : #test }
DFRobotExBoardTest >> testChPwm [
	| r |
	r := self mpCodeFor: #ch:pwm:.
	self
		assert: r
		equals:
			'from microbit import i2c

class DFRobotExBoard:
  def ch_pwm(self,b,c):
    if (b < 0) or (b > 15):
      return self
    a = ((4 * b) + 6,0,0,c & 255,(c >> 8) & 255)
    i2c.write(64,(bytes(a)))

'
]

{ #category : #test }
DFRobotExBoardTest >> testInitialize [
	| r |
	r := self mpCodeFor: #initialize.
	self
		assert: r
		equals:
			'import time
from microbit import i2c

class DFRobotExBoard:
  def __init__(self):
    i2c.write(64,bytes([0,0]))
    b = (i2c.read(64,1))[0]
    a = (b & 127) | 16
    i2c.write(64,(bytes((0,a))))
    i2c.write(64,bytes([254,121]))
    i2c.write(64,(bytes((0,b))))
    time.sleep_us(5000)
    i2c.write(64,(bytes((0,b | 161))))

'
]

{ #category : #test }
DFRobotExBoardTest >> testMotorSpeed [
	| r |
	r := self mpCodeFor: #motor:speed:.
	self
		assert: r
		equals:
			'
class DFRobotExBoard:
  def motor_speed(self,d,e):
    if (d < 1) or (d > 4):
      return self
    b = 0
    c = min((e * 16),4095)
    c = max(c,-4095)
    if c < 0:
      b = -c
      c = 0
    a = (4 - d) * 2
    ch_pwm(a + 1, c)
    ch_pwm(a, b)

'
]

{ #category : #test }
DFRobotExBoardTest >> testServoDegree [
	| r |
	r := self mpCodeFor: #servo:degree:.
	self
		assert: r
		equals:
			'
class DFRobotExBoard:
  def servo_degree(self,a,b):
    v = (((b * 10) + 600) * 4095) / 20000
    ch_pwm(16 - a, int(v))

'
]
