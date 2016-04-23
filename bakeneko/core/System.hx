package bakeneko.core;

import bakeneko.input.KeyCode;
import bakeneko.input.KeyModifier;

@:access(bakeneko.core.Application)
class System {

	static var app:Application;
	
	static public function init(create:Void->Application) {
		SystemImpl.init();
		app = create();
		app.windows.push(cast SystemImpl.app.windows[0]);
		
		app.init();
	}
	
	static public function keyDown(window:Window, keyCode:KeyCode, modifier:KeyModifier):Void {
		app.keyDown(window, keyCode, modifier);
	}
	
	static public function keyUp(window:Window, keyCode:KeyCode, modifier:KeyModifier):Void {
		app.keyUp(window, keyCode, modifier);
	}
	
}