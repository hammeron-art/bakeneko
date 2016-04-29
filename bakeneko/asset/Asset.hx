package bakeneko.asset;
import bakeneko.core.Log;
import bakeneko.task.Task;

class Asset {

	// The id resource is the relative path to the file
	public var id:String;
	public var state:AssetState;
	public var resourceType:AssetType = AssetType.undefined;
	// Number of references to this resource
	public var refCount:Int = 0;
	
	public var fromFile:Bool = true;
	
	public function new(?options:AssetProp):Void {
		id = (options != null) ? options.id : bakeneko.utils.Utils.uniqueID();
		state = AssetState.undefined;
	}
	
	public function reload() {
		Log.api('Reload not implemented for ${Type.getClassName(Type.getClass(this))} asset');
		return Task.cancelled();
	}
	
	public function clear() {
		Log.api('Clear not implemented for ${Type.getClassName(Type.getClass(this))} asset');
		return null;
	}
	
	function loadingError(error:Dynamic) {
		Log.error('Could not load ${typeString()}: "$id" - $error');
	}

	public function typeString() {
		return switch(resourceType) {
			case AssetType.text: 'text';
			case AssetType.binary: 'binary';
			case AssetType.texture: 'texture';
			case AssetType.shader: 'shader';
			case AssetType.json: 'json';
			case AssetType.sound: 'sound';
			case AssetType.model: 'model';
			case AssetType.font: 'font';
			default: 'custom($resourceType)';
		}
	}
	
	public function stateString() {
		return switch(state) {
			case AssetState.undefined: 'undefined';
			case AssetState.listed: 'listed';
			case AssetState.loading: 'loading';
			case AssetState.loaded: 'loaded';
			case AssetState.failed: 'failed';
			case AssetState.invalidated: 'invalidated';
			case AssetState.destroyed: 'destroyed';
		}
	}

	public function toString():String {
		return 'Resource: {id: $id, type:${typeString()}, state:${stateString()}';
	}
	
}

typedef AssetProp = {
	var id:String;
}

@:enum
abstract AssetType(Int) from Int to Int {
	var undefined = 0;
	var text = 1;
	var binary = 2;
	var texture = 3;
	var shader = 4;
	var json = 5;
	var sound = 6;
	var model = 7;
	var font = 8;
}

@:enum
abstract AssetState(Int) from Int to Int {
	var undefined = 0;
	var listed = 1;
	var loading = 2;
	var loaded = 3;
	var failed = 4;
	var invalidated = 5;
	var destroyed = 6;
}

typedef AssetOptions = {
	var id:String;
}