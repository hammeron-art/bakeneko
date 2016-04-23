package bakeneko;

/*import bakeneko.core.Application;
import bakeneko.core.Core;
import bakeneko.core.System;
import bakeneko.graphics4.Framebuffer;
import bakeneko.graphics4.Graphics;
import cpp.Void;
import lime.app.Application;
import lime.graphics.GLRenderContext;*/

import lime.app.Application;

@:access(lime.app.Application)
class SystemImpl {

	static public var app:LimeApplication;
	static var windows:Map<lime.ui.Window, Window>;
	
	static public function init() {
		windows = new Map();
		
		app = new LimeApplication();
		app.setPreloader(ApplicationMain.preloader);
		
		var config = ApplicationMain.config;
		config.windows[0].title = "Bakeneko App";
		app.create(config);
	}
	
	@:access(bakeneko.Window)
	static public function createWindow(window:Window) {
		windows.set(window.limeWindow, window);
		
		app.createWindow(window.limeWindow);
	}
	
	static public function keyDown(window:lime.ui.Window, keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		bakeneko.core.System.keyDown(windows[window], cast keyCode, cast modifier);
	}
	
	static public function keyUp(window:lime.ui.Window, keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		bakeneko.core.System.keyUp(windows[window], cast keyCode, cast modifier);
	}
	
	/*public static var g:Graphics;
	public static var gl:GLRenderContext = new GLRenderContext();
	public static var frame:bakeneko.graphics4.Framebuffer;
	
	public function new() {
		frame = new Framebuffer(0, new bakeneko.native.graphics4.Graphics());
	}
	
	public static function init(core:Core) {
		gl = switch(core.renderer.context) {
			case OPENGL(context):
				gl = context;
			default:
				throw "Can't use other context";
		}
	}*/
	
}