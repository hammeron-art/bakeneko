package bakeneko.render;

class Pass {

	public function new() {
	}

	public function compileShader( p : h3d.mat.Pass ) : hxsl.RuntimeShader {
		throw "Not implemented for this pass";
		return null;
	}

	public function dispose() {
	}

	public function draw(passes:Pass) {
		return passes;
	}
	
}