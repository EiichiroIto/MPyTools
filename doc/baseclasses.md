# Base classes
Base class is an abstract class to make your own application.

Each base class defines instance and class variables and methods.
Instance and class variables represents module name and Class name of MicroPython respectively.
(ex. 'machine' instance variable defines machine module in MicroPython)
Method of base class is just a dummy and its body is empty. It is to suppress error indications in System Browser.

You may create an appropriate subclass for your application. For example,

```Smalltalk
ESP8266Base subclass: #M5AtomLite
  instanceVariableNames: ''
  classVariableNames: 'BUTTON GPIO19 GPIO21 GPIO22 GPIO23 GPIO25 GPIO26 GPIO32 GPIO33 IR NEOPIXEL'
  package: 'MPyTools-Samples'
```

This class is suclass of ESP8266Base. It is intended to make an application for M5Atom Lite device. See applications document.

Available base classes are the followings.

## MicroPythonBase class
This class is for general MicroPython code commonly used in various application.
Currently it defines only 're' module.

## ESP8266Base class
This class is for a device using ESP8266/ESP32 micro-controller.
Its subclasses may be for M5Stack series devices.

## MicrobitBase class
This class is for BBC micro:bit device.

# Class side methods
Base class has class side methods. Most important methods are #coderClass and #recordModuleNamed:into:.

## coderClass method
#coderClass method should return the MicroPythonCoder class or its subclass. Coder class generates MicroPython codes, and base class specifies corresponding coder class for generating suitable code for that class.

## recordModuleNamed:into: method
#recordModuleNamed:into: method should record modules and classes to generate import statements of MicroPython. Coder class manages which modules are used in a class by checking instance and class variable usage. This method determines the appropriate import way like this,

```smalltalk
recordModuleNamed: aString into: aModules
  (#('ADC' 'SoftI2C' 'Pin' 'RTC' 'PWM' 'SoftSPI' 'UART')
    includes: aString)
    ifTrue: [ ^ aModules from: 'machine' import: aString ].
  aString = 'WLAN'
    ifTrue: [ ^ aModules import: 'network' ].
  aString = 'NeoPixel'
    ifTrue: [ ^ aModules from: 'neopixel' import: aString ].
  super recordModuleNamed: aString into: aModules
```
