package bakeneko.render;

/**
 * Non-animated meshes
 */
class StaticMeshComponent extends RenderComponent {

	public function new(mesh:Mesh, ?material:Material) {
		super(mesh, material);
	}

	public function attachMesh(mesh:Mesh, material:Material) {
		this.mesh = mesh;
		this.mesh.material = material;
	}

	override public function draw() {
		mesh.draw();
	}
}