package bakeneko;

import bakeneko.core.Application;
import bakeneko.core.Core;
import bakeneko.graphics.Graphics;
import lime.graphics.GLRenderContext;

/**
 * ...
 * @author Christian
 */
class SystemImpl {

	public static var g:Graphics;
	public static var gl:GLRenderContext = new GLRenderContext();
	public static var frame:bakeneko.graphics.Framebuffer;
	
	public function new() {
		
	}
	
	public static function init(core:Core) {
		gl = switch(core.renderer.context) {
			case OPENGL(context):
				gl = context;
			default:
				throw "Can't use other context";
		}
	}
	
}