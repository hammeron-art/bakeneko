package bakeneko.render;

import lime.graphics.opengl.GL;
import lime.utils.UInt16Array;
import bakeneko.render.Usage;

class IndexBuffer {
	var buffer: Dynamic;
	var data: UInt16Array;
	var size: Int;
	var usage: Usage;
	
	var render:Renderer;
	
	public function new(render:Renderer, count:Int, structure:VertexStructure, usage:Usage) {
		this.usage = usage != null ? usage : Usage.StaticUsage;
		this.render = render;
		size = count;
	}
	
	public function lock():UInt16Array {
		if (data == null)
			data = new UInt16Array(size);
			
		return data;
	}
	
	public function unlock(): Void {
		@:privateAccess
		render.uploadIndexBuffer(this);
	}
	
	public function count(): Int {
		return size;
	}
}
