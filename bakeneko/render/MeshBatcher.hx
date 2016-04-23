package bakeneko.render;

import bakeneko.core.Pair;
import bakeneko.math.Matrix4x4;

/**
 * Batch groups of meshes in a single buffer to optimize performance
 */
class MeshBatcher extends Mesh {

	// Array of the mesh to be included in the batcher
	var meshCache:Array<Pair<Mesh, Matrix4x4>>;

	public var meshCount(get, never):Int;

	public function new(?vertexFormat:VertexFormat, ?data:MeshData) {
		super(data, vertexFormat);
		
		meshCache = new Array();
	}
	
	public function addMesh(mesh:Mesh, transform:Matrix4x4) {
		meshCache.push(new Pair(mesh, transform));
	}

	override public function build() {

		if (meshCache.length == 0)
			return;

		var vertexCount = 0;
		
		var vertices:Array<Float> = [];
		var indexes:Array<Int> = [];

		for (pair in meshCache) {
			vertices = vertices.concat(pair.first.getTransformedMesh(pair.second));
			indexes = indexes.concat(pair.first.getTransformedIndex(vertexCount));
		}

		setVertexFromArray(vertices);
		setIndexFromArray(indexes);

		super.build();
	}

	public function flush() {
		meshCache.splice(0, meshCache.length);
	}
	
	public function get_meshCount() {
		return meshCache.length;
	}

}

typedef MeshTransformMap = Map<Mesh, Matrix4x4>;