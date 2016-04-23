package bakeneko.geometry;

import bakeneko.math.Vector3;

/**
 * A 3D box
 */
class AABB {

	public var origin:Vector3;
	public var size:Vector3;
	
	public var halfSize:Vector3;
	public var min:Vector3;
	public var max:Vector3;
	
	/**
	 * Constructor
	 * 
	 * @param	radius
	 * @param	origin
	 */
	public function new(origin:Vector3, size:Vector3) {
		this.size = size.clone();
		this.origin = origin.clone();
		
		halfSize = size * 0.5;
		min = Vector3.zero;
		max = Vector3.zero;
		
		calculateBoundary();
	}
	
	public function calculateBoundary():Void {
		min.set(origin.x - halfSize.x, origin.y - halfSize.y, origin.z - halfSize.z);
		max.set(origin.x + halfSize.x, origin.y + halfSize.y, origin.z + halfSize.z);
	}
	
	/**
	 * Checks whether a point is inside this circle.
	 * 
	 * @param	point
	 */
	public inline function containsPoint(point:Vector3):Bool {
        return ShapeIntersection.aabbVsPoint(this, point);
    }
	
	/**
	 * Checks whether a circle is inside this circle
	 * @param	circle
	 */
	public inline function containsCircle(aabb:AABB):Bool {
		return ShapeIntersection.aabbVsAabb(this, aabb);
	}
	
	function toString() {
        return '{ origin: $origin, size: $size }';
    }
	
}