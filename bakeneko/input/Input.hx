package bakeneko.input;

import bakeneko.core.Window;

@:enum abstract PointerKey(Int) from Int to Int from UInt to UInt {
	
	var LEFT = 0;
	var MIDDLE = 1;
	var RIGHT = 2;
	
}

@:enum abstract PadKey(Int) from Int to Int from UInt to UInt #if lime from lime.ui.GamepadButton to lime.ui.GamepadButton #end {
	
	var A = 0;
	var B = 1;
	var X = 2;
	var Y = 3;
	var BACK = 4;
	var GUIDE = 5;
	var START = 6;
	var LEFT_STICK = 7;
	var RIGHT_STICK = 8;
	var LEFT_TRIGGER = 9;
	var RIGHT_TRIGGER = 10;
	var DPAD_UP = 11;
	var DPAD_DOWN = 12;
	var DPAD_LEFT = 13;
	var DPAD_RIGHT = 14;
	
	// Axises can simulate the same events as regular keys
	
	var LSTICK_LEFT = 15;
	var LSTICK_RIGHT = 16;
	var LSTICK_UP = 17;
	var LSTICK_DOWN = 18;
	var RSTICK_LEFT = 19;
	var RSTICK_RIGHT = 20;
	var RSTICK_UP = 21;
	var RSTICK_DOWN = 22;
	
	//var LEFT_TRIGGER = 15;
	//var RIGHT_TRIGGER = 16;
	
	var UNKNOWN = 23;
	
	public inline function toString ():String {
		
		return switch (this) {
			
			case A: "A";
			case B: "B";
			case X: "X";
			case Y: "Y";
			case BACK: "BACK";
			case GUIDE: "GUIDE";
			case START: "START";
			case LEFT_STICK: "LEFT_STICK";
			case RIGHT_STICK: "RIGHT_STICK";
			case LEFT_TRIGGER: "LEFT_TRIGGER";
			case RIGHT_TRIGGER: "RIGHT_TRIGGER";
			case DPAD_UP: "DPAD_UP";
			case DPAD_DOWN: "DPAD_DOWN";
			case DPAD_LEFT: "DPAD_LEFT";
			case DPAD_RIGHT: "DPAD_RIGHT";
			case LSTICK_LEFT: "LSTICK_LEFT";
			case LSTICK_RIGHT: "LSTICK_RIGHT";
			case LSTICK_UP: "LSTICK_UP";
			case LSTICK_DOWN: "LSTICK_DOWN";
			case RSTICK_LEFT: "RSTICK_LEFT";
			case RSTICK_RIGHT: "RSTICK_RIGHT";
			case RSTICK_UP: "RSTICK_UP";
			case RSTICK_DOWN: "RSTICK_DOWN";
			default: "UNKNOWN(" + this + ")";
			
		}
		
	}
	
}

@:enum abstract PadAxis(Int) from Int to Int from UInt to UInt #if lime from lime.ui.GamepadAxis to lime.ui.GamepadAxis #end  {
	
	
	var LEFT_X = 0;
	var LEFT_Y = 1;
	var RIGHT_X = 2;
	var RIGHT_Y = 3;
	var TRIGGER_LEFT = 4;
	var TRIGGER_RIGHT = 5;
	
	var UNKNOWN = 6;
	
	
	public inline function toString ():String {
		
		return switch (this) {
			
			case LEFT_X: "LEFT_X";
			case LEFT_Y: "LEFT_Y";
			case RIGHT_X: "RIGHT_X";
			case RIGHT_Y: "RIGHT_Y";
			case TRIGGER_LEFT: "TRIGGER_LEFT";
			case TRIGGER_RIGHT: "TRIGGER_RIGHT";
			default: "UNKNOWN(" + this + ")";
			
		}
		
	}
	
	
}