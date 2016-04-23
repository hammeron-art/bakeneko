package bakeneko.entity;

import bakeneko.core.Application;
import bakeneko.format.model.Data.Vector;
import bakeneko.math.Matrix4x4;
import bakeneko.math.Quaternion;
import bakeneko.math.Vector3;
import haxe.CallStack;

class Transform {

	// Local transform
	var local:Matrix4x4;
	// World Transform
	var world:Matrix4x4;

	// Can't execute getter when field x, y, z are changed so
	// is not a good ideia make these properties public
	// because we can't invalidade the cache in this case
	
	var position(default, set):Vector3 = new Vector3();
	var scale(default, set):Vector3 = new Vector3(1.0, 1.0, 1.0);
	var rotation(default, set):Quaternion = new Quaternion();
	
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var z(get, set):Float;

	var parentTransform:Transform;
	var childTransforms:Array<Transform>;

	var isTranformCacheValid:Bool = false;
	var isParentTransformCacheValid:Bool = false;

	public function new() {
		local = new Matrix4x4();
		world = new Matrix4x4();

		parentTransform = null;
		childTransforms = [];
	}

	public function lookAt(position:Vector3, target:Vector3, upAxis:Vector3) {
		var vUp:Vector3 = upAxis.clone();

		var vFoward = (target - position);
		vFoward.normalize();

		var vRight = Vector3.Cross(vUp, vFoward);
		vUp = Vector3.Cross(vFoward, vRight);

		vUp.normalize();
		vRight.normalize();

		var cRot = Quaternion.FromEulerAxis(vRight, vUp, vFoward);
		cRot.normalize();

		setPositionScaleRotation(position, this.scale, cRot);
	}

	public function setPositionScaleRotation(position:Vector3, scale:Vector3, rotation:Quaternion) {
		this.position = position;
		this.scale = scale;
		this.rotation = rotation;

		onTransformChanged();
	}
	
	public inline function get_x() {
		return position.x;
	}
	
	public inline function get_y() {
		return position.y;
	}
	
	public inline function get_z() {
		return position.z;
	}
	
	public inline function set_x(x:Float) {
		if (x == position.x)
			return x;

		position.x = x;
		onTransformChanged();
		
		return x;
	}
	
	public inline function set_y(y:Float) {
		if (y == position.y)
			return y;

		position.y = y;
		onTransformChanged();
		
		return y;
	}
	
	public inline function set_z(z:Float) {
		if (z == position.z)
			return z;

		position.z = z;
		onTransformChanged();
		
		return z;
	}
	
	public inline function translateBy(vec:Vector3) {
		position.add(vec);
		onTransformChanged();
	}
	
	public inline function setPosition(vec:Vector3) {
		if (vec.x == position.x && vec.y == position.y && vec.z == position.z)
			return;
		
		position.set(vec.x, vec.y, vec.z);
		onTransformChanged();
	}
	
	public inline function getPosition() {
		return position;
	}

	public inline function rotateBy(axis:Vector3, angle:Float) {
		rotation = rotation * Quaternion.FromAxisAngle(axis, angle);
	}

	public inline function rotateXBy(angle) {
		rotateBy(Vector3.xAxis, angle);
	}

	public inline function rotateYBy(angle) {
		rotateBy(Vector3.yAxis, angle);
	}

	public inline function rotateZBy(angle) {
		rotateBy(Vector3.zAxis, angle);
	}

	public inline function rotateTo(axis:Vector3, angle:Float) {
		rotation = Quaternion.FromAxisAngle(axis, angle);
	}

	public inline function scaleTo(scale:Vector3) {
		this.scale.x = scale.x;
		this.scale.y = scale.y;
		this.scale.z = scale.z;

		onTransformChanged();
	}

	public function addChildTransform(transform:Transform) {
		transform.parentTransform = this;
		childTransforms.push(transform);
	}

	public function onTransformChanged() {
		isTranformCacheValid = false;

		for (child in childTransforms) {
			child.onParentTransformChanged();
		}
	}

	public function onParentTransformChanged() {
		isParentTransformCacheValid = false;

		onTransformChanged();
	}

	// Local position
	inline function set_position(newPosition:Vector3):Vector3 {
		if (newPosition == position)
			return position;

		position = newPosition;
		onTransformChanged();

		return position;
	}

	// Local scale
	inline function set_scale(newScale:Vector3):Vector3 {
		if (newScale == scale)
			return scale;

		scale = newScale;
		onTransformChanged();

		return scale;
	}

	inline public function setRotation(newRotation:Quaternion) {
		rotation = newRotation;
	}
	
	inline public function rotate(rotation:Quaternion) {
		this.rotation.multiply(rotation);
		onTransformChanged();
	}
	
	// Local rotation
	inline function set_rotation(newRotation:Quaternion):Quaternion {
		if (newRotation == rotation)
			return rotation;

		rotation = newRotation;
		onTransformChanged();

		return rotation;
	}

	public function getLocal():Matrix4x4 {
		if (!isTranformCacheValid) {
			isTranformCacheValid = true;
			local = Matrix4x4.CreateTransform(position, scale, rotation);
		}

		return local;
	}

	public function setLocal(newLocal:Matrix4x4):Matrix4x4 {
		newLocal.decompose(position, scale, rotation);
		local = newLocal;

		onTransformChanged();
		isTranformCacheValid = false;

		return local;
	}

	public function getWorld():Matrix4x4 {
		if (parentTransform != null) {
			if (!isParentTransformCacheValid) {
				isParentTransformCacheValid = true;

				world = getLocal() * parentTransform.getWorld();
			} else {
				if (!isTranformCacheValid) {
					world = getLocal() * parentTransform.getWorld();
				}
			}
		} else {
			//if (!isTranformCacheValid) {
				world = getLocal();
			//}
		}

		return world;
	}

	public function setWorld(newWorld:Matrix4x4):Matrix4x4 {
		if (parentTransform != null) {
			local = newWorld * Matrix4x4.Inverse(parentTransform.getWorld());
		} else {
			local = newWorld;
		}

		local.decompose(position, scale, rotation);

		onTransformChanged();

		isTranformCacheValid = false;
		isParentTransformCacheValid = false;

		return world;
	}


}