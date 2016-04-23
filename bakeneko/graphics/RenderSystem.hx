package bakeneko.graphics;

import bakeneko.core.AppSystem;

/**
 * ...
 * @author Christian
 */
class RenderSystem extends AppSystem {
	
	public var driver:Dynamic;
	
	override public function onInit():Void {
		trace('inie');
	}
	
	public function onRender(frame:Framebuffer) {
		var gl = SystemImpl.gl;
		
		gl.clearColor(1.0, 0.5, 0.0, 1.0);
		gl.clear(gl.COLOR_BUFFER_BIT);
	}
	
}