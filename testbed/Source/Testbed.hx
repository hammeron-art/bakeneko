package;

import bakeneko.core.Application;
import bakeneko.core.WindowEvent;
import samples.RenderTest;

class Testbed extends Application {
	
	override public function initialState():Void {
		stateManager.push(new RenderTest());
	}
	
}