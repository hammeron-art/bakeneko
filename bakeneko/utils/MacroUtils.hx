package bakeneko.utils;

import haxe.macro.Context;
import haxe.macro.Expr;

class MacroUtils {

	static public function formatedExprString(expr:Expr) {
		Utils.formatedCodeString('$expr');
	}
	
	static public function reifyDynamicStruct(struct:Dynamic):ExprDef {
		if (Std.is(struct, String)) {
			var e = macro $v{struct};
			return e.expr;//EConst(CString(struct));
		}
		
		var names = Reflect.fields(struct);
		return EObjectDecl([
			for (name in names) {
				{
					expr: {
						expr: reifyDynamicStruct(Reflect.field(struct, name)),
						pos: Context.currentPos()
					},
					field: name
				}
			}
		]);
	}
	
}