package bakeneko.geometry;

import bakeneko.math.Vector3;

/**
 * A 3D ray
 */
class Ray {

	public var origin:Vector3;
	public var direction:Vector3;
	public var length:Float;
	
	/**
	 * Constructor
	 * 
	 * @param	origin
	 * @param	direction
	 */
	public function new(origin:Vector3, direction:Vector3, length:Float = 5000.0) {
		this.origin = origin;
		this.direction = direction;
		this.length = length;
	}
	
	/**
	 * Get the position of a point t units along the ray
	 * 
	 * @param	t	distance along the ray
	 * @return	Point on ray
	 */
	public function getPoint(t:Float):Vector3 {
		return origin + (direction * t) * length;
	}
	
	public function distanceFromPoint(point:Vector3):Float {
		return Vector3.Cross(direction, point).length;
	}
	
	function toString() {
        return '{ origin: $origin, direction: $direction, $length }';
    }
	
}