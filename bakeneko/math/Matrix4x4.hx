package bakeneko.math;

import lime.utils.Float32Array;

// All notations are row-major where the translation components
// Occupy the 13th, 14th and 15th elements of the 16-element matrix
// following the OpenGL specification
// https://www.opengl.org/archives/resources/faq/technical/transformations.htm

/**
 * The underlying type of Matrix4x4.
 */
@:noCompletion
class Matrix4x4Base {
	public var m:Float32Array;

    public inline function new(
        m00:Float, m10:Float, m20:Float, m30:Float,
        m01:Float, m11:Float, m21:Float, m31:Float,
        m02:Float, m12:Float, m22:Float, m32:Float,
        m03:Float, m13:Float, m23:Float, m33:Float)
    {
		m = new Float32Array(16);

        m[0] = m00;
        m[1] = m10;
        m[2] = m20;
        m[3] = m30;

        m[4] = m01;
        m[5] = m11;
        m[6] = m21;
        m[7] = m31;

        m[8] = m02;
        m[9] = m12;
        m[10] = m22;
        m[11] = m32;

        m[12] = m03;
        m[13] = m13;
        m[14] = m23;
        m[15] = m33;
    }

    public inline function toString():String {
        return '[[${m[0]}, ${m[1]}, ${m[2]}, ${m[3]}], [${m[4]}, ${m[5]}, ${m[6]}, ${m[7]}], [${m[8]}, ${m[9]}, ${m[10]}, ${m[11]}], [${m[12]}, ${m[13]}, ${m[14]}, ${m[15]}]]';
    }
}

/**
 * 4x4 matrix for homogenous/projection transformations in 3D.
 */
@:forward(m)
abstract Matrix4x4(Matrix4x4Base) from Matrix4x4Base to Matrix4x4Base {
    // The number of elements in this structure
    public static inline var elementCount:Int = 16;

    // Zero matrix (A + 0 = A, A * 0 = 0)
    public static var zero(get, never):Matrix4x4;

    // Translation column vector
    public var translation(get, set):Vector3;

    // Determinant (the "area" of the basis)
    public var det(get, never):Float;

    // Transpose (columns become rows)
    public var transpose(get, never):Matrix4x4;

    // Get the upper-left sub-matrix
    public var subMatrix(get, never):Matrix3x3;

    /**
     * Constructor. Parameters are in row-major order (when written out the array is ordered like the matrix).
     *
     * @param m00
     * @param m10
     * @param m20
     * @param m30
     * @param m01
     * @param m11
     * @param m21
     * @param m31
     * @param m02
     * @param m12
     * @param m22
     * @param m32
     * @param m03
     * @param m13
     * @param m23
     * @param m33
     */
    public inline function new(
        m00:Float = 1.0, m10:Float = 0.0, m20:Float = 0.0, m30:Float = 0.0,
        m01:Float = 0.0, m11:Float = 1.0, m21:Float = 0.0, m31:Float = 0.0,
        m02:Float = 0.0, m12:Float = 0.0, m22:Float = 1.0, m32:Float = 0.0,
        m03:Float = 0.0, m13:Float = 0.0, m23:Float = 0.0, m33:Float = 1.0)
    {
        this = new Matrix4x4Base(
            m00, m10, m20, m30,
            m01, m11, m21, m31,
            m02, m12, m22, m32,
            m03, m13, m23, m33);
    }

	public inline function set(
        m00:Float = 1.0, m10:Float = 0.0, m20:Float = 0.0, m30:Float = 0.0,
        m01:Float = 0.0, m11:Float = 1.0, m21:Float = 0.0, m31:Float = 0.0,
        m02:Float = 0.0, m12:Float = 0.0, m22:Float = 1.0, m32:Float = 0.0,
        m03:Float = 0.0, m13:Float = 0.0, m23:Float = 0.0, m33:Float = 1.0)
	{
		this.m[0] = m00;
        this.m[1] = m10;
        this.m[2] = m20;
        this.m[3] = m30;

        this.m[4] = m01;
        this.m[5] = m11;
        this.m[6] = m21;
        this.m[7] = m31;

        this.m[8] = m02;
        this.m[9] = m12;
        this.m[10] = m22;
        this.m[11] = m32;

        this.m[12] = m03;
        this.m[13] = m13;
        this.m[14] = m23;
        this.m[15] = m33;
	}

	public inline function identity() {
		set(
			1.0, 0.0, 0.0, 0.0,
			0.0, 1.0, 0.0, 0.0,
			0.0, 0.0, 1.0, 0.0,
			0.0, 0.0, 0.0, 1.0
		);
	}

    /**
     * Construct a Matrix4x4 from an array.
     *
     * @param rawData   The input array.
     * @return          The constructed structure.
     */
    public static inline function FromArray(rawData:Array<Float>):Matrix4x4 {
        if (rawData.length != Matrix4x4.elementCount)
        {
            throw "Invalid rawData.";
        }

        return new Matrix4x4(
            rawData[0],  rawData[1],  rawData[2],  rawData[3],
            rawData[4],  rawData[5],  rawData[6],  rawData[7],
            rawData[8],  rawData[9],  rawData[10], rawData[11],
            rawData[12], rawData[13], rawData[14], rawData[15]);
    }

	// Left hand
	public static inline function CreatePerspective(fov:Float, aspectRatio:Float, near:Float, far:Float):Matrix4x4 {

		var b1 = 1 / Math.tan(fov * 0.5);
		var a0 = b1 / aspectRatio;
		var c2 = (far + near) / (far - near);
		var d2 = -(2 * far * near) / (far - near);

		return new Matrix4x4(
			a0, 0, 0, 0,
			0, b1, 0, 0,
			0, 0, c2, 1,
			0, 0, d2, 0
		);
	}

	// Left hand
	public static inline function CreateOrthographic(width:Float, height:Float, near:Float, far:Float):Matrix4x4 {
		
		var a0 = 2.0 / width;
		var b1 = 2.0 / height;
		var c2 = 2.0 / (far - near);
		var d2 = (far + near) / (near - far);

		return new Matrix4x4(
			a0, 0, 0, 0,
			0, b1, 0, 0,
			0, 0, c2, 0,
			0, 0, d2, 1
		);
	}

	public static inline function CreateFrustum(left:Float, right:Float, bottom:Float, top:Float, near:Float, far:Float):Matrix4x4 {
		var result = new Matrix4x4();

		var tx = 2 * near / (right - left);
		var ty = 2 * near / (top - bottom);

		var a = (right + left) / (right - left);
		var b = (top + bottom) / (top - bottom);
		var c = -(far + near) / (far - near);
		var d = -2 * far * near / (far - near);

		trace('$a, $b, $c, $d');

		return new Matrix4x4(
			tx, 0, 0, 0,
			0, ty, 0, 0,
			a,  b, c, -1,
			0,  0, d, 0
		);
	}

	/**
	 * Return a typed array of this Matrix
	 * @return
	 */
	public inline function float32Array():Float32Array {
		return this.m;
	}

    /**
     * Multiply a matrix with a vector.
     *
     * @param a
     * @param v
     * @return      a * v
     */
    @:op(A * B)
    public static inline function MultiplyVector(a:Matrix4x4, v:Vector4):Vector4 {
        return new Vector4(
            a.m[0] * v.x + a.m[4] * v.y + a.m[8] * v.z + a.m[12] * v.w,
            a.m[1] * v.x + a.m[5] * v.y + a.m[9] * v.z + a.m[13] * v.w,
            a.m[2] * v.x + a.m[6] * v.y + a.m[10] * v.z + a.m[14] * v.w,
            a.m[3] * v.x + a.m[7] * v.y + a.m[11] * v.z + a.m[15] * v.w);
    }

    /**
     * Multiply two matrices.
     *
     * @param a
     * @param b
     * @return      a * b
     */
    @:op(A * B)
    public static inline function Multiply(a:Matrix4x4, b:Matrix4x4):Matrix4x4 {
        return new Matrix4x4(
            a.m[0] * b.m[0] + a.m[1] * b.m[4] + a.m[2] * b.m[8] + a.m[3] * b.m[12],
            a.m[0] * b.m[1] + a.m[1] * b.m[5] + a.m[2] * b.m[9] + a.m[3] * b.m[13],
            a.m[0] * b.m[2] + a.m[1] * b.m[6] + a.m[2] * b.m[10] + a.m[3] * b.m[14],
            a.m[0] * b.m[3] + a.m[1] * b.m[7] + a.m[2] * b.m[11] + a.m[3] * b.m[15],

            a.m[4] * b.m[0] + a.m[5] * b.m[4] + a.m[6] * b.m[8] + a.m[7] * b.m[12],
            a.m[4] * b.m[1] + a.m[5] * b.m[5] + a.m[6] * b.m[9] + a.m[7] * b.m[13],
            a.m[4] * b.m[2] + a.m[5] * b.m[6] + a.m[6] * b.m[10] + a.m[7] * b.m[14],
            a.m[4] * b.m[3] + a.m[5] * b.m[7] + a.m[6] * b.m[11] + a.m[7] * b.m[15],

            a.m[8] * b.m[0] + a.m[9] * b.m[4] + a.m[10] * b.m[8] + a.m[11] * b.m[12],
            a.m[8] * b.m[1] + a.m[9] * b.m[5] + a.m[10] * b.m[9] + a.m[11] * b.m[13],
            a.m[8] * b.m[2] + a.m[9] * b.m[6] + a.m[10] * b.m[10] + a.m[11] * b.m[14],
            a.m[8] * b.m[3] + a.m[9] * b.m[7] + a.m[10] * b.m[11] + a.m[11] * b.m[15],

            a.m[12] * b.m[0] + a.m[13] * b.m[4] + a.m[14] * b.m[8] + a.m[15] * b.m[12],
            a.m[12] * b.m[1] + a.m[13] * b.m[5] + a.m[14] * b.m[9] + a.m[15] * b.m[13],
            a.m[12] * b.m[2] + a.m[13] * b.m[6] + a.m[14] * b.m[10] + a.m[15] * b.m[14],
            a.m[12] * b.m[3] + a.m[13] * b.m[7] + a.m[14] * b.m[11] + a.m[15] * b.m[15]);
    }

    /**
     * Add two matrices.
     *
     * @param a
     * @param b
     * @return      a + b
     */
    @:op(A + B)
    public static inline function Add(a:Matrix4x4, b:Matrix4x4):Matrix4x4 {
        return a.clone().add(b);
    }

    /**
     * Subtract one matrix from another.
     *
     * @param a
     * @param b
     * @return      a - b
     */
    @:op(A - B)
    public static inline function Subtract(a:Matrix4x4, b:Matrix4x4):Matrix4x4 {
        return a.clone().subtract(b);
    }

    /**
     * Create a negated copy of a matrix.
     *
     * @param a
     * @return      -a
     */
    @:op(-A)
    public static inline function Negate(a:Matrix4x4):Matrix4x4 {
        return new Matrix4x4(
            -a.m[0], -a.m[1], -a.m[2], -a.m[3],
            -a.m[4], -a.m[5], -a.m[6], -a.m[7],
            -a.m[8], -a.m[9], -a.m[10], -a.m[11],
            -a.m[12], -a.m[13], -a.m[14], -a.m[15]);
    }

    /**
     * Test element-wise equality between two matrices.
     * False if one of the inputs is null and the other is not.
     *
     * @param a
     * @param b
     * @return      a_ij == b_ij
     */
    @:op(A == B)
    public static inline function Equals(a:Matrix4x4, b:Matrix4x4):Bool {
        return (a == null && b == null) ||
            a != null &&
            b != null &&
            a.m[0] == b.m[0] &&
            a.m[1] == b.m[1] &&
            a.m[2] == b.m[2] &&
            a.m[3] == b.m[3] &&
            a.m[4] == b.m[4] &&
            a.m[5] == b.m[5] &&
            a.m[6] == b.m[6] &&
            a.m[7] == b.m[7] &&
            a.m[8] == b.m[8] &&
            a.m[9] == b.m[9] &&
            a.m[10] == b.m[10] &&
            a.m[11] == b.m[11] &&
            a.m[12] == b.m[12] &&
            a.m[13] == b.m[13] &&
            a.m[14] == b.m[14] &&
            a.m[15] == b.m[15];
    }

	public static inline function Inverse(a:Matrix4x4):Matrix4x4 {
		var det = a.determinant();

		if (det == 0) {
			return a;
		}

		var b:Matrix4x4 = new Matrix4x4();

		b.m[0] = (a.m[6] * a.m[11] * a.m[13] - a.m[7] * a.m[10] * a.m[13] + a.m[7] * a.m[9] * a.m[14] - a.m[5] * a.m[11] * a.m[14] - a.m[6] * a.m[9] * a.m[15] + a.m[5] * a.m[10] * a.m[15]) / det;
		b.m[1] = (a.m[3] * a.m[10] * a.m[13] - a.m[2] * a.m[11] * a.m[13] - a.m[3] * a.m[9] * a.m[14] + a.m[1] * a.m[11] * a.m[14] + a.m[2] * a.m[9] * a.m[15] - a.m[1] * a.m[10] * a.m[15]) / det;
		b.m[2] = (a.m[2] * a.m[7] * a.m[13] - a.m[3] * a.m[6] * a.m[13] + a.m[3] * a.m[5] * a.m[14] - a.m[1] * a.m[7] * a.m[14] - a.m[2] * a.m[5] * a.m[15] + a.m[1] * a.m[6] * a.m[15]) / det;
		b.m[3] = (a.m[3] * a.m[6] * a.m[9] - a.m[2] * a.m[7] * a.m[9] - a.m[3] * a.m[5] * a.m[10] + a.m[1] * a.m[7] * a.m[10] + a.m[2] * a.m[5] * a.m[11] - a.m[1] * a.m[6] * a.m[11]) / det;
		b.m[4] = (a.m[7] * a.m[10] * a.m[12] - a.m[6] * a.m[11] * a.m[12] - a.m[7] * a.m[8] * a.m[14] + a.m[4] * a.m[11] * a.m[14] + a.m[6] * a.m[8] * a.m[15] - a.m[4] * a.m[10] * a.m[15]) / det;
		b.m[5] = (a.m[2] * a.m[11] * a.m[12] - a.m[3] * a.m[10] * a.m[12] + a.m[3] * a.m[8] * a.m[14] - a.m[0] * a.m[11] * a.m[14] - a.m[2] * a.m[8] * a.m[15] + a.m[0] * a.m[10] * a.m[15]) / det;
		b.m[6] = (a.m[3] * a.m[6] * a.m[12] - a.m[2] * a.m[7] * a.m[12] - a.m[3] * a.m[4] * a.m[14] + a.m[0] * a.m[7] * a.m[14] + a.m[2] * a.m[4] * a.m[15] - a.m[0] * a.m[6] * a.m[15]) / det;
		b.m[7] = (a.m[2] * a.m[7] * a.m[8] - a.m[3] * a.m[6] * a.m[8] + a.m[3] * a.m[4] * a.m[10] - a.m[0] * a.m[7] * a.m[10] - a.m[2] * a.m[4] * a.m[11] + a.m[0] * a.m[6] * a.m[11]) / det;
		b.m[8] = (a.m[5] * a.m[11] * a.m[12] - a.m[7] * a.m[9] * a.m[12] + a.m[7] * a.m[8] * a.m[13] - a.m[4] * a.m[11] * a.m[13] - a.m[5] * a.m[8] * a.m[15] + a.m[4] * a.m[9] * a.m[15]) / det;
		b.m[9] = (a.m[3] * a.m[9] * a.m[12] - a.m[1] * a.m[11] * a.m[12] - a.m[3] * a.m[8] * a.m[13] + a.m[0] * a.m[11] * a.m[13] + a.m[1] * a.m[8] * a.m[15] - a.m[0] * a.m[9] * a.m[15]) / det;
		b.m[10] = (a.m[1] * a.m[7] * a.m[12] - a.m[3] * a.m[5] * a.m[12] + a.m[3] * a.m[4] * a.m[13] - a.m[0] * a.m[7] * a.m[13] - a.m[1] * a.m[4] * a.m[15] + a.m[0] * a.m[5] * a.m[15]) / det;
		b.m[11] = (a.m[3] * a.m[5] * a.m[8] - a.m[1] * a.m[7] * a.m[8] - a.m[3] * a.m[4] * a.m[9] + a.m[0] * a.m[7] * a.m[9] + a.m[1] * a.m[4] * a.m[11] - a.m[0] * a.m[5] * a.m[11]) / det;
		b.m[12] = (a.m[6] * a.m[9] * a.m[12] - a.m[5] * a.m[10] * a.m[12] - a.m[6] * a.m[8] * a.m[13] + a.m[4] * a.m[10] * a.m[13] + a.m[5] * a.m[8] * a.m[14] - a.m[4] * a.m[9] * a.m[14]) / det;
		b.m[13] = (a.m[1] * a.m[10] * a.m[12] - a.m[2] * a.m[9] * a.m[12] + a.m[2] * a.m[8] * a.m[13] - a.m[0] * a.m[10] * a.m[13] - a.m[1] * a.m[8] * a.m[14] + a.m[0] * a.m[9] * a.m[14]) / det;
		b.m[14] = (a.m[2] * a.m[5] * a.m[12] - a.m[1] * a.m[6] * a.m[12] - a.m[2] * a.m[4] * a.m[13] + a.m[0] * a.m[6] * a.m[13] + a.m[1] * a.m[4] * a.m[14] - a.m[0] * a.m[5] * a.m[14]) / det;
		b.m[15] = (a.m[1] * a.m[6] * a.m[8] - a.m[2] * a.m[5] * a.m[8] + a.m[2] * a.m[4] * a.m[9] - a.m[0] * a.m[6] * a.m[9] - a.m[1] * a.m[4] * a.m[10] + a.m[0] * a.m[5] * a.m[10]) / det;

		return b;
	}

	public inline function inverse() {
		this = Inverse(this);
		return this;
	}

	public inline function decompose(outTranslation:Vector3, outScale:Vector3, outRotation:Quaternion) {
		outTranslation.set(this.m[12], this.m[13], this.m[14]);

		var p:Matrix4x4 = new Matrix4x4();

		// Build orthogonal matrix p
		var invLength = 1 / Math.sqrt(this.m[0] * this.m[0] +this.m[1] * this.m[1] + this.m[2] * this.m[2]);
		p.m[0] = this.m[0] * invLength;
		p.m[1] = this.m[1] * invLength;
		p.m[2] = this.m[2] * invLength;

		var dot = p.m[0] * this.m[4] + p.m[1] * this.m[5] + p.m[2] * this.m[6];
		p.m[4] = this.m[4] - dot * p.m[0];
		p.m[5] = this.m[5] - dot * p.m[1];
		p.m[6] = this.m[6] - dot * p.m[2];
		invLength = 1 / Math.sqrt(p.m[4] * p.m[4] + p.m[5] * p.m[5] + p.m[6] * p.m[6]);
		p.m[4] *= invLength;
		p.m[5] *= invLength;
		p.m[6] *= invLength;

		dot = p.m[0] * this.m[8] + p.m[1] * this.m[9] + p.m[2] * this.m[10];
		p.m[8] = this.m[8] - dot * p.m[0];
		p.m[9] = this.m[9] - dot * p.m[1];
		p.m[10] = this.m[10] - dot * p.m[2];
		dot = p.m[4] * this.m[8] + p.m[5] * this.m[9] + p.m[6] * this.m[10];
		p.m[8] -= dot * p.m[4];
		p.m[9] -= dot * p.m[5];
		p.m[10] -= dot * p.m[6];
		invLength = 1 / Math.sqrt(p.m[8] * p.m[8] + p.m[9] * p.m[9] + p.m[10] * p.m[10]);
		p.m[8] *= invLength;
		p.m[9] *= invLength;
		p.m[10] *= invLength;

		// Guarantee that orthonogal matrix has determinant 1 (no reflections)
		var det = 	p.m[0] * p.m[5] * p.m[10] + p.m[4] * p.m[9] * p.m[2] +
					p.m[8] * p.m[1] * p.m[6] - p.m[8] * p.m[5] * p.m[2] -
					p.m[4] * p.m[1] * p.m[10] - p.m[0] * p.m[9] * p.m[6];

		if (det < 0) {
			for (i in 0...16) {
				p.m[i] = -p.m[i];
			}
		}

		// build "right" matrix R
		var r:Matrix4x4 = new Matrix4x4();

		r.m[0] =  p.m[0] * this.m[0] + p.m[1] * this.m[1] + p.m[2] * this.m[2];
		r.m[4] =  p.m[0] * this.m[4] + p.m[1] * this.m[5] + p.m[2] * this.m[6];
		r.m[5] =  p.m[4] * this.m[4] + p.m[5] * this.m[5] + p.m[6] * this.m[6];
		r.m[8] =  p.m[0] * this.m[8] + p.m[1] * this.m[9] + p.m[2] * this.m[10];
		r.m[9] =  p.m[4] * this.m[8] + p.m[5] * this.m[9] + p.m[6] * this.m[10];
		r.m[10] = p.m[8] * this.m[8] + p.m[9] * this.m[9] + p.m[10] * this.m[10];

		// the scaling component
		outScale.set(r.m[0], r.m[5], r.m[10]);

		outRotation = Quaternion.FromMatrix(p);
	}

	public static inline function CreateTransform(position:Vector3, scale:Vector3, rotation:Quaternion) {
		var matrix:Matrix4x4 = CreateRotation(rotation);

		return new Matrix4x4(
			scale.x * matrix.m[0], scale.x * matrix.m[1], scale.x * matrix.m[2], 0,
			scale.y * matrix.m[4], scale.y * matrix.m[5], scale.y * matrix.m[6], 0,
			scale.z * matrix.m[8], scale.z * matrix.m[9], scale.z * matrix.m[10], 0,
			position.x, position.y, position.z, 1
		);
	}

	public static inline function CreateTranslation(position:Vector3) {
		return new Matrix4x4(
			1, 0, 0, position.x,
			0, 1, 0, position.y,
			0, 0, 1, position.z,
			0, 0, 0, 1
		);
	}

	public static inline function Translate(a:Matrix4x4, position:Vector3) {
		a *= CreateTranslation(position);
		return a;
	}

	public inline function translate(position:Vector3) {
		this = Translate(this, position);
		return this;
	}

	public static inline function CreateScale(scale:Vector3) {
		return new Matrix4x4(
			scale.x, 0, 0, 0,
			0, scale.y, 0, 0,
			0, 0, scale.z, 0,
			0, 0, 0, 1
		);
	}

	public static inline function Scale(a:Matrix4x4, scale:Vector3) {
		a *= CreateScale(scale);
		return a;
	}

	public inline function scale(scale:Vector3) {
		this = Scale(this, scale);
		return this;
	}

	public static inline function CreateRotation(rotation:Quaternion):Matrix4x4 {
		var q:Quaternion = rotation.clone();
		q.normalize();

		var wSquared = q.w * q.w;
		var xSquated = q.x * q.x;
		var ySquared = q.y * q.y;
		var zSquared = q.z * q.z;

		var a = wSquared + xSquated - ySquared - zSquared;
		var b = 2 * q.x * q.y + 2 * q.w * q.z;
		var c = 2 * q.x * q.z - 2 * q.w * q.y;

		var e = 2 * q.x * q.y - 2 * q.w * q.z;
		var f = wSquared - xSquated + ySquared - zSquared;
		var g = 2 * q.y * q.z + 2 * q.w * q.x;

		var i = 2 * q.x * q.z + 2 * q.w * q.y;
		var j = 2 * q.y * q.z - 2 * q.w * q.x;
		var k = wSquared - xSquated - ySquared + zSquared;


		return new Matrix4x4(
			a, b, c, 0,
			e, f, g, 0,
			i, j, k, 0,
			0, 0, 0, 1
		);
	}

	public static inline function CreateRotationX(angle:Float) {
		var sinA = Math.sin(angle);
		var cosA = Math.cos(angle);

		return new Matrix4x4(
			1, 0, 0, 0,
			0, cosA, sinA, 0,
			0, -sinA, cosA, 0,
			0, 0, 0, 1
		);
	}

	public static inline function CreateRotationY(angle:Float) {
		var sinA = Math.sin(angle);
		var cosA = Math.cos(angle);

		return new Matrix4x4(
			cosA, 0, -sinA, 0,
			0, 1, 0, 0,
			sinA, 0, cosA, 0,
			0, 0, 0, 1
		);
	}

	public static inline function CreateRotationZ(angle:Float) {
		var sinA = Math.sin(angle);
		var cosA = Math.cos(angle);

		return new Matrix4x4(
			cosA, -sinA, 0, 0,
			sinA, cosA, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1
		);
	}

	public static inline function RotateX(a:Matrix4x4, angle:Float) {
		a *= CreateRotationX(angle);
		return a;
	}

	public static inline function RotateY(a:Matrix4x4, angle:Float) {
		a *= CreateRotationY(angle);
		return a;
	}

	public static inline function RotateZ(a:Matrix4x4, angle:Float) {
		a *= CreateRotationZ(angle);
		return a;
	}

	public inline function rotateX(angle:Float) {
		this = RotateX(this, angle);
		return this;
	}

	public inline function rotateY(angle:Float) {
		this = RotateY(this, angle);
		return this;
	}

	public inline function rotateZ(angle:Float) {
		this = RotateZ(this, angle);
		return this;
	}

	public static inline function LookAt(position:Vector3, target:Vector3, upAxis:Vector3):Matrix4x4 {
		var zAxis = target - position;
		zAxis.normalize();

		var xAxis = Vector3.Cross(upAxis, zAxis);
		xAxis.normalize();

		var yAxis = Vector3.Cross(zAxis, xAxis);

		var dotX = Vector3.Dot(xAxis, position);
		var dotY = Vector3.Dot(yAxis, position);
		var dotZ = Vector3.Dot(zAxis, position);

		return new Matrix4x4(
			xAxis.x, yAxis.x, zAxis.x, 0,
			xAxis.y, yAxis.y, zAxis.y, 0,
			xAxis.z, yAxis.z, zAxis.z, 0,
			-dotX,   -dotY,   -dotZ,   1
		);
	}

    /**
     * Add a matrix in place.
     * Note: += operator on Haxe abstracts does not behave this way (a new object is returned).
     *
     * @param a
     * @return      self_ij += a_ij
     */
    public inline function add(a:Matrix4x4):Matrix4x4 {
        var self:Matrix4x4 = this;

        self.m[0] += a.m[0];
        self.m[1] += a.m[1];
        self.m[2] += a.m[2];
        self.m[3] += a.m[3];
        self.m[4] += a.m[4];
        self.m[5] += a.m[5];
        self.m[6] += a.m[6];
        self.m[7] += a.m[7];
        self.m[8] += a.m[8];
        self.m[9] += a.m[9];
        self.m[10] += a.m[10];
        self.m[11] += a.m[11];
        self.m[12] += a.m[12];
        self.m[13] += a.m[13];
        self.m[14] += a.m[14];
        self.m[15] += a.m[15];

        return self;
    }

    /**
     * Subtract a matrix in place.
     * Note: -= operator on Haxe abstracts does not behave this way (a new object is returned).
     *
     * @param a
     * @return      self_ij -= a_ij
     */
    public inline function subtract(a:Matrix4x4):Matrix4x4 {
        var self:Matrix4x4 = this;

        self.m[0] -= a.m[0];
        self.m[1] -= a.m[1];
        self.m[2] -= a.m[2];
        self.m[3] -= a.m[3];
        self.m[4] -= a.m[4];
        self.m[5] -= a.m[5];
        self.m[6] -= a.m[6];
        self.m[7] -= a.m[7];
        self.m[8] -= a.m[8];
        self.m[9] -= a.m[9];
        self.m[10] -= a.m[10];
        self.m[11] -= a.m[11];
        self.m[12] -= a.m[12];
        self.m[13] -= a.m[13];
        self.m[14] -= a.m[14];
        self.m[15] -= a.m[15];

        return self;
    }

    /**
     * Copy the contents of this structure to another.
     * Faster than copyToShape for static platforms (C++, etc) but requires the target to have the exact same inner type.
     *
     * @param target    The target structure.
     */
    public inline function copyTo(target:Matrix4x4):Void {
        var self:Matrix4x4 = this;

        for (i in 0...Matrix4x4.elementCount)
        {
            target[i] = self[i];
        }
    }

    /**
     * Set the linear portion of this matrix to a rotation from a quaternion.
     *
     * @param q         The quaternion containing the rotation.
     * @return          This.
     */
    public inline function setRotateFromQuaternion(q:Quaternion):Matrix4x4 {
        var self:Matrix4x4 = this;

        var s = q.w;
        var x = q.x;
        var y = q.y;
        var z = q.z;

        self.m[0] = 1 - 2 * (y * y + z * z);
        self.m[1] = 2 * (x * y - s * z);
        self.m[2] = 2 * (s * y + x * z);

        self.m[4] = 2 * (x * y + s * z);
        self.m[5] = 1 - 2 * (x * x + z * z);
        self.m[6] = 2 * (y * z - s * x);

        self.m[8] = 2 * (x * z - s * y);
        self.m[9] = 2 * (y * z + s * x);
        self.m[10] = 1 - 2 * (x * x + y * y);

        return self;
    }

    /**
     * Set the right column to a translation.
     *
     * @param x
     * @param y
     * @param z
     * @return      This.
     */
    public inline function setTranslate(x:Float, y:Float, z:Float):Matrix4x4 {
        var self:Matrix4x4 = this;

        self.m[3] = x;
        self.m[7] = y;
        self.m[11] = z;

        return self;
    }

    /**
     * Clone.
     *
     * @return  The cloned object.
     */
    public inline function clone():Matrix4x4 {
        var self:Matrix4x4 = this;
        return new Matrix4x4(
            self.m[0], self.m[1], self.m[2], self.m[3],
            self.m[4], self.m[5], self.m[6], self.m[7],
            self.m[8], self.m[9], self.m[10], self.m[11],
            self.m[12], self.m[13], self.m[14], self.m[15]);
    }

    /**
     * Get an element by position.
     * The implicit array is row-major (e.g. element (column count) + 1 is the first element of the second row).
     *
     * @param i         The element index.
     * @return          The element.
     */
    @:arrayAccess
    public inline function getArrayElement(i:Int):Float {
        var self:Matrix4x4 = this;

        switch (i)
        {
            case 0:
                return self.m[0];
            case 1:
                return self.m[1];
            case 2:
                return self.m[2];
            case 3:
                return self.m[3];
            case 4:
                return self.m[4];
            case 5:
                return self.m[5];
            case 6:
                return self.m[6];
            case 7:
                return self.m[7];
            case 8:
                return self.m[8];
            case 9:
                return self.m[9];
            case 10:
                return self.m[10];
            case 11:
                return self.m[11];
            case 12:
                return self.m[12];
            case 13:
                return self.m[13];
            case 14:
                return self.m[14];
            case 15:
                return self.m[15];
            default:
                throw "Invalid element";
        }
    }

    /**
     * Set an element by position.
     * The implicit array is row-major (e.g. element (column count) + 1 is the first element of the second row).
     *
     * @param i         The element index.
     * @param value     The new value.
     * @return          The updated element.
     */
    @:arrayAccess
    public inline function setArrayElement(i:Int, value:Float):Float {
        var self:Matrix4x4 = this;
		self.m[i] = value;
		
		return self.m[i];
        /*switch (i)
        {
            case 0:
                return self.m[0] = value;
            case 1:
                return self.m[1] = value;
            case 2:
                return self.m[2] = value;
            case 3:
                return self.m[3] = value;
            case 4:
                return self.m[4] = value;
            case 5:
                return self.m[5] = value;
            case 6:
                return self.m[6] = value;
            case 7:
                return self.m[7] = value;
            case 8:
                return self.m[8] = value;
            case 9:
                return self.m[9] = value;
            case 10:
                return self.m[10] = value;
            case 11:
                return self.m[11] = value;
            case 12:
                return self.m[12] = value;
            case 13:
                return self.m[13] = value;
            case 14:
                return self.m[14] = value;
            case 15:
                return self.m[15] = value;
            default:
                throw "Invalid element";
        }*/
    }

    /**
     * Get an element by (row, column) indices.
     * Both row and column indices start at 0, e.g. the index of the first element of the first row is (0, 0).
     *
	 * @param row       The row index.
     * @param column    The column index.
     * @return          The element.
     */
    public inline function get(row:Int, column:Int):Float {
        var self:Matrix4x4 = this;
        return self[column + row * 4];
    }

    /**
     * Set an element by (column, row) indices.
     * Both column and row indices start at 0, e.g. the index of the first element of the first row is (0, 0).
     *
     * @param column    The column index.
     * @param row       The row index.
     * @param value     The new value.
     * @return          The updated element.
     */
    public inline function setElement(column:Int, row:Int, value:Float):Float {
        var self:Matrix4x4 = this;
        return self[row * 4 + column] = value;
    }

    /**
     * Get a column vector by index.
     *
     * @param index     The 0-based index of the column.
     * @return          The column as a vector.
     */
    public inline function column(index:Int):Vector4 {
        var self:Matrix4x4 = this;

        switch (index)
        {
            case 0:
                return new Vector4(self.m[0], self.m[4], self.m[8], self.m[12]);
            case 1:
                return new Vector4(self.m[1], self.m[5], self.m[9], self.m[13]);
            case 2:
                return new Vector4(self.m[2], self.m[6], self.m[10], self.m[14]);
            case 3:
                return new Vector4(self.m[3], self.m[7], self.m[11], self.m[15]);
            default:
                throw "Invalid column";
        }
    }

    /**
     * Get a row vector by index.
     *
     * @param index     The 0-based index of the row.
     * @return          The row as a vector.
     */
    public inline function row(index:Int):Vector4 {
        var self:Matrix4x4 = this;

        switch (index)
        {
            case 0:
                return new Vector4(self.m[0], self.m[1], self.m[2], self.m[3]);
            case 1:
                return new Vector4(self.m[4], self.m[5], self.m[6], self.m[7]);
            case 2:
                return new Vector4(self.m[8], self.m[9], self.m[10], self.m[11]);
            case 3:
                return new Vector4(self.m[12], self.m[13], self.m[14], self.m[15]);
            default:
                throw "Invalid row";
        }
    }

    /**
     * Apply a scalar function to each element.
     *
     * @param func  The function to apply.
     * @return      The modified object.
     */
    public inline function applyScalarFunc(func:Float->Float):Matrix4x4 {
        var self:Matrix4x4 = this;

        for (i in 0...elementCount)
        {
            self[i] = func(self[i]);
        }

        return self;
    }

    /**
     * Transpose the upper 3x3 block (the linear sub-matrix in a homogenous matrix).
     *
     * @return  The modified object.
     */
    public inline function applySubMatrixTranspose():Matrix4x4 {
        var self:Matrix4x4 = this;

        var temp:Float;

        temp = self.m[4];
        self.m[4] = self.m[1];
        self.m[1] = temp;

        temp = self.m[8];
        self.m[8] = self.m[2];
        self.m[2] = temp;

        temp = self.m[9];
        self.m[9] = self.m[6];
        self.m[6] = temp;

        return self;
    }

    /**
     * Inverts the matrix assuming that it is a homogenous affine matrix (the last column gives
     * the translation) with a special orthogonal sub-matrix for the linear portion (a rotation
     * without any scaling/shearing/etc).
     *
     * @return  The modified object.
     */
    public inline function applyInvertFrame():Matrix4x4 {
        var self:Matrix4x4 = this;

        // Assuming the sub-matrix is a special orthogonal matrix transpose gives the inverse
        self.applySubMatrixTranspose();

        // The inverse of the translation is equal to -M^T * translation
        var tx = -(self.m[0] * self.m[3] + self.m[1] * self.m[7] + self.m[2] * self.m[11]);
        var ty = -(self.m[4] * self.m[3] + self.m[5] * self.m[7] + self.m[6] * self.m[11]);
        var tz = -(self.m[8] * self.m[3] + self.m[9] * self.m[7] + self.m[10] * self.m[11]);

        self.m[3] = tx;
        self.m[7] = ty;
        self.m[11] = tz;

        return self;
    }

	public inline function determinant() {
		return	this.m[3] * this.m[6] * this.m[9]  * this.m[12] - this.m[2] * this.m[7] * this.m[9]  * this.m[12] - this.m[3] * this.m[5] * this.m[10] * this.m[12] + this.m[1] * this.m[7] * this.m[10] * this.m[12] +
				this.m[2] * this.m[5] * this.m[11] * this.m[12] - this.m[1] * this.m[6] * this.m[11] * this.m[12] - this.m[3] * this.m[6] * this.m[8]  * this.m[13] + this.m[2] * this.m[7] * this.m[8]  * this.m[13] +
				this.m[3] * this.m[4] * this.m[10] * this.m[13] - this.m[0] * this.m[7] * this.m[10] * this.m[13] - this.m[2] * this.m[4] * this.m[11] * this.m[13] + this.m[0] * this.m[6] * this.m[11] * this.m[13] +
				this.m[3] * this.m[5] * this.m[8]  * this.m[14] - this.m[1] * this.m[7] * this.m[8]  * this.m[14] - this.m[3] * this.m[4] * this.m[9]  * this.m[14] + this.m[0] * this.m[7] * this.m[9]  * this.m[14] +
				this.m[1] * this.m[4] * this.m[11] * this.m[14] - this.m[0] * this.m[5] * this.m[11] * this.m[14] - this.m[2] * this.m[5] * this.m[8]  * this.m[15] + this.m[1] * this.m[6] * this.m[8]  * this.m[15] +
				this.m[2] * this.m[4] * this.m[9]  * this.m[15] - this.m[0] * this.m[6] * this.m[9]  * this.m[15] - this.m[1] * this.m[4] * this.m[10] * this.m[15] + this.m[0] * this.m[5] * this.m[10] * this.m[15];
	}

	public inline function up():Vector3 {
		var self:Matrix4x4 = this;
        return new Vector3(self[4], self[5], self[6]);
    }

    public inline function down():Vector3 {
        return up().negate();
    }

    public inline function right():Vector3 {
		var self:Matrix4x4 = this;
        return new Vector3(self[0], self[1], self[2]);
    }

	public inline function left():Vector3 {
        return right().negate();
    }

	public inline function forward():Vector3 {
		var self:Matrix4x4 = this;
        return new Vector3(self[8], self[9], self[10]);
    }

    public inline function backward():Vector3 {
        return forward().negate();
    }

    private static inline function get_zero():Matrix4x4 {
        return new Matrix4x4(
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.0);
    }

    private static inline function get_identity():Matrix4x4 {
        return new Matrix4x4(
            1.0, 0.0, 0.0, 0.0,
            0.0, 1.0, 0.0, 0.0,
            0.0, 0.0, 1.0, 0.0,
            0.0, 0.0, 0.0, 1.0);
    }

    private inline function get_translation():Vector3 {
        var self:Matrix4x4 = this;
        return new Vector3(self[12], self[13], self[14]);
    }

    private inline function set_translation(pos:Vector3):Vector3 {
        var self:Matrix4x4 = this;
        self[12] = pos.x;
        self[13] = pos.y;
        self[14] = pos.z;
        return pos;
    }

    private inline function get_transpose():Matrix4x4 {
        var self:Matrix4x4 = this;
        return new Matrix4x4(
            self.m[0], self.m[4], self.m[8], self.m[12],
            self.m[1], self.m[5], self.m[9], self.m[13],
            self.m[2], self.m[6], self.m[10], self.m[14],
            self.m[3], self.m[7], self.m[11], self.m[15]);
    }

    private inline function get_det():Float {
        var self:Matrix4x4 = this;
        return MathUtil.det4x4(
            self.m[0], self.m[1], self.m[2], self.m[3],
            self.m[4], self.m[5], self.m[6], self.m[7],
            self.m[8], self.m[9], self.m[10], self.m[11],
            self.m[12], self.m[13], self.m[14], self.m[15]);
    }

    private inline function get_subMatrix():Matrix3x3 {
        var self:Matrix4x4 = this;
        return new Matrix3x3(
            self.m[0], self.m[1], self.m[2],
            self.m[4], self.m[5], self.m[6],
            self.m[8], self.m[9], self.m[10]);
    }
}