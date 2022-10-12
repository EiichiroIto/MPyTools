Class {
	#name : #SpMPyTool,
	#superclass : #SpPresenter,
	#instVars : [
		'proxy',
		'menu',
		'buttonConnect',
		'buttonDisconnect',
		'buttonRestart',
		'buttonBreak',
		'buttonSend',
		'buttonSave',
		'labelStatus',
		'output',
		'timer',
		'buttonClass',
		'buttonMethod',
		'buttonCode',
		'buttonInput',
		'directory',
		'isTransferring'
	],
	#category : #'MPyTools-GUI'
}

{ #category : #'world menu' }
SpMPyTool class >> menuCommandOn: aBuilder [
	<worldMenu>

	(aBuilder item: 'MPyTool')
		parent: #Tools;
		order: 900;
		target: self;
		action: [self new open]
]

{ #category : #examples }
SpMPyTool class >> open [
	<script>

	self new open
]

{ #category : #private }
SpMPyTool >> addOutput: aString [

	output morph
		put: aString;
		changed
]

{ #category : #constants }
SpMPyTool >> appName [
	^ 'MPyTool GUI'
]

{ #category : #constants }
SpMPyTool >> appText [

	^ self appName , ' ' , self appVersion , String cr , String cr
	  , 'Copyright © 2022 Eiichiro Ito (ghc02331@nifty.com)' , String cr
	  , 'All rights reserved.'
]

{ #category : #constants }
SpMPyTool >> appVersion [
	^ '1.0.1'
]

{ #category : #private }
SpMPyTool >> autoConnectIfFail: aBlock [

	proxy isReady ifTrue: [ ^ self ]. 
	self connectIfFail: aBlock.
	proxy break.
	proxy waitPromptIfError: aBlock
]

{ #category : #private }
SpMPyTool >> autoSelectPortName [

	| list ret |
	list := proxy portNames sorted.
	list isEmpty ifTrue: [ ^ self ].
	ret := list first.
	list size > 1 ifTrue: [ 
		ret := self
			       select: 'Select port' localized
			       chooseFrom: list.
		ret ifNil: [ ^ self ] ].
	proxy portName: ret
]

{ #category : #'buttons behavior' }
SpMPyTool >> break [

	proxy isIdle ifTrue: [ ^ self ].
	proxy isNotConnected ifTrue: [ 
		proxy open ifFalse: [ 
			owner enableConnect.
			^ self message: 'cannot open:' localized , proxy comm portName ] ].
	proxy break.
	self disableConnect.
	self message: 'stopped' localized
]

{ #category : #constants }
SpMPyTool >> buttonMethodLabel [
	^ 'select Method' localized
]

{ #category : #'buttons behavior' }
SpMPyTool >> connect [

	self connectIfFail: [ :msg | ^ self message: msg ].
	proxy break
]

{ #category : #private }
SpMPyTool >> connectIfFail: aBlock [

	proxy isIdle ifTrue: [ 
		self autoSelectPortName.
		proxy isIdle ifTrue: [ 
			^ aBlock cull: 'cannot select port' localized ] ].
	proxy isNotConnected ifTrue: [ 
		proxy open ifFalse: [ 
			^ aBlock cull: 'cannot open:' localized , proxy comm portName ] ].
	self disableConnect
]

{ #category : #initialization }
SpMPyTool >> connectPresenters [

	buttonConnect action: [ self connect ].
	buttonDisconnect action: [ self disconnect ].
	buttonRestart action: [ self restart ].
	buttonBreak action: [ self break ].
	buttonSend action: [ self send ].
	buttonSave action: [ self save ].
	buttonCode action: [ self showCode ].
	buttonClass action: [ self selectClass ].
	buttonMethod action: [ self selectMethod ].
	buttonInput action: [ self input ].
	timer morph whenStepsDo: [ self step ]
]

{ #category : #private }
SpMPyTool >> createConsoleMorph [
	^ ScratchConsoleMorph new
]

{ #category : #private }
SpMPyTool >> createTimerMorph [

	^ ScratchStepperMorph new
		  stepTime: 100;
		  yourself
]

{ #category : #private }
SpMPyTool >> currentTarget [

	| cl |
	buttonClass state ifTrue: [ 
		^ Smalltalk at: buttonClass label asSymbol ].
	buttonMethod state ifFalse: [ ^ nil ].
	cl := Smalltalk at: buttonClass label asSymbol.
	^ cl >> buttonMethod label asSymbol
]

{ #category : #constants }
SpMPyTool >> defaultBaudRate [
	^ 115200
]

{ #category : #layout }
SpMPyTool >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: #menu expand: false;
		  add: (SpBoxLayout newHorizontal
				   add: #buttonConnect;
				   add: #buttonDisconnect;
				   add: #buttonBreak;
				   add: #buttonRestart;
				   add: #buttonInput;
				   yourself)
		  withConstraints: [ :c | c height: self class buttonHeight ];
		  add: (SpBoxLayout newHorizontal
				   add: #buttonClass;
				   add: #buttonMethod;
				   add: #buttonCode expand: false;
				   add: #buttonSend expand: false;
				   add: #buttonSave expand: false;
				   yourself)
		  withConstraints: [ :c | c height: self class buttonHeight ];
		  add: #output;
		  add: (SpBoxLayout newHorizontal
				   add: #timer width: 5;
				   add: #labelStatus;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : #'menu actions' }
SpMPyTool >> deleteFile [

	| file |
	self autoConnectIfFail: [ :msg | ^ self message: msg ].
	file := self selectRemoteFile.
	file ifNil: [ ^ self ].
	proxy isReady ifFalse: [ 
		^ self message: 'device is not ready' localized ].
	proxy deleteFileNamed: file.
	isTransferring := true.
	self message: 'delete done' localized
]

{ #category : #private }
SpMPyTool >> disableConnect [
	buttonConnect disable.
	buttonDisconnect enable
]

{ #category : #'buttons behavior' }
SpMPyTool >> disconnect [

	self enableConnect.
	proxy disconnect.
	self message: 'port closed' localized
]

{ #category : #'menu actions' }
SpMPyTool >> downloadFile [

	| file code |
	self autoConnectIfFail: [ :msg | ^ self message: msg ].
	file := self selectRemoteFile.
	file ifNil: [ ^ self ].
	proxy isReady ifFalse: [ 
		^ self message: 'device is not ready' localized ].
	code := proxy
		        downloadFileNamed: file
		        ifError: [ :msg | ^ self message: msg ].
	(code isNil or: [ code isEmpty ]) ifTrue: [ ^ self ].
	code := MicroPythonParser new parse: code.
	code := UIManager default
		        multiLineRequest: 'OK to save, or cancel' localized
		        initialAnswer: code
		        answerHeight: 450.
	code ifNil: [ ^ self ].
	self exportString: code extension: self pyExtension
]

{ #category : #private }
SpMPyTool >> enableConnect [

	buttonConnect enable.
	buttonDisconnect disable
]

{ #category : #utilities }
SpMPyTool >> exportString: aContentsString extension: aString [

	| file f |
	file := UIManager default
		        chooseForSaveFileReference: 'Export ...' localized
		        extensions: { aString }
		        path: directory.
	file ifNil: [ ^ self ].
	directory := file parent.
	f := nil.
	f := file writeStream.
	[ f nextPutAll: aContentsString ] ensure: [ f close ]
]

{ #category : #initialization }
SpMPyTool >> fileMenu [

	| m |
	m := self newMenu.
	m addGroup: [ :grp | 
		grp
			addItem: [ :item | 
				item
					name: 'Close' localized;
					action: [ application closeAllWindows ] ];
			addItem: [ :item | 
				item
					name: 'Quit' localized;
					action: [ application quit ] ] ].
	^ m
]

{ #category : #private }
SpMPyTool >> getDirectory [

	| cmd ret |
	self autoConnectIfFail: [ :msg | 
		self message: msg.
		^ nil ].
	cmd := 'import os' , String lf , 'os.listdir()'.
	ret := proxy evaluate: cmd ifError: [ :msg | 
		       self message: msg.
		       ^ nil ].
	ret ifNil: [ ^ nil ].
	^ MicroPythonParser new parse: ret
]

{ #category : #initialization }
SpMPyTool >> helpMenu [

	^ self newMenu
		  addItem: [ :item | 
			  item
				  name: 'About ' , self appName;
				  action: [ owner window showAbout ] ];
		  addItem: [ :item | 
			  item
				  name: 'Restart';
				  action: [ timer morph startStepping ] ];
		  addItem: [ :item | 
			  item
				  name: 'Inspect';
				  action: [ self inspect ] ];
		  yourself
]

{ #category : #utilities }
SpMPyTool >> importFileWithExtension: aString [

	| file f code |
	file := UIManager default
		        chooseExistingFileReference: 'Import ...' localized
		        extensions: { aString }
		        path: directory.
	file ifNil: [ ^ nil ].
	file isFile ifFalse: [ ^ nil ].
	directory := file parent.
	f := file readStream.
	code := [ f contents ] ensure: [ 
		        f close.
		        nil ].
	^ Array with: code with: file
]

{ #category : #constants }
SpMPyTool >> initialExtent [
	^ 800 @ 600
]

{ #category : #initialization }
SpMPyTool >> initialize [
	proxy := self newProxy.
	isTransferring := false.
	directory := FileSystem workingDirectory.
	super initialize
]

{ #category : #initialization }
SpMPyTool >> initializePresenters [

	menu := self newMenuBar.
	buttonConnect := self newButton
		                 help: 'Connect to device';
		                 label: 'Connect' localized;
		                 icon: (self iconNamed: #radioButtonOn);
		                 yourself.
	buttonDisconnect := self newButton
		                    help: 'Disconnect from device';
		                    label: 'Disconnect' localized;
		                    icon: (self iconNamed: #radioButtonPressed);
		                    disable;
		                    yourself.
	buttonRestart := self newButton
		                 help: 'Restart device';
		                 label: 'Restart' localized;
		                 icon: (self iconNamed: #refresh);
		                 yourself.
	buttonBreak := self newButton
		               help: 'Stop';
		               label: 'Stop' localized;
		               icon: (self iconNamed: #stop);
		               yourself.
	buttonInput := self newButton
		               help: 'Input an expression';
		               label: 'Input' localized;
		               icon: (self iconNamed: #edit);
		               yourself.
	buttonClass := self newButton
		               label: 'select Class' localized;
		               icon: (self iconNamed: #class);
		               state: false;
		               yourself.
	buttonMethod := self newButton
		                label: self buttonMethodLabel;
		                state: false;
			              icon: (self iconNamed: #announcement);
		                yourself.
	buttonCode := self newButton
		              help: 'View code';
		              label: 'View' localized;
		              icon: (self iconNamed: #scriptManager);
		              yourself.
	buttonSend := self newButton
		              help: 'Send code';
		              label: 'Send' localized;
		              icon: (self iconNamed: #glamorousGo);
		              yourself.
	buttonSave := self newButton
		              help: 'Save code to main.py';
		              label: 'Save' localized;
		              icon: (self iconNamed: #glamorousSave);
		              yourself.
	output := self newMorph
		          morph: self createConsoleMorph;
		          yourself.
	timer := self newMorph
		         morph: self createTimerMorph;
		         yourself.
	labelStatus := self newLabel
		               label: 'Status';
		               yourself.
	self setupMenu
]

{ #category : #initialization }
SpMPyTool >> initializeWindow: aWindow [

	aWindow
		whenClosedDo: [ proxy close ];
		initialExtent: self initialExtent;
		title: self appName;
		aboutText: self appText
]

{ #category : #'buttons behavior' }
SpMPyTool >> input [

	| ret |
	self autoConnectIfFail: [ :msg | ^ self message: msg ].
	ret := self multiLineRequest: 'Enter expression' localized initialAnswer: ''.
	ret ifNil: [ ^ self ].
	proxy isReady ifFalse: [ ^ self ].
	proxy execute: ret
]

{ #category : #private }
SpMPyTool >> message: aString [

	labelStatus label: proxy state asString , aString
]

{ #category : #utilities }
SpMPyTool >> multiLineRequest: aString initialAnswer: aString2 [

	^ SpRequestTextDialog new
		  title: 'Information request' localized;
		  label: aString;
		  text: aString2;
			acceptLabel: 'OK' localized;
			cancelLabel: 'Cancel' localized;
		  openModal
]

{ #category : #private }
SpMPyTool >> newProxy [

	^ MicroPythonProxy new
		  comm: SerialComm new;
		  yourself
]

{ #category : #private }
SpMPyTool >> newSerial [
	^ SerialComm new
]

{ #category : #constants }
SpMPyTool >> pyExtension [
	^ 'py'
]

{ #category : #utilities }
SpMPyTool >> request: aString initialAnswer: aString2 [

	^ SpRequestDialog new
		  title: 'Information request' localized;
		  label: aString;
		  text: aString2;
			acceptLabel: 'OK' localized;
			cancelLabel: 'Cancel' localized;
		  openModal
]

{ #category : #'buttons behavior' }
SpMPyTool >> restart [

	self autoConnectIfFail: [ :msg | ^ self message: msg ].
	self enableConnect.
	proxy restart.
	self message: 'restarted' localized
]

{ #category : #'buttons behavior' }
SpMPyTool >> save [

	| target filename |
	target := self currentTarget.
	target ifNil: [ ^ self ].
	filename := self
		            request: 'Upload file name?' localized
		            initialAnswer: 'main.py'.
	(filename isNil or: [ filename isEmpty ]) ifTrue: [ ^ self ].
	filename := (filename withoutSuffix: '.py') , '.py'.
	self autoConnectIfFail: [ :msg | ^ self message: msg ].
	proxy upload: target asMicroPython fileNamed: filename
]

{ #category : #utilities }
SpMPyTool >> select: aString chooseFrom: aCollection [

	^ SpSelectDialog new
		  title: aString;
		  items: aCollection;
			acceptLabel: 'OK' localized;
			cancelLabel: 'Cancel' localized;
		  openModal
]

{ #category : #'buttons behavior' }
SpMPyTool >> selectClass [

	| ret list |
	list := MicroPythonBase allSubclasses reject: #isBase.
	list isEmpty ifTrue: [ ^ self ].
	list := list sort: [ :a :b | a name < b name ].
	ret := list size = 1
		       ifTrue: [ ret := list first ]
		       ifFalse: [ 
		       self select: 'Select a Class' localized chooseFrom: list ].
	ret ifNil: [ ^ self ].
	buttonClass label: ret name.
	buttonMethod label: self buttonMethodLabel.
	buttonClass state: true.
	buttonMethod state: false
]

{ #category : #'buttons behavior' }
SpMPyTool >> selectMethod [

	| cl ret list |
	cl := Smalltalk at: buttonClass label asSymbol ifAbsent: [ ^ self ].
	list := cl methods.
	list isEmpty ifTrue: [ ^ self ].
	list := list collect: #selector.
	list := list sorted.
	ret := list size = 1
		       ifTrue: [ ret := list first ]
		       ifFalse: [ 
		       self select: 'Select a Method' localized chooseFrom: list ].
	ret ifNil: [ ^ self ].
	buttonMethod label: ret.
	buttonClass state: false.
	buttonMethod state: true.
]

{ #category : #private }
SpMPyTool >> selectRemoteFile [

	| choices |
	choices := self getDirectory.
	(choices isNil or: [ choices isEmpty ]) ifTrue: [ ^ nil ].
	^ self select: 'Select file' localized chooseFrom: choices
]

{ #category : #'buttons behavior' }
SpMPyTool >> send [

	| target |
	target := self currentTarget.
	target ifNil: [ ^ self ].
	self autoConnectIfFail: [ :msg | ^ self message: msg ].
	proxy execute: target asMicroPython
]

{ #category : #initialization }
SpMPyTool >> setupMenu [
	menu
		addItem: [ :item | 
			item
				name: 'File' localized;
				subMenu: self fileMenu ];
		addItem: [ :item | 
			item
				name: 'Tools' localized;
				subMenu: self toolsMenu ];
		addItem: [ :item | 
			item
				name: 'Help' localized;
				subMenu: self helpMenu ]
]

{ #category : #'buttons behavior' }
SpMPyTool >> showCode [

	| target |
	target := self currentTarget.
	target ifNil: [ ^ self ].
	UIManager default
		longMessage: target asMicroPython
		title: 'MicroPython code'
]

{ #category : #stepping }
SpMPyTool >> step [

	| out |
	proxy step.
	self message: ''.
	proxy isReady ifTrue: [ isTransferring := false ].
	out := proxy receiveQueue getAll.
	isTransferring
		ifTrue: [ ^ self message: 'transferring ...' localized ]
		ifFalse: [ out do: [ :each | self addOutput: each asString ] ].
	proxy ifTimeoutDo: [ self message: 'timeout' localized ]
]

{ #category : #initialization }
SpMPyTool >> toolsMenu [

	^ self newMenu
		  addGroup: [ :grp | 
			  grp
				  addItem: [ :item | 
					  item
						  name: 'Upload file' localized;
						  icon: (self iconNamed: #up);
						  action: [ self uploadFile ] ];
				  addItem: [ :item | 
					  item
						  name: 'Download file' localized;
						  icon: (self iconNamed: #down);
						  action: [ self downloadFile ] ];
				  addItem: [ :item | 
					  item
						  name: 'Delete file' localized;
						  icon: (self iconNamed: #delete);
						  action: [ self deleteFile ] ] ];
		  yourself
]

{ #category : #'menu actions' }
SpMPyTool >> uploadFile [

	| pair filename |
	pair := self importFileWithExtension: self pyExtension.
	pair ifNil: [ ^ self ].
	filename := self
		            request: 'Upload file name?' localized
		            initialAnswer: pair second basename.
	(filename isNil or: [ filename isEmpty ]) ifTrue: [ ^ self ].
	self autoConnectIfFail: [ :msg | ^ self message: msg ].
	proxy upload: pair first fileNamed: filename.
	isTransferring := true
]
