package bakeneko.core;

abstract Pair<A, B>(PairBase<A, B>) {

	public var first(get, never):A;
	public var second(get, never):B;

	public inline function new(first:A, second:B) this = new PairBase(first, second);

	inline function get_first():A return this.first;
	inline function get_second():B return this.second;

	@:to inline function toBool()
		return this != null;

	@:op(!first) public function isNil()
		return this == null;

	static public function nil<A, B>():Pair<A, B>
		return null;
		
}

class PairBase<A, B> {
	
	public var first:A;
	public var second:B;
	
	public inline function new(first, second) {
		this.first = first;
		this.second = second;
	}
	
	public inline function toString() {
		return 'Pair($first, $second)';
	}
	
}