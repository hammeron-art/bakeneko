package bakeneko.render;

import bakeneko.hxsl.ShaderList;
import bakeneko.render.Color;

interface IRenderer {
	public function reset():Void;
	
	public function begin(surfaces:Array<Surface> = null):Void;
	public function end():Void;
	
	public function createVertexBuffer(vertexCount:Int, structure: VertexStructure, ?usage:Usage):VertexBuffer;
	public function createIndexBuffer(vertexCount:Int, structure: VertexStructure, ?usage:Usage):IndexBuffer;
	public function createPipeline(?shaderList:ShaderList):Pipeline;
	
	public function clear(?color:Color, ?depth:Float, ?stencil:Int):Void;
	public function viewport(x:Int, y:Int, width:Int, height:Int):Void;
	
	public function present():Void;
}