package bakeneko.render;

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
	
	var backColor = Color.fromInt32(0x1c1d23);
	
	override public function onInit():Void {
	}
	
	public function onRender(window:Window) {
		var g = window.renderer;
		
		g.begin();
		g.clear(backColor);
		g.end();
		
		onRenderEvent.dispatch(window);
		
		g.present();
	}
	
}