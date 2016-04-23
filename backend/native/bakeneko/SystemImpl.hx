package bakeneko;

/*import bakeneko.core.Application;
import bakeneko.core.Core;
import bakeneko.graphics4.Framebuffer;
import bakeneko.graphics4.Graphics;
import lime.app.Application;
import lime.graphics.GLRenderContext;*/

import lime.app.Application;

@:access(lime.app.Application)
class SystemImpl {

	static public var app:Application;
	
	static public function init() {
		app = new Application();
		app.setPreloader(ApplicationMain.preloader);
		app.create(ApplicationMain.config);
	}
	
	/*public static var g:Graphics;
	public static var gl:GLRenderContext = new GLRenderContext();
	public static var frame:bakeneko.graphics4.Framebuffer;
	
	public function new() {
		frame = new Framebuffer(0, new bakeneko.native.graphics4.Graphics());
	}
	
	public static function init(core:Core) {
		gl = switch(core.renderer.context) {
			case OPENGL(context):
				gl = context;
			default:
				throw "Can't use other context";
		}
	}*/
	
}