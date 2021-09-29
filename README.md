# MPyTools
MicroPython tools for Pharo Smalltalk

[![Build Status](https://app.travis-ci.com/EiichiroIto/MPyTools.svg?branch=master)](https://app.travis-ci.com/EiichiroIto/MPyTools)

MPyTools has two functionalities, which communicates with MicroPython devices, and which generates MicroPython codes from Smalltalk codes.

This project is inspired from MicroSqueak and rewrited some codes in Pharo Smalltalk. (https://web.media.mit.edu/~jmaloney/microsqueak/)

# MPyTool
MPyTool communicates with MicroPython devices through a serial port. It sends MicroPython expression and receive its response, also it supports for uploading and downloading files.

## Usage

```Smalltalk
| mp |
mp := MPyTool new.
mp useSerial.
mp execute: 'import time
time.sleep(3)'.
mp waitUntilPrompt.
(mp evaluate: '1+2') inspect.
```

```Smalltalk
MPyTool new
  useSerial;
  upload: 'print("Hello")' fileNamed: 'main.py';
  close.
```

# MicroPythonCoder
MicroPythonCoder generates MicroPython code from Smalltalk-like MicroPython code.
For example,

```Smalltalk
helloWorld
  self isFunction: true.
  self print: 'Hello, World!'
```

It is converted into the following code.

```Python
def hello_world():
  print("Hello, World!")
```

There are several types of devices using MicroPython. Currently MicroPythonCoder supports only ESP8266/ESP32 and micro:bit devices. See samples.

## Usage
To get MicroPython code string of a class, send #asMicroPython message to the class.

```smalltalk
ESP8266Sample asMicroPython
```

To execute whole the class in a device.

```smalltalk
MPyTool new
  useSerial;
  execute: ESP8266Sample asMicroPython;
  close.
```
