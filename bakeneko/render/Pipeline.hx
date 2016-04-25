package bakeneko.render;

import bakeneko.hxsl.Shader;
import bakeneko.hxsl.ShaderList;
import bakeneko.render.FragmentShader;
import bakeneko.render.VertexData;
import bakeneko.render.VertexShader;
import bakeneko.render.VertexStructure;

class Pipeline {

	public var vertexStructures: Array<VertexStructure>;

	public var cullMode: CullMode;

	public var depthWrite: Bool;
	public var depthMode: CompareMode;

	public var stencilMode: CompareMode;
	public var stencilBothPass: StencilAction;
	public var stencilDepthFail: StencilAction;
	public var stencilFail: StencilAction;
	public var stencilReferenceValue: Int;
	public var stencilReadMask: Int;
	public var stencilWriteMask: Int;

	// One, Zero deactivates blending
	public var blendSource: BlendingFactor;
	public var blendDestination: BlendingFactor;
	public var blendOperation: BlendingOperation;
	public var alphaBlendSource: BlendingFactor;
	public var alphaBlendDestination: BlendingFactor;
	public var alphaBlendOperation: BlendingOperation;
	
	public var colorWriteMask(never, set) : Bool;
	public var colorWriteMaskRed : Bool;
	public var colorWriteMaskGreen : Bool;
	public var colorWriteMaskBlue : Bool;
	public var colorWriteMaskAlpha : Bool;
	
	var shaderList:ShaderList;
	var textures: Array<String>;
	var textureValues: Array<Dynamic>;
	
	var render:Renderer;
	
	function new(render:Renderer, ?shaderList:ShaderList) {
		this.render = render;
		this.shaderList = shaderList;
		
		vertexStructures = [];

		cullMode = CullMode.None;

		depthWrite = false;
		depthMode = CompareMode.Always;

		stencilMode = CompareMode.Always;
		stencilBothPass = StencilAction.Keep;
		stencilDepthFail = StencilAction.Keep;
		stencilFail = StencilAction.Keep;
		stencilReferenceValue = 0;
		stencilReadMask = 0xff;
		stencilWriteMask = 0xff;

		blendSource = BlendingFactor.BlendOne;
		blendDestination = BlendingFactor.BlendZero;
		blendOperation = BlendingOperation.Add;
		alphaBlendSource = BlendingFactor.BlendOne;
		alphaBlendDestination = BlendingFactor.BlendZero;
		alphaBlendOperation = BlendingOperation.Add;
		
		colorWriteMask = true;

		textures = new Array<String>();
		textureValues = new Array<Dynamic>();
	}
	
	public function addShader(?shader:Shader) {
		shaderList = new ShaderList(shader, shaderList);
	}
	
	public function removeShader(shader:Shader) {
		var sl = shaderList, prev = null;
		while( sl != null ) {
			if( sl.s == shader ) {
				if( prev == null )
					shaderList = sl.next;
				else
					prev.next = sl.next;
				return true;
			}
			prev = sl;
			sl = sl.next;
		}
		return false;
	}
	
	/*public function getShader< T:hxsl.Shader >(t:Class<T>) : T {
		var s = shaderList;
		while( s != parentShaders ) {
			var sh = Std.instance(s.s, t);
			if( sh != null )
				return sh;
			s = s.next;
		}
		return null;
	}

	public inline function getShaders() {
		return shaderList.iterateTo(parentShaders);
	}*/
	
	/*public function compile(): Void {
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
	
	public function getConstantLocation(name: String): bakeneko.graphics4.ConstantLocation {
		return new bakeneko.native.graphics4.ConstantLocation(SystemImpl.gl.getUniformLocation(program, name));
	}
	
	public function getTextureUnit(name: String): bakeneko.graphics4.TextureUnit {
		var index = findTexture(name);
		if (index < 0) {
			var location = SystemImpl.gl.getUniformLocation(program, name);
			index = textures.length;
			textureValues.push(location);
			textures.push(name);
		}
		return new bakeneko.native.graphics4.TextureUnit(index);
	}
	
	private function findTexture(name: String): Int {
		for (index in 0...textures.length) {
			if (textures[index] == name) return index;
		}
		return -1;
	}*/
	
	inline function set_colorWriteMask( value : Bool ) : Bool {
		return colorWriteMaskRed = colorWriteMaskBlue = colorWriteMaskGreen = colorWriteMaskAlpha = value;
	}
}
