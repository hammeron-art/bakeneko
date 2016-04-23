package bakeneko.format.openddl;

import bakeneko.format.openddl.Data.DataType;
import bakeneko.format.openddl.Data.Struct;
import bakeneko.format.openddl.Data.Value;

/**
 * Data returned by the OpenDDL reader
 */
 
enum DataType {
	TBool;
	TInt;
	TFloat;
	TString;
	TReference;
	TNull;
	TStruct(t:String);
	
	TArray(t:DataType, size:Int);
}

enum Value {
	VBool(b:Bool);
	VInt(v:Int);
	VFloat(v:Float);
	VString(s:String);
	VStruct(v:Struct);
	
	VArray(a:Array<Value>);
}

typedef Struct = {
	var name:String;
	var type:String;
	var values:Array<Dynamic>;
	var props:{};
}

class Data {
	var data:Struct;
	
	public function new(data:Struct) {
		this.data = data;
	}
	
	public function find(type:String, name:String = '', props:Dynamic = null):Array<Dynamic> {
		return findStruct(data.values, type, name, props);
	}
	
	static public function findStruct(data:Array<Dynamic>, type:String , name:String = '', props:Dynamic = null):Array<Dynamic> {
		var result = [];
		
		if (data != null) {
			result = data.filter(function (struct:Struct) {
				return isStruct(struct, type, name, props);
			});
			
			if (result == null || result.length == 0) {
				for (struct in data) {
					result = findStruct(struct.values, type, name, props);
				}
			}
		}
		
		return result;
	}
	
	static public function isStruct(struct:Struct, type:String = null, name:String = null, props:Dynamic = null):Bool {
		var result = false;
		
		if (type == null)
			result = true;
		else if (struct.type == type)
			result = true;
		else
			return false;
			
		if (name == null)
			result = true;
		else if (struct.name == name)
			result = true;
		else
			return false;
			
		if (props == null)
			result = true;
		else {
			var props0 = Reflect.fields(props);
			var props1 = Reflect.fields(struct.props);
			
			if (props0.length != props1.length)
				return false;
			
			for (i in 0...props0.length) {
				if (Reflect.field(props, props0[i]) != Reflect.field(struct.props, props1[i]))
					return false;
			}
		}
	
		return result;
	}
	
	static public function getValue(struct:Dynamic) {
		return struct.values[0].values[0].values[0];
	}
}