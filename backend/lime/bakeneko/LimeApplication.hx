package bakeneko;

import bakeneko.core.System;
import bakeneko.core.WindowEvent;
import bakeneko.core.WindowEventType;
import lime.app.Config;
import lime.graphics.Renderer;
import lime.ui.Window;

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
					
					var window = new bakeneko.core.Window(windowConfig);
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
	
	override public function update(deltaTime:Int):Void {
		System.app.update(deltaTime / 1000.0);
	}
	
	override public function render(renderer:Renderer):Void {
		System.app.render(bWindows[renderer.window]);
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
	
	function windowEvent(type:WindowEventType, limeWindow:lime.ui.Window, x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0) {

		var window = bWindows[limeWindow];
		
		var event:WindowEvent = {
			type: type,
			window: window,
			x: window.x,
			y: window.y,
			width: width,
			height: height
		}
		
		switch(type) {
			case WindowEventType.close:
				removeWindow (limeWindow);
			case WindowEventType.move:
				event.x = x;
				event.y = y;
			case WindowEventType.resize:
				event.width = width;
				event.height = height;
			case WindowEventType.focusOut:
				//bkApp.background();
			case WindowEventType.focusIn:
				//bkApp.foreground();
			default:
		}
		
		System.app.windowEvent(event);
	}
	
	public override function onWindowActivate (window:Window):Void {
		windowEvent(WindowEventType.activate, window);
	}
	
	public override function onWindowClose (window:Window):Void {
		windowEvent(WindowEventType.close, window);
	}
	
	public override function onWindowCreate (window:Window):Void {
		windowEvent(WindowEventType.create, window);
	}
	
	public override function onWindowDeactivate (window:Window):Void {
		windowEvent(WindowEventType.deactivate, window);
	}
	
	public override function onWindowEnter (window:Window):Void {
		windowEvent(WindowEventType.enter, window);
	}
	
	public override function onWindowFocusIn (window:Window):Void {
		windowEvent(WindowEventType.focusIn, window);
	}
	
	public override function onWindowFocusOut (window:Window):Void {
		windowEvent(WindowEventType.focusOut, window);
	}
	
	public override function onWindowFullscreen (window:Window):Void {
		windowEvent(WindowEventType.fullscreen, window);
	}
	
	public override function onWindowLeave (window:Window):Void {
		windowEvent(WindowEventType.leave, window);
	}
	
	public override function onWindowMinimize (window:Window):Void {
		windowEvent(WindowEventType.minimize, window);
	}
	
	public override function onWindowMove (window:Window, x:Float, y:Float):Void {
		windowEvent(WindowEventType.move, window, x, y);
	}
	
	public override function onWindowResize (window:Window, width:Int, height:Int):Void {
		windowEvent(WindowEventType.resize, window,  0, 0, width, height);
	}
	
	public override function onWindowRestore (window:Window):Void {
		windowEvent(WindowEventType.restore, window);
	}
	
}