package bakeneko.asset;

import bakeneko.backend.FileLoader;
import bakeneko.core.Application;
import bakeneko.asset.Resource;
import bakeneko.core.Log;
import bakeneko.task.Task;
import bakeneko.task.TaskCompletionSource;
import bakeneko.task.TaskExt;
import lime.app.Future;
import lime.utils.Bytes;

class Binary extends Resource implements IResource {
	public var asset:lime.utils.Bytes;
	
	public function new(?options:ResourceOptions) {
		super(options);
		resourceType = ResourceType.text;
	}
	
	public function reload():Task<Binary> {
		clear();
		
		var tcs = new TaskCompletionSource<Binary>();
		state = ResourceState.loading;
		
		TaskExt.IMMEDIATE_EXECUTOR.execute(function() {
			/*asset = FileLoader.getBytes(id);
			state = ResourceState.loaded;
			Log.assert(asset != null, 'Binary for $id can\'t be null');
			tcs.setResult(this);*/
			/*onSuccess(function(task:Task<haxe.io.Bytes>) {
				asset = task.result;
				state = ResourceState.loaded;
				Log.assert(asset != null, 'Font for $id can\'t be null');
				tcs.setResult(this);
			});*/
		});
		
		return tcs.task;
		
		/*return Task.call(function() {
			asset = FileLoader.getBytes(id);
			state = ResourceState.loaded;
			return this;
		}, TaskExt.BACKGROUND_EXECUTOR);*/
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