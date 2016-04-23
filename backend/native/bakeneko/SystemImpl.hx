package bakeneko;

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
	
	@:access(bakeneko.native.Window)
	static public function createWindow(window:bakeneko.native.Window) {
		@:privateAccess
		app.bWindows.set(window.limeWindow, window);
		app.createWindow(window.limeWindow);
		
		bakeneko.core.System.app.windows.push(window);
	}
	
}