package bakeneko.render.pass;

import bakeneko.render.Mesh;
import bakeneko.render.pass.Types;

/**
 * Drawing pass of meshes
 */
class Pass {
	
	public var primitive:Primitive;
	public var cullFace:Face;
	public var blendMode:BlendMode;
	
	public var wireframe:Bool;
	public var fill:Bool;
	
	public function new() {
		primitive = Primitive.Triangles;
		cullFace = Back;
		
		wireframe = false;
		fill = true;
	}
	
	public function draw(mesh:Mesh) {
		mesh.draw();
	}
	
}