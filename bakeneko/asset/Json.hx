package bakeneko.asset;

import bakeneko.backend.FileLoader;
import bakeneko.core.Application;
import bakeneko.asset.Resource;
import bakeneko.task.Task;
import bakeneko.task.TaskExt;

class Json extends Resource implements IResource {
	public var asset:Dynamic;
	
	public function new(?options:ResourceOptions) {
		super(options);
		resourceType = ResourceType.text;
	}
	
	public function reload():Task<Json> {
		clear();
		
		state = ResourceState.loading;
					
		return Task.call(function() {
			asset = haxe.Json.parse(FileLoader.getText(id));
			state = ResourceState.loaded;
			
			return this;
		}, TaskExt.BACKGROUND_EXECUTOR);
	}
	
	public function clear():Void {
		if (asset != null) {
			asset.destroy();
			asset = null;
		}
	}
	
	public function memoryUsage():Int {
		if (asset == null)
			return 0;
			
		return 0;
	}
}