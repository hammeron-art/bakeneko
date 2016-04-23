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
					
					var window = new Window (windowConfig);
					createWindow (window.limeWindow);
					
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
	
}