package bakeneko.asset;

import bakeneko.backend.FileLoader;
import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.asset.Resource;
import bakeneko.task.Task;
import bakeneko.task.TaskCompletionSource;
import bakeneko.task.TaskExt;
import lime.graphics.Image;
import lime.utils.UInt8Array;
import bakeneko.backend.opengl.GL;
import lime.Assets;

/**
 * Handles GPU texture.
 * Can load and create GPU textures from hard-disk or create custom textures.
 * Edition into texture (fill rectangle, resize, draw circle, etc) is GPU accelerated.
 */
class Texture extends Resource implements IResource {

	// CPU resource
	public var asset:Image;

	// GPU texture
	public var textureID(default, null):GLTexture;
	public var textureTarget:Int;
	public var textureType:Int;
	public var textureDataType:Int;

	public var props:TextureProperties;
	
	// Array of pixels
	public var pixels:UInt8Array;
	// Source width
	public var width:Int = -1;
	// Source height
	public var height:Int = -1;
	// Actual width (web target forces power of two textures) 
	public var widthActual:Int = -1;
	// Actual height (web target forces power of two textures)
	public var heightActual:Int = -1;

	public function new(?options:TextureOptions) {
		super(options);
		resourceType = ResourceType.texture;
		textureTarget = GL.TEXTURE_2D;
		textureDataType = GL.RGBA;
		textureType = GL.UNSIGNED_BYTE;

		textureID = GL.createTexture();

		props = {
			wrapS: GL.REPEAT,
			wrapT: GL.REPEAT,
			minFilter: GL.LINEAR,
			magFilter: GL.LINEAR,
		};
		
		if (options != null) {
			if (options.props != null)
				props = options.props;
			
			if (options.pixels != null) {
				pixels = options.pixels;
				
				Log.assert(options.width != null && options.height != null, "width and height must be set when using custom pixel array");
				
				width = options.width;
				height = options.height;
				
				build(options.pixels, width, height);
			}
		}
	}

	public function reload():Task<Texture> {
		clear();

		if (textureID == null)
			textureID = GL.createTexture();

		state = ResourceState.loading;
		var tcs = new TaskCompletionSource<Texture>();
			
		TaskExt.IMMEDIATE_EXECUTOR.execute(function() {
			FileLoader.loadImage(id).onSuccess(function(task:Task<Image>) {
				asset = task.result;
				Log.assert(asset != null, 'Image for $id can\'t be null');
				
				build(asset.data, asset.width, asset.height, asset.width, asset.height);
				tcs.setResult(this);
				state = ResourceState.loaded;
			});
		});
		
		return tcs.task;
	}

	// Set asset info and gpu texture
	public function build(pixelArray:UInt8Array, width:Int, height:Int, ?widthActual:Int, ?heightActual:Int) {
		pixels = pixelArray;
		
		/*for (i in 0...8)
			trace(pixels.toBytes());*/
		
		this.width = width;
		this.height = height;
		this.widthActual = widthActual != null ? widthActual : width;
		this.heightActual = heightActual != null ? heightActual : height;

		state = ResourceState.loaded;
		//TODO: implement premultiply alpha
		
		reloadPixels();
		
		setProperties();
	}

	public function bind(?slot:Int) {
		if (slot != null) {
			GL.activeTexture(GL.TEXTURE0 + slot);
		}

		Log.assert(textureID != null, "Trying to bind null texture");

		GL.bindTexture(textureTarget, textureID);
	}
	
	/**
	 * Reload pixel from raw memory to GPU
	 */
	public function reloadPixels() {
		bind();

		GL.texImage2D(textureTarget, 0, GL.RGBA, widthActual, heightActual, 0, textureDataType, textureType, pixels);
	}

	function setProperties() {
		GL.texParameteri(textureTarget, GL.TEXTURE_WRAP_S, props.wrapS);
		GL.texParameteri(textureTarget, GL.TEXTURE_WRAP_T, props.wrapT);

		GL.texParameteri(textureTarget, GL.TEXTURE_MIN_FILTER, props.minFilter);
		GL.texParameteri(textureTarget, GL.TEXTURE_MAG_FILTER, props.magFilter);
	}

	public function clear():Void {
		if (asset != null) {
			asset = null;
		}
		
		pixels = null;

		if (textureID != null) {
			GL.deleteTexture(textureID);
			textureID = null;
		}
	}

	public function memoryUsage():Int {
		if (asset == null)
			return 0;
		return asset.buffer.data.length;
	}
}

@:enum
abstract PropType(Int) from Int to Int {
	var REPEAT = GL.REPEAT;
	var CLAMP_TO_EDGE = GL.CLAMP_TO_EDGE;
	var MIRRORED_REPEAT = GL.MIRRORED_REPEAT;
	
	var NEAREST = GL.NEAREST;
	var LINEAR = GL.LINEAR;
	
	var RGBA = GL.RGBA;
}

typedef TextureProperties = {
	var wrapS:Int;
	var wrapT:Int;
	var minFilter:Int;
	var magFilter:Int;
}

typedef TextureOptions = {
	> ResourceOptions,
	
	@:optional var props:TextureProperties;
	@:optional var pixels:UInt8Array;
	@:optional var width:Int;
	@:optional var height:Int;
	
}