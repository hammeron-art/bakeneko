package bakeneko.asset;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import lime.Assets;
import lime.project.Library;

class Macros {
	static public function build() {
		var fields = Context.getBuildFields();
		
		//var a = new Library();
		
		//trace(ApplicationMain.config.assetsPrefix);
		var ids = ['jkl', 'fdg'];
		
		var gtype = TAnonymous([for (id in ids) {name: id, pos: Context.currentPos(), kind:FVar(macro : String)}]);
		
		var gids : Field = {
			name: 'gids',
			pos: Context.currentPos(),
			kind: FVar(gtype),
			access: [AStatic],
		};
		
		for (i in 0...fields.length) {
			if (fields[i].name == 'gids') {
				fields[i] = gids;
			}
		}
		
		//fields.push(gids);
		
		return fields;
	}
}