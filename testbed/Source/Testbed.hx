package;

import bakeneko.core.Application;
import bakeneko.core.WindowEvent;
import tests.RenderTest;

class Testbed extends Application {
	
	override public function initialState():Void {
		stateManager.push(new RenderTest());
	}
	
}