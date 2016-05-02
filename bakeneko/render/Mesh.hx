package bakeneko.render;

import bakeneko.core.Application;
import bakeneko.utils.Float32Array;
import bakeneko.utils.UInt16Array;

class Mesh {

	var data:MeshData;
	var render:Renderer;
	var meshBuffer:MeshBuffer;
	var structure:VertexStructure;
	
	var material:Material;
	
	public function new(data:MeshData, material:Material, structure:VertexStructure) {
		render = Application.get().getRenderer();
		
		this.data = data;
		this.material = material;
		this.structure = structure;
		
		var vertexData = MeshTools.buildVertexData(data, structure);
		var vertexBuffer = render.createVertexBuffer(data.vertexCount, structure);
		var indexBuffer = render.createIndexBuffer(data.vertexCount, structure);
		
		meshBuffer = new MeshBuffer(vertexBuffer, indexBuffer, vertexData, new UInt16Array(data.indices));
		
		@:privateAccess
		vertexBuffer.data = vertexData;
		vertexBuffer.unlock();
		
		var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = data.indices[i];
		}
		indexBuffer.unlock();
	}
	
	public function setMaterial(material:Material) {
		this.material = material;
	}
	
	public function draw() {
		material.apply();
		render.drawBuffer(meshBuffer.vertexBuffer, meshBuffer.indexBuffer);
		//GL.drawElements(GL.TRIANGLES, 3, GL.UNSIGNED_SHORT, 0);
	}
	
	public function init() {
		
	}
	
}

private class MeshBuffer {
	public var vertexData:Float32Array;
	public var indexData:UInt16Array;
	public var vertexBuffer:VertexBuffer;
	public var indexBuffer:IndexBuffer;
	
	inline public function new(vertexBuffer, indexBuffer, vertexData, indexData) {
		this.vertexBuffer = vertexBuffer;
		this.indexBuffer = indexBuffer;
		this.vertexData = vertexData;
		this.indexData = indexData;
	}
}