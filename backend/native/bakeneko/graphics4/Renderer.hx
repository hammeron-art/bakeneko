package bakeneko.graphics4;

import bakeneko.core.Log;
import bakeneko.core.System;
import bakeneko.core.Window;
import bakeneko.graphics4.IRenderer;
import bakeneko.render.Color;
import lime.graphics.GLRenderContext;

class Renderer implements IRenderer {

	var window:bakeneko.core.Window;
	var gl:GLRenderContext;
	
	public function new(window:bakeneko.core.Window) {
		this.window = window != null ? window : cast System.app.windows[0];
		
		gl = switch (@:privateAccess this.window.limeWindow.renderer.context) {
			case OPENGL(gl):
				gl;
			default:
				throw "Unsupported context";
		}
	}
	
	public function begin(surfaces:Array<Surface> = null):Void {
		gl.enable(gl.BLEND);
		gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
		
		if (surfaces == null) {
			gl.bindFramebuffer(gl.FRAMEBUFFER, null);
			gl.viewport(0, 0, window.width, window.height);
		}
	}
	
	public function end():Void {
		
	}
	
	public function clear(?color:Color, ?depth:Float, ?stencil:Int):Void {
		var clearMask: Int = 0;
		if (color != null) {
			clearMask |= gl.COLOR_BUFFER_BIT;
			gl.clearColor(color.r, color.g, color.b, color.a);
		}
		if (depth != null) {
			clearMask |= gl.DEPTH_BUFFER_BIT;
			gl.clearDepth(depth);
		}
		if (stencil != null) {
			clearMask |= gl.STENCIL_BUFFER_BIT;
			gl.enable(gl.STENCIL_TEST);
			gl.stencilMask(0xff);
			gl.clearStencil(stencil);
		}
		gl.clear(clearMask);
	}
	
}