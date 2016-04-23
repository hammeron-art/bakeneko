package bakeneko;

/*import bakeneko.core.Application;
import bakeneko.core.Core;
import bakeneko.graphics4.Framebuffer;
import bakeneko.graphics4.Graphics;
import cpp.Void;
import lime.app.Application;
import lime.graphics.GLRenderContext;*/

import lime.app.Application;

@:access(lime.app.Application)
class SystemImpl {

	static public var app:LimeApplication;
	
	static var windows:Array<Window>;
	
	static public function init() {
		app = new LimeApplication();
		app.setPreloader(ApplicationMain.preloader);
		
		var config = ApplicationMain.config;
		config.windows[0].title = "Bakeneko App";
		app.create(config);
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