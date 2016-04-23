package bakeneko.render;

import bakeneko.backend.opengl.GL;

/**
 * Vertex attribute format to be send to the shader
 */
class VertexFormat {

	public var elements(default, null):Array<VertexElement>;
	// Total size of bytes
	public var totalSize(default, null):Int = 0;
	// Total number of values (eg. float2 + int3 = 5 values);
	public var totalNumValues(default, null):Int = 0;

	public function new() {
		this.elements = [];
	}

	public function push(vertex:VertexElement) {
		totalSize += vertex.size();
		totalNumValues += vertex.numData();
		elements.push(vertex);
	}
	
	public function hasSemantic(type:VertexSemantic) {
		for (element in elements)
			if (element.semantic == type)
				return true;
		
		return false;
	}
	
	public function getOffsetTo(semantic:VertexSemantic) {
		
		var offset = 0;
		
		for (element in elements) {
			if (element.semantic == semantic)
				break;
			
			offset += element.size();
		}
		
		return offset;
	}
}

class VertexElement {
	public var type:VertexType;
	public var semantic:VertexSemantic;

	public inline function new(type:VertexType, semantic:VertexSemantic) {
		this.type = type;
		this.semantic = semantic;
	}

	public inline function size():Int {
		return switch(type) {
			case TInt(size): size * 4;
			case TFloat(size): size * 4;
			case TByte(size): size * 4;
		}
	}

	public inline function numData():Int {
		return switch(type) {
			case TInt(size): size;
			case TFloat(size): size;
			case TByte(size): size;
		}
	}

	public inline function attributeName():String {
		return switch(semantic) {
			case SPosition: 'position';
			case STexcoord: 'texcoord';
			case SColor: 'color';
			case SNormal: 'normal';
			case SWeight: 'weight';
			case SJointIndex: 'jointIndex';
		}
	}

	public inline function glType():Int {
		return switch(type) {
			case TInt(size): GL.INT;
			case TFloat(size): GL.FLOAT;
			case TByte(size): GL.BYTE;
		}
	}
	
	public function toString() {
		return 'Element (${attributeName()}(${numData()}))';
	}
}

enum VertexType {
	TInt(size:Int);
	TFloat(size:Int);
	TByte(size:Int);
}

enum VertexSemantic {
	SPosition;
	STexcoord;
	SColor;
	SNormal;
	SWeight;
	SJointIndex;
}