package bakeneko.core;

class System {

	static var app:Application;
	
	static public function init(create:Void->Application) {
		SystemImpl.init();
		app = create();
	}
	
}