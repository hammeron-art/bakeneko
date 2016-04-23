package bakeneko.asset;

import bakeneko.backend.FileLoader;
import bakeneko.core.Application;
import bakeneko.asset.Resource;
import bakeneko.core.Log;
import bakeneko.task.Task;
import bakeneko.task.TaskCompletionSource;
import bakeneko.task.TaskExt;

class Text extends Resource implements IResource {
	public var asset:String;
	
	public function new(?options:ResourceOptions) {
		super(options);
		resourceType = ResourceType.text;
	}
	
	public function reload():Task<Text> {
		clear();
		
		var tcs = new TaskCompletionSource<Text>();
		state = ResourceState.loading;
		
		TaskExt.IMMEDIATE_EXECUTOR.execute(function() {
			var t = FileLoader.loadText(id).onSuccess(function (task) {
				asset = task.result;
				Log.assert(asset != null, 'Text for $id can\'t be null');
				state = ResourceState.loaded;
				
				tcs.setResult(this);
			});
		});
		
		return tcs.task;
	}
	
	public function clear():Void {
		if (asset != null) {
			asset = null;
		}
	}
	
	public function memoryUsage():Int {
		if (asset == null)
			return 0;
			
		return asset.length;
	}
}