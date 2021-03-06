package states;

import bakeneko.core.Log;
import bakeneko.input.Input.PadKey;
import bakeneko.input.InputSystem;
import bakeneko.input.KeyCode;
import bakeneko.state.State;

class InputTest extends State {
	
	var input:InputSystem;
	
	override public function onInit():Void {
		var input = app.input;
		
		input.bindKey('up', KeyCode.W);
		input.bindKey('down', KeyCode.S);
		input.bindKey('left', KeyCode.A);
		input.bindKey('right', KeyCode.D);
		
		input.bindKey('up', KeyCode.UP);
		input.bindKey('down', KeyCode.DOWN);
		input.bindKey('left', KeyCode.LEFT);
		input.bindKey('right', KeyCode.RIGHT);
		
		input.bindPadKey('up', PadKey.DPAD_UP);
		input.bindPadKey('down', PadKey.DPAD_DOWN);
		input.bindPadKey('left', PadKey.DPAD_LEFT);
		input.bindPadKey('right', PadKey.DPAD_RIGHT);
		
		input.onKeyEvent.add(function(event) Log.info(event, 0));
		input.onPointerEvent.add(function(event) Log.info(event, 0));
		input.onPadEvent.add(function(event) Log.info(event, 0));
	}
	
}