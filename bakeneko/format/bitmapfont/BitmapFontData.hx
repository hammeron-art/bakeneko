package bakeneko.format.bitmapfont;

import bakeneko.core.Pair;

/**
 * Bitmap Font format specification:
 * http://www.angelcode.com/products/bmfont/doc/file_format.html
 */

typedef Info = {
	var face:String;
	var size:Number;
	var bold:Bool;
	var italic:Bool;
	var charset:String;
	var unicode:Bool;
	var stretchH:Number;
	var smooth:Bool;
	var aa:Int;
	var padding:CharPadding;
	var spacing:Spacing;
	var outline:Number;
}

typedef Common = {
	var lineHeight:Number;
	var base:Number;
	var scaleW:Number;
	var scaleH:Number;
	var pages:Int;
	var packed:Bool;
}

typedef Page = {
	var id:Int;
	var file:String;
}

typedef Character = {
	var id:Int;
	var x:Number;
	var y:Number;
	var width:Number;
	var height:Number;
	var xoffset:Number;
	var yoffset:Number;
	var xadvance:Number;
	var page:Int;
	var chnl:Int;
}

typedef CharPadding = {
	var up:Number;
	var right:Number;
	var down:Number;
	var left:Number;
}

typedef Spacing = {
	var horizontal:Int;
	var vertical:Int;
}

typedef Number = Int;