package tests;

import bakeneko.core.Log;
import bakeneko.hxsl.AgalOptim;
import bakeneko.hxsl.AgalOut;
import bakeneko.hxsl.Cache;
import bakeneko.hxsl.Globals;
import bakeneko.hxsl.GlslOut;
import bakeneko.hxsl.RuntimeShader;
import bakeneko.hxsl.ShaderList;
import bakeneko.hxsl.SharedShader;
import bakeneko.state.State;

class HxslTest extends State {
	
	var globals:Globals;
	var cache:Cache;
	var output:Int;
	var compiledShader:RuntimeShader;
	
	override public function onInit():Void {
		trace('hxsl');
		cache = Cache.get();
		
		var globals = new Globals();
		var output = cache.allocOutputVars(["pixelColor"]);
		
		var shader = new TestShader();
		shader.additive = true;
		
		compiledShader = compileShaders(new ShaderList(shader));
		
		tryOpengGl();
		tryFlash();
	}
	
	function tryOpengGl() {
		var out = new GlslOut();
		var vertexSource = out.run(compiledShader.vertex.data);
		var fragmentSource = out.run(compiledShader.fragment.data);
		
		Log.info('$vertexSource\n\n$fragmentSource', 0);
	}
	
	function tryFlash() {
		//cache.constsToGlobal = true;
		var out = new AgalOut();
		
		var vertexSource = out.compile(compiledShader.vertex, 2);
		var fragmentSource = out.compile(compiledShader.fragment, 2);
		var opt = new AgalOptim();
		vertexSource = opt.optimize(vertexSource);
		fragmentSource = opt.optimize(fragmentSource);
		
		Log.info('${format.agal.Tools.toString(vertexSource)}\n\n${format.agal.Tools.toString(fragmentSource)}', 0);
	}
	
	function compileShaders(shaders:ShaderList) {
		for (shader in shaders)
			shader.updateConstants(globals);
		return cache.link(shaders, output);
	}
	
}

class TestShader extends bakeneko.hxsl.Shader {

	static var SRC = {
		@input var input: {
			var color:Vec4;
		};

		var pixelColor:Vec4;
		@const var additive:Bool;

		function fragment() {
			if (additive)
				pixelColor += input.color;
			else
				pixelColor *= input.color;
		}
	}

}