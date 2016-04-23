package bakeneko.core;

import bakeneko.input.KeyCode;
import bakeneko.input.KeyModifier;

@:access(bakeneko.core.Application)
class System {

	static public var app:Application;
	
	static public function init(create:Void->Application) {
		app = create();
		SystemImpl.init();
		app.init();
	}
	
}