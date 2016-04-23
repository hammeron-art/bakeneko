package bakeneko.core;

//typedef Window = lime.ui.Window;

interface Window {
	public var onWindowEvent:Event<WindowEvent->Void>;
}

typedef WindowEvent = {
	var type:WindowEventType;
	var x:Float;
	var y:Float;
	var width:Int;
	var height:Int;
	var window:Window;
}

@:enum
abstract WindowEventType(Int) {
	var activate = 0;
	var close = 1;
	var create = 2;
	var deactivate = 3;
	var enter = 4;
	var focusIn = 5;
	var focusOut = 6;
	var fullscreen = 7;
	var leave = 8;
	var minimize = 9;
	var move = 10;
	var resize = 11;
	var restore = 12;
}