package bakeneko;

import bakeneko.graphics4.Renderer;
import bakeneko.graphics4.Surface;
import lime.app.Application;

@:access(lime.app.Application)
class SystemImpl {

	static public var app:LimeApplication;
	
	static public function init() {
		app = new LimeApplication();
		app.setPreloader(ApplicationMain.preloader);
		
		var config = ApplicationMain.config;
		config.windows[0].title = "Bakeneko App";
		app.create(config);
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
	
}