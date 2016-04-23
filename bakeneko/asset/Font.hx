package bakeneko.asset;

import bakeneko.asset.Resource;
import bakeneko.backend.FileLoader;
import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.format.bitmapfont.BitmapFontData.Page;
import bakeneko.format.bitmapfont.BitmapFontReader;
import bakeneko.task.Task;
import bakeneko.task.TaskCompletionSource;
import bakeneko.task.TaskExt;
import haxe.io.Path;

class Font extends Resource implements IResource {
	
	public var asset:String;
	
	var bitmapFont:BitmapFontReader;
	public var texturePages:Map<Int, Texture>;
	
	public function new(?options:ResourceOptions) {
		super(options);
		resourceType = ResourceType.font;
		
		texturePages = new Map();
	}
	
	public function reload():Task<Font> {
		clear();
		
		var tcs = new TaskCompletionSource<Font>();
		state = ResourceState.loading;
		
		TaskExt.IMMEDIATE_EXECUTOR.execute(function() {
			asset = FileLoader.getText(id);
			Log.assert(asset != null, 'Font for $id can\'t be null');
			
			bitmapFont = new BitmapFontReader(asset);
			
			loadPages(bitmapFont.pageList).onSuccess(function(task:Task<Map<Int, Texture>>) {
				state = ResourceState.loaded;
				tcs.setResult(this);
			});
		});
		
		return tcs.task;
	}
	
	function loadPages(pages:Array<Page>) {
		
		var tcs = new TaskCompletionSource<Map<Int, Texture>>();
		state = ResourceState.loading;
		
		var textPages = new Map<Int, Texture>();
		
		TaskExt.IMMEDIATE_EXECUTOR.execute(function() {
			var taskList = [];
			for (page in pages) {
				var task = Application.get().resourceManager.loadTexture({id: Path.directory(id) + '/' + page.file});
				task.onSuccess(function (task:Task<Texture>) {
					textPages.set(page.id, task.result);
				});
				
				taskList.push(task);
			}
			
			Task.whenAll(taskList).onSuccess(function(_) {
				tcs.setResult(textPages);
			});
		});
		
		return tcs.task;
	}
	
	public function clear():Void {
		if (asset != null) {
			asset = null;
		}
		bitmapFont = null;
	}
	
	public function memoryUsage():Int {
		/*var usage = asset.length;
		
		for (page in texturePages) {
			usage += page.memoryUsage();
		}
		
		return usage;*/
		return 0;
	}
	
}