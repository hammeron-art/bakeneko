package bakeneko.graphics4;

import bakeneko.core.Log;
import bakeneko.core.System;
import bakeneko.core.Window;
import bakeneko.graphics4.IRenderer;
import bakeneko.render.Color;

#if !flash

import lime.graphics.GLRenderContext;

class Renderer implements IRenderer {

	var window:bakeneko.core.Window;
	var gl:GLRenderContext;
	
	public function new(window:bakeneko.core.Window) {
		this.window = window != null ? window : cast System.app.windows[0];
		
		gl = switch (@:privateAccess this.window.limeWindow.renderer.context) {
			case OPENGL(gl):
				gl;
			default:
				throw "Unsupported context";
		}
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
	
}

#else

import flash.events.Event;
import flash.display.StageScaleMode;
import flash.display3D.Context3DClearMask;

class Renderer implements IRenderer {

	var window:bakeneko.core.Window;
	
	var stage3D:flash.display.Stage3D;
	var stage:flash.display.Stage;
	var context:flash.display3D.Context3D;
	
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
		stage3D.requestContext3D(cast flash.display3D.Context3DRenderMode.AUTO, cast 'standard');
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
		if (surfaces == null)
			context.setRenderToBackBuffer();
		else
			throw "Not implemented";
	}
	
	public function end():Void {
		context.present();
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
	
}

#end