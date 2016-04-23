package bakeneko.format.model;
import bakeneko.render.VertexFormat;

/**
 * Unified data structures returned by Readers
 */

typedef Vector = Array<Float>;
typedef Face = Array<Int>;

typedef MeshData = bakeneko.render.MeshData;

typedef NodeData = {
	var name:String;
	
	var meshes:Array<MeshData>;
	var type:NodeType;
}
typedef MaterialData = {
	var name:String;
}
typedef SceneData = {
	var name:String;
	var nodes:Array<NodeData>;
}

@:enum
abstract NodeType(Int) from Int to Int {
	var undefined = 0;
	var model = 1;
	var light = 2;
}