package tests.unit;

import bakeneko.math.Vector3;
import bakeneko.geometry.AABB;
import bakeneko.geometry.Ray;
import bakeneko.geometry.ShapeIntersection;
import bakeneko.geometry.Sphere;
import tests.unit.BakenekoTestCase;

import bakeneko.math.MathUtil;
import bakeneko.math.Vector2;
import bakeneko.geometry.Circle;
import bakeneko.geometry.Rectangle;

class ShapeTest extends BakenekoTestCase
{
	public function testAABB()
	{
		// Contains point
        var aabb = new AABB(new Vector3(0.0, 0.0, -0.5), new Vector3(16.0, 16.0, 16.0));
        
        assertTrue(aabb.containsPoint(new Vector3(12.0, 0.9, -0.4)));
		assertFalse(aabb.containsPoint(new Vector3(16.0, -16.0, 16.0)));
		
		// Contains AABB
		aabb = new AABB(new Vector3(0.0, 0.0, -0.5), new Vector3(16.0, 16.0, 16.0));
        
        assertTrue(ShapeIntersection.aabbVsAabb(aabb, new AABB(new Vector3(0.0, 0.0, -0.5), new Vector3(16.0, 16.0, 16.0))));
		assertFalse(ShapeIntersection.aabbVsAabb(aabb, new AABB(new Vector3(16.0, 16.0, 16.0), new Vector3(16.0, 16.0, 16.0))));
    
		// Ray
		aabb = new AABB(new Vector3(0.0, 0.0, 0.0), new Vector3(16.0, 16.0, 16.0));
		
		var intersection0 = ShapeIntersection.aabbVsRay(aabb, new Ray(new Vector3( -2.0, 0.0, 0.0), new Vector3(1.0, 0.0, 0.0), 1000.0));
		var intersection1 = ShapeIntersection.aabbVsRay(aabb, new Ray(new Vector3( -2.0, -16.0, 0.0), new Vector3(1.0, 0.0, 0.0), 1000.0));
		
		assertTrue(intersection0.result);
		assertFalse(intersection1.result);		
	}
	
    public function testRectangle()
	{
		// Contains point
        var rectangle = new Rectangle(-5.0, -10.0, 128.0, 64.0);
        
        assertTrue(rectangle.containsPoint(new Vector2(12, -0.8)));
		assertFalse(rectangle.containsPoint(new Vector2(16, -16)));
		
		// Contains rectagle
		rectangle = new Rectangle(-5.0, -10.0, 128.0, 64.0);
        
        assertTrue(ShapeIntersection.rectangleVSRectangle(rectangle, new Rectangle(0.0, 0.0, 32.0, 63.0)));
		assertFalse(ShapeIntersection.rectangleVSRectangle(rectangle, new Rectangle(128.0, 64.0, 16, 16)));
    }
	
	public function testCircle()
	{
		// Contains point
        var circle = new Circle(new Vector2(0.0, 0.0), 16.0);
        
        assertTrue(circle.containsPoint(new Vector2(12, -0.8)));
		assertFalse(circle.containsPoint(new Vector2(16, -16)));
		
		// Contains circle
		circle = new Circle(new Vector2(0.0, 0.0), 32.0);
        
        assertTrue(ShapeIntersection.circleVsCicle(circle, new Circle(new Vector2(0.0, 0.0), 0.16)));
		assertFalse(ShapeIntersection.circleVsCicle(circle, new Circle(new Vector2(64.0, 64.0), 32)));
    }
	
	public function testSphere()
	{
		// Contains point
        var sphere = new Sphere(new Vector3(0.0, 0.0, 0.0), 16.0);
        
        assertTrue(sphere.containsPoint(new Vector3(12, -0.8, 0.0)));
		assertFalse(sphere.containsPoint(new Vector3(16, -16, 0.0)));
		
		// Contains sphere
		sphere = new Sphere(new Vector3(0.0, 0.0, 0.0), 32.0);
        
        assertTrue(ShapeIntersection.sphereVsSphere(sphere, new Sphere(new Vector3(0.0, 0.0, 0.0), 0.16)));
		assertFalse(ShapeIntersection.sphereVsSphere(sphere, new Sphere(new Vector3(64.0, 64.0, 0.0), 32)));
    
		// Ray
		sphere = new Sphere(new Vector3(0.0, 0.0, 0.0), 32.0);
		
		var intersection0:RayIntersection = ShapeIntersection.sphereVsRay(sphere, new Ray(new Vector3( -128.0, 0.0, 0.0), new Vector3(1.0, 0.0, 0.0), 1000));
		var intersection1:RayIntersection = ShapeIntersection.sphereVsRay(sphere, new Ray(new Vector3( -128.0, 0.0, 0.0), new Vector3( -1.0, 0.0, 0.0), 1000));
		
		assertTrue(intersection0.t0 > 0 && intersection0.t1 > 0);
		assertTrue(intersection1.t0 < 0 && intersection1.t1 < 0);
	}
	
	//TODO: Implement tests for Ray and Plane
	
}