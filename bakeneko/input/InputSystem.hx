package bakeneko.input;

import bakeneko.core.Application;
import bakeneko.core.AppSystem;
import bakeneko.core.Core;
import bakeneko.core.Event;
import bakeneko.core.Log;
import bakeneko.core.Window;
import bakeneko.input.Input;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.Window;

#if !macro
/**
 * Handle all player input
 * Keyboard, mouse, touch and gamepad
 */
@:allow(bakeneko.core.Application)
class InputSystem extends AppSystem {
	
	public var onKeyEvent = new Event<KeyEvent->Void>();
	public var onPointerEvent = new Event<PointerEvent->Void>();
	public var onTextEvent = new Event<Window->String->Void>();
	
	var keyStates:Map<KeyCode, Int>;
	var padStates:Map<PadKey, Int>;
	var padAxisStates:Map<PadAxis, Float>;
	var pointerStates:Map<Int, Map<PointerKey, Pointer>>;
	
	var keyBindings:Map<String, Array<KeyCode>>;
    var padKeyBindings:Map<String, Array<PadKey>>;
	var pointerBindings:Map<String, Array<PointerKey>>;
	
    var inputReleased:Map<String, Bool>;
    var inputPressed:Map<String, Bool>;
    var inputDown:Map<String, Bool>;
	
	var ignoreLastKey:Bool;
	
	override public function onInit():Void {
		keyStates = new Map();
		padStates = new Map();
		padAxisStates = new Map();
		pointerStates = new Map();
		
		keyBindings = new Map();
        padKeyBindings = new Map();
		pointerBindings = new Map();
		
        inputDown = new Map();
        inputPressed = new Map();
        inputReleased = new Map();
		
		ignoreLastKey = false;
		
		setupMouse();
		setupGamePad();
	}
	
	function setupMouse() {
		var window = Application.core.window;
		
		//flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);
		
		window.onMouseDown.add(function (x, y, device) {
			mouseEvent({
				kind: MDown,
				x: x,
				y: y,
				dx: 0,
				dy: 0,
				id: 0,
				pressure: 1,
				device: device,
			});
		});
		window.onMouseMove.add(function (x, y) {
			mouseEvent({
				kind: MMove,
				x: x,
				y: y,
				dx: 0,
				dy: 0,
				id: 0,
				pressure: 1,
				device: 0,
			});
		});
		window.onMouseMoveRelative.add(function (x, y) {
			mouseEvent({
				kind: MMoveRelative,
				x: 0,
				y: 0,
				dx: x,
				dy: y,
				id: 0,
				pressure: 1,
				device: 0,
			});
		});
		window.onMouseUp.add(function (x, y, device) {
			mouseEvent({
				kind: MUp,
				x: x,
				y: y,
				dx: 0,
				dy: 0,
				id: 0,
				pressure: 1,
				device: device,
			});
		});
		
		lime.ui.Touch.onStart.add(function (touch) {
			mouseEvent({
				kind: MDown,
				x: touch.x,
				y: touch.y,
				dx: touch.dx,
				dy: touch.dy,
				id: touch.id,
				pressure: touch.pressure,
				device: touch.device,
			});
		});
		lime.ui.Touch.onMove.add(function (touch) {
			mouseEvent({
				kind: MMove,
				x: touch.x,
				y: touch.y,
				dx: touch.dx,
				dy: touch.dy,
				id: touch.id,
				pressure: touch.pressure,
				device: touch.device,
			});
		});
		lime.ui.Touch.onEnd.add(function (touch) {
			mouseEvent({
				kind: MMove,
				x: touch.x,
				y: touch.y,
				dx: touch.dx,
				dy: touch.dy,
				id: touch.id,
				pressure: touch.pressure,
				device: touch.device,
			});
		});
	}
	
	function setupGamePad() {
		
		#if (!flash && lime)
		
		for (pad in lime.ui.Gamepad.devices) {
			if (pad.connected == true)
				padConnected(pad);
		}
		
		lime.ui.Gamepad.onConnect.add(padConnected);
		
		#else

		// Hack code
		// because gamepad handling in flash is very weird
		// Flash target is just for development anyway...
		
		/*hxd.Pad.wait(function(pad) {
			
			var device = @:privateAccess pad.d;

			Log.info('Gamepad ${device.name} detected');
		
			var axisCount = 0;
			for( i in 0...device.numControls ) {
				var c = device.getControlAt(i);
				if( StringTools.startsWith(c.id, "AXIS_") ) {
					var axisID = axisCount++;
					
					var axis = switch (Std.parseInt(c.id.substr("AXIS_".length))) {
						case 0:
							PadAxis.LEFT_X;
						case 1:
							PadAxis.LEFT_Y;
						case 2:
							PadAxis.RIGHT_X;
						case 3:
							PadAxis.RIGHT_Y;
						default:
							PadAxis.UNKNOWN;
					};
					
					c.addEventListener(flash.events.Event.CHANGE, function(_) {
						var value = (c.value - c.minValue) / (c.maxValue - c.minValue);
						
						var event:PadEvent = {
							axis: axis,
							value: c.value,
							kind: PAxis
						}
						
						padEvent(event);
					});
				} else if ( StringTools.startsWith(c.id, "BUTTON_") ) {
					var key = switch (Std.parseInt(c.id.substr("BUTTON_".length))) {
						case 4:
							PadKey.A;
						case 5:
							PadKey.B;
						case 6:
							PadKey.X;
						case 7:
							PadKey.Y;
						case 10:
							PadKey.LEFT_TRIGGER;
						case 11:
							PadKey.RIGHT_TRIGGER;
						case 12:
							PadKey.BACK;
						case 13:
							PadKey.START;
						case 14:
							PadKey.LEFT_STICK;
						case 15:
							PadKey.RIGHT_STICK;
						case 16:
							PadKey.DPAD_UP;
						case 17:
							PadKey.DPAD_DOWN;
						case 18:
							PadKey.DPAD_LEFT;
						case 19:
							PadKey.DPAD_RIGHT;
						default:
							PadKey.UNKNOWN;
					};
				
					if (key != PadKey.UNKNOWN) {
						c.addEventListener(flash.events.Event.CHANGE, function(_) {
							var value = (c.value - c.minValue) / (c.maxValue - c.minValue);
								
							switch (key) {
							case PadKey.LEFT_TRIGGER:
								var event:PadEvent = {
									axis: PadAxis.TRIGGER_LEFT,
									value: c.value,
									kind: PAxis
								}
								
								padEvent(event);
							
							case PadKey.RIGHT_TRIGGER:
								var event:PadEvent = {
									axis: PadAxis.TRIGGER_RIGHT,
									value: c.value,
									kind: PAxis
								}
								
								padEvent(event);
							
							default:
								var kind = PUnknown;
							
								if (!isPadDown(key) && value >= 0.5)
									kind = PKeyDown;
								if (isPadDown(key) && value < 0.5)
									kind = PKeyUp;
								
								if (kind == PUnknown)
									return;
									
								var event:PadEvent = {
									key: key,
									kind: kind
								}
								
								padEvent(event);
							}
						});
					}
				}
			}
		});*/
		
		#end
	}
	
	public function isDown(name:String) {
		var result = false;
		
		if (keyBindings.exists(name)) {
			for (key in keyBindings[name]) {
				result = isKeyDown(key);
				if (result) break;
			}
		}
		
		if (padKeyBindings.exists(name)) {
			for (key in padKeyBindings[name]) {
				result = result || isPadDown(key);
				if (result) break;
			}
		}
		
		if (pointerBindings.exists(name)) {
			for (key in pointerBindings[name]) {
				result = result || isPointerDown(key);
				if (result) break;
			}
		}
		
		return result;
	}
	
	public function isPressed(name:String) {
		if (!keyBindings.exists(name))
			return false;
		
		for (key in keyBindings[name]) {
			return isKeyPressed(key);
		}
		
		return false;
	}
	
	public function isReleased(name:String) {
		if (!keyBindings.exists(name))
			return false;
		
		for (key in keyBindings[name]) {
			return isKeyReleased(key);
		}
		
		return false;
	}
	
	inline public function isKeyDown(key:KeyCode) {
		return keyStates[key] > 0;
	}
	
	inline public function isKeyPressed(key:KeyCode) {
		return keyStates[key] == getFrame();
	}
	
	inline public function isKeyReleased(key:KeyCode) {
		return keyStates[key] == -getFrame();
	}
	
	inline public function isPointerDown(key:PointerKey) {
		return getPointerState(key).frame > 0;
	}
	
	inline public function isPointerPressed(key:PointerKey) {
		return getPointerState(key).frame == getFrame();
	}
	
	inline public function isPointerReleased(key:PointerKey) {
		return getPointerState(key).frame == -getFrame();
	}
	
	inline public function isPadDown(key:PadKey) {
		return padStates[key] > 0;
	}
	
	inline public function isPadPressed(key:PadKey) {
		return padStates[key] == getFrame();
	}
	
	inline public function isPadReleased(key:PadKey) {
		return padStates[key] == -getFrame();
	}
	
	public function getAxisValue(axis:PadAxis) {
		return padAxisStates.exists(axis) ? padAxisStates[axis] : 0;
	}
	
	public function getKeyState(key:KeyCode) {
		if (!keyStates.exists(key)) {
			keyStates.set(key, 0);
		}
		
		// For some reason keyState map don't work for neko
		// and we have to manually loop through the map
		
		#if !neko
		return keyStates[key];
		#else
		for (k in keyStates)
			if (k == key)
				return k;
		
		return null;
		#end
	}
	
	public function getPadState(key:PadKey) {
		if (!padStates.exists(key)) {
			padStates.set(key, 0);
		}
		
		return padStates[key];
	}
	
	public function getPointerState(key:PointerKey, id = 0) {
		if (!pointerStates.exists(id)) {
			pointerStates.set(id, new Map());
		}
		
		if (!pointerStates[id].exists(key)) {
			pointerStates[id].set(key, {
				device: key,
				id: 0,
				x: 0,
				y: 0,
				dx: 0,
				dy: 0,
				pressure: 0,
				frame: 0,
			});
		}
		
		return pointerStates[id].get(key);
	}
	
	public function bindKey(name:String, key:KeyCode) {
		if (!keyBindings.exists(name)) {
			keyBindings.set(name, []);
		}
		
		keyBindings[name].push(key);
	}
	
	public function bindPadKey(name:String, key:PadKey) {
		if (!padKeyBindings.exists(name)) {
			padKeyBindings.set(name, []);
		}
		
		padKeyBindings[name].push(key);
	}
	
	public function bindPointer(name:String, key:PointerKey) {
		if (!pointerBindings.exists(name)) {
			pointerBindings.set(name, []);
		}
		
		pointerBindings[name].push(key);
	}
	
	#if (!flash && lime)
	function padConnected(pad:lime.ui.Gamepad) {
		Log.info('Gamepad ${pad.name} detected');
		Log.info([pad.guid, pad.name]);
		
		pad.onDisconnect.add(function() {
			padDisconnected(pad);
		});
		
		pad.onButtonDown.add(function(key) {
			var event:PadEvent = {
				key: key,
				kind: PKeyDown
			}
			
			padEvent(event);
		});
		
		pad.onButtonUp.add(function(key) {
			var event:PadEvent = {
				key: key,
				kind: PKeyUp
			}
			
			padEvent(event);
		});
		
		pad.onAxisMove.add(function(axis, value) {
			var event:PadEvent = {
				axis: axis,
				value: value,
				kind: PAxis
			}
			
			padEvent(event);
		});
	}
	
	function padDisconnected(pad:lime.ui.Gamepad) {
		Log.info('Gamepad ${pad.name} disconnected');
	}
	#end
	
	static inline function getFrame() {
		return Application.core.frameCount + 1;
	}
	
	
	/**
	 * Transform axis move in key event
	 * @param	axis
	 * @param	value value must be between 0 and 1
	 */ 
	function axisEvent(event:PadEvent) {
		
		var threshold = 0.2;
		
		// Test and send axis as key event
		function stick(key:PadKey, v:Float) {
		
			var kind = PUnknown;
			
			if (!isPadDown(key) && v > 0.5 + threshold)
				kind = PKeyDown;
			if (isPadDown(key) && v < 0.5 + threshold)
				kind = PKeyUp;
			
			if (kind == PUnknown)
				return PUnknown;
			
			var event:PadEvent = {
				key: key,
				kind: kind
			}
			
			padEvent(event);
			
			return kind;
		}
		
		function dir(dir1, dir2, value, sValue) {
			if (value < 0.0) {
				stick(dir1, sValue);
				var event:PadEvent = {
					key: dir2,
					kind: PKeyUp
				}
				
				padEvent(event);
			} else {
				stick(dir2, sValue);
				var event:PadEvent = {
					key: dir1,
					kind: PKeyUp
				}
				
				padEvent(event);
			}
		}
		
		var sValue = Math.abs(event.value) * 0.5 + 0.5;
		
		switch (event.axis) {
			case PadAxis.LEFT_X:
				dir(PadKey.LSTICK_LEFT, PadKey.LSTICK_RIGHT, event.value, sValue);
				
			case PadAxis.LEFT_Y:
				dir(PadKey.LSTICK_UP, PadKey.LSTICK_DOWN, event.value, sValue);
				
			case PadAxis.RIGHT_X:
				dir(PadKey.RSTICK_LEFT, PadKey.RSTICK_RIGHT, event.value, sValue);
				
			case PadAxis.RIGHT_Y:
				dir(PadKey.RSTICK_UP, PadKey.RSTICK_DOWN, event.value, sValue);
			
			case PadAxis.TRIGGER_LEFT:
				var kind = PUnknown;
							
				if (!isPadDown(PadKey.LEFT_TRIGGER) && event.value >= 0.5)
					kind = PKeyDown;
				if (isPadDown(PadKey.LEFT_TRIGGER) && event.value < 0.5)
					kind = PKeyUp;
				
				if (kind == PUnknown)
					return;
				
				var event:PadEvent = {
					key: PadKey.LEFT_TRIGGER,
					kind: kind
				}
				
				padEvent(event);
			
			case PadAxis.TRIGGER_RIGHT:
				var kind = PUnknown;
							
				if (!isPadDown(PadKey.RIGHT_TRIGGER) && event.value >= 0.5)
					kind = PKeyDown;
				if (isPadDown(PadKey.RIGHT_TRIGGER) && event.value < 0.5)
					kind = PKeyUp;
				
				if (kind == PUnknown)
					return;
				
				var event:PadEvent = {
					key: PadKey.RIGHT_TRIGGER,
					kind: kind
				}
				
				padEvent(event);
				
			
			default:
				Log.info("Unknown gamepad event");
		}
	}
	
	function padEvent(event:PadEvent) {
		switch (event.kind) {
		case PKeyDown:
			if (getPadState(event.key) <= 0)
				padStates[event.key] = getFrame();
		case PKeyUp:
			padStates[event.key] = -getFrame();
		case PAxis:
			axisEvent(event);
			padAxisStates[event.axis] = event.value;
		case PUnknown:
			Log.warn('Unknown gamepad event $event');
		}
	}
	
	function onKeyDown(window:Window, key:KeyCode, modifier:KeyModifier) {
		var event:KeyEvent = {
			keyCode: key,
			charCode: key,
			modifier: modifier,
			kind: KDown,
			frame: 0,
			propagate: true
		}
		
		keyEvent(event);
	}
	
	function onKeyUp(window:Window, key:KeyCode, modifier:KeyModifier) {
		var event:KeyEvent = {
			keyCode: key,
			charCode: key,
			modifier: modifier,
			kind: KUp,
			frame: 0,
			propagate: true
		}
		
		keyEvent(event);
	}
	
	function onTextInput(window:Window, text:String) {
		onTextEvent.dispatch(window, text);
	}
	
	function keyEvent(event:KeyEvent) {
		
		onKeyEvent.dispatch(event);
		
		if (!event.propagate)
			return;
		
		switch( event.kind ) {
		case KDown:
			if (getKeyState(event.keyCode) <= 0) {
				keyStates[event.keyCode] = getFrame();
			}
		case KUp:
			keyStates[event.keyCode] = -getFrame();
		default:
		}
	}
	
	function mouseEvent(event:PointerEvent) {
		var pointer = getPointerState(event.device, event.id);
		
		onPointerEvent.dispatch(event);
		
		switch( event.kind ) {
		case MDown:
			if (pointer.frame <= 0)
				pointer.frame = getFrame();
		case MUp:
			pointer.frame = -getFrame();
			pointer.x = event.x;
			pointer.y = event.y;
		case MMove:
			pointer.x = event.x;
			pointer.y = event.y;
		case MMoveRelative:
			pointer.dx = event.dx;
			pointer.dy = event.dy;
		case MUnknown:
			Log.info('Unknown mouse event');
		}
	}
	
}

typedef KeyEvent = {
	var keyCode:KeyCode;
	var charCode:Int;
	var modifier:KeyModifier;
	var kind:KeyEventKind;
	var frame:Int;
	var propagate:Bool;
}

typedef Pointer = {
	var device:Int;
	var id:Int;
	var dx:Float;
	var dy:Float;
	var pressure:Float;
	var x:Float;
	var y:Float;
	@:optional var frame:Int;
}

typedef PointerEvent = {
	> Pointer,
	var kind:PointerEventKind;
}

typedef PadEvent = {
	var kind:PadEventKind;
	@:optional var key:PadKey;
	@:optional var axis:PadAxis;
	@:optional var value:Float;
}

enum KeyEventKind {
	KDown;
	KUp;
	KUnknown;
	KWheel;
}

enum PadEventKind {
	PKeyDown;
	PKeyUp;
	PAxis;
	PUnknown;
}

enum PointerEventKind {
	MDown;
	MMoveRelative;
	MUp;
	MMove;
	MUnknown;
}

typedef AxisState = {
	var frame:Int;
	var value:Float;
}
#end