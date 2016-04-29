package bakeneko.utils;

import haxe.macro.Context;
import haxe.macro.Expr;

class MacroUtils {

	static public function formatedExprString(expr:Expr) {
		Utils.formatedCodeString('$expr');
	}
	
	/*static public function reifyStructExpr(struct:Dynamic):ExprDef {
		if (Std.is(struct, String)) {
			var e = macro $v{struct};
			return e.expr;
		}
		
		var names = Reflect.fields(struct);
		return EObjectDecl([
			for (name in names) {
				{
					expr: {
						expr: reifyStructExpr(Reflect.field(struct, name)),
						pos: Context.currentPos()
					},
					field: name
				}
			}
		]);
	}*/
	
	static public function reifyStructComplexType(struct:Dynamic):ComplexType {
		return switch (Type.typeof(struct)) {
			case TClass(c):
				Context.toComplexType(Context.getType(Type.getClassName(c)));
			default:
				var fieldNames = Reflect.fields(struct);
		
				var array = [];
				
				TAnonymous([
					for (id in fieldNames) {
						{
							name: id,
							pos: Context.currentPos(),
							kind:FVar(reifyStructComplexType(Reflect.field(struct, id)))
						}
					}
				]);
		}
	}
	
}