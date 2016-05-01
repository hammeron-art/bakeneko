package bakeneko.asset;

import bakeneko.FileLoader;
import bakeneko.asset.Asset.AssetProp;
import bakeneko.asset.Asset.AssetType;
import bakeneko.asset.Asset.AssetState;
import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.render.NativeTexture;
import bakeneko.render.TextureFilter;
import bakeneko.render.TextureFormat;
import bakeneko.render.TextureUnit;
import bakeneko.render.TextureWrap;
import bakeneko.task.TaskCompletionSource;
import bakeneko.task.TaskExt;
import lime.graphics.Image;
import lime.graphics.PixelFormat;
import lime.utils.UInt8Array;

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
					
					image.buffer.data = image.data;
					
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
		
			
		trace(image.format == PixelFormat.BGRA32, image.buffer.data);
		//lime.graphics.im
		
		nativeTexture = render.createTexture(image.width, image.height);
		render.updaloadTexturePixel(nativeTexture, image.data/*pixelFormat(image)*/);
	}
	
	function pixelFormat(image:Image/*, format:TextureFormat*/) {
		
		var data = image.data;
		var newData = new UInt8Array(data.length);
	
		var index, a16;
		var length = Std.int (data.length / 4);
		var r1, g1, b1, a1, r2, g2, b2, a2;
		var r, g, b, a;
		
		switch (image.format) {
			case RGBA32:
				r1 = 0;
				g1 = 1;
				b1 = 2;
				a1 = 3;
			case ARGB32:
				r1 = 1;
				g1 = 2;
				b1 = 3;
				a1 = 0;
			case BGRA32:
				r1 = 2;
				g1 = 1;
				b1 = 0;
				a1 = 3;
		}
		
		r2 = 2;
		g2 = 1;
		b2 = 0;
		a2 = 3;
				
		/*switch (format) {
			
			case RGBA32:
				
				r2 = 0;
				g2 = 1;
				b2 = 2;
				a2 = 3;
			
			case ARGB32:
				
				r2 = 1;
				g2 = 2;
				b2 = 3;
				a2 = 0;
			
			case BGRA32:
				
				r2 = 2;
				g2 = 1;
				b2 = 0;
				a2 = 3;
			
		}*/
		
		for (i in 0...length) {
			index = i * 4;
			
			r = data[index + r1];
			g = data[index + g1];
			b = data[index + b1];
			a = data[index + a1];
			
			newData[index + r2] = r;
			newData[index + g2] = g;
			newData[index + b2] = b;
			newData[index + a2] = a;
		}
			
		return newData;
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