package bakeneko.render;

class VertexElement {
	public var type:VertexData;
	public var semantic:VertexSemantic;

	public inline function new(type:VertexData, semantic:VertexSemantic) {
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

	public function numData():Int {
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
	
	public function toString() {
		return 'Element (${attributeName()}(${numData()}))';
	}
}