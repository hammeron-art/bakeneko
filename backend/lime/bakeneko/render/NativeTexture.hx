package bakeneko.render;

class NativeTexture implements TextureUnit {

	public var texture:Dynamic;
	public var width:Int;
	public var height:Int;
	public var format:TextureFormat;
	
	public function new(texture:Dynamic, width:Int, height:Int, ?format:TextureFormat) {
		this.texture = texture;
		this.width = width;
		this.height = height;
		this.format = format != null ? format : TextureFormat.RGBA32;
	}
	
}