package bakeneko.physic;

import bakeneko.entity.Component;
import bakeneko.render.RenderComponent;
import nape.phys.Body;
import nape.phys.BodyType;

class BodyComponent extends Component {
	public var body:Body;
	var phySystem:PhysicsSystem;
	
	public function new(body:Body, phySystem:PhysicsSystem) {
		this.body = body;
		this.phySystem = phySystem;
	}
	
	override public function onAddedToScene() {
		phySystem.addBody(this);
	}
}