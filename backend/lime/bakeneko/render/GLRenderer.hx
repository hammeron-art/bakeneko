package bakeneko.render;

import bakeneko.core.Log;
import bakeneko.core.System;
import bakeneko.core.Window;
import bakeneko.hxsl.Cache;
import bakeneko.hxsl.Globals;
import bakeneko.hxsl.GlslOut;
import bakeneko.hxsl.RuntimeShader;
import bakeneko.hxsl.Shader;
import bakeneko.hxsl.ShaderList;
import bakeneko.render.IRenderer;
import bakeneko.render.Color;
import bakeneko.utils.UInt8Array;

import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GLUniformLocation;

@:access(bakeneko.render.VertexBuffer)
@:access(bakeneko.render.IndexBuffer)
@:access(bakeneko.render.RenderState)
class GLRenderer implements IRenderer {

	var window:bakeneko.core.Window;
	var gl:GLRenderContext;
	
	var boundVertexBuffer:VertexBuffer = null;
	var boundIndexBuffer:IndexBuffer = null;
	//var boundProgram:Dynamic = null;
	
	public function new(window:bakeneko.core.Window) {
		this.window = window != null ? window : cast System.app.windows[0];
		
		gl = switch (@:privateAccess this.window.limeWindow.renderer.context) {
			case OPENGL(gl):
				gl;
			default:
				throw "Unsupported context";
		}
		
		reset();
	}
	
	public function reset():Void {
		begin();
		
		gl.enable(gl.BLEND);
		gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
		
		clear(Color.BLACK);
		end();
		
		present();
		
		Log.info('Renderer for window(${window.id}) reset');
	}
	
	public function begin(surfaces:Array<Surface> = null):Void {		
		if (surfaces == null) {
			gl.bindFramebuffer(gl.FRAMEBUFFER, null);
			gl.viewport(0, 0, window.width, window.height);
		}
	}
	
	public function end():Void {
		
	}
	
	public function createEffect(compiledShader:RuntimeShader):Effect {
		
		var out = new GlslOut();
		var vertexSource = out.run(compiledShader.vertex.data);
		var fragmentSource = out.run(compiledShader.fragment.data);
		
		//Log.info('$vertexSource\n\n$fragmentSource', 0);
		
		var vertexShader = gl.createShader(gl.VERTEX_SHADER);
		var fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
		gl.shaderSource(vertexShader, vertexSource);
		gl.shaderSource(fragmentShader, fragmentSource);
		gl.compileShader(vertexShader);
		gl.compileShader(fragmentShader);
		
		var program = gl.createProgram();
		gl.attachShader(program, vertexShader);
		gl.attachShader(program, fragmentShader);

		gl.linkProgram(program);

		if (gl.getProgramParameter(program, gl.LINK_STATUS) == 0) {
			Log.error(gl.getProgramInfoLog(program));
			gl.deleteProgram(program);
		}
		
		gl.useProgram(program);
		
		var vertexLocation = gl.getUniformLocation(program, 'vertexParams');
		var fragmentLocation = gl.getUniformLocation(program, 'fragmentParams');
		var vertGlobalLocation = gl.getUniformLocation(program, 'vertexGlobals');
		var fragGlobalLocation = gl.getUniformLocation(program, 'fragmentGlobals');
		var vertTexLocations = [
			for (i in 0...compiledShader.vertex.textures2DCount) {
				gl.getUniformLocation(program, 'vertexTextures[$i]');
			}
		];
		var fragTexLocations = [
			for (i in 0...compiledShader.fragment.textures2DCount) {
				var v = gl.getUniformLocation(program, 'fragmentTextures[$i]');
				trace(v);
				v;
			}
		];
		
		return new Effect(compiledShader, vertexShader, fragmentShader, program, vertexLocation, fragmentLocation, vertGlobalLocation, fragGlobalLocation, vertTexLocations, fragTexLocations);
	}
	
	@:access(bakeneko.render.Effect)
	public function applyEffect(effect:Effect, buffer:ProgramBuffer):Void {
		if (effect.runtimeShader.vertex.paramsSize > 0)
			gl.uniform4fv(effect.vertexLocation, buffer.vertex.params);
		if (effect.runtimeShader.fragment.paramsSize > 0)
			gl.uniform4fv(effect.fragmentLocation, buffer.fragment.params);
		if (effect.runtimeShader.vertex.globalsSize > 0)
			gl.uniform4fv(effect.vertGlobalLocation, buffer.vertex.globals);
		if (effect.runtimeShader.fragment.globalsSize > 0)
			gl.uniform4fv(effect.fragGlobalLocation, buffer.fragment.globals);
		//if (compiledShader.fragment.textures2DCount > 0)
			//GL.uniform1iv(GL.getUniformLocation(program, 'fragmentTextures'), new Int32Array([0, 1]));
			
		/*for (i in 0...compiledShader.vertex.textures2DCount) {
			GL.activeTexture(GL.TEXTURE0 + i);
			GL.uniform1i(vertTexLocations[i], i);
			@:privateAccess
			GL.bindTexture(GL.TEXTURE_2D, buffer.vertex.textures[i].nativeTexture.texture);
		}*/
		for (i in 0...effect.runtimeShader.fragment.textures2DCount) {
			@:privateAccess
			gl.bindTexture(gl.TEXTURE_2D, buffer.fragment.textures[i].nativeTexture.texture);
			gl.activeTexture(gl.TEXTURE0 + i);
			gl.uniform1i(effect.fragTexLocations[i], i);
		}
	}
	
	public function createVertexBuffer(vertexCount:Int, structure: VertexStructure, ?usage:Usage) {
		var buffer = gl.createBuffer();
		
		var vBuffer = new VertexBuffer(this, vertexCount, structure, usage);
		vBuffer.buffer = buffer;
		
		return vBuffer;
	}
	
	public function applyVertexAttributes(vertex:VertexBuffer) {
		//GL.bindBuffer(GL.ARRAY_BUFFER, vertex);
		//GL.bufferData(GL.ARRAY_BUFFER, vertexData, GL.STATIC_DRAW);
		
		bindVertexBuffer(vertex);
		
		var i = 0;
		var offset = 0;
		for (element in vertex.structure.elements) {
			var size = element.numData();
			
			gl.vertexAttribPointer(i, size, gl.FLOAT, false, vertex.structure.totalSize, offset * 4);
			gl.enableVertexAttribArray(i);
			
			offset += size;
			++i;
		}
	}
	
	public function drawBuffer(vertex:VertexBuffer, index:IndexBuffer):Void {
		bindVertexBuffer(vertex);
		applyVertexAttributes(vertex);
		bindIndexBuffer(index);
		gl.drawElements(gl.TRIANGLES, index.count(), gl.UNSIGNED_SHORT, 0);
	}
	
	public function createIndexBuffer(vertexCount:Int, structure: VertexStructure, ?usage:Usage) {
		var buffer = gl.createBuffer();
		
		var iBuffer = new IndexBuffer(this, vertexCount, structure, usage);
		iBuffer.buffer = buffer;
		
		return iBuffer;
	}

	function bindVertexBuffer(buffer:VertexBuffer) {
		if (boundVertexBuffer == buffer)
			return;
		
		gl.bindBuffer(gl.ARRAY_BUFFER, buffer.buffer);
		boundVertexBuffer = buffer;
	}
	
	function bindIndexBuffer(buffer:IndexBuffer) {
		if (boundIndexBuffer == buffer)
			return;
		
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffer.buffer);
		boundIndexBuffer = buffer;
	}
	
	function uploadVertexBuffer(buffer:VertexBuffer) {
		bindVertexBuffer(buffer);
		gl.bufferData(gl.ARRAY_BUFFER, buffer.data, buffer.usage == Usage.DynamicUsage ? gl.DYNAMIC_DRAW : gl.STATIC_DRAW);
	}
	
	function uploadIndexBuffer(buffer:IndexBuffer) {
		bindIndexBuffer(buffer);
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, buffer.data, buffer.usage == Usage.DynamicUsage ? gl.DYNAMIC_DRAW : gl.STATIC_DRAW);
	}
	
	public function setVertexBuffer(buffer:VertexBuffer) {
		
		if (boundVertexBuffer == buffer)
			return;
		
		var stride = 0;

		@:privateAccess
		for (element in buffer.structure.elements) {
			stride += element.size();
		}

		var offset = 0;
		
		var i = 0;
		for (element in buffer.structure.elements) {
			//var verticeAttribute = driver.getAttribLocation(shader.program, element.attributeName());
			//Log.assert(verticeAttribute >= 0, 'Vertex attribute (${element.attributeName()}) not found for shader (${this.shader}). Check the vertexFormat or not used variables in the shader.');
			
			gl.enableVertexAttribArray(i);
			gl.vertexAttribPointer(i, element.numData(), getElementType(element), false, stride, offset);

			offset += element.size();
			
			++i;
		}
		
		boundVertexBuffer = buffer;
	}
	
	public function setIndexBuffer(buffer:IndexBuffer) {
		if (boundIndexBuffer == buffer)
			return;
			
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffer.buffer);
		
		boundIndexBuffer = buffer;
	}
	
	inline public function createTexture(width:Int, height:Int, ?format:TextureFormat):NativeTexture {
		return new NativeTexture(gl.createTexture(), width, height, format);
	}
	
	inline public function deleteTexture(texture:NativeTexture):Void {
		gl.deleteTexture(texture.texture);
	}
	
	public function updaloadTexturePixel(texture:NativeTexture, pixel:UInt8Array):Void {
		Log.assert(pixel != null, 'Pixel data can\'t be null');
		
		gl.bindTexture(gl.TEXTURE_2D, texture.texture);
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, texture.width, texture.height, 0, gl.RGBA, gl.UNSIGNED_BYTE, pixel);
		
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);

		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
	}
	
	/*public function setTextureProp() {
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, props.wrapS);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, props.wrapT);

		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, props.minFilter);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, props.magFilter);
	}*/
	
	function getElementType(element:VertexElement) {
		return switch (element.type) {
			case TByte(_):
				gl.BYTE;
			case TInt(_):
				gl.INT;
			case TFloat(_):
				gl.FLOAT;
		}
	}
	
	public function compileShader(shader:Shader) {
	}
	
	public function applyRenderState(pipe:RenderState) {
		setCullMode(pipe.cullMode);
		setDepthMode(pipe.depthWrite, pipe.depthMode);
		setStencilParameters(pipe.stencilMode, pipe.stencilBothPass, pipe.stencilDepthFail, pipe.stencilFail, pipe.stencilReferenceValue, pipe.stencilReadMask, pipe.stencilWriteMask);
		setBlendingMode(pipe.blendSource, pipe.blendDestination);
	}
	
	public function setCullMode(mode:CullMode) {
		switch (mode) {
			case None:
				gl.disable(gl.CULL_FACE);
			case Clockwise:
				gl.enable(gl.CULL_FACE);
				gl.cullFace(gl.FRONT);
			case CounterClockwise:
				gl.enable(gl.CULL_FACE);
				gl.cullFace(gl.BACK);
		}
	}
	
	public function setDepthMode(write:Bool, mode:CompareMode) {
		switch (mode) {
			case Always:
				gl.disable(gl.DEPTH_TEST);
				gl.depthFunc(gl.ALWAYS);
			case Never:
				gl.enable(gl.DEPTH_TEST);
				gl.depthFunc(gl.NEVER);
			case Equal:
				gl.enable(gl.DEPTH_TEST);
				gl.depthFunc(gl.EQUAL);
			case NotEqual:
				gl.enable(gl.DEPTH_TEST);
				gl.depthFunc(gl.NOTEQUAL);
			case Less:
				gl.enable(gl.DEPTH_TEST);
				gl.depthFunc(gl.LESS);
			case LessEqual:
				gl.enable(gl.DEPTH_TEST);
				gl.depthFunc(gl.LEQUAL);
			case Greater:
				gl.enable(gl.DEPTH_TEST);
				gl.depthFunc(gl.GREATER);
			case GreaterEqual:
				gl.enable(gl.DEPTH_TEST);
				gl.depthFunc(gl.GEQUAL);
		}
		gl.depthMask(write);
	}
	
	public function setStencilParameters(compareMode:CompareMode, bothPass:StencilAction, depthFail:StencilAction, stencilFail:StencilAction, referenceValue:Int, readMask:Int = 0xff, writeMask:Int = 0xff) {
		if (compareMode == CompareMode.Always && bothPass == StencilAction.Keep && depthFail == StencilAction.Keep && stencilFail == StencilAction.Keep) {
				gl.disable(gl.STENCIL_TEST);
		} else {
			gl.enable(gl.STENCIL_TEST);
			var stencilFunc = 0;
			switch (compareMode) {
				case CompareMode.Always:
					stencilFunc = gl.ALWAYS;
				case CompareMode.Equal:
					stencilFunc = gl.EQUAL;
				case CompareMode.Greater:
					stencilFunc = gl.GREATER;
				case CompareMode.GreaterEqual:
					stencilFunc = gl.GEQUAL;
				case CompareMode.Less:
					stencilFunc = gl.LESS;
				case CompareMode.LessEqual:
					stencilFunc = gl.LEQUAL;
				case CompareMode.Never:
					stencilFunc = gl.NEVER;
				case CompareMode.NotEqual:
					stencilFunc = gl.NOTEQUAL;
			}
			gl.stencilMask(writeMask);
			gl.stencilOp(convertStencilAction(stencilFail), convertStencilAction(depthFail), convertStencilAction(bothPass));
			gl.stencilFunc(stencilFunc, referenceValue, readMask);
		}
	}
	
	function convertStencilAction(action:StencilAction) {
		return switch (action) {
				case StencilAction.Decrement:
					gl.DECR;
				case StencilAction.DecrementWrap:
					gl.DECR_WRAP;
				case StencilAction.Increment:
					gl.INCR;
				case StencilAction.IncrementWrap:
					gl.INCR_WRAP;
				case StencilAction.Invert:
					gl.INVERT;
				case StencilAction.Keep:
					gl.KEEP;
				case StencilAction.Replace:
					gl.REPLACE;
				case StencilAction.Zero:
					gl.ZERO;
		}
	}
	
	public function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void {
		if (source == BlendOne && destination == BlendZero) {
			gl.disable(gl.BLEND);
		}
		else {
			gl.enable(gl.BLEND);
			gl.blendFunc(getBlendFunc(source), getBlendFunc(destination));
		}
	}
	
	function getBlendFunc(op: BlendingOperation): Int {
		return switch (op) {
			case BlendZero, Undefined:
				gl.ZERO;
			case BlendOne:
				gl.ONE;
			case SourceAlpha:
				gl.SRC_ALPHA;
			case DestinationAlpha:
				gl.DST_ALPHA;
			case InverseSourceAlpha:
				gl.ONE_MINUS_SRC_ALPHA;
			case InverseDestinationAlpha:
				gl.ONE_MINUS_DST_ALPHA;
		}
	}
	
	inline public function viewport(x:Int, y:Int, width:Int, height:Int): Void{
		gl.viewport(x, y, width, height);
	}
	
	public function clear(?color:Color, ?depth:Float, ?stencil:Int):Void {
		var clearMask: Int = 0;
		if (color != null) {
			clearMask |= gl.COLOR_BUFFER_BIT;
			gl.clearColor(color.r, color.g, color.b, color.a);
		}
		if (depth != null) {
			clearMask |= gl.DEPTH_BUFFER_BIT;
			gl.clearDepth(depth);
		}
		if (stencil != null) {
			clearMask |= gl.STENCIL_BUFFER_BIT;
			gl.enable(gl.STENCIL_TEST);
			gl.stencilMask(0xff);
			gl.clearStencil(stencil);
		}
		gl.clear(clearMask);
	}
	
	public function present():Void {
	}
	
}