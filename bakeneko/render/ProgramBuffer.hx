package bakeneko.render;

import bakeneko.asset.Texture;
import bakeneko.hxsl.RuntimeShader;
import haxe.ds.Vector;
import lime.utils.Float32Array;

class ShaderBuffer {
	
	public var globals:Float32Array;
	public var params:Float32Array;
	public var textures:haxe.ds.Vector<Texture>;
	
	public function new(shaderData:RuntimeShaderData) {
		globals = new Float32Array(shaderData.globalsSize * 4);
		params = new Float32Array(shaderData.paramsSize * 4);
		textures = new haxe.ds.Vector(shaderData.textures2DCount);
	}
	
	// Debug
	public function toString() {
		var sGlobals = [ for (i in 0...globals.length) globals[i] ];
		var sParams = [ for (i in 0...params.length) params[i] ];
		var sTextures = [ for (i in 0...textures.length) textures[i] ];
		
		return 'Globals: $sGlobals\nParams: $sParams\nTextures: $sTextures';
	}
}

class ProgramBuffer {

	public var vertex:ShaderBuffer;
	public var fragment:ShaderBuffer;
	
	public function new(shader:RuntimeShader) {
		vertex = new ShaderBuffer(shader.vertex);
		fragment = new ShaderBuffer(shader.fragment);
	}
	
	// Debug
	public function toString() {
		return 'Vertex: $vertex\nFragment: $fragment';
	}
}