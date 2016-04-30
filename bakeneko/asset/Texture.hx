package bakeneko.asset;

import bakeneko.FileLoader;
import bakeneko.asset.Asset.AssetProp;
import bakeneko.asset.Asset.AssetType;
import bakeneko.asset.Asset.AssetState;
import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.render.NativeTexture;
import bakeneko.render.TextureFilter;
import bakeneko.render.TextureUnit;
import bakeneko.render.TextureWrap;
import bakeneko.task.TaskCompletionSource;
import bakeneko.task.TaskExt;
import lime.graphics.Image;

class Texture extends Asset {
	
	public var image:Image;
	var options:TextureProp;
	var nativeTexture:NativeTexture;
	
	public function new (options:TextureProp) {
		super(options);
		
		this.options = options;
		resourceType = AssetType.texture;
	}
	
	override public function reload() {
		clear();

		state = AssetState.loading;
		var tcs = new TaskCompletionSource<Texture>();
			
		TaskExt.IMMEDIATE_EXECUTOR.execute(function() {
			FileLoader.loadImage(options.id).continueWith(function(task) {
				if (task.isSuccessed) {
					image = task.result;
					Log.assert(image != null, 'Image for $id can\'t be null');
					
					build();
					state = AssetState.loaded;
					tcs.setResult(this);
				} else {
					tcs.setError(task.error);
				}
			});
		});
		
		return tcs.task;
	}
	
	function build() {
		var render = Application.get().windows[0].renderer;
		
		if (nativeTexture != null && (nativeTexture.width != image.width || nativeTexture.height != image.height))
			render.deleteTexture(nativeTexture);
		
		nativeTexture = Application.get().windows[0].renderer.createTexture(image.width, image.height);
		render.updaloadTexturePixel(nativeTexture, image.buffer.data);
	}
	
	function upload() {
		
	}
	
}

typedef TextureProp = {
	> AssetProp,
	
	@:optional var wrap:TextureWrap;
	@:optional var filter:TextureFilter;
	@:optional var width:Int;
	@:optional var height:Int;
	
}