package bakeneko.render;
import bakeneko.math.Vector2;
import bakeneko.math.Vector3;
import bakeneko.math.Vector4;

class Vertex {

	var position:Vector3;
	var uv:Vector2;
	var color:Color;
	var normal:Vector3;

	public function new(?position:Vector3, ?uv:Vector2, ?color:Color, ?normal:Vector3) {
		this.position = (position == null) ? new Vector3() : position;
		this.uv = (uv == null) ? new Vector2() : uv;
		this.color = (color == null) ? new Color() : color;
		this.normal = (normal == null) ? new Vector3() : normal;
	}
	
}