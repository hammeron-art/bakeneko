package bakeneko.graphics4;

import lime.graphics.opengl.GL;
import bakeneko.graphics4.FragmentShader;
import bakeneko.graphics4.VertexData;
import bakeneko.graphics4.VertexShader;
import bakeneko.graphics4.VertexStructure;

class Pass {

	public var inputLayouts: Array<VertexStructure>;
	/*public var vertexShader: VertexShader;
	public var fragmentShader: FragmentShader;
	public var geometryShader: GeometryShader;
	public var tesselationControlShader: TesselationControlShader;
	public var tesselationEvaluationShader: TesselationEvaluationShader;*/

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
	
	var shaders:Array<Shader>;
	var textures: Array<String>;
	var textureValues: Array<Dynamic>;
	
	var render:Renderer;
	
	function new(render:Renderer) {
		this.render = render;
		
		inputLayouts = [];
		/*vertexShader = null;
		fragmentShader = null;
		geometryShader = null;
		tesselationControlShader = null;
		tesselationEvaluationShader = null;*/

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

		shaders = [];
		textures = new Array<String>();
		textureValues = new Array<Dynamic>();
	}
	
	public function addShader(shader:Shader) {
		shaders.push(shader);
	}
	
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
