package bakeneko.graphics4;

import bakeneko.core.AppSystem;
import bakeneko.render.Color;

/**
 * ...
 * @author Christian
 */
class RenderSystem extends AppSystem {
	
	public var driver:Dynamic;
	
	override public function onInit():Void {
		trace('inie');
	}
	
	public function onRender(frame:ISurface) {
		//var g = frame.g4;
		
		//g.clear(new Color(1.0, 0.5, 0.0, 1.0));
		/*var g = SystemImpl.gl;
		
		g.clearColor(1.0, 0.5, 0.0, 1.0);
		g.clear(gl.COLOR_BUFFER_BIT);*/
	}
	
}