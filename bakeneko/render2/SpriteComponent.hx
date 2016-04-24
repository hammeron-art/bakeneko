package bakeneko.render;

import bakeneko.core.Application;
import bakeneko.render.VertexFormat;

/**
 * Component for sprites
 */
class SpriteComponent extends StaticMeshComponent {

	public function new(?mesh:Mesh, ?material:Material) {

		if (mesh == null) {
			mesh = new Mesh(MeshTools.createQuad());
		}

		super(mesh, material);
	}

}