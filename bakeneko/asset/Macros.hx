package bakeneko.asset;

import bakeneko.utils.MacroUtils;
import bakeneko.utils.Utils;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import sys.FileSystem;

using StringTools;

class Macros {
	
	static public function build(directory:String) {
		var fields = Context.getBuildFields();
		
		var root = Context.resolvePath(directory);
		var files = getFileStructure(root);
		
		var expr:Array<{field:String, expr:Expr}> = [];

		for (i in 0...fields.length) {
			for (meta in fields[i].meta) {
				if (meta.name == 'assets') {
					fields[i] = {
						name: fields[i].name,
						pos: Context.currentPos(),
						kind: FVar(MacroUtils.reifyStructComplexType(files), macro $v{files}),
						access: fields[i].access,
					};
				}
			}
		}
		
		return fields;
	}
	
	static function getFileStructure(directory:String, ?filterExtensions:Array<String>) {
		
		var files = {};
		
		var resolvedPath = #if (ios || tvos) Context.resolvePath(directory) #else directory #end;
		var directoryInfo = FileSystem.readDirectory(resolvedPath);
		for (name in directoryInfo) {
			if (!FileSystem.isDirectory(resolvedPath + name)) {
				if (name.startsWith("."))
					continue;
				
				if (filterExtensions != null) {
					var extension:String = name.split('.')[1];
					if (filterExtensions.indexOf(extension) == -1)
						continue;
				}
				
				Reflect.setField(files, normalizeName(name), directory + name);
			} else {
				var split:Array<String> = name.split('/');
				var folder = split[split.length - 1];
				
				Reflect.setField(files, normalizeName(name), getFileStructure(directory + name + '/', filterExtensions));
			}
		}
		
		return files;
	}
	
	static function normalizeName(name:String):String {
		return name.replace(' ', '_').replace('.', '_');
	}

}