package;

import bakeneko.core.Application;
import bakeneko.core.WindowEvent;
import tests.HxslTest;

class Testbed extends Application {
	
	override public function initialState():Void {
		stateManager.push(new HxslTest());
	}
	
}