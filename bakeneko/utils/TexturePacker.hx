package bakeneko.utils;

import bakeneko.core.Log;
import bakeneko.task.Task;
import bakeneko.task.TaskExt;
import haxe.io.Path;
import lime.project.Haxelib;
import lime.tools.helpers.PathHelper;
import lime.tools.helpers.ProcessHelper;

class TexturePacker {
	
	public static var packing(default, null):Bool = false;
	
	public static function process(inputDir:String, outputDir:String, packFileName:String) {
		packing = true;
		
		inputDir = Path.normalize(Sys.getCwd() + inputDir);
		outputDir = Path.normalize(Sys.getCwd() + outputDir);

		var toolPath = Path.normalize(PathHelper.getHaxelib(new Haxelib('bakeneko')) + '\\tools\\packer');

		//var tcs = new TaskCompletionSource<Texture>();
		
		var out = ProcessHelper.runCommand(toolPath, 'java', ['-cp', 'gdx.jar;gdx-tools.jar', 'com.badlogic.gdx.tools.texturepacker.TexturePacker', inputDir, outputDir, packFileName]);
		
		if (out != 0) {
			Log.error('Can\'t create texture pack');
		}
		
		packing = false;
	}
	
}