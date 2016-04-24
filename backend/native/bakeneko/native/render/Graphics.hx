package bakeneko.native.render;

import bakeneko.graphics4.IRenderer;
import bakeneko.render.Color;
import lime.graphics.GLRenderContext;

class Graphics implements IRenderer {

	var gl:GLRenderContext;
	
	public function new(context:GLRenderContext = null) {
		this.gl = context != null ? context : switch (SystemImpl.app.window.renderer.context) { case OPENGL(gl): gl; default: throw "Unsupported context"; };
	}
	
	public function clear(?color:Color, ?depth:Float, ?stencil:Int):Void {
		
	}
	
}