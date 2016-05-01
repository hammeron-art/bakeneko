package bakeneko.render;

class NativeTexture implements TextureUnit {

	public var texture: #if flash flash.display3D.textures.Texture #else lime.graphics.opengl.GLTexture #end ;
	public var width:Int;
	public var height:Int;
	public var format:TextureFormat;
	
	public function new(texture, width:Int, height:Int, ?format:TextureFormat) {
		this.texture = texture;
		this.width = width;
		this.height = height;
		this.format = format != null ? format : TextureFormat.RGBA32;
	}
	
}