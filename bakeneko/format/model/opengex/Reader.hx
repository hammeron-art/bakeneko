package bakeneko.format.model.opengex;
import bakeneko.format.openddl.Parser;
import bakeneko.format.openddl.Data;
import haxe.Json;
import haxe.macro.Context;

private typedef Metric = {
	var distance:Float;
	var angle:Float;
	var time:Float;
	var up:String;
}

class Reader {

	static public function read(text:String) {
		var parser = new Parser(text);
		var data = parser.parseDDL();
		
		//trace(Json.stringify(data, null, ' '));
		
		var metricArray = data.find('Metric');

		/*var metrics:Metric = {
			distance: data.
		}*/
		
		trace(Data.findStruct(Data.findStruct(metricArray, null, null, {key: 'distance'}), 'float')[0].values[0]);
		
		return null;
	}
	
}