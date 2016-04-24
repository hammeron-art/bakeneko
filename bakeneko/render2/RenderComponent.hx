package bakeneko.render;

import bakeneko.asset.Shader;
import bakeneko.asset.Texture;
import bakeneko.core.Application;
import bakeneko.entity.Component;
import bakeneko.entity.Transform;
import bakeneko.math.Matrix4x4;

class RenderComponent extends Component {

	public var visible:Bool = true;

	/**
	 * Layer index.
	 * A camera will only render the components of its specified layers
	 */
	public var layer:Int;

	public var mesh:Mesh;

	public function new(mesh:Mesh, ?material:Material, ?layer:Int = 0) {
		this.mesh = mesh;
		this.mesh.material = (material != null) ? material : Application.get().renderSystem.defaultMaterial;
		this.layer = layer;
	}

	public function draw() { }

	function get_transform() {
		return entity.transform;
	}

}