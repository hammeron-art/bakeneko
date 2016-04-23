package bakeneko;

import lime.app.Config;

class LimeApplication extends lime.app.Application {
	
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
		SystemImpl.keyDown(window, keyCode, modifier);
	}
	
	override public function onKeyUp(window:lime.ui.Window, keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		SystemImpl.keyUp(window, keyCode, modifier);
	}
	
}