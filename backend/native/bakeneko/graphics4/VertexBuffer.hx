package bakeneko.graphics4;

import lime.graphics.opengl.GL;
import lime.utils.Float32Array;
import bakeneko.graphics4.Usage;
import bakeneko.graphics4.VertexStructure;
import bakeneko.graphics4.VertexData;

@:access(bakeneko.graphics4.Renderer)
class VertexBuffer {
	private var buffer: Dynamic;
	private var data: Float32Array;
	private var mySize: Int;
	private var myStride: Int;
	private var sizes: Array<Int>;
	private var offsets: Array<Int>;
	private var usage: Usage;
	private var instanceDataStepRate: Int;
	
	var render:Renderer;
	
	function new(render:Renderer, structure:VertexStructure, usage:Usage) {
		this.usage = usage != null ? usage : Usage.StaticUsage;
		this.render = render;
		
		/*this.usage = usage;
		this.instanceDataStepRate = instanceDataStepRate;
		mySize = vertexCount;
		myStride = 0;
		for (element in structure.elements) {
			switch (element.data) {
			case Float1:
				myStride += 4 * 1;
			case Float2:
				myStride += 4 * 2;
			case Float3:
				myStride += 4 * 3;
			case Float4:
				myStride += 4 * 4;
			case Float4x4:
				myStride += 4 * 4 * 4;
			}
		}
	
		buffer = SystemImpl.gl.createBuffer();
		data = new Float32Array(Std.int(vertexCount * myStride / 4));
		
		sizes = new Array<Int>();
		offsets = new Array<Int>();
		sizes[structure.elements.length - 1] = 0;
		offsets[structure.elements.length - 1] = 0;
		
		var offset = 0;
		var index = 0;
		for (element in structure.elements) {
			var size;
			switch (element.data) {
			case Float1:
				size = 1;
			case Float2:
				size = 2;
			case Float3:
				size = 3;
			case Float4:
				size = 4;
			case Float4x4:
				size = 4 * 4;
			}
			sizes[index] = size;
			offsets[index] = offset;
			switch (element.data) {
			case Float1:
				offset += 4 * 1;
			case Float2:
				offset += 4 * 2;
			case Float3:
				offset += 4 * 3;
			case Float4:
				offset += 4 * 4;
			case Float4x4:
				offset += 4 * 4 * 4;
			}
			++index;
		}*/
	}
	
	inline public function lock(): Float32Array {
		return data;
	}
	
	inline public function unlock(): Void {
		render.uploadVertexBuffer(this);
	}
	
	public function stride(): Int {
		return myStride;
	}
	
	public function count(): Int {
		return mySize;
	}
}
