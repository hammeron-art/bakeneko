package bakeneko.backend;

import bakeneko.task.Task;
import bakeneko.task.TaskCompletionSource;
import lime.app.Future;
import lime.app.Promise;
import lime.Assets;
import lime.graphics.Image;
import lime.net.HTTPRequest;
import lime.utils.Bytes;

/**
 * Direct file loading
 * Use ResourceManager for cache and other features
 */
class FileLoader {

	static var library:DefaultAssetLibrary;
	
	// Called by ApplicationMain
	static function init() {
		library = new DefaultAssetLibrary();
	}
	
	static public function loadText(id:String):Task<String> {
		var promise = new Promise<String> ();
		
		var tcs = new TaskCompletionSource();
		
		library.loadText(id).onComplete(function(text:String) {
			tcs.setResult(text);
		}).onError(function(error:Dynamic) {
			tcs.setError(error);
		});
		
		return tcs.task;
	}
	
	static public function loadImage(id:String):Task<Image> {
		var promise = new Promise<Image> ();
		
		var tcs = new TaskCompletionSource();
		
		library.loadImage(id).onComplete(function(text:Image) {
			tcs.setResult(text);
		}).onError(function(error:Dynamic) {
			tcs.setError(error);
		});
		
		return tcs.task;
	}
	
	static public function loadFont(id:String):Task<lime.text.Font> {
		var promise = new Promise<lime.text.Font> ();
		
		var tcs = new TaskCompletionSource();
		
		library.loadFont(id).onComplete(function(font:lime.text.Font) {
			tcs.setResult(font);
		}).onError(function(error:Dynamic) {
			tcs.setError(error);
		});
		
		return tcs.task;
	}
	
	static public function getText(path:String) {
		return library.getText(path);
	}
	
	static public function getBytes(path:String):Bytes {
		return library.getBytes(path);
	}
	
	static public function getFont(path:String):lime.text.Font {
		return library.getFont(path);
	}
	
	static public function getImage(path:String) {
		return library.getImage(path);
	}
	
}