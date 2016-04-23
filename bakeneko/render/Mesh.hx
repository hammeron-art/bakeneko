package bakeneko.render;

import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.format.model.Data.Face;
import bakeneko.render.MeshTools;
import bakeneko.math.Matrix4x4;
import bakeneko.math.Vector4;
import bakeneko.backend.buffer.Float32Array;
import bakeneko.backend.buffer.Uint16Array;
import bakeneko.backend.opengl.GL;
import bakeneko.render.VertexFormat.VertexElement;

/**
 * Mesh object create and manager VBO and EBO buffers for the GPU
 */
class Mesh {

	// Material and mesh formats should match for drawing
	public var format:VertexFormat;
	
	public var data:MeshData;

	static var currentlyBound(default, null):Mesh = null;

	public var wireframe:Bool = false;
	public var material:Material;
		
	public var render:RenderSystem;
	
	//public var vertexList:Float32Array;
	//public var indexList:UInt16Array;
	
	public var vertexList(default, null):Array<Float>;
	// List of quads and triangles
	public var faceList(default, null):Array<Int>;
	// Triangulated index
	public var indexList(default, null):Array<Int>;
	
	var vertexBuffer:GLBuffer;
	var indexBuffer:GLBuffer;
	var usage:Int = GL.STATIC_DRAW;

	public function new(?data:MeshData, ?vertexFormat:VertexFormat) {
		this.format = vertexFormat == null ? Application.get().renderSystem.defaultFormat : vertexFormat;

		render = Application.get().renderSystem;

		vertexBuffer = GL.createBuffer();
		indexBuffer = GL.createBuffer();
		
		if (data == null)
			data = {};
		
		this.data = {
			positions: data.positions != null ? data.positions : [],
			uvs: data.uvs != null ? data.uvs : [],
			colors: data.colors != null ? data.colors : [],
			normals: data.normals != null ? data.normals : [],
			faces: data.faces != null ? data.faces : [],
			indexes: data.indexes != null ? data.indexes : [],
		}
		
		//this.data = data != null ? data : {positions: [], uvs: [], colors: [], normals: [], faces: [], indexes: []};
		
		vertexList = MeshTools.buildVertexData(this.data, this.format);
		indexList = this.data.indexes;
	}
	
	public inline function setVertexFromArray(data:Array<Float>) {
		this.vertexList = data;
	}

	public inline function setIndexFromArray(index:Array<Int>) {
		this.indexList = index;
	}
	
	public inline function vertexTypedArray() {
		return new Float32Array(vertexList);
	}

	public inline function indexTypedArray() {
		return new UInt16Array(indexList);
	}

	public function setMaterial(material:Material) {
		this.material = material;
	}
	
	public inline function indexSize() {
		// Uint16Array - 2 bytes
		return 2;
	}
	
	public inline function indexFormat() {
		return GL.UNSIGNED_SHORT;
	}
	
	/**
	 * Return a vertex group of this mesh in the vertex format
	 * @param	index
	 */
	public inline function getVertex(index:Int):Array<Float> {
		var offset = format.totalNumValues * index;
		
		return [ for (i in 0...format.totalNumValues) vertexList[offset + i] ];
	}

	/**
	 * Setup GPU memory for this mesh
	 */
	public function build() {
		if (data == null)
			return;
		
		bind();
		lockData();
	}

	/**
	 * Bind this GPU memory of this mesh
	 */
	public function bind() {
		if (currentlyBound != this) {
			GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);

			currentlyBound = this;
		}
	}

	/**
	 * Fills the GPU memory of this mesh with its vertices and indexes
	 */
	public function lockData() {
		GL.bufferData(GL.ARRAY_BUFFER, vertexTypedArray(), usage);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indexTypedArray(), usage);
	}

	/**
	 * Draw mesh
	 * 
	 * @param	material
	 */
	public function draw() {
		bind();
		Application.get().renderSystem.drawBuffer(this, material);
	}

	/**
	 * Transform and return the vertices of this mesh using the
	 * Matrix.
	 * This will not change the Mesh object
	 *
	 * @param	transform
	 */
	public function getTransformedMesh(transform:Matrix4x4):Array<Float> {
		var vertices:Array<Float> = [for (v in vertexList) v];
		var pos = new Vector4();
		
		var count = getVertexCount();
		var p = 0;
		var i = 0;
		
		while (i < count) {
			p = i * format.totalNumValues;
			
			pos.set(vertexList[p], vertexList[p + 1], vertexList[p + 2], 1.0);
			pos = transform * pos;
			
			vertices[p] = pos.x;
			vertices[p + 1] = pos.y;
			vertices[p + 2] = pos.z;
			
			++i;
		}

		return vertices;
	}
	
	/**
	 * Offset and return the indices of this mesh.
	 * This will not change the Mesh object
	 *
	 * @param	offset
	 */
	public function getTransformedIndex(offset:Int):Array<Int> {
		var indices:Array<Int> = [];
		
		for (index in indexList) {
			indices.push(offset + index);
		}
		
		return indices;
	}

	/**
	 * Transform the vertex data of this Mesh with the given transform
	 *
	 * @param	transform
	 */
	public function transformMesh(transform:Matrix4x4) {
		vertexList = getTransformedMesh(transform);
	}
	
	/**
	 * Return the number of vertice groups according to vertex format of this mesh
	 */
	public function getVertexCount() {
		return Std.int(vertexList.length / format.totalNumValues);
	}
	
	/**
	 * Scale the position data of this mesh
	 * @param	x
	 * @param	y
	 * @param	z
	 */
	public function scale(x:Int, y:Int, z:Int) {
		var count = getVertexCount();
		var p = 0;
		var i = 0;
		
		while (i < count) {
			p = i * format.totalNumValues;
			
			vertexList[p] *= x;
			vertexList[p + 1] *= y;
			vertexList[p + 2] *= z;
			
			++i;
		}
	}

	public function toString() {
		var str = '{ ';
		for (i in vertexList) {
			str += '$i, ';
		}
		str += '}';
		return str;
	}

}