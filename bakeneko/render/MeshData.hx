package bakeneko.render;

typedef Vector = Array<Float>;
typedef Face = Array<Int>;

typedef MeshData = {
	var vertexCount:Int;
	
	@:optional var name:String;
	@:optional var structure:VertexStructure;
	
	@:optional var positions:Array<Vector>;
	@:optional var uvs:Array<Vector>;
	@:optional var colors:Array<Vector>;
	@:optional var normals:Array<Vector>;
	@:optional var faces:Array<Face>;
	@:optional var indices:Array<Int>;
}