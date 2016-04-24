package;

import bakeneko.core.Application;
import bakeneko.core.WindowEvent;
import states.RenderTest;

class Project extends Application {
	
	public function new() {
		super();
	}
	
	override public function initialState():Void {
		stateManager.push(new RenderTest());
	}
	
}