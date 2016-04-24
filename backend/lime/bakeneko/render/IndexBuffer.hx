package bakeneko.render;

import lime.graphics.opengl.GL;
import lime.utils.UInt16Array;
import bakeneko.graphics4.Usage;

class IndexBuffer {
	private var buffer: Dynamic;
	private var data: Array<Int>;
	private var mySize: Int;
	private var usage: Usage;
	
	public function new(indexCount: Int, usage: Usage, canRead: Bool = false) {
		this.usage = usage;
		mySize = indexCount;
		buffer = SystemImpl.gl.createBuffer();
		data = new Array<Int>();
		data[indexCount - 1] = 0;
	}
	
	public function lock(): Array<Int> {
		return data;
	}
	
	public function unlock(): Void {
		SystemImpl.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
		SystemImpl.gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, cast new UInt16Array(data), usage == Usage.DynamicUsage ? GL.DYNAMIC_DRAW : GL.STATIC_DRAW);
	}
	
	public function set(): Void {
		SystemImpl.gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
	}
	
	public function count(): Int {
		return mySize;
	}
}
