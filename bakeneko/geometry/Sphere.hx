package bakeneko.geometry;

import bakeneko.math.Vector3;

/**
 * A 3D sphere shape.
 */
class Sphere {

	public var origin:Vector3;
	public var radius:Float;
	
	/**
	 * Constructor
	 * 
	 * @param	origin
	 * @param	radius
	 */
	public function new(origin:Vector3, radius:Float = 0.0) {
		this.radius = radius;
		
		if (origin != null) {
			this.origin = origin.clone();
		} else {
			this.origin = new Vector3(0.0, 0.0, 0.0);
		}
	}
	
	/**
	 * Checks whether a point is inside this sphere.
	 * 
	 * @param	point
	 */
	public function containsPoint(point:Vector3):Bool {
        return ShapeIntersection.sphereVsPoint(this, point);
    }
	
	/**
	 * Checks whether a sphere is inside this sphere
	 * @param	sphere
	 */
	public function containsCircle(sphere:Sphere):Bool {
		return ShapeIntersection.sphereVsSphere(this, sphere);
	}
	
	function toString() {
        return '{ origin: $origin, radius: $radius }';
    }
	
}