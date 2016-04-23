package bakeneko.backend;

import bakeneko.asset.Texture;
import bakeneko.render.pass.Types;
import bakeneko.backend.opengl.GL;
import bakeneko.core.Log;
import bakeneko.render.Color;
import lime.Lib;
import lime.app.Application;
import lime.graphics.GLRenderContext;

typedef Framebuffer = lime.graphics.opengl.GLFramebuffer;
typedef Renderbuffer = lime.graphics.opengl.GLRenderbuffer;

//TODO: unfinished
@:access(bakeneko.backend.Surface)
class RenderDriver {

	var gl:GLRenderContext;
	
	var PRIMITIVE = [
		GL.POINTS,
		GL.LINES,
		GL.LINE_LOOP,
		GL.LINE_STRIP,
		GL.TRIANGLES,
		GL.TRIANGLE_STRIP,
		GL.TRIANGLE_FAN,
	];
	
	public function new() {
		switch (Application.current.renderer.context) {
			case OPENGL(context):
				gl = context;
			default:
				Log.error('Unkown render contex');
		}
	}
	
	public function init() {
	}
	
	public function enableDepthTest(enable:Bool) {
		if (enable)
			gl.enable(GL.DEPTH_TEST);
		else
			gl.disable(GL.DEPTH_TEST);
	}
	
	public function enableBlend(enable:Bool) {
		if (enable)
			gl.enable(gl.BLEND);
		else
			gl.disable(gl.BLEND);
	}
	
	public function setBlend(sfactor:Int, dfactor:Int) {
		gl.blendFunc(sfactor, dfactor);
	}
	
	public function clearColor(?color:Color, ?depth:Float, ?stencil:Int) {
		if (color != null)
			gl.clearColor(color.r, color.g, color.b, color.a);
		if (depth != null)
			gl.clearDepth(depth);
		if (stencil != null)
			gl.clearStencil(stencil);
	}
	
	inline public function clear(mask:Int) {
		gl.clear(mask);
	}
	
	inline public function setDepthFunction(funct:Int) {
		gl.depthFunc(funct);
	}
	
	inline public function getDepthFunction() {
		return gl.getParameter(GL.DEPTH_FUNC);
	}
	
	inline public function getLineWidth() {
		return gl.getParameter(GL.LINE_WIDTH);
	}
	
	inline public function setLineWidth(width:Int) {
		return gl.lineWidth(width);
	}
	
	inline public function setTexture(slot:Int, texture:Texture) {
		gl.activeTexture(GL.TEXTURE0 + slot);
		gl.bindTexture(GL.TEXTURE_2D, texture == null ? null : texture.textureID);
	}
	
	inline public function drawVertices(primitive:Primitive, start, count) {
		gl.drawArrays(PRIMITIVE[primitive], start, count);
	}
	
	inline public function drawIndexes(primitive:Primitive, start, type, offset) {
		gl.drawElements(PRIMITIVE[primitive], start, type, offset);
	}
	
	inline public function getAttribLocation(program, name) {
		return gl.getAttribLocation(program, name);
	}
	
	inline public function enableVertexAttribArray(index) {
		gl.enableVertexAttribArray(index);
	}
	
	inline public function vertexAttribPointer(index, size, type, normalized, stride, offset) {
		gl.vertexAttribPointer(index, size, type, normalized, stride, offset);
	}
	
	// INTERNAL
	
	inline function createFramebuffer() {
		return gl.createFramebuffer();
	}
	
	inline function createRenderbuffer() {
		return gl.createRenderbuffer();
	}
	
	inline function framebufferTexture2D(target, attachment, textarget, texture, level) {
		gl.framebufferTexture2D(target, attachment, textarget, texture, level);
	}
	
	inline function bindRenderbuffer(target, renderbuffer) {
		gl.bindRenderbuffer(target, renderbuffer);
	}
	
	inline function renderbufferStorage(target, internal, width, height) {
		gl.renderbufferStorage(target, internal, width, height);
	}
	
	inline function framebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer) {
		gl.framebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
	}
}