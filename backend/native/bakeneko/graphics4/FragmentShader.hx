package bakeneko.graphics4;

import lime.graphics.opengl.GL;

class FragmentShader {
	public var source: String;
	public var type: Dynamic;
	public var shader: Dynamic;
	
	public function new(source: Dynamic) {
		this.source = source.toString();
		this.type = GL.FRAGMENT_SHADER;
		this.shader = null;
	}
}
