package bakeneko.render;

import bakeneko.hxsl.ShaderList;
import bakeneko.render.Color;
import lime.utils.UInt8Array;

interface IRenderer {
	public function reset():Void;
	
	public function begin(surfaces:Array<Surface> = null):Void;
	public function end():Void;
	
	public function createVertexBuffer(vertexCount:Int, structure: VertexStructure, ?usage:Usage):VertexBuffer;
	public function createIndexBuffer(vertexCount:Int, structure: VertexStructure, ?usage:Usage):IndexBuffer;
	
	public function createTexture(width:Int, height:Int, ?format:TextureFormat):NativeTexture;
	public function deleteTexture(texture:NativeTexture):Void;
	public function updaloadTexturePixel(texture:NativeTexture, pixel:UInt8Array):Void;
	
	public function clear(?color:Color, ?depth:Float, ?stencil:Int):Void;
	public function viewport(x:Int, y:Int, width:Int, height:Int):Void;
	
	public function present():Void;
}