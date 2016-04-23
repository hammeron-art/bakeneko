package bakeneko.graphics;

import lime.graphics.opengl.GL;
import bakeneko.graphics.FragmentShader;
import bakeneko.graphics.VertexData;
import bakeneko.graphics.VertexShader;
import bakeneko.graphics.VertexStructure;

class PipelineState extends PipelineStateBase {
	private var program: Dynamic;
	private var textures: Array<String>;
	private var textureValues: Array<Dynamic>;
	
	public function new() {
		super();
		program = SystemImpl.gl.createProgram();
		textures = new Array<String>();
		textureValues = new Array<Dynamic>();
	}
		
	public function compile(): Void {
		compileShader(vertexShader);
		compileShader(fragmentShader);
		SystemImpl.gl.attachShader(program, vertexShader.shader);
		SystemImpl.gl.attachShader(program, fragmentShader.shader);
		
		var index = 0;
		for (structure in inputLayout) {
			for (element in structure.elements) {
				SystemImpl.gl.bindAttribLocation(program, index, element.name);
				if (element.data == VertexData.Float4x4) {
					index += 4;
				}
				else {
					++index;
				}
			}
		}
		
		SystemImpl.gl.linkProgram(program);
		if (SystemImpl.gl.getProgramParameter(program, GL.LINK_STATUS) == 0) {
			throw "Could not link the shader program:\n" + SystemImpl.gl.getProgramInfoLog(program);
		}
	}
	
	public function set(): Void {
		SystemImpl.gl.useProgram(program);
		for (index in 0...textureValues.length) SystemImpl.gl.uniform1i(textureValues[index], index);
		SystemImpl.gl.colorMask(colorWriteMaskRed, colorWriteMaskGreen, colorWriteMaskBlue, colorWriteMaskAlpha);
	}
	
	private function compileShader(shader: Dynamic): Void {
		if (shader.shader != null) return;
		var s = SystemImpl.gl.createShader(shader.type);
		SystemImpl.gl.shaderSource(s, shader.source);
		SystemImpl.gl.compileShader(s);
		if (SystemImpl.gl.getShaderParameter(s, GL.COMPILE_STATUS) == 0) {
			throw "Could not compile shader:\n" + SystemImpl.gl.getShaderInfoLog(s);
		}
		shader.shader = s;
	}
	
	public function getConstantLocation(name: String): bakeneko.graphics.ConstantLocation {
		return new bakeneko.native.ConstantLocation(SystemImpl.gl.getUniformLocation(program, name));
	}
	
	public function getTextureUnit(name: String): bakeneko.graphics.TextureUnit {
		var index = findTexture(name);
		if (index < 0) {
			var location = SystemImpl.gl.getUniformLocation(program, name);
			index = textures.length;
			textureValues.push(location);
			textures.push(name);
		}
		return new bakeneko.native.TextureUnit(index);
	}
	
	private function findTexture(name: String): Int {
		for (index in 0...textures.length) {
			if (textures[index] == name) return index;
		}
		return -1;
	}
}
