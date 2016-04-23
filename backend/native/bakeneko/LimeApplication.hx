package bakeneko;

import bakeneko.core.System;
import lime.app.Config;

@:access(bakeneko.core.Application)
class LimeApplication extends lime.app.Application {
	
	var bWindows:Map<lime.ui.Window, bakeneko.core.Window>;
	
	public function new() {
		super();
		
		bWindows = new Map();
	}
	
	override public function create(config:Config):Void {
		
		this.config = config;
		backend.create (config);
		
		if (config != null) {
			
			if (Reflect.hasField (config, "fps")) {
				frameRate = config.fps;
			}
			
			if (Reflect.hasField (config, "windows")) {
				for (windowConfig in config.windows) {
					
					var window = new Window(windowConfig);
					SystemImpl.createWindow(window);
					
					#if (flash || html5)
					break;
					#end
					
				}
			}
			
			if (preloader == null || preloader.complete) {
				onPreloadComplete ();
			}
		}
	}
	
	override public function onKeyDown(window:lime.ui.Window, keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		System.app.keyDown(bWindows[window], keyCode, modifier);
	}
	
	override public function onKeyUp(window:lime.ui.Window, keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		System.app.keyUp(bWindows[window], keyCode, modifier);
	}
	
	override public function onMouseDown(window:lime.ui.Window, x:Float, y:Float, button:Int):Void {
		System.app.mouseDown(bWindows[window], x, y, button);
	}
	
	override public function onMouseMove(window:lime.ui.Window, x:Float, y:Float):Void {
		System.app.mouseMove(bWindows[window], x, y);
	}
	
	
	override public function onMouseMoveRelative(window:lime.ui.Window, x:Float, y:Float):Void {
		System.app.mouseMoveRelative(bWindows[window], x, y);
	}
	
	
	override public function onMouseUp(window:lime.ui.Window, x:Float, y:Float, button:Int):Void {
		System.app.mouseUp(bWindows[window], x, y, button);
	}
	
	
	override public function onMouseWheel(window:lime.ui.Window, deltaX:Float, deltaY:Float):Void {
		System.app.mouseWheel(bWindows[window], deltaX, deltaY);
	}
	
}