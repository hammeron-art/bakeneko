package bakeneko.render;

import bakeneko.core.Log;
import bakeneko.core.System;
import bakeneko.core.Window;
import bakeneko.hxsl.Cache;
import bakeneko.hxsl.Globals;
import bakeneko.hxsl.GlslOut;
import bakeneko.hxsl.Shader;
import bakeneko.hxsl.ShaderList;
import bakeneko.render.IRenderer;
import bakeneko.render.Color;

#if !flash
import lime.graphics.GLRenderContext;
#end

#if !flash

@:access(bakeneko.render.VertexBuffer)
@:access(bakeneko.render.IndexBuffer)
@:access(bakeneko.render.RenderState)
class Renderer implements IRenderer {

	var window:bakeneko.core.Window;
	var gl:GLRenderContext;
	
	var defaultPass:Pass;
	
	var boundVertexBuffer:VertexBuffer = null;
	var boundIndexBuffer:IndexBuffer = null;
	//var boundProgram:Dynamic = null;
	
	public function new(window:bakeneko.core.Window) {
		this.window = window != null ? window : cast System.app.windows[0];
		defaultPass = new Pass();
		
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
		clear(Color.BLACK);
		end();
		
		present();
		
		Log.info('Renderer for window(${window.id}) reset');
	}
	
	public function begin(surfaces:Array<Surface> = null):Void {
		gl.enable(gl.BLEND);
		gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
		
		if (surfaces == null) {
			gl.bindFramebuffer(gl.FRAMEBUFFER, null);
			gl.viewport(0, 0, window.width, window.height);
		}
	}
	
	public function end():Void {
		
	}
	
	public function createVertexBuffer(vertexCount:Int, structure: VertexStructure, ?usage:Usage) {
		var buffer = gl.createBuffer();
		
		var vBuffer = new VertexBuffer(this, vertexCount, structure, usage);
		vBuffer.buffer = buffer;
		
		return vBuffer;
	}
	
	public function createIndexBuffer(vertexCount:Int, structure: VertexStructure, ?usage:Usage) {
		var buffer = gl.createBuffer();
		
		var iBuffer = new IndexBuffer(this, vertexCount, structure, usage);
		iBuffer.buffer = buffer;
		
		return iBuffer;
	}

	function uploadVertexBuffer(buffer:VertexBuffer) {
		gl.bindBuffer(gl.ARRAY_BUFFER, buffer.buffer);
		gl.bufferData(gl.ARRAY_BUFFER, cast buffer.data, buffer.usage == Usage.DynamicUsage ? gl.DYNAMIC_DRAW : gl.STATIC_DRAW);
	}
	
	function uploadIndexBuffer(buffer:IndexBuffer) {
		gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, buffer.buffer);
		gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, cast buffer.data, buffer.usage == Usage.DynamicUsage ? gl.DYNAMIC_DRAW : gl.STATIC_DRAW);
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
	
	public function setRenderState(pipe:RenderState) {
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

#else

import flash.events.Event;
import flash.display.StageScaleMode;
import flash.display3D.Context3DClearMask;
import flash.display3D.Context3DBufferUsage;
import flash.display3D.Context3DRenderMode;
import flash.display3D.Context3DProfile;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DStencilAction;

@:access(bakeneko.render.VertexBuffer)
@:access(bakeneko.render.IndexBuffer)
@:access(bakeneko.render.RenderState)
class Renderer implements IRenderer {

	var window:bakeneko.core.Window;
	
	var stage3D:flash.display.Stage3D;
	var stage:flash.display.Stage;
	var context:flash.display3D.Context3D;
	
	var surfaces:Array<Surface>;
	
	public function new(window:bakeneko.core.Window) {
		this.window = window != null ? window : cast System.app.windows[0];
		
		switch (@:privateAccess this.window.limeWindow.renderer.context) {
			case FLASH(stage):
			default:
				throw "Unsupported context";
		}
		
		stage = flash.Lib.current.stage;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		function handle(event:Event) {
			Log.info(event.toString());
		}
		
		stage.addEventListener(Event.RESIZE, function(_) resize());
		
		stage3D = stage.stage3Ds[0];
		stage3D.addEventListener(Event.CONTEXT3D_CREATE, onReady);
		stage3D.requestContext3D(cast Context3DRenderMode.AUTO, Context3DProfile.STANDARD);
	}
	
	public function reset():Void {
		begin();
		clear(Color.BLACK);
		end();
		
		present();
		
		Log.info('Renderer for window(${window.id}) reset');
	}
	
	function onReady(_): Void {
		context = stage3D.context3D;
		context.setRenderToBackBuffer();
		resize();
		
		reset();
	}
	
	function resize() {
		if (stage.stageWidth >= 32 && stage.stageHeight >= 32) {
			context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, true);
		}
	}
	
	public function begin(surfaces:Array<Surface> = null):Void {
		this.surfaces = surfaces;
		
		if (surfaces == null)
			context.setRenderToBackBuffer();
		else
			throw "Not implemented";
	}
	
	public function end():Void {
		
	}
	
	public function createVertexBuffer(vertexCount:Int, structure: VertexStructure, ?usage:Usage) {
		var buffer = context.createVertexBuffer(vertexCount, structure.totalNumValues, usage == Usage.DynamicUsage ? Context3DBufferUsage.DYNAMIC_DRAW : Context3DBufferUsage.STATIC_DRAW);
		
		var vBuffer = new VertexBuffer(this, vertexCount, structure, usage);
		vBuffer.buffer = buffer;
		
		return vBuffer;
	}
	
	public function createIndexBuffer(vertexCount:Int, structure: VertexStructure, ?usage:Usage) {
		var buffer = context.createIndexBuffer(vertexCount, usage == Usage.DynamicUsage ? Context3DBufferUsage.DYNAMIC_DRAW : Context3DBufferUsage.STATIC_DRAW);
		
		var iBuffer = new IndexBuffer(this, vertexCount, structure, usage);
		iBuffer.buffer = buffer;
		
		return iBuffer;
	}

	function uploadVertexBuffer(buffer:VertexBuffer) {
		var b:flash.display3D.VertexBuffer3D = cast buffer.buffer;
		b.uploadFromByteArray(buffer.data.buffer.getData(), 0, 0, buffer.count());
	}
	
	function uploadIndexBuffer(buffer:IndexBuffer) {
		var b:flash.display3D.IndexBuffer3D = cast buffer.buffer;
		b.uploadFromByteArray(buffer.data.buffer.getData(), 0, 0, buffer.count());
	}
	
	public function setRenderState(pipe:RenderState) {
		setCullMode(pipe.cullMode);
		setDepthMode(pipe.depthWrite, pipe.depthMode);
		setStencilParameters(pipe.stencilMode, pipe.stencilBothPass, pipe.stencilDepthFail, pipe.stencilFail, pipe.stencilReferenceValue, pipe.stencilReadMask, pipe.stencilWriteMask);
		setBlendingMode(pipe.blendSource, pipe.blendDestination);
		context.setColorMask(pipe.colorWriteMaskRed, pipe.colorWriteMaskGreen, pipe.colorWriteMaskBlue, pipe.colorWriteMaskAlpha);
	}
	
	public function setCullMode(mode: CullMode): Void {
		switch (mode) {
		case Clockwise:
			context.setCulling(Context3DTriangleFace.FRONT);
		case CounterClockwise:
			context.setCulling(Context3DTriangleFace.BACK);
		case None:
			context.setCulling(Context3DTriangleFace.NONE);
		}
	}
	
	public function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void {
		context.setBlendFactors(getBlendFactor(source), getBlendFactor(destination));
	}
	
	function getBlendFactor(op: BlendingOperation): Context3DBlendFactor {
		switch (op) {
			case BlendZero, Undefined:
				return Context3DBlendFactor.ZERO;
			case BlendOne:
				return Context3DBlendFactor.ONE;
			case SourceAlpha:
				return Context3DBlendFactor.SOURCE_ALPHA;
			case DestinationAlpha:
				return Context3DBlendFactor.DESTINATION_ALPHA;
			case InverseSourceAlpha:
				return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			case InverseDestinationAlpha:
				return Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA;
		}
	}
	
	public function setDepthMode(write: Bool, mode: CompareMode): Void {
		context.setDepthTest(write, getCompareMode(mode));
	}
	
	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {
		context.setStencilReferenceValue(referenceValue, readMask, writeMask);
		context.setStencilActions(Context3DTriangleFace.FRONT_AND_BACK, getCompareMode(compareMode), getStencilAction(bothPass), getStencilAction(depthFail), getStencilAction(stencilFail));
	}
	
	function getCompareMode(mode: CompareMode): Context3DCompareMode {
		switch (mode) {
		case Always:
			return Context3DCompareMode.ALWAYS;
		case Equal:
			return Context3DCompareMode.EQUAL;
		case Greater:
			return Context3DCompareMode.GREATER;
		case GreaterEqual:
			return Context3DCompareMode.GREATER_EQUAL;
		case Less:
			return Context3DCompareMode.LESS;
		case LessEqual:
			return Context3DCompareMode.LESS_EQUAL;
		case Never:
			return Context3DCompareMode.NEVER;
		case NotEqual:
			return Context3DCompareMode.NOT_EQUAL;
		}
	}
	
	private function getStencilAction(action: StencilAction): Context3DStencilAction {
		switch (action) {
		case Keep:
			return Context3DStencilAction.KEEP;
		case Replace:
			return Context3DStencilAction.SET;
		case Zero:
			return Context3DStencilAction.ZERO;
		case Invert:
			return Context3DStencilAction.INVERT;
		case Increment:
			return Context3DStencilAction.INCREMENT_SATURATE;
		case IncrementWrap:
			return Context3DStencilAction.INCREMENT_WRAP;
		case Decrement:
			return Context3DStencilAction.DECREMENT_SATURATE;
		case DecrementWrap:
			return Context3DStencilAction.DECREMENT_WRAP;
		}
	}
	
	inline public function viewport(x:Int, y:Int, width:Int, height:Int): Void{
		stage3D.x = x;
		stage3D.y = y;
		context.configureBackBuffer(width, height, 0);
	}
	
	public function clear(?color:Color, ?depth:Float, ?stencil:Int):Void {
		var clearMask: UInt = 0;
		
		if (color != null) clearMask |= Context3DClearMask.COLOR;
		if (depth != null) clearMask |= Context3DClearMask.DEPTH;
		if (stencil != null) clearMask |= Context3DClearMask.STENCIL;
		
		var r = color == null ? 0.0 : color.r;
		var g = color == null ? 0.0 : color.g;
		var b = color == null ? 0.0 : color.b;
		var a = color == null ? 1.0 : color.a;
		
		context.clear(r, g, b, a, depth == null ? 1.0 : depth, stencil == null ? 0 : stencil, clearMask);
	}
	
	public function present():Void {
		context.present();
	}
	
}

#end