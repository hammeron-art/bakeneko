package;

import bakeneko.core.Application;
import bakeneko.core.WindowEvent;
import bakeneko.input.KeyCode;
import bakeneko.render.Color;
import bakeneko.state.State;
import bakeneko.utils.Utils;
import states.HxslTest;
import states.InputTest;
import states.RenderTest;

class Testbed extends Application {
	
	var createState:Array<State>;
	var currentState:Int;
	
	public function new() {
		super();
		
		createState = [];
		currentState = 0;
	}
	
	override public function onInit():Void {
		addState(new RenderTest());
		addState(new HxslTest());
		addState(new InputTest());
	}
	
	override public function initialState():Void {
		stateManager.push(createState[currentState]);
	}
	
	override public function onUpdate(delta:Float):Void {
		var dir = Utils.int(input.isKeyPressed(KeyCode.PAGE_UP)) - Utils.int(input.isKeyPressed(KeyCode.PAGE_DOWN));
		
		if (dir != 0) {
			currentState = Utils.cycle(currentState + dir, createState.length);
			changeState(currentState);
		}
	}
	
	function addState(method:State) {
		createState.push(method);
	}
	
	function changeState(index:Int) {
		stateManager.change(createState[currentState]);
	}
	
}