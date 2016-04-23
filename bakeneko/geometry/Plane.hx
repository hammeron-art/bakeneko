package bakeneko.geometry;

import bakeneko.math.Vector3;

/**
 * A 3D plane shape
 */
class Plane {

	public var normal:Vector3;
	public var d:Float;
	
	/**
	 * Constructor
	 * 
	 * @param	origin
	 * @param	normal
	 */
	public function new(origin:Vector3, normal:Vector3) {
		this.normal = normal.clone();
		this.d = Vector3.Dot(normal, origin);
	}
	
	/**
	 * Distance from point
	 * 
	 * @param	point
	 * @return
	 */
	public function distanceFromPoint(point:Vector3):Float {
		return Vector3.Dot(normal, point) + d;
	}
	
	public function set(a:Float, b:Float, c:Float, d:Float) {
		this.normal.set(a, b, c);
		this.d = d;
	}
	
	function toString() {
        return '{ normal: $normal, d: $d }';
    }
	
}