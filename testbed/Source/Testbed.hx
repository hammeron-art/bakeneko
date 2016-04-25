package;

import bakeneko.core.Application;
import bakeneko.core.WindowEvent;
import bakeneko.input.KeyCode;
import bakeneko.render.Color;
import bakeneko.state.State;
import bakeneko.utils.Utils;
import tests.HxslTest;
import tests.RenderTest;

class Testbed extends Application {
	
	var createState:Array<Void->State>;
	var currentState:Int = 0;
	
	public function new() {
		super();
		
		createState = [];
		currentState = 0;
	}
	
	override public function onInit():Void {
		addState(HxslTest.new.bind());
		addState(RenderTest.new.bind(Color.fromInt32(0x4b151e/*0x1c1d23*/)));
	}
	
	override public function initialState():Void {
		stateManager.push(createState[currentState]());
	}
	
	override public function onUpdate(delta:Float):Void {
		var dir = Utils.int(input.isKeyPressed(KeyCode.RIGHT)) - Utils.int(input.isKeyPressed(KeyCode.LEFT));
		
		if (dir != 0) {
			currentState = Utils.cycle(currentState + dir, createState.length);
			changeState(currentState);
		}
	}
	
	function addState(method:Void->State) {
		createState.push(method);
	}
	
	function changeState(index:Int) {
		stateManager.change(createState[currentState]());
	}
	
}