package tests.unit;

import haxe.unit.TestCase;
import bakeneko.math.*;
import tests.unit.BakenekoTestCase;

/**
 * Test case for the core math class
 * Vector, Matrix and Quaternion
 */
class MathTest extends BakenekoTestCase {

	// ======== 2D tests ======== //
	
	public function testVector2Operations() {
		
		var a:Vector2 = new Vector2(2.0, 4.0);
		var b:Vector2 = new Vector2(1.0, 0.5);
		var c:Vector2 = new Vector2(2.0, 4.0);

		assertTrue(((Vector2.zero + a) * b / b) == c);
    }
	
		
	public function testVectorRotate()
    {
        // After 90 degree ccw rotation around 0, 0:
        // x -> +y
        // y -> -x
        assertApproxEquals(0.0, ((Vector2.xAxis.rotate(Math.PI / 2.0, Vector2.zero)) - Vector2.yAxis).length);
        assertApproxEquals(0.0, ((Vector2.yAxis.rotate(Math.PI / 2.0, Vector2.zero)) + Vector2.xAxis).length);
    }
	
	public function testVector3Operations() {
		
		var a:Vector3 = new Vector3(2.0, 4.0, 1.0);
		var b:Vector3 = new Vector3(1.0, 0.5, 2.0);
		var c:Vector3 = new Vector3(2.0, 4.0, 1.0);

		assertTrue(((Vector3.zero + a) * b / b) == c);
	
    }
	
	public function testVector4Operations() {
		
		var a:Vector4 = new Vector4(2.0, 4.0, 1.0, 3.0);
		var b:Vector4 = new Vector4(1.0, 0.5, 2.0, 2.0);
		var c:Vector4 = new Vector4(2.0, 4.0, 1.0, 3.0);

		assertTrue(((Vector4.zero + a) * b / b) == c);
	
    }
	
	// Determinante
	public function testMatrix2x2() {
		
		var a:Matrix2x2 = new Matrix2x2();
		assertTrue(a.determinant == 1.0);
		
	}
	
	// Transpose
	public function testMatrix2x2Tranpose() {
		
		var m = new Matrix2x2(Math.random(), Math.random(), Math.random(), Math.random());
        
        var n = m.transpose.transpose;
            
        var k = (m - n);
        var normSq = k.a * k.a + k.b * k.b + k.c * k.c + k.d * k.d;
        assertTrue(normSq < MathUtil.epsilon);
	}
	
	public function testRotation(){
        // After 90 degree ccw rotation:
        // x -> +y
        // y -> -x
        assertApproxEquals(0.0, ((Matrix2x2.Rotate(Math.PI / 2.0) * Vector2.xAxis) - Vector2.yAxis).length);
        assertApproxEquals(0.0, ((Matrix2x2.Rotate(Math.PI / 2.0) * Vector2.yAxis) + Vector2.xAxis).length);
    }
	
	public function testHomogenousTranslation() {
        var m = Matrix3x2.identity;
        m.translation = new Vector2(3, -1);
        assertTrue(m * Vector2.zero == m.translation);
    }
    
    public function testPolarConversion() {
        assertApproxEquals(0.0, (Vector2.FromPolar(Math.PI, 1.0) + Vector2.xAxis).length);
        
        // Some backends give +PI, others -PI (they are both equivalent)
        assertApproxEquals(Math.PI, Math.abs((-Vector2.xAxis).angle));
    }
	
	public function testNorms() {
        assertTrue(Vector2.Dot(Vector2.yAxis.normal.rotate(Math.PI, Vector2.zero), new Vector2(-1, 0)) > 0.0);
        assertTrue(Vector2.Dot(Vector2.yAxis.normal.rotate(-Math.PI, Vector2.zero), new Vector2(-1, 0)) < 0.0);
	}
	
	public function testAngles() {
        assertApproxEquals(Vector2.yAxis.signedAngleWith(new Vector2(-1, 1)), Math.PI / 4.0);
        assertApproxEquals(Vector2.yAxis.signedAngleWith(new Vector2(1, 1)), -Math.PI / 4.0);
        assertApproxEquals(Vector2.yAxis.signedAngleWith(new Vector2(-1, -1)), 3.0 * Math.PI / 4.0);
        assertApproxEquals(Vector2.yAxis.signedAngleWith(new Vector2(1, -1)), -3.0 * Math.PI / 4.0);
        
        assertApproxEquals(Vector2.yAxis.signedAngleWith(Vector2.xAxis), -Math.PI / 2.0);
        assertApproxEquals(Vector2.xAxis.signedAngleWith(Vector2.yAxis), Math.PI / 2.0);
        
        assertApproxEquals(Vector2.yAxis.angleWith(Vector2.xAxis), Math.PI / 2.0);
        assertApproxEquals(Vector2.xAxis.angleWith(Vector2.yAxis), Math.PI / 2.0);
    }
	
	public function testOrbit() {
        for (i in 0...5) {
            var center = randomVector2() + new Vector2(1, 1);
            var m:Matrix3x2 = Matrix3x2.Orbit(center, Math.PI / 2);
            
            for (j in 0...5) {
                var point = randomVector2();
                var pointAfter = m * point;
                assertApproxEquals(0.0, Vector2.Dot((point - center), (pointAfter - center)));
            }
        }
    }
	
	public function testLinearSubMatrix() {
        var m = Matrix3x2.identity;
        m.linearSubMatrix = new Matrix2x2(1.0, 2.0, 3.0, 4.0);
        assertTrue(m.linearSubMatrix == new Matrix2x2(1.0, 2.0, 3.0, 4.0));
    }
	
	public function testOrthoNormalize() {
        for (i in 0...10) {
            var u = randomVector2();
            var v = randomVector2();
            
            Vector2.OrthoNormalize(u, v);
            
            assertApproxEquals(1.0, u.length);
            assertApproxEquals(1.0, v.length);
            assertApproxEquals(0.0, Vector2.Dot(u, v));
        }
    }
    
    public function testReflect() {
        for (i in 0...10) {
            var u = randomVector2();
            var v = Vector2.Reflect(u, Vector2.yAxis);
            
            assertEquals(u.x, v.x);
            assertEquals(-u.y, v.y);
        }
    }
	
	// ======== 3D tests ======== //
	public function testMatrixMult() {
        for (i in 0...10) {
            var a = randomMatrix3x3();
            assertTrue(Matrix3x3.identity * a == a);
        }
    }
	
	public function testAddSub()
    {
        for (i in 0...10)
        {
            var a = randomMatrix3x3();
            var b = randomMatrix3x3();
            var c = a.clone();
            assertTrue((c.add(b)) == (a + b));
        }
        
        for (i in 0...10)
        {
            var a = randomMatrix3x3();
            var b = randomMatrix3x3();
            var c = a.clone();
            assertTrue((c.subtract(b)) == (a - b));
        }
    }
    
    public function testCrossProductPrecedence()
    {
        assertTrue(Vector3.xAxis + Vector3.yAxis % Vector3.zAxis == 2.0 * Vector3.xAxis);
    }
    
    public function testAxialRotation()
    {
        var quarterRot = 90.0;
        
        // After 90 degree ccw rotation around X:
        // y -> +z
        // z -> -y
        assertApproxEquals(((Matrix3x3.RotationX(quarterRot) * Vector3.yAxis) - Vector3.zAxis).length, 0.0);
        assertApproxEquals(((Matrix3x3.RotationX(quarterRot) * Vector3.zAxis) + Vector3.yAxis).length, 0.0);
        
        // After 90 degree ccw rotation around Y:
        // z -> +x
        // x -> -z
        assertApproxEquals(((Matrix3x3.RotationY(quarterRot) * Vector3.zAxis) - Vector3.xAxis).length, 0.0);
        assertApproxEquals(((Matrix3x3.RotationY(quarterRot) * Vector3.xAxis) + Vector3.zAxis).length, 0.0);
        
        // After 90 degree ccw rotation around Z:
        // x -> +y
        // y -> -x
        assertApproxEquals(((Matrix3x3.RotationZ(quarterRot) * Vector3.xAxis) - Vector3.yAxis).length, 0.0);
        assertApproxEquals(((Matrix3x3.RotationZ(quarterRot) * Vector3.yAxis) + Vector3.xAxis).length, 0.0);
    }
	
	// Matrix4X4
	public function testMatrix4() {
		
		// Transformations
		var vec = new Vector4(1.0, 0.0, 1.0, 1.0);

		assertApproxEquals((Matrix4x4.CreateRotationX(Math.PI) * vec).z, -1.0);
		assertApproxEquals((Matrix4x4.CreateRotationY(Math.PI) * vec).x, -1.0);
		assertApproxEquals((Matrix4x4.CreateRotationZ(Math.PI) * vec).x, -1.0);
		
		assertTrue(Matrix4x4.CreateTranslation(new Vector3(2.0, 3.4, 7.5)) * vec == new Vector4(3.0, 3.4, 8.5, 1.0));
		assertTrue(Matrix4x4.CreateScale(new Vector3(2.0, 4.0, 7.0)) * vec == new Vector4(2.0, 0.0, 7.0, 1.0));
		
		// LookAt, Axis
		var m = Matrix4x4.LookAt(new Vector3(2.0, -3.0, -10.0), new Vector3(2.0, -3.0, 0.0), new Vector3(0.0, 1.0, 0.0));
		assertTrue(m.right() == new Vector3(1.0, 0.0, 0.0));
		assertTrue(m.up() == new Vector3(0.0, 1.0, 0.0));
		assertTrue(m.forward() == new Vector3(0.0, 0.0, 1.0));
		
		// Indexing
		m = Matrix4x4.LookAt(new Vector3(2.0, 3.4, 7.5), new Vector3(28.0, 39.4, 71.5), new Vector3(1.0, 0.0, 0.0)); 
		assertTrue(m.m03 == m.get(0, 3) && m.m22 == m.get(2, 2) && m[5] == m.m11);
	}
    
    public function testQuaternionToMatrix()
    {
        function createMatrixPair(unitAngle:Float, axis:Int)
        {
            var axes = [Vector3.xAxis, Vector3.yAxis, Vector3.zAxis];
            var const = [Matrix3x3.RotationX, Matrix3x3.RotationY, Matrix3x3.RotationZ];
            var angle = unitAngle * 360.0;
            var q = Quaternion.FromAxisAngle(angle, axes[axis]);
            var n = q.matrix;
            var m = const[axis](angle);
            
            return { m: m, n: n }
        }
        
        for (axis in 0...3)
        {
            var unitAngle:Float = 0.0;
            
            for (i in 0...10)
            {
                unitAngle += 0.01;
                var totalLength = 0.0;
                
                for (c in 0...3)
                {
                    var pair = createMatrixPair(unitAngle, axis);
                    totalLength += (pair.n.column(c) - pair.m.column(c)).length;
                }
                
                assertApproxEquals(totalLength, 0.0);
            }
        }
    }
    
    public function testQuaternionInverse()
    {
        for (i in 0...10)
        {
            var q = randomQuaternion().normal;
            var qInv = q.clone().applyConjugate();
            
            var p = q * qInv;
            
            assertApproxEquals(1.0, p.w);
            assertApproxEquals(0.0, new Vector3(p.x, p.y, p.z).length);
        }
    }
    
    public function testOrthoNormalize3D()
    {
        for (i in 0...10)
        {
            var u = randomVector3();
            var v = randomVector3();
            var w = randomVector3();
            
            Vector3.OrthoNormalize(u, v, w);
            
            assertApproxEquals(1.0, u.length);
            assertApproxEquals(1.0, v.length);
            assertApproxEquals(1.0, w.length);
            assertApproxEquals(0.0, Vector3.Dot(u, v));
            assertApproxEquals(0.0, Vector3.Dot(u, w));
            assertApproxEquals(0.0, Vector3.Dot(v, w));
            
            assertApproxEquals(0.0, ((u % v) % w).length);
        }
    }
    
    public function testAngles3D()
    {
        assertApproxEquals(Vector3.xAxis.angleWith(Vector3.yAxis), Math.PI / 2.0);
        assertApproxEquals(Vector3.xAxis.angleWith(Vector3.zAxis), Math.PI / 2.0);
        assertApproxEquals(Vector3.yAxis.angleWith(Vector3.zAxis), Math.PI / 2.0);
    }
    
    public function testReflect3D()
    {
        for (i in 0...10)
        {
            var u = randomVector3();
            var v = Vector3.Reflect(u, Vector3.zAxis);
            
            assertEquals(u.x, v.x);
            assertEquals(u.y, v.y);
            assertEquals(-u.z, v.z);
        }
    }
    
    public function testProjectOntoPlane()
    {
        for (i in 0...10)
        {
            var u = randomVector3();
            var normal = randomVector3();
            
            u.projectOntoPlane(normal);
            
            assertApproxEquals(0.0, Vector3.Dot(u, normal));
        }
    }
    
    public function testSlerpMidpointAngle()
    {
        var qA = Quaternion.FromAxisAngle(0, Vector3.zAxis);
        var qB = Quaternion.FromAxisAngle(90, Vector3.zAxis);
        var qC = Quaternion.Slerp(qA, qB, 0.5);
        
        var angleAC = qA.angleWith(qC) * 180.0 / Math.PI;
        var angleCB = qC.angleWith(qB) * 180.0 / Math.PI;
        assertApproxEquals(45.0, angleAC);
        assertApproxEquals(45.0, angleCB);
    }
    
    public function testSlerpMonotonicity()
    {
        for (i in 0...10)
        {
            var qA = randomQuaternion().normalize();
            var qB = randomQuaternion().normalize();
            
            var lastAC = Math.NEGATIVE_INFINITY;
            var lastCB = Math.POSITIVE_INFINITY;
            
            for (step in 1...12)
            {
                var t = step / 12;
                var qC = Quaternion.Slerp(qA, qB, t);
                var angleAC = qA.angleWith(qC) * 180.0 / Math.PI;
                var angleCB = qC.angleWith(qB) * 180.0 / Math.PI;
                
                assertTrue(angleAC > lastAC);
                assertTrue(angleCB < lastCB);
                lastAC = angleAC;
                lastCB = angleCB;
            }
        }
    }
    
    public function testSlerpLargeAngleStability()
    {
        var qA = Quaternion.FromAxisAngle(0, Vector3.zAxis);
        var qB = Quaternion.FromAxisAngle(180, Vector3.zAxis);
        var qC = Quaternion.Slerp(qA, qB, 0.5);
        
        assertApproxEquals(90, qC.angleWith(qA) * 180.0 / Math.PI);
    }
    
    public function testSlerpSmallAngleStability()
    {
        var qA = Quaternion.FromAxisAngle(0, Vector3.zAxis);
        var qB = Quaternion.FromAxisAngle(1e-2, Vector3.zAxis);
        var qC = Quaternion.Slerp(qA, qB, 0.5);
        
        assertTrue(qA.angleWith(qC) <= 1e-2);
    }
	
	
}