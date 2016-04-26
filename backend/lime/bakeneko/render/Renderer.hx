package bakeneko.render;

import bakeneko.core.Log;
import bakeneko.core.System;
import bakeneko.core.Window;
import bakeneko.hxsl.GlslOut;
import bakeneko.hxsl.Shader;
import bakeneko.hxsl.ShaderList;
import bakeneko.render.IRenderer;
import bakeneko.render.Color;

#if !flash

import lime.graphics.GLRenderContext;

@:access(bakeneko.render.VertexBuffer)
@:access(bakeneko.render.IndexBuffer)
@:access(bakeneko.render.Pipeline)
class Renderer implements IRenderer {

	var window:bakeneko.core.Window;
	var gl:GLRenderContext;
	var out:GlslOut;
	
	public function new(window:bakeneko.core.Window) {
		this.window = window != null ? window : cast System.app.windows[0];
		
		gl = switch (@:privateAccess this.window.limeWindow.renderer.context) {
			case OPENGL(gl):
				gl;
			default:
				throw "Unsupported context";
		}
		
		out = new GlslOut();
		
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
	
	inline public function createPipeline(?shaderList:ShaderList):Pipeline {
		return new Pipeline(this, shaderList);
	}
	
	public function compileShader(shader:Shader) {
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

@:access(bakeneko.render.VertexBuffer)
@:access(bakeneko.render.IndexBuffer)
@:access(bakeneko.render.Pipeline)
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
	
	inline public function createPipeline(?shaderList:ShaderList):Pipeline {
		return new Pipeline(this);
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