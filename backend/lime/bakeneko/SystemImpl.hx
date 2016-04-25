package bakeneko;

import bakeneko.core.Log;
import bakeneko.render.Renderer;
import bakeneko.render.Surface;
import lime.app.Application;

#if flash
import bakeneko.input.Gamepad;
import bakeneko.input.Input.PadAxis;
import bakeneko.input.Input.PadKey;
import bakeneko.input.InputSystem.PadEventKind;
#end

@:access(lime.app.Application)
class SystemImpl {

	static public var app:LimeApplication;
	
	static public function init() {
		app = new LimeApplication();
		app.setPreloader(ApplicationMain.preloader);
		
		var config = ApplicationMain.config;
		config.windows[0].title = "Bakeneko App";
		app.create(config);
		
		setupFlashGamepad();
	}
	
	@:access(bakeneko.core.Window)
	static public function createWindow(window:bakeneko.core.Window) {
		@:privateAccess
		app.bWindows.set(window.limeWindow, window);
		app.createWindow(window.limeWindow);
		
		window.renderer = new Renderer(window);
		
		window.surface = new Surface();
		
		bakeneko.core.System.app.windows.push(window);
	}
	
	#if flash
	static var gameInput:flash.ui.GameInput;
	static var gameInputCount = 0;
	#end
	
	@:access(bakeneko.input.Gamepad)
	static function setupFlashGamepad() {
		#if flash
		gameInput = new flash.ui.GameInput();
		gameInput.addEventListener(flash.events.GameInputEvent.DEVICE_ADDED, function(e:flash.events.GameInputEvent) {
			var pad = new Gamepad(gameInputCount);
			pad.flashPad = e.device;
			
			var device = pad.flashPad;
			device.enabled = true;
			//Log.info('Gamepad ${pad.name} detected');
		
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
						
						pad.onAxisMove.dispatch(axis, c.value);
						
						/*var event:PadEvent = {
							axis: axis,
							value: c.value,
							kind: PAxis
						}
						
						padEvent(event);*/
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
								
								pad.onAxisMove.dispatch(PadAxis.TRIGGER_LEFT, c.value);
								
								/*var event:PadEvent = {
									axis: PadAxis.TRIGGER_LEFT,
									value: c.value,
									kind: PAxis
								}
								
								padEvent(event);*/
							
							case PadKey.RIGHT_TRIGGER:
								
								pad.onAxisMove.dispatch(PadAxis.TRIGGER_RIGHT, c.value);
								
								/*var event:PadEvent = {
									axis: PadAxis.TRIGGER_RIGHT,
									value: c.value,
									kind: PAxis
								}
								
								padEvent(event);*/
							
							default:
								var input = bakeneko.core.System.app.input;
								
								var kind = PUnknown;
							
								if (!input.isPadDown(key) && value >= 0.5)
									kind = PKeyDown;
								if (input.isPadDown(key) && value < 0.5)
									kind = PKeyUp;
								
								if (kind == PUnknown)
									return;
								
								switch (kind) {
									case PKeyDown:
										pad.onButtonDown.dispatch(key);
									case PKeyUp:
										pad.onButtonUp.dispatch(key);
									default:
										Log.error('Unprocessed event $key');
								}
								
								/*var event:PadEvent = {
									key: key,
									kind: kind
								}
								
								padEvent(event);*/
							}
						});
					}
				}
			}
			
			if (!Gamepad.devices.exists(pad.id)) {
				Gamepad.devices.set(pad.id, pad);
				Gamepad.onConnect.dispatch(pad);
			}
			
		});
		// necessary to trigger added
		//var count = flash.ui.GameInput.numDevices;
		#end
	}
	
}