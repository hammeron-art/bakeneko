package bakeneko.graphics4;

import bakeneko.core.AppSystem;
import bakeneko.core.Event;
import bakeneko.core.Window;
import bakeneko.render.Color;

/**
 * ...
 * @author Christian
 */
class RenderSystem extends AppSystem {
	
	public var onRenderEvent = new Event<Window->Void>();
	
	override public function onInit():Void {
	}
	
	public function onRender(window:Window) {
		var g = window.renderer;
		
		g.begin();
		g.clear(Color.WHITE);
		g.end();
		
		onRenderEvent.dispatch(window);
		
		g.present();
	}
	
}