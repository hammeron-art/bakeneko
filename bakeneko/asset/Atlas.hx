package bakeneko.asset;

import bakeneko.asset.Texture;
import bakeneko.asset.Texture.TextureOptions;
import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.task.Task;
import bakeneko.asset.Resource;
import bakeneko.task.TaskCompletionSource;
import bakeneko.task.TaskExt;
import bakeneko.backend.FileLoader;

class Atlas extends Resource implements IResource {

	public var asset:TexturePages;
	
	var atlas:AtlasDescription;
	var textureOptions:TextureOptions;
	
	public function new(?options:AtlasOptions) {
		super(options);
		
		textureOptions = options;
		
		asset = new TexturePages();
	}
	
	public function reload():Task<Atlas> {
		clear();
		
		state = ResourceState.loading;
		var tcs = new TaskCompletionSource<Atlas>();
		
		TaskExt.IMMEDIATE_EXECUTOR.execute(function() {
			var manager = Application.get().resourceManager;
			
			manager.loadText({id: id}).onSuccess(function(task:Task<Text>) {
				atlas = new AtlasDescription(task.result.asset);
			});
			tcs.setResult(this);
			/*FileLoader.loadImage(id).onSuccess(function(task:Task<Image>) {
				asset = task.result;
				Log.assert(asset != null, 'Image for $id can\'t be null');
				
				build(asset.data, asset.width, asset.height, asset.width, asset.height);
				tcs.setResult(this);
				state = ResourceState.loaded;
			});*/
		});
		
		return tcs.task;
	}
	
	public function clear():Void {
		for (texture in asset.keys()) {
			trace(texture);
		}
		/*if (asset != null) {
			asset = null;
		}
		
		pixels = null;

		if (textureID != null) {
			GL.deleteTexture(textureID);
			textureID = null;
		}*/
	}

	public function memoryUsage():Int {
		if (asset == null)
			return 0;
		return 0;
		//return asset.buffer.data.length;
	}
	
}

typedef TexturePages = Map<Int, Texture>;
typedef AtlasOptions = TextureOptions;