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
		
		@:privateAccess
		vertexBuffer.data = vertexData;
		vertexBuffer.unlock();
		
		trace(vertexData.length);
		
		/*var iData = indexBuffer.lock();
		for (i in 0...iData.length) {
			iData[i] = data.indices[i];
		}*/
		@:privateAccess
		indexBuffer.data = new UInt16Array(data.indices);
		indexBuffer.unlock();
		
		meshBuffer = new MeshBuffer(vertexBuffer, indexBuffer);
	}
	
	public function setMaterial(material:Material) {
		this.material = material;
	}
	
	public function draw() {
		//render.applyVertexAttributes(meshBuffer.vertexBuffer);
		material.apply();
		render.drawBuffer(meshBuffer.vertexBuffer, meshBuffer.indexBuffer);
	}
	
	public function init() {
		
	}
	
}

private class MeshBuffer {
	public var vertexBuffer:VertexBuffer;
	public var indexBuffer:IndexBuffer;
	
	inline public function new(vertexBuffer, indexBuffer) {
		this.vertexBuffer = vertexBuffer;
		this.indexBuffer = indexBuffer;
	}
}