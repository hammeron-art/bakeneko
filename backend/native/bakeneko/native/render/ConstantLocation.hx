package bakeneko.native.render;

class ConstantLocation implements bakeneko.graphics4.ConstantLocation {
	public var value: Dynamic;
	
	public function new(value: Dynamic) {
		this.value = value;
	}
}
