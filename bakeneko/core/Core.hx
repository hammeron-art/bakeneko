package bakeneko.core;

import bakeneko.SystemImpl;
import bakeneko.input.Input.PointerKey;
import bakeneko.input.Input.PadKey;
import bakeneko.input.Input.PadAxis;
import bakeneko.input.InputSystem.KeyEvent;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import bakeneko.core.Window;
import lime.app.Config;
import lime.app.Event;
import lime.graphics.Renderer;

@:allow(ApplicationMain)
class Core extends lime.app.Application {
	
	public var bkApp(default, null):Application;

	public var inited:Bool = false;
	public var shuttingDown:Bool = false;
	
	public var lastTime:Float;
	
	public var frameCount = 0;
	
	// Debug and telemetry
	#if telemetry
	var telemetry:hxtelemetry.HxTelemetry;
	#end
	var max = 0.0;
	var start = false;
	
	public function new () {
		
		#if logneko
		logneko.inspector.GLInspector.init();
		#end
		
		#if telemetry
		var config = new hxtelemetry.HxTelemetry.Config();
		config.app_name = 'Bakeneko App';
		config.allocations = false;
		telemetry = new hxtelemetry.HxTelemetry(/*config*/);
		#end
		
		super ();
	}
	
	function initApp() {
		SystemImpl.init(this);
		
		bkApp.init(this);
		
		bkApp.timer.schedule(2, function() {
			start = true;
		});
	}
	
	function init(bkApp:Application) {
		this.bkApp = bkApp;
		//this.config = this.bkApp.initConfig(config);
		
		Scheduler.init();
		Scheduler.start();
		
		//Scheduler.addTimeTask(function() nextFrame(1 / 60), 0, 1 / 60);
	}
	
	override public function update(deltaTime:Int):Void {
		//nextFrame(deltaTime / 1000.0);
		/*UpdateTimer.update();
		bkApp.update(deltaTime/1000);
		bkApp.render(renderer);*/
	}
	
	public override function render (renderer:Renderer):Void {
		Scheduler.executeFrame();
		nextFrame(1/60);
	}
	
	function nextFrame(delta:Float) {
		var time = Timer.stamp();
		
		UpdateTimer.update();
		
		bkApp.update(delta);
		//var time = Timer.stamp();
		
		bkApp.render(SystemImpl.frame);
		
		frameCount++;
		
		#if telemetry
		telemetry.advance_frame();
		#end
		
		var count = Timer.stamp() - time;
		if (count > 1 / 60)
			Log.info('Frame lag: $count');
		
		if (start)
			max = Math.max(max, count);
	}
	
	function windowEvent(type:WindowEventType, window:bakeneko.core.Window, x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0) {
		if (!inited)
			return;
			
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
				removeWindow (window);
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
		
		bkApp.windowEvent(event);
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
	
	override public function onKeyDown(window:Window, keyCode:lime.ui.KeyCode, modifier:KeyModifier):Void {
		bkApp.keyDown(window, keyCode, modifier);
	}
	
	override public function onKeyUp(window:Window, keyCode:KeyCode, modifier:KeyModifier):Void {
		bkApp.keyUp(window, keyCode, modifier);
	}
	
	override public function onMouseDown(window:Window, x:Float, y:Float, button:Int):Void {
		super.onMouseDown(window, x, y, button);
	}
	
	override public function onMouseMove(window:Window, x:Float, y:Float):Void {
		super.onMouseMove(window, x, y);
	}
	
	override public function onMouseMoveRelative(window:Window, x:Float, y:Float):Void {
		super.onMouseMoveRelative(window, x, y);
	}
	
	override public function onMouseUp(window:Window, x:Float, y:Float, button:Int):Void {
		super.onMouseUp(window, x, y, button);
	}
	
	override public function onMouseWheel(window:Window, deltaX:Float, deltaY:Float):Void {
		super.onMouseWheel(window, deltaX, deltaY);
	}
	
}

class UpdateTimer {

	public static var wantedFPS = 60.;
	public static var maxDeltaTime = 0.5;
	public static var oldTime = haxe.Timer.stamp();
	public static var tmod_factor = 0.95;
	public static var calc_tmod : Float = 1;
	public static var tmod : Float = 1;
	public static var deltaT : Float = 1;
	static var frameCount = 0;

	public inline static function update() {
		frameCount++;
		var newTime = haxe.Timer.stamp();
		deltaT = newTime - oldTime;
		oldTime = newTime;
		if( deltaT < maxDeltaTime )
			calc_tmod = calc_tmod * tmod_factor + (1 - tmod_factor) * deltaT * wantedFPS;
		else
			deltaT = 1 / wantedFPS;
		tmod = calc_tmod;
	}

	public inline static function fps() : Float {
		return wantedFPS/calc_tmod;
	}

	public static function skip() {
		oldTime = haxe.Timer.stamp();
	}

}
