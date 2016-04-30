package states.hxsl;

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
		params = new Float32Array(shaderData.globalsSize * 4);
		textures = new haxe.ds.Vector(shaderData.textures2DCount);
	}
}

class ProgramBuffer {

	public var vertex:ShaderBuffer;
	public var fragment:ShaderBuffer;
	
	public function new(shader:RuntimeShader) {
		vertex = new ShaderBuffer(shader.vertex);
		fragment = new ShaderBuffer(shader.fragment);
	}
	
}