package bakeneko.math;

/**
 * Vector2 underlying type.
 */
@:noCompletion
class Vector2Base {
    public var x:Float;
    public var y:Float;

    public inline function new(x:Float, y:Float) {
        this.x = x;
        this.y = y;
    }

    public inline function toString():String {
        return '{x: $x, y: $y}';
    }
}

/**
 * 2D vector type
 */
@:forward(x, y)
abstract Vector2(Vector2Base) from Vector2Base to Vector2Base {

    // The number of elements in this structure
    public static inline var elementCount:Int = 2;

    // Zero vector (0, 0)
    public static var zero(get, never):Vector2;

	// Unit vector (1, 1)
	public static var one(get, never):Vector2;

    // X axis (1, 0)
    public static var xAxis(get, never):Vector2;

    // Y axis (0, 1)
    public static var yAxis(get, never):Vector2;

    // Magnitude
    public var length(get, set):Float;

    // Vector dotted with itself
    public var lengthSq(get, never):Float;

    // The angle between this vector and the X axis
    public var angle(get, set):Float;

    // The normalized vector
    public var normal(get, never):Vector2;

    /**
     * Constructor.
     *
     * @param x
     * @param y
     */
    public inline function new(x:Float = 0.0, y:Float = 0.0) {
        this = new Vector2Base(x, y);
    }

	/**
	 * Set this vector with the given components
	 * @param	x
	 * @param	y
	 * @return	this vector
	 */
	public inline function set(x:Float, y:Float):Vector2 {
		this.x = x;
		this.y = y;

		return this;
	}

    /**
     * Construct a Vector2 from an array.
     *
     * @param rawData   The input array.
     * @return          The constructed structure.
     */
    public static inline function FromArray(rawData:Array<Float>):Vector2 {
        if (rawData.length != Vector2.elementCount)
        {
            throw "Invalid rawData.";
        }

        return new Vector2(rawData[0], rawData[1]);
    }

    /**
     * Create a new Vector2 from polar coordinates.
     * Example angle-to-vector direction conversions:
     *   0       radians -> +X axis
     *   (1/2)pi radians -> +Y axis
     *   pi      radians -> -X axis
     *   (3/2)pi radians -> -Y axis
     *
     * @param angle     The angle of the vector (counter-clockwise from the +X axis) in radians.
     * @param radius    The length of the vector.
     * @return          The vector.
     */
    public static inline function FromPolar(angle:Float, radius:Float):Vector2 {
        return new Vector2(radius * Math.cos(angle), radius * Math.sin(angle));
    }

	/**
     * Add two vectors.
     *
     * @param a
     * @param b
     * @return      a + b
     */
    @:op(A + B)
    public static inline function Add(a:Vector2, b:Vector2):Vector2 {
        return a.clone().add(b);
    }

    /**
     * Subtract one vector from another.
     *
     * @param a
     * @param b
     * @return      a - b
     */
    @:op(A - B)
    public static inline function Subtract(a:Vector2, b:Vector2):Vector2 {
        return a.clone().subtract(b);
    }

	/**
	 * Multiply vectors
	 */
    @:op(A * B)
	public static inline function Multiply(a:Vector2, b:Vector2):Vector2 {
		return a.clone().multiply(b);
	}

	/**
	 * Divide vectors
	 */
    @:op(A / B)
	public static inline function Divide(a:Vector2, b:Vector2):Vector2 {
		return a.clone().divide(b);
	}

    /**
     * Dot product.
     *
     * @param a
     * @param b
     * @return      sum_i (a_i * b_i)
     */
    public static inline function Dot(a:Vector2, b:Vector2):Float {
        return (a.x * b.x) + (a.y * b.y);
    }

    /**
     * Multiply a scalar with a vector.
     *
     * @param a
     * @param s
     * @return      s * a
     */
    @:op(A * B)
    @:commutative
    public static inline function MultiplyScalar(a:Vector2, s:Float):Vector2 {
        return a.clone().multiplyScalar(s);
    }

    /**
     * Divide a vector by a scalar.
     *
     * @param s
     * @param a
     * @return      a / s
     */
    @:op(A / B)
    public static inline function DivideScalar(a:Vector2, s:Float):Vector2 {
        return a.clone().divideScalar(s);
    }

    /**
     * Create a negated copy of a vector.
     *
     * @param a
     * @return      -a
     */
    @:op(-A)
    public static inline function Negate(a:Vector2):Vector2 {
        return new Vector2(-a.x, -a.y);
    }

    /**
     * Test element-wise equality between two vectors.
     * False if one of the inputs is null and the other is not.
     *
     * @param a
     * @param b
     * @return     a_i == b_i
     */
    @:op(A == B)
    public static inline function Equals(a:Vector2, b:Vector2):Bool {
        return (a == null && b == null) ||
            a != null &&
            b != null &&
            a.x == b.x &&
            a.y == b.y;
    }

    /**
     * Linear interpolation between two vectors.
     *
     * @param a     The value at t = 0
     * @param b     The value at t = 1
     * @param t     A number in the range [0, 1]
     * @return      The interpolated value
     */
    public static inline function Lerp(a:Vector2, b:Vector2, t:Float):Vector2 {
        return new Vector2((1.0 - t) * a.x + t * b.x, (1.0 - t) * a.y + t * b.y);
    }

    /**
     * Returns a vector built from the componentwise max of the input vectors.
     *
     * @param a
     * @param b
     * @return      max(a_i, b_i)
     */
    public static inline function Max(a:Vector2, b:Vector2):Vector2 {
        return a.clone().max(b);
    }

    /**
     * Returns a vector built from the componentwise min of the input vectors.
     *
     * @param a
     * @param b
     * @return      min(a_i, b_i)
     */
    public static inline function Min(a:Vector2, b:Vector2):Vector2 {
        return a.clone().min(b);
    }

    /**
     * Returns a vector resulting from this vector projected onto the specified vector.
     *
     * @param a
     * @param b
     * @return      (dot(self, a) / dot(a, a)) * a
     */
    public static inline function Project(a:Vector2, b:Vector2):Vector2 {
        return a.clone().projectOnto(b);
    }

    /**
     * Returns a vector resulting from reflecting a vector around the specified normal.
     *
     * @param a
     * @param b
     * @return       v - 2.0 * proj(v, normal)
     */
    public static inline function Reflect(v:Vector2, normal:Vector2):Vector2 {
        return v.clone().reflectBy(normal);
    }

    /**
     * Ortho-normalize a set of vectors in place using the Gram-Schmidt process.
     *
     * @param u
     * @param v
     */
    public static inline function OrthoNormalize(u:Vector2, v:Vector2):Void {
        u.normalize();

        v.subtract(Vector2.Project(v, u));
        v.normalize();
    }

    /**
     * Multiply a vector with a scalar in place.
     * Note: *= operator on Haxe abstracts does not behave this way (a new object is returned).
     *
     * @param a
     * @return      this *= s
     */
    public inline function multiplyScalar(s:Float):Vector2 {

        this.x *= s;
        this.y *= s;

        return this;
    }

    /**
     * Divide a vector by a scalar in place.
     * Note: /= operator on Haxe abstracts does not behave this way (a new object is returned).
     *
     * @param a
     * @return      this /= s
     */
    public inline function divideScalar(s:Float):Vector2 {
        this.x /= s;
        this.y /= s;

        return this;
    }

    /**
     * Add with a given vector
     * Note: += operator on Haxe abstracts does not behave this way (a new object is returned).
     *
     * @param a
     * @return      this += a_i
     */
    public inline function add(a:Vector2):Vector2 {
        this.x += a.x;
        this.y += a.y;

        return this;
    }

    /**
     * Subtract with a given vector
     * Note: -= operator on Haxe abstracts does not behave this way (a new object is returned).
     *
     * @param a
     * @return      this -= a_i
     */
    public inline function subtract(a:Vector2):Vector2 {
        this.x -= a.x;
        this.y -= a.y;

        return this;
    }

	/**
	 * Multiply with a given vector
	 * @param	a
	 * @return
	 */
	public inline function multiply(a:Vector2):Vector2 {
		this.x *= a.x;
		this.y *= a.y;

		return this;
	}

	/**
	 * Multiply with a given vector
	 * @param	a
	 * @return
	 */
	public inline function divide(a:Vector2):Vector2 {
		this.x /= a.x;
		this.y /= a.y;

		return this;
	}

    /**
     * Returns a vector built from the componentwise max of this vector and another.
     *
     * @param a
     * @param b
     * @return      this = max(this, a_i)
     */
    public inline function max(a:Vector2):Vector2 {
        this.x = Math.max(this.x, a.x);
        this.y = Math.max(this.y, a.y);

        return this;
    }

    /**
     * Returns a vector built from the componentwise min of this vector and another.
     *
     * @param a
     * @param b
     * @return      this = min(this, a_i)
     */
    public inline function min(a:Vector2):Vector2 {
        this.x = Math.min(this.x, a.x);
        this.y = Math.min(this.y, a.y);

        return this;
    }

    /**
     * Returns a vector resulting from this vector projected onto the specified vector.
     *
     * @param a
     * @return      self = (dot(self, a) / dot(a, a)) * a
     */
    public inline function projectOnto(a:Vector2):Vector2 {
		var self:Vector2 = this;

		var s:Float = Vector2.Dot(self, a) / Vector2.Dot(a, a);

        // Set self = s * a without allocating
        a.copyTo(self);
        self.multiplyScalar(s);

        return self;
    }

    /**
     * Returns a vector resulting from reflecting this vector around the specified normal.
     *
     * @param normal
     * @return          self = self - 2.0 * proj(self, normal)
     */
    public inline function reflectBy(normal:Vector2):Vector2 {
        var self:Vector2 = this;

        var projected:Vector2 = Vector2.Project(self, normal);
        projected.multiplyScalar(2.0);

        self.subtract(projected);

        return self;
    }

    /**
     * Copy the contents of this structure to another.
     * Faster than copyToShape for static platforms (C++, etc) but requires the target to have the exact same inner type.
     *
     * @param target    The target structure.
     */
    public inline function copyTo(target:Vector2):Void {
        var self:Vector2 = this;

        for (i in 0...Vector2.elementCount)
        {
            target[i] = self[i];
        }
    }

    /**
     * Clone.
     *
     * @return  The cloned object.
     */
    public inline function clone():Vector2 {
        return new Vector2(this.x, this.y);
    }

    /**
     * Get an element by position.
     *
     * @param i         The element index.
     * @return          The element.
     */
    @:arrayAccess
    public inline function getArrayElement(i:Int):Float {
        switch (i)
        {
            case 0:
                return this.x;
            case 1:
                return this.y;
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
        switch (i)
        {
            case 0:
                return this.x = value;
            case 1:
                return this.y = value;
            default:
                throw "Invalid element";
        }
    }

    /**
     * Negate vector in-place.
     *
     * @return  The modified object.
     */
    public inline function applyNegate():Vector2 {
        this.x = -this.x;
        this.y = -this.y;

        return this;
    }

    /**
     * Apply a scalar function to each element.
     *
     * @param func  The function to apply.
     * @return      The modified object.
     */
    public inline function applyScalarFunc(func:Float->Float):Vector2 {
        var self:Vector2 = this;

        for (i in 0...elementCount)
        {
            self[i] = func(self[i]);
        }

        return self;
    }

    /**
     * Find the arccosine of the angle between two vectors.
     *
     * @param b     The other vector.
     * @return      The arccosine angle between this vector and the other in radians.
     */
    public inline function angleWith(b:Vector2):Float {
        var self:Vector2 = this;
        return Math.acos(Vector2.Dot(self, b) / (self.length * b.length));
    }

    /**
     * Find the signed angle between two vectors.
     *
     * If the other vector is in the left halfspace of this vector (e.g. the shortest angle to align
     * this vector with the other is ccw) then the result is positive.
     *
     * If the other vector is in the right halfspace of this vector (e.g. the shortest angle to align
     * this vector with the other is cw) then the result is negative.
     *
     * @param b     The other vector.
     * @return      The signed angle between this vector and the other in radians.
     */
    public inline function signedAngleWith(b:Vector2):Float {

        // Compensate for the range of arcsine [-pi/2, pi/2) by using arccos [0, pi) to do the actual angle calculation
        // and the sine (from the determinant) to calculate the sign.

        // sign(|a b|) = sign(sin(angle)) = sign(angle)
        return MathUtil.sign(MathUtil.det2x2(this.x, b.x, this.y, b.y)) * angleWith(b);
    }

    /**
     * Get the distance between this vector and another.
     *
     * @param b
     * @return      |self - b|
     */
    public inline function distanceTo(b:Vector2):Float {
        var self:Vector2 = this;

        return (self - b).length;
    }

    /**
     * Normalize this vector.
     *
     * @return  The modified object.
     */
    public inline function normalize():Vector2 {
        var self:Vector2 = this;

        var length = self.length;

        if (length > 0.0)
        {
            self.divideScalar(length);
        }

        return self;
    }

    /**
     * Normalize this vector and scale it to the specified length.
     *
     * @param newLength     The new length to normalize to.
     * @return              The modified object.
     */
    public inline function normalizeTo(newLength:Float):Vector2 {
        var self:Vector2 = this;

        self.normalize();
        self.multiplyScalar(newLength);

        return self;
    }

    /**
     * Clamp this vector's length to the specified range.
     *
     * @param min   The min length.
     * @param max   The max length.
     * @return      The modified object.
     */
    public inline function clamp(min:Float, max:Float):Vector2 {
        var self:Vector2 = this;

        var length = self.length;

        if (length < min)
        {
            self.normalizeTo(min);
        }
        else if (length > max)
        {
            self.normalizeTo(max);
        }

        return self;
    }

    /**
     * Rotate this point counter-clockwise around a pivot point.
     *
     * @param angle     The signed angle in radians.
     * @param pivot     The pivot point to rotate around.
     * @return          The modified object.
     */
    public inline function rotate(angle:Float, pivot:Vector2):Vector2 {
        var self:Vector2 = this;

        var cos = Math.cos(angle);
        var sin = Math.sin(angle);
        var dx = self.x - pivot.x;
        var dy = self.y - pivot.y;

        self.x = dx * Math.cos(angle) - dy * Math.sin(angle);
        self.y = dx * Math.sin(angle) + dy * Math.cos(angle);

        return self;
    }

    /**
     * Rotate this vector by 90 degrees to the left/counterclockwise.
     *
     * @return  The modified object. (-y, x)
     */
    public inline function rotateLeft():Vector2 {

        var newX = -this.y;
        this.y = this.x;
        this.x = newX;

        return this;
    }

    /**
     * Rotate this vector by 90 degrees to the right/clockwise.
     *
     * @return  The modified object. (y, -x)
     */
    public inline function rotateRight():Vector2 {

        var newX = this.y;
        this.y = -this.x;
        this.x = newX;

        return this;
    }

    private static inline function get_zero():Vector2 {
        return new Vector2(0.0, 0.0);
    }

	private static inline function get_one():Vector2 {
        return new Vector2(1.0, 1.0);
    }

    private static inline function get_xAxis():Vector2 {
        return new Vector2(1.0, 0.0);
    }

    private static inline function get_yAxis():Vector2 {
        return new Vector2(0.0, 1.0);
    }

    private inline function get_length():Float {
        return Math.sqrt((this.x * this.x) + (this.y * this.y));
    }

	private inline function set_length(newLength:Float):Float {
		normalize().multiplyScalar(newLength);
        return newLength;
    }

    private inline function get_lengthSq():Float {
        return (this.x * this.x) + (this.y * this.y);
    }

    private inline function get_angle():Float {
        return Math.atan2(this.y, this.x);
    }

	private inline function set_angle(angle:Float):Float {
		var self:Vector2 = this;

		var len:Float = self.length;

		self.x = Math.cos(angle) * len;
		self.y = Math.sin(angle) * len;

        return angle;
    }

    private inline function get_normal():Vector2 {
		var self:Vector2 = this;
        return self.clone().normalize();
    }

}

