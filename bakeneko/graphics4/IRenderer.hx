package bakeneko.graphics4;

import bakeneko.render.Color;

interface IRenderer {
	public function begin(surfaces:Array<Surface> = null):Void;
	public function end():Void;
	
	public function clear(?color:Color, ?depth:Float, ?stencil:Int):Void;
	public function viewport(x:Int, y:Int, width:Int, height:Int):Void;
	
	public function present():Void;
}