package bakeneko.render;

import bakeneko.core.Log;
import bakeneko.core.System;
import bakeneko.core.Window;
import bakeneko.hxsl.AgalOptim;
import bakeneko.hxsl.AgalOut;
import bakeneko.hxsl.Cache;
import bakeneko.hxsl.Globals;
import bakeneko.hxsl.GlslOut;
import bakeneko.hxsl.RuntimeShader;
import bakeneko.hxsl.Shader;
import bakeneko.hxsl.ShaderList;
import bakeneko.render.IRenderer;
import bakeneko.render.Color;
import bakeneko.utils.UInt8Array;
import states.hxsl.ProgramBuffer;

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
class FlashRenderer implements IRenderer {

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
		context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
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
	
	public function createEffect(compiledShader:RuntimeShader):Effect {
		var vertexSource = AgalOut.toAgal(compiledShader.vertex, 2);
		var fragmentSource = AgalOut.toAgal(compiledShader.fragment, 2);
		var opt = new AgalOptim();
		vertexSource = opt.optimize(vertexSource);
		fragmentSource = opt.optimize(fragmentSource);
		
		Log.info('${format.agal.Tools.toString(vertexSource)}\n\n${format.agal.Tools.toString(fragmentSource)}', 0);
		
		var vBytes = new haxe.io.BytesOutput();
		new format.agal.Writer(vBytes).write(vertexSource);
		var fBytes = new haxe.io.BytesOutput();
		new format.agal.Writer(fBytes).write(fragmentSource);
		
		var vb = vBytes.getBytes().getData();
		var fb = fBytes.getBytes().getData();
		
		var program = context.createProgram();
		program.upload(vb, fb);
		context.setProgram(program);
		
		return new Effect(compiledShader, program);
	}
	
	public function applyVertexAttributes(vertex:VertexBuffer):Void {
		
		Log.assert(vertex.structure != null, 'Can\'t apply vertex attributes without structure');
		
		var flashSize = [
			flash.display3D.Context3DVertexBufferFormat.FLOAT_1,
			flash.display3D.Context3DVertexBufferFormat.FLOAT_2,
			flash.display3D.Context3DVertexBufferFormat.FLOAT_3,
			flash.display3D.Context3DVertexBufferFormat.FLOAT_4,
		];
		
		var i = 0;
		var offset = 0;
		for (element in vertex.structure.elements) {
			var size = element.numData();

			context.setVertexBufferAt(i, vertex.buffer, offset, flashSize[size-1]);
			
			offset += size;
			++i;
		}
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
	
	public function applyRenderState(pipe:RenderState) {
		setCullMode(pipe.cullMode);
		setDepthMode(pipe.depthWrite, pipe.depthMode);
		setStencilParameters(pipe.stencilMode, pipe.stencilBothPass, pipe.stencilDepthFail, pipe.stencilFail, pipe.stencilReferenceValue, pipe.stencilReadMask, pipe.stencilWriteMask);
		setBlendingMode(pipe.blendSource, pipe.blendDestination);
		context.setColorMask(pipe.colorWriteMaskRed, pipe.colorWriteMaskGreen, pipe.colorWriteMaskBlue, pipe.colorWriteMaskAlpha);
	}
	
	public function drawBuffer(vertex:VertexBuffer, index:IndexBuffer):Void {
		applyVertexAttributes(vertex);
		context.drawTriangles(index.buffer, 0, index.count());
	}
	
	@:access(bakeneko.render.Effect)
	public function applyEffect(effect:Effect, buffer:ProgramBuffer):Void {
		Log.assert(effect != null, 'Effect can\'t be null');
		Log.assert(buffer != null, 'Buffer can\'t be null');
		
		context.setProgram(effect.program);
		
		var compiledShader = effect.runtimeShader;
		//trace(compiledShader.vertex.paramsSize, compiledShader.fragment.paramsSize, compiledShader.vertex.globalsSize, compiledShader.fragment.globalsSize);
		if (compiledShader.vertex.paramsSize > 0)
			context.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.VERTEX, compiledShader.vertex.globalsSize, compiledShader.vertex.paramsSize, buffer.vertex.params.buffer.getData(), 0);
		if (compiledShader.fragment.paramsSize > 0)
			context.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.FRAGMENT, compiledShader.fragment.globalsSize, compiledShader.fragment.paramsSize, buffer.fragment.params.buffer.getData(), 0);

		buffer.vertex.globals[0] = 1.0;
		if (compiledShader.vertex.globalsSize > 0)
			context.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.VERTEX, 0, compiledShader.vertex.globalsSize, buffer.vertex.globals.buffer.getData(), 0);
		if (compiledShader.fragment.globalsSize > 0)
			context.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.FRAGMENT, 0, compiledShader.fragment.globalsSize, buffer.fragment.globals.buffer.getData(), 0);

		for (i in 0...compiledShader.fragment.textures2DCount) {
			@:privateAccess
			context.setTextureAt(i, buffer.fragment.textures[i].nativeTexture.texture);
			context.setSamplerStateAt(i, flash.display3D.Context3DWrapMode.REPEAT, flash.display3D.Context3DTextureFilter.NEAREST, flash.display3D.Context3DMipFilter.MIPNONE);
		}

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
	
	public function createTexture(width:Int, height:Int, ?format:TextureFormat):NativeTexture {
		var native = context.createTexture(width, height, flash.display3D.Context3DTextureFormat.BGRA, false);
		trace(native);
		return new NativeTexture(native, width, height, format);
	}
	
	public function deleteTexture(texture:NativeTexture):Void {
		texture.texture.dispose();
		texture.texture = null;
	}
	
	public function updaloadTexturePixel(texture:NativeTexture, pixel:UInt8Array):Void {
		trace(pixel.buffer.getData().length, texture.width * texture.height * 4);
		texture.texture.uploadFromByteArray(pixel.toBytes().getData(), 0);
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