package bakeneko.physic;

import bakeneko.core.Application;
import bakeneko.render.Material;
import bakeneko.state.StateSystem;
import nape.geom.Vec2;
import nape.space.Space;

class PhysicsSystem extends StateSystem {

	public var space(default, null):Space;
	public var debug:DebugDraw;
	
	var bodyComps:Array<BodyComponent>;
	
	public function new(gravity:Vec2) {
		space = new Space(gravity);
		bodyComps = [];
		
		#if debug
		debug = new DebugDraw(this);
		#end
	}
	
	override public function onUpdate(delta:Float):Void {
		if (delta > 0)
			space.step(delta);
		
		/*for (comp in bodyComps) {
			var transform = comp.entity.transform;
			transform.x = comp.body.position.x;
			transform.y = comp.body.position.y;
		}*/
	}
	
	public function addBody(bodyComp:BodyComponent) {
		bodyComp.body.space = space;
		bodyComps.push(bodyComp);
	}
	
}