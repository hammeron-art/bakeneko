package bakeneko.native;

class ConstantLocation implements bakeneko.graphics.ConstantLocation {
	public var value: Dynamic;
	
	public function new(value: Dynamic) {
		this.value = value;
	}
}
