package bakeneko.asset;

import bakeneko.core.Log;
import bakeneko.utils.Utils;

/**
 * A resource is an asset loaded from file.
 * All loading is asynchronously by default and the resource cached.
 */
class Resource {
	// The id resource is the relative path to the file
	public var id:String;
	public var state:ResourceState;
	public var resourceType:ResourceType = ResourceType.undefined;
	// Number of references to this resource
	public var refCount:Int = 0;
	
	public var fromFile:Bool = true;
	
	public function new(?options:ResourceOptions):Void {
		id = (options != null) ? options.id : Utils.uniqueID();

		state = ResourceState.undefined;
	}

	// Error mensagem
	function loadingError(error:Dynamic) {
		Log.error('Could not load ${typeString()}: "$id" - $error');
	}

	public function typeString() {
		return switch(resourceType) {
			case ResourceType.text: 'text';
			case ResourceType.binary: 'binary';
			case ResourceType.texture: 'texture';
			case ResourceType.shader: 'shader';
			case ResourceType.json: 'json';
			case ResourceType.sound: 'sound';
			case ResourceType.model: 'model';
			case ResourceType.font: 'font';
			default: 'custom($resourceType)';
		}
	}
	
	public function stateString() {
		return switch(state) {
			case ResourceState.undefined: 'undefined';
			case ResourceState.listed: 'listed';
			case ResourceState.loading: 'loading';
			case ResourceState.loaded: 'loaded';
			case ResourceState.failed: 'failed';
			case ResourceState.invalidated: 'invalidated';
			case ResourceState.destroyed: 'destroyed';
		}
	}

	public function toString():String {
		return 'Resource: {id: $id, type:${typeString()}, state:${stateString()}';
	}

}

@:enum
abstract ResourceType(Int) from Int to Int {
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
abstract ResourceState(Int) from Int to Int {
	var undefined = 0;
	var listed = 1;
	var loading = 2;
	var loaded = 3;
	var failed = 4;
	var invalidated = 5;
	var destroyed = 6;
}

typedef ResourceOptions = {
	var id:String;
}