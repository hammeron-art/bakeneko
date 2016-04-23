package tests.unit;

import haxe.PosInfos;
import haxe.unit.TestCase;

import bakeneko.math.Vector2;
import bakeneko.math.Vector3;
import bakeneko.math.Vector4;
import bakeneko.math.Matrix2x2;
import bakeneko.math.Matrix3x2;
import bakeneko.math.Matrix3x3;
import bakeneko.math.Matrix4x4;
import bakeneko.math.Quaternion;

/**
 * ...
 * @author Hammer On Art
 */
class BakenekoTestCase extends TestCase {
	
	private function assertApproxEquals(expected:Float, actual:Float, tolerance:Float=1e-6, ?p:PosInfos) {
        if (Math.abs(expected - actual) < tolerance) {
            success(p);
        }
        else {
            fail('expected $expected +-$tolerance but was $actual', p);
        }
    }
	
	private function success(info:PosInfos) {
		assertTrue(true);
	}
	
	private function fail(message:String, info:PosInfos) {
		assertTrue(false);
		
		if (info != null)
			trace(info);
	}
	
	private function randomFloat(center:Float=0.0, width:Float = 1.0, precision:Float=1e-4)
    {
        // Generate a float in the range [center - width/2, center + width/2)
        var x = (Math.random() - 0.5) * width + center;
        
        // Round the the specified precision
        return Math.floor(x / precision) * precision;
    }
    
    private function randomArray(size:Int, distribution:Distribution=null):Array<Float>
    {
        var data = new Array<Float>();
        var distribution = distribution == null ? new Distribution() : distribution;
        
        for (i in 0...size)
        {
            data.push(randomFloat(distribution.center, distribution.width, distribution.precision));
        }
        
        return data;
    }
	
	private function randomVector2(precision:Float = 1e-4):Vector2 {
        var distribution = new Distribution();
        distribution.precision = precision;
        return Vector2.FromArray(randomArray(Vector2.elementCount, distribution));
    }
    
    private function randomVector3(precision:Float = 1e-4):Vector3 {
        var distribution = new Distribution();
        distribution.precision = precision;
        return Vector3.FromArray(randomArray(Vector3.elementCount, distribution));
    }
    
    private function randomVector4(precision:Float = 1e-4):Vector4 {
        var distribution = new Distribution();
        distribution.precision = precision;
        return Vector4.FromArray(randomArray(Vector4.elementCount, distribution));
    }
    
    private function randomMatrix2x2(precision:Float=1e-4):Matrix2x2 {
        var distribution = new Distribution();
        distribution.precision = precision;
        return Matrix2x2.FromArray(randomArray(Matrix2x2.elementCount, distribution));
    }
    
    private function randomMatrix3x2(precision:Float=1e-4):Matrix3x2 {
        var distribution = new Distribution();
        distribution.precision = precision;
        return Matrix3x2.FromArray(randomArray(Matrix3x2.elementCount, distribution));
    }

    private function randomMatrix3x3(precision:Float=1e-4):Matrix3x3 {
        var distribution = new Distribution();
        distribution.precision = precision;
        return Matrix3x3.FromArray(randomArray(Matrix3x3.elementCount, distribution));
    }
    
    private function randomMatrix4x4(precision:Float=1e-4):Matrix4x4 {
        var distribution = new Distribution();
        distribution.precision = precision;
        return Matrix4x4.FromArray(randomArray(Matrix4x4.elementCount, distribution));
    }
    
    private function randomQuaternion(precision:Float=1e-4):Quaternion {
        var distribution = new Distribution();
        distribution.precision = precision;
        return Quaternion.FromArray(randomArray(Quaternion.elementCount, distribution));
    }
}