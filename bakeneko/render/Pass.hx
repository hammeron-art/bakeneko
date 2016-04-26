package bakeneko.render;

import bakeneko.hxsl.ShaderList;

class Pass {

	var manager:ShaderManager;
	
	public function new() {
		manager = new ShaderManager(['pixelColor']);
	}

	function compileShader(shaders:ShaderList):bakeneko.hxsl.RuntimeShader {
		return manager.compileShaders(shaders);
	}

	public function dispose() {
	}

	public function draw(passes:Pass) {
		return passes;
	}
	
}