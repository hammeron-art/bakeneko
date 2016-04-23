package bakeneko.math;
import haxe.ds.Vector;
import bakeneko.backend.buffer.Float32Array;

/**
 * The underlying type of Quaternion
 */
class QuaternionBase {
    public var q:Float32Array;

    public function new(w:Float, x:Float, y:Float, z:Float) {
		q = new Float32Array(4);

        q[0] = x;
        q[1] = y;
        q[2] = z;
		q[3] = w;
    }

    public function toString():String {
        return '[${q[3]}, (${q[0]}, ${q[1]}, ${q[2]})]';
    }
}

/**
 * Quaternion for rotation in 3D.
 */
@:forward(q)
abstract Quaternion(QuaternionBase) from QuaternionBase to QuaternionBase {

	// Elements
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;
	public var w(get, set):Float;

    // The number of elements in this structure
    public static inline var elementCount:Int = 4;

    // Zero quaternion (q + 0 = 0, q * 0 = 0)
    public static var zero(get, never):Quaternion;

    // One/identity quaternion (q * 1 = q)
    public static var identity(get, never):Quaternion;

    // Gets the corresponding rotation matrix
    public var matrix(get, never):Matrix3x3;

    // Magnitude
    public var length(get, never):Float;

    // Quaternion dotted with itself
    public var lengthSq(get, never):Float;

    // The normalized quaternion
    public var normal(get, never):Quaternion;

    /**
     * Constructor.
     *
     * @param w     Scalar (real) part.
     * @param x     Vector (complex) part x component.
     * @param y     Vector (complex) part y component.
     * @param z     Vector (complex) part z component
     */
    public inline function new(w:Float = 1.0, x:Float = 0.0, y:Float = 0.0, z:Float = 0.0) {
        this = new QuaternionBase(w, x, y, z);
    }

    /**
     * Construct a Quaternion from an array.
     *
     * @param rawData   The input array.
     * @return          The constructed structure.
     */
    public static inline function FromArray(rawData:Array<Float>):Quaternion {
        if (rawData.length != Quaternion.elementCount) {
            throw "Invalid rawData.";
        }

        return new Quaternion(rawData[0], rawData[1], rawData[2], rawData[3]);
    }

    /**
     * Create a quaternion from an axis-angle pair.
     *
     * @param angleDegrees  The angle to rotate
     * @param axis          The axis to rotate around.
     * @return              The quaternion.
     */
    public static inline function FromAxisAngle(axis:Vector3, angle:Float):Quaternion {
        var cosHalfAngle = Math.cos(angle * 0.5);
        var sinHalfAngle = Math.sin(angle * 0.5);

        return new Quaternion(
            cosHalfAngle,
            sinHalfAngle * axis.x,
            sinHalfAngle * axis.y,
            sinHalfAngle * axis.z);
    }

	public static inline function FromEulerAxis(xAxis:Vector3, yAxis:Vector3, zAxis:Vector3):Quaternion {
		var rotation:Matrix4x4 = new Matrix4x4();

		rotation.m[0] = xAxis.x;
		rotation.m[1] = xAxis.y;
		rotation.m[2] = xAxis.z;

		rotation.m[4] = yAxis.x;
		rotation.m[5] = yAxis.y;
		rotation.m[6] = yAxis.z;

		rotation.m[8] = zAxis.x;
		rotation.m[9] = zAxis.y;
		rotation.m[10] = zAxis.z;

		return FromMatrix(rotation);
	}

	/**
	 * Algorithm in Ken Shoemake's article in 1987
	 * SIGGRAPH course notes article "Quaternion Calculus and Fast Animation"
	 *
	 * @param	rotation
	 */
	public static inline function FromMatrix(rotation:Matrix4x4) {
		var result = new Quaternion();

		var trace = rotation.m[0] + rotation.m[5] + rotation.m[10];
		var root:Float = 0.0;

		if (trace > 0) {
			root = Math.sqrt(trace + 1);
			result.w = 0.5 * root;
			root = 0.5 / root;
			result.x = (rotation.m[6] - rotation.m[9]) * root;
			result.y = (rotation.m[8] - rotation.m[2]) * root;
			result.z = (rotation.m[1] - rotation.m[4]) * root;
		} else {
			var iNext = new haxe.ds.Vector(3);
			iNext[0] = 1;
			iNext[1] = 2;
			iNext[2] = 0;

			var i = 0;

			if (rotation.m[5] > rotation.m[0]) {
				i = 1;
			}
			if (rotation.m[10] > rotation.get(i, i)) {
				i = 2;
			}
			var j = iNext[i];
			var k = iNext[j];

			root = Math.sqrt(rotation.get(i, i) - rotation.get(j, j) - rotation.get(k, k) + 1);

			result.q[i] = 0.5 * root;
			root = 0.5 / root;
			result.w = (rotation.get(j, k) - rotation.get(k, j)) * root;
			result.q[j] = (rotation.get(j, i) + rotation.get(i, j)) * root;
			result.q[k] = (rotation.get(k, i) + rotation.get(i, k)) * root;

			trace(rotation.get(j, k), rotation.get(k, j), root, (rotation.get(j, k) - rotation.get(k, j)), result.w);
		}

		return result;
	}

	//TODO: Change underlying type to haxe.ds.Vector and optimize this
	public inline function get(index:Int) {
		if (index == 0)
			return x;
		if (index == 1)
			return y;

		return z;
	}

    /**
     * Multiply a (real) scalar with a quaternion.
     *
     * @param a
     * @param s
     * @return      s * a
     */
    @:op(A * B)
    @:commutative
    public static inline function MultiplyScalar(a:Quaternion, s:Float):Quaternion {
        return a.clone().multiplyWithScalar(s);
    }

    /**
     * Multiply two quaternions.
     *
     * @param a
     * @param b
     * @return      a * b
     */
    @:op(A * B)
    public static inline function Multiply(a:Quaternion, b:Quaternion):Quaternion {
        return new Quaternion(
            a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
            a.w * b.x + b.w * a.x + a.y * b.z - a.z * b.y,
            a.w * b.y + b.w * a.y + a.z * b.x - a.x * b.z,
            a.w * b.z + b.w * a.z + a.x * b.y - a.y * b.x);
    }

    /**
     * Add two quaternions.
     *
     * @param a
     * @param b
     * @return      a + b
     */
    @:op(A + B)
    public static inline function Add(a:Quaternion, b:Quaternion):Quaternion {
        return a.clone().add(b);
    }

    /**
     * Subtract one quaternion from another.
     *
     * @param a
     * @param b
     * @return      a - b
     */
    @:op(A - B)
    public static inline function Subtract(a:Quaternion, b:Quaternion):Quaternion {
        return a.clone().subtract(b);
    }

    /**
     * Create a complex conjugate copy of a quaternion (complex/vector portion is negated).
     *
     * @param a
     * @return      a*
     */
    @:op(~A)
    public static inline function Conjugate(a:Quaternion):Quaternion {
        return new Quaternion(a.w, -a.x, -a.y, -a.z);
    }

    /**
     * Create a negated copy of a quaternion.
     *
     * @param a
     * @return      -a
     */
    @:op(-A)
    public static inline function Negate(a:Quaternion):Quaternion {
        return new Quaternion(-a.w, -a.x, -a.y, -a.z);
    }

    /**
     * Test element-wise equality between two quaternions.
     * False if one of the inputs is null and the other is not.
     *
     * @param a
     * @param b
     * @return     a_i == b_i
     */
    @:op(A == B)
    public static inline function Equals(a:Quaternion, b:Quaternion):Bool {
        return (a == null && b == null) ||
            a != null &&
            b != null &&
            a.w == b.w &&
            a.x == b.x &&
            a.y == b.y &&
            a.z == b.z;
    }

    /**
     * Linear interpolation between two quaternions.
     *
     * @param a     The value at t = 0
     * @param b     The value at t = 1
     * @param t     A number in the range [0, 1]
     * @return      The interpolated value
     */
    public static inline function Lerp(a:Quaternion, b:Quaternion, t:Float):Quaternion {
        return (1.0 - t)*a + t*b;
    }

    public static inline function Slerp(a:Quaternion, b:Quaternion, t:Float):Quaternion {
        var cosHalfTheta = Quaternion.dot(a, b);

        // If the two quaternions are nearly the same return the first one
        if (Math.abs(cosHalfTheta) >= 1.0) {
            return a;
        }

        var halfTheta = Math.acos(cosHalfTheta);
        var sinHalfTheta = Math.sqrt(1.0 - cosHalfTheta * cosHalfTheta);

        // Do not slerp if the result is ill-defined (a large angle near 180 degrees)
        if (Math.abs(sinHalfTheta) < 1e-3) {
            return Quaternion.Lerp(a, b, t).normalize();
        }

        var ta = Math.sin((1 - t) * halfTheta) / sinHalfTheta;
        var tb = Math.sin(t * halfTheta) / sinHalfTheta;

        var result:Quaternion = Quaternion.get_zero();

        result.x = a.x * ta + b.x * tb;
        result.y = a.y * ta + b.y * tb;
        result.z = a.z * ta + b.z * tb;
        result.w = a.w * ta + b.w * tb;

        return result;
    }

    /**
     * Dot product.
     *
     * @param a
     * @return      sum_i (a_i * b_i)
     */
    public static inline function dot(a:Quaternion, b:Quaternion):Float {
        return a.w * b.w +
            a.x * b.x +
            a.y * b.y +
            a.z * b.z;
    }

    /**
     * Create an inverted copy.
     *
     * @return  The inverse.
     */
    public inline function invert():Quaternion {
        var self:Quaternion = this;

        return self.clone().applyInvert();
    }

    /**
     * Multiply a quaternion with a scalar in place.
     * Note: *= operator on Haxe abstracts does not behave this way (a new object is returned).
     *
     * @param a
     * @return      self_i *= s
     */
    public inline function multiplyWithScalar(s:Float):Quaternion {
        var self:Quaternion = this;

        self.w *= s;
        self.x *= s;
        self.y *= s;
        self.z *= s;

        return self;
    }
	
	public inline function multiply(b:Quaternion):Quaternion {
		var self:Quaternion = this;
		
        self.w = self.w * b.w - self.x * b.x - self.y * b.y - self.z * b.z;
        self.x = self.w * b.x + b.w * self.x + self.y * b.z - self.z * b.y;
        self.y = self.w * b.y + b.w * self.y + self.z * b.x - self.x * b.z;
        self.z = self.w * b.z + b.w * self.z + self.x * b.y - self.y * b.x;
		
		return self;
	}

    /**
     * Add a quaternion in place.
     * Note: += operator on Haxe abstracts does not behave this way (a new object is returned).
     *
     * @param a
     * @return      self_i += a_i
     */
    public inline function add(a:Quaternion):Quaternion {
        var self:Quaternion = this;

        self.w += a.w;
        self.x += a.x;
        self.y += a.y;
        self.z += a.z;

        return self;
    }

    /**
     * Subtract a quaternion in place.
     * Note: -= operator on Haxe abstracts does not behave this way (a new object is returned).
     *
     * @param a
     * @return      self_i -= a_i
     */
    public inline function subtract(a:Quaternion):Quaternion {
        var self:Quaternion = this;

        self.w -= a.w;
        self.x -= a.x;
        self.y -= a.y;
        self.z -= a.z;

        return self;
    }

    /**
     * Copy the contents of this structure to another.
     * Faster than copyToShape for static platforms (C++, etc) but requires the target to have the exact same inner type.
     *
     * @param target    The target structure.
     */
    public inline function copyTo(target:Quaternion):Void {
        var self:Quaternion = this;

        for (i in 0...Quaternion.elementCount)
        {
            target[i] = self[i];
        }
    }

    /**
     * Clone.
     *
     * @return  The cloned object.
     */
    public inline function clone():Quaternion {
        var self:Quaternion = this;
        return new Quaternion(self.w, self.x, self.y, self.z);
    }

    /**
     * Get an element by position.
     *
     * @param i         The element index.
     * @return          The element.
     */
    @:arrayAccess
    public inline function getArrayElement(i:Int):Float {
        var self:Quaternion = this;
        switch (i) {
            case 0:
                return self.w;
            case 1:
                return self.x;
            case 2:
                return self.y;
            case 3:
                return self.z;
            default:
                throw "Invalid element";
        }
    }

    /**
     * Set an element by position.
     *
     * @param i         The element index.
     * @param value     The new value.
     * @return          The updated element.
     */
    @:arrayAccess
    public inline function setArrayElement(i:Int, value:Float):Float {
        var self:Quaternion = this;
        switch (i) {
            case 0:
                return self.w = value;
            case 1:
                return self.x = value;
            case 2:
                return self.y = value;
            case 3:
                return self.z = value;
            default:
                throw "Invalid element";
        }
    }

    /**
     * Apply a scalar function to each element.
     *
     * @param func  The function to apply.
     * @return      The modified object.
     */
    public inline function applyScalarFunc(func:Float->Float):Quaternion {
        var self:Quaternion = this;

        for (i in 0...elementCount) {
            self[i] = func(self[i]);
        }

        return self;
    }

    /**
     * Get the log for the quaternion.
     *
     * @return  log(q) == [0, theta/sin(theta) * v]
     */
    public inline function log():Quaternion {
        var self:Quaternion = this;
        var theta = Math.acos(self.w);
        var sinTheta = Math.sin(theta);

        // Avoid division by zero
        if (sinTheta > 0.0) {
            var k = theta / sinTheta;
            return new Quaternion(0.0, k * self.x, k * self.y, k * self.z);
        } else {
            return Quaternion.zero;
        }
    }

    /**
     * Get the exponential for the quaternion.
     *
     * @return  exp(q) == [cos(theta), v * sin(theta)]
     */
    public inline function exp():Quaternion {
        var self:Quaternion = this;
        var theta = Math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
        var sinTheta = Math.sin(theta);
        var cosTheta = Math.cos(theta);

        // Avoid division by zero
        if(theta > 0.0) {
            return new Quaternion(cosTheta, sinTheta * self.x, sinTheta * self.y, sinTheta * self.z);
        } else {
            return new Quaternion(cosTheta, 0, 0, 0);
        }
    }

    /**
     * Rotate the given vector, assuming the current quaternion is normalized (if not, normalize first).
     *
     * @param u     The vector to rotate.
     * @return      The rotated vector.
     */
    public inline function rotate(u:Vector3):Vector3 {
        // Calculate qvq'
        var self:Quaternion = this;

        var a = 2.0 * (self.x * u.x + self.y * u.y + self.z * u.z);
        var b = self.w * self.w - self.x * self.x - self.y * self.y - self.z * self.z;
        var c = 2.0 * self.w;

        return new Vector3(
            a * self.x + b * u.x + c * (self.y * u.z - self.z * u.y),
            a * self.y + b * u.y + c * (self.z * u.x - self.x * u.z),
            a * self.z + b * u.z + c * (self.x * u.y - self.y * u.x));
    }

    /**
     * Find the arccosine of the angle between two quaternions.
     *
     * @param b     The other quaternion.
     * @return      The arccosine angle between this vector and the other in radians.
     */
    public inline function angleWith(b:Quaternion):Float {
        var self:Quaternion = this;
        return 2.0 * Math.acos(Quaternion.dot(self, b) / (self.length * b.length));
    }

    /**
     * Normalize the quaternion in-place.
     *
     * @return  The modified object.
     */
    public inline function normalize():Quaternion {
        var self:Quaternion = this;
        var length = self.length;

        if (length > 0.0) {
            var k = 1.0 / length;
            self.multiplyWithScalar(k);
        }

        return self;
    }

    /**
     * Conjugate the quaternion in-place.
     *
     * @return  The modified object.
     */
    public inline function applyConjugate():Quaternion {
        var self:Quaternion = this;

        self.x = -self.x;
        self.y = -self.y;
        self.z = -self.z;

        return self;
    }

    /**
     * Invert the quaternion in-place. Useful when the quaternion may have been denormalized.
     *
     * @return  The modified object.
     */
    public inline function applyInvert():Quaternion {
        var self:Quaternion = this;

        return self.applyConjugate().normalize();
    }

	private inline function get_x():Float {
		return this.q[0];
	}

	private inline function get_y():Float {
		return this.q[1];
	}

	private inline function get_z():Float {
		return this.q[2];
	}

	private inline function get_w():Float {
		return this.q[3];
	}

	private inline function set_x(value:Float) {
		this.q[0] = value;
		return this.q[0];
	}

	private inline function set_y(value:Float) {
		this.q[1] = value;
		return this.q[1];
	}

	private inline function set_z(value:Float) {
		this.q[2] = value;
		return this.q[2];
	}

	private inline function set_w(value:Float) {
		this.q[3] = value;
		return this.q[3];
	}

    private static inline function get_zero():Quaternion {
        return new Quaternion(0, 0, 0, 0);
    }

    private static inline function get_identity():Quaternion {
        return new Quaternion(1, 0, 0, 0);
    }

    private inline function get_length():Float {
        var self:Quaternion = this;
        return Math.sqrt(Quaternion.dot(self, self));
    }

    private inline function get_lengthSq():Float {
        var self:Quaternion = this;
        return Quaternion.dot(self, self);
    }

    private inline function get_matrix():Matrix3x3 {
        var self:Quaternion = this;

        var s = self.w;
        var x = self.x;
        var y = self.y;
        var z = self.z;

        var m = new Matrix3x3(
            1 - 2 * (y * y + z * z), 2 * (x * y - s * z), 2 * (s * y + x * z),
            2 * (x * y + s * z), 1 - 2 * (x * x + z * z), 2 * (y * z - s * x),
            2 * (x * z - s * y), 2 * (y * z + s * x),  1 - 2 * (x * x + y * y));

        return m;
    }

    private inline function get_normal():Quaternion {
        var self:Quaternion = this;
        return (1.0 / self.length) * self;
    }
}