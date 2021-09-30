Class {
	#name : #MqttSample,
	#superclass : #ESP8266Base,
	#instVars : [
		'client'
	],
	#category : #'MPyTools-Samples'
}

{ #category : #samples }
MqttSample >> connectMqtt: aString to: aString2 [
	client := MQTTClient initMqtt: aString ipaddr: aString2.
	client connect
]

{ #category : #samples }
MqttSample >> connectWifi: aString password: aString2 [
	| wlan |
	self isFunction: true.
	wlan := WLAN initWifi: #STA_IF.
	wlan active: true.
	wlan isConnected
		ifFalse: [ wlan connect: aString password: aString2.
			[ wlan isConnected ] whileFalse: [ time sleepMs: 100 ] ].
	self print: wlan ifconfig
]

{ #category : #samples }
MqttSample >> publishTest [
	10
		timesRepeat: [ client publish: 'test' message: 'Hello'.
			time sleep: 1 ]
]

{ #category : #samples }
MqttSample >> read: aString msg: aString2 [
	self isFunction: true.
	self print: aString2
]

{ #category : #samples }
MqttSample >> subscribeTest [
	client setCallback: #read:msg: asFunctionName.
	client subscribe: 'test'.
	[ client waitMsg ] repeat
]
