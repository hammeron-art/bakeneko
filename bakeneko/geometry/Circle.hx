package bakeneko.geometry;

import bakeneko.math.Vector2;

/**
 * A 2D circle shape
 */
class Circle {

	public var origin:Vector2;
	public var radius:Float;
	
	/**
	 * Constructor
	 * 
	 * @param	origin
	 * @param	radius
	 */
	public function new(origin:Vector2, radius:Float = 0.0) {
		this.radius = radius;
		
		if (origin != null) {
			this.origin = origin.clone();
		} else {
			this.origin = new Vector2(0.0, 0.0);
		}
	}
	
	/**
	 * Checks whether a point is inside this circle.
	 * 
	 * @param	point
	 */
	public function containsPoint(point:Vector2):Bool {
        var diff = new Vector2(point.x - origin.x, point.y - origin.y);
        return diff.length <= radius;
    }
	
	/**
	 * Checks whether a circle is inside this circle
	 * @param	circle
	 */
	public function containsCircle(circle:Circle):Bool {
		return ShapeIntersection.circleVsCicle(this, circle);
	}
	
	function toString() {
        return '{ origin: $origin, radius: $radius }' ;
    }
	
}