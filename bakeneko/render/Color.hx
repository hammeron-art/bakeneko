package bakeneko.render;

class Color
{
	public var r:Float;
	public var g:Float;
	public var b:Float;
	public var a:Float;
	
	public inline function new(r:Float = 1.0, g:Float = 1.0, b:Float = 1.0, a:Float = 1.0)
	{
		set(r, g, b, a);
	}
	
	public inline function set(r:Float, g:Float, b:Float, a:Float)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}
	
	public inline function setInt24(rgb:Int) {
		r = (rgb >> 16) / 255.0;
		g = (rgb >> 8 & 0xFF) / 255.0;
		b = (rgb & 0xFF) / 255.0;
	}
	
	public inline function setInt32(argb:Int) {
		a = (argb >> 24 & 0xFF) / 255.0;
		r = (argb >> 16 & 0xFF) / 255.0;
        g = (argb >> 8 & 0xFF) / 255.0;
        b = (argb & 0xFF) / 255.0;
	}
	
	public static function fromInt24(rgb:Int)
	{

        var r = (rgb >> 16) / 255.0;
        var g = (rgb >> 8 & 0xFF) / 255.0;
        var b = (rgb & 0xFF) / 255.0;
		
		return new Color(r, g, b, 1.0);
    }
	
	public static function fromInt32(argb:Int)
	{
		
		var a = (argb >> 24 & 0xFF) / 255.0;
		var r = (argb >> 16 & 0xFF) / 255.0;
        var g = (argb >> 8 & 0xFF) / 255.0;
        var b = (argb & 0xFF) / 255.0;
		
		return new Color(r, g, b, a);
	}
	
	public inline function clone()
	{
		return new Color(r, g, b, a);
	}
	
	public inline function copy(color:Color)
	{
		r = color.r;
		g = color.g;
		b = color.g;
		a = color.a;
	}

}

// Common colors
@:enum abstract ColorSet(Color) from Color to Color
{
	public static var white = new Color(1.0, 1.0, 1.0);
	public static var black = new Color(0.0, 0.0, 0.0);
	public static var grey = new Color(0.5, 0.5, 0.5);
	public static var red = new Color(1.0, 0.0, 0.0);
	public static var green = new Color(0.0, 1.0, 0.0);
	public static var blue = new Color(0.0, 0.0, 1.0);
}