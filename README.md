# MPyTools
MicroPython tools for Pharo Smalltalk

[![Build Status](https://app.travis-ci.com/EiichiroIto/MPyTools.svg?branch=master)](https://app.travis-ci.com/EiichiroIto/MPyTools)

MPyTools has two functionalities, which communicates with MicroPython devices, and which generates MicroPython codes.

# MPyTool
MPyTool communicates with MicroPython devices through a serial port. It sends MicroPython expression and receive its response, also it supports for uploading and downloading files.

Like this,

```
|mp|
mp := MPyTool new.
mp useSerial.
mp execute: 'import time'.
mp execute: 'time.sleep(5)'.
mp waitUntilPrompt.
(mp evaluate: '1+2') inspect.
mp close.
```

```
MPyTool new
  useSerial;
  upload: 'print("Hello")' fileNamed: 'main.py';
  close.
```

# MicroPythonCoder
MicroPythonCoder generates MicroPython code from Smalltalk-like MicroPython code.
For example,

```Smalltalk
printTest
  self isFunction: true.
	self print: 'Hello, World!'
```

It is converted into the following code.

```
def print_test():
  print("Hello, World!")
```


