package samples;

import bakeneko.core.Window;
import bakeneko.render.Color;
import bakeneko.state.State;

class RenderTest extends State {
	
	override public function onInit():Void {
		app.renderSystem.onRenderEvent.add(render);
	}
	
	function render(window:Window) {
		var g = window.renderer;
		
		g.begin();
		
		g.clear(Color.fromInt32(0x1c1d23));
		
		g.end();
	}
	
}