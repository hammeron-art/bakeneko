package bakeneko.render;

import bakeneko.backend.Surface;
import bakeneko.core.Application;
import bakeneko.core.Pair;
import bakeneko.entity.Component;
import bakeneko.math.Matrix4x4;

/**
 * Camera components draw components of the same layers of its layer group and has its own render target.
 * The renderable components are drawn in this target allowing features such multiple cameras,
 * layering, render scene to texture and post-processing.
 */
class CameraComponent extends Component {

	/**
	 * Layers flags
	 * The camera will only render components of this layers
	 */
	var layers:Int = 0;

	/**
	 * Cameras are sorted by depth
	 * The depth defines the render order to the actual screen
	 */
	public var depth = 0;
	
	// Automatic redraw render target
	public var autoRedraw:Bool = true;

	var renderSystem:RenderSystem;
	public var projection:Matrix4x4;
	public var renderTarget:Surface;

	// Mesh batches by material
	var dynamicBatches:Map<Material, MeshBatcher>;
	
	var sortedByMaterial:Map<Material, Array<Pair<Mesh, Matrix4x4>>>;
	
	static public var mainCamera:CameraComponent = null;

	// Clear color
	public var color:Color;

	public function new() {
		projection = null;

		renderSystem = Application.get().renderSystem;
		dynamicBatches = new Map();
		color = new Color(0.0, 0.0, 0.0, 0.0);

		renderTarget = new Surface(Application.core.window.width, Application.core.window.height);
		sortedByMaterial = new Map();
		
		mainCamera = this;
	}

	public function setPerspective(fov:Float, near:Float, far:Float, aspect:Float) {
		projection = Matrix4x4.CreatePerspective(fov, aspect, near, far);
	}

	public function setOrthographic(width:Float, height:Float, near:Float, far:Float) {
		projection = Matrix4x4.CreateOrthographic(width, height, near, far);
	}
	
	public function sortMaterials() {
		for (key in sortedByMaterial.keys()) {
			sortedByMaterial.remove(key);
		}
		
		var componentList:Array<RenderComponent> = entity.scene.queryComponents(StaticMeshComponent);
		
		for (comp in componentList) {
			if (comp.visible == false || hasLayer(comp.layer) == false)
				continue;

			if (!sortedByMaterial.exists(comp.mesh.material)) {
				sortedByMaterial.set(comp.mesh.material, new Array());
			}
			
			sortedByMaterial.get(comp.mesh.material).push(new Pair(comp.mesh, comp.entity.transform.getWorld()));
		}
	}

	public function buildBatches() {
		for (material in sortedByMaterial.keys()) {
			var batch = dynamicBatches[material];
			
			if (batch == null) {
				batch = new MeshBatcher();
				dynamicBatches.set(material, batch);
			} else {
				batch.flush();
			}
			
			batch.setMaterial(material);
			
			for (pair in sortedByMaterial.get(material)) {
				batch.addMesh(pair.first, pair.second);
			}

			//Log.error(camera.renderTarget.colorTexture.textureID.id);
			batch.build();
			
			dynamicBatches.set(material, batch);
		}
	}
	
	public function draw() {
		for (material in sortedByMaterial.keys()) {
			dynamicBatches[material].draw();
		}
	}
	
	/**
	 * Set layers that can render to this camera
	 * @param	flags
	 */
	public function setLayers(flags:Array<Int>) {
		for (flag in flags) {
			layers |= 1 << flag;
		}
	}

	public function hasLayer(layer:Int) {
		return layers & (1 << layer) == (1 << layer);
	}

}