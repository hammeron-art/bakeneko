package bakeneko.geometry;

import bakeneko.math.MathUtil;
import bakeneko.math.Vector2;
import bakeneko.math.Vector3;

/**
 * Static methods to check intersection between shapes
 */
class ShapeIntersection {
	
	/**
	 * Intersects an AABB and a Ray
	 * 
	 * @param	aabb
	 * @param	ray
	 * @return
	 */
	public static function aabbVsRay(aabb:AABB, ray:Ray):RayIntersection {
		var t1:Float = Math.POSITIVE_INFINITY;
		var t0:Float = -t1;
		
		var rayOrigin:Vector3 = ray.origin;
		var rayDir:Vector3 = ray.direction;
		
		var aabbMin = aabb.min.clone();
		var aabbMax = aabb.max.clone();
		
		var raySlabResult:RayIntersection = {
			result: false,
			t0: t0,
			t1: t1,
		}
		
		// X
		raySlabResult = rayVsSlab(rayOrigin.x, rayDir.x, aabbMin.x, aabbMax.x, t0, t1);
		
		if (raySlabResult.result == false)
		{
			return raySlabResult;
		}
		
		// Y
		raySlabResult = rayVsSlab(rayOrigin.y, rayDir.y, aabbMin.y, aabbMax.y, t0, t1);
		
		if (raySlabResult.result == false)
			return raySlabResult;
		
		// Z
		raySlabResult = rayVsSlab(rayOrigin.z, rayDir.z, aabbMin.z, aabbMax.z, t0, t1);
		
		if (raySlabResult.result == false)
			return raySlabResult;
		
		// We haven't failed intersection against any slab therefore we must have hit
		// t1 and t2 will give us our entry and exit point on the parametric ray
		raySlabResult.result = true;
			
		return raySlabResult;
	}
	
	public static function aabbVsPoint(aabb:AABB, point:Vector3):Bool {
		return 	MathUtil.closedRangeContains(aabb.origin.x, aabb.size.x, point.x) &&
				MathUtil.closedRangeContains(aabb.origin.y, aabb.size.y, point.y) &&
				MathUtil.closedRangeContains(aabb.origin.z, aabb.size.z, point.z);
	}
	
	public static function aabbVsAabb(aabbA:AABB, aabbB:AABB):Bool {
		return 	MathUtil.openRangesIntersect(aabbA.origin.x, aabbA.size.x, aabbB.origin.x, aabbB.size.x) &&
				MathUtil.openRangesIntersect(aabbA.origin.y, aabbA.size.y, aabbB.origin.y, aabbB.size.y) &&
				MathUtil.openRangesIntersect(aabbA.origin.z, aabbA.size.z, aabbB.origin.z, aabbB.size.z);
	
	}
	
	/**
	 * Intersects a sphere and a ray.
	 * 
	 * This doesn't consider the actual ray length but an "infinity" length
	 * so note the follow cases for the RayIntersection output:
	 * 
	 * (t0 > 0) && (t1 > 0) : ray origin is outside the sphere and intersects the sphere in two points
	 * (t0 = t1)			: ray origin is outside the sphere and intersects at a single point
	 * (t0 < 0) && (t1 > 0)	: ray origin is inside the sphere and intersects at two points
	 * result: false		: no intersection
	 * (t0 < 0) && (t1 < 0)	: intersects in two points but the ray origin is behind the sphere
	 * 
	 * http://www.scratchapixel.com/images/upload/ray-simple-shapes/rayspherecases.png
	 * 
	 * @param	sphere
	 * @param	ray
	 * @return
	 */
	public static function sphereVsRay(sphere:Sphere, ray:Ray):RayIntersection {
		var output:RayIntersection = {
			result: false,
			t0: 0,
			t1: 0,
		}
		
		var delta:Vector3 = ray.origin - sphere.origin;
		
		var b = 2.0 * Vector3.Dot(delta, ray.direction);
		var c = Vector3.Dot(delta, delta) - sphere.radius * sphere.radius;
		var discriminant = b * b - 4.0 * c;
		
		if (discriminant < 0.0) {
			output.result = false;
		} else {
			var sqrtDist:Float = Math.sqrt(discriminant);
			var t1:Float = ( -b - sqrtDist) * 0.5;
			var t2:Float = ( -b + sqrtDist) * 0.5;
			
			output.result = true;
			output.t0 = t1;
			output.t1 = t2;
		}
	
		return output;
	}
	
	public static function rectangleVsPoint(rect:Rectangle, point:Vector2):Bool {
		return MathUtil.closedRangeContains(rect.x, rect.width, point.x) && MathUtil.closedRangeContains(rect.y, rect.height, point.y);
	}
	
	public static function rectangleVSRectangle(rectA:Rectangle, rectB:Rectangle):Bool {
		return 	MathUtil.openRangesIntersect(rectA.x, rectA.width, rectB.x, rectB.width) &&
				MathUtil.openRangesIntersect(rectA.y, rectA.height, rectB.y, rectB.height);
	}
	
	public static function circleVsPoint(circle:Circle, point:Vector2):Bool {
		var diff = new Vector2(point.x - circle.origin.x, point.y - circle.origin.y);
        return diff.length <= circle.radius;
	}
	
	public static function circleVsCicle(circleA:Circle, circleB:Circle):Bool {
		var radius = circleA.radius + circleB.radius;
		
		return 	Math.abs(circleA.origin.x - circleB.origin.x) < radius &&
				Math.abs(circleA.origin.y - circleB.origin.y) < radius;
	}
	
	public static function sphereVsPoint(sphere:Sphere, point:Vector3):Bool {
		var diff = new Vector3(point.x - sphere.origin.x, point.y - sphere.origin.y, point.z - sphere.origin.z);
        return diff.length <= sphere.radius;
	}
	public static function sphereVsSphere(sphereA:Sphere, sphereB:Sphere):Bool {
		var radius = sphereA.radius + sphereB.radius;
		
		return 	Math.abs(sphereA.origin.x - sphereB.origin.x) < radius &&
				Math.abs(sphereA.origin.y - sphereB.origin.y) < radius &&
				Math.abs(sphereA.origin.z - sphereB.origin.z) < radius;
	}
	
	public static function rayVsSlab(start:Float, dir:Float, min:Float, max:Float, firstT:Float, lastT:Float):RayIntersection {
		
		var output:RayIntersection = {
			result: false,
			t0: firstT,
			t1: lastT,
		};
		
		if (dir == 0.0) {
			// The ray direction is parallel to the slab therefore will only collide if it starts within
			// Check if the ray begins inside the slab
			output.result = start < max && start > min;
			return output;
		}
		
		// Work out the near and far intersection planes of the slab
		var tMin = (min - start) / dir;
		var tMax = (max - start) / dir;
		
		// tMin shold be intersection with the near plane
		if (tMin > tMax) {
			var tMinCopy = tMin;
			tMin = tMax;
			tMax = tMinCopy;
		}
		
		// Calculate the entry and exit pointt
		output.t0 = Math.max(tMin, firstT);
		output.t1 = Math.min(tMax, lastT);
		
		if (output.t0 > output.t1 || output.t1 < 0.0) {
			// We have missed the slab
			output.result = false;
		}
		
		output.result = true;
		
		return output;
	}
	
	//TODO: Implement intersections for Ray and Planes
	
}

typedef RayIntersection = {
	var result:Bool;
	var t0:Float;
	var t1:Float;
}