package bakeneko.render;

import lime.graphics.opengl.GL;
import lime.utils.Float32Array;
import bakeneko.render.Usage;
import bakeneko.render.VertexStructure;
import bakeneko.render.VertexData;

class VertexBuffer {
	var buffer: Dynamic;
	var data: Float32Array;
	var size: Int;
	var myStride: Int;
	var sizes: Array<Int>;
	var offsets: Array<Int>;
	var usage: Usage;
	var instanceDataStepRate: Int;
	
	var structure:VertexStructure;
	
	var render:Renderer;
	
	function new(render:Renderer, count:Int, structure:VertexStructure, usage:Usage) {
		this.usage = usage != null ? usage : Usage.StaticUsage;
		this.render = render;
		this.structure = structure;
		size = count;
	}
	
	inline public function lock():Float32Array {
		if (data == null)
			data = new Float32Array(size * structure.totalNumValues);
		
		return data;
	}
	
	inline public function unlock():Void {
		@:privateAccess
		render.uploadVertexBuffer(this);
	}
	
	public function stride():Int {
		return myStride;
	}
	
	public function count(): Int {
		return size;
	}
}
