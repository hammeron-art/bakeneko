package bakeneko.geometry;

import bakeneko.math.Vector2;

//TODO: finish implementation
class Ellipse {

	public var origin:Vector2;
	public var radiusX:Float;
	public var radiusY:Float;
	
	/**
	 * Constructor
	 * 
	 * @param	origin
	 * @param	radius
	 */
	public function new(origin:Vector2, radiusX:Float = 0.0, radiusY:Float) {
		this.radiusX = radius;
		this.radiusY = radiusY;
		
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
	/*public function containsPoint(point:Vector2):Bool {
        var diff = new Vector2(point.x - origin.x, point.y - origin.y);
        return diff.length <= radius;
    }*/
	
	/**
	 * Checks whether a circle is inside this circle
	 * @param	circle
	 */
	/*public function containsCircle(circle:Circle):Bool {
		return ShapeIntersection.circleVsCicle(this, circle);
	}*/
	
	function toString() {
        return '{ origin: $origin, radiusX: $radiusX, radiusY:$radiusY }' ;
    }
	
}