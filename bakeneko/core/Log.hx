package bakeneko.core;

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;

class Log {

	/**
	 * HaxeDevelop prefix for colored trace
	 * Info:
	 * Debug:
	 * Warnning:
	 * Error:
	 * Fatal:
	 */
	
	static var debugLevel:Int = #if debug 2 #else 0 #end;

	macro public static function info(message:Dynamic, ?level:Int = 2):Expr {
		if (level <= debugLevel)
		{
			var file = Path.withoutDirectory(getSender());
			var context = Path.withoutExtension(file);
			
			return macro @:pos(Context.currentPos()) trace('Info: ' + $message);
		}
		
		return macro null;
	}

	macro public static function warn(message:Dynamic, ?level:Int = 1):Expr {
		if (level <= debugLevel)
		{
			var file = Path.withoutDirectory(getSender());
			var context = Path.withoutExtension(file);
			
			return macro @:pos(Context.currentPos()) trace('Warnning: ' + $message);
		}
		
		return macro null;
	}
	
	macro public static function api(message:Dynamic, ?level:Int = 1):Expr {
		if (level <= debugLevel)
		{
			var file = Path.withoutDirectory(getSender());
			var context = Path.withoutExtension(file);
			
			return macro @:pos(Context.currentPos()) trace('Warnning: API: ' + $message);
		}
		
		return macro null;
	}
	
	macro public static function error(message:Dynamic):Expr {
		var file = Path.withoutDirectory(getSender());
		var context = Path.withoutExtension(file);

		return macro @:pos(Context.currentPos()) trace('Error: ' + $message);
	}

	macro public static function assert(expr:Expr, ?message:Dynamic) {
		if (debugLevel > 0) {
			var str = haxe.macro.ExprTools.toString(expr);
			
			return macro @:pos(Context.currentPos()) {
				if (!$expr)
					if ($message != null) {
						trace('Fatal: $str => ' + $message);
						throw bakeneko.core.Log.LogType.assertion('$str, ' + $message);
					} else {
						throw bakeneko.core.Log.LogType.assertion('$str');
					}
			}
		}
		
		return macro null;
	}

	macro static function getSender() {
		return macro Context.getPosInfos(Context.currentPos()).file;
	}
}

enum LogType {
	assertion(message:String);
	error(message:String);
}
