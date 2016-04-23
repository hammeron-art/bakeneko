package bakeneko.geometry;

import bakeneko.math.MathUtil;
import bakeneko.math.Vector2;

/**
 * A 2D rectangle shape
 */
class Rectangle {
	
	public var x:Float;
    public var y:Float;
    public var width:Float;
    public var height:Float;
    
    // Get the center of the rectangle
    public var center(get, never):Vector2;
    
    // Get the area
    public var area(get, never):Float;
	
    public function new(x:Float = 0.0, y:Float = 0.0, width:Float = 0.0, height:Float = 0.0) {
        set(x, y, width, height);
    }
	
	public inline function set(x:Float, y:Float, width:Float, height:Float) {
		this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
	}
	
    public inline function equals(r:Rectangle):Bool {
        return r != null &&
            x == r.x &&
            y == r.y &&
            width == r.width &&
            height == r.height;
    }
 
    public inline function clone():Rectangle {
        return new Rectangle(x, y, width, height);
	}
	
	/**
     * Checks whether a point is inside this rectangle.
     * All coordinate ranges are treated as closed.
     * 
     * @param    point	The point to test.
     * @return        	True if the point is contained.
     */
    public inline function containsPoint(point:Vector2):Bool {
        return ShapeIntersection.rectangleVsPoint(this, point);
    }
	
	/**
     * Checks whether a rectangle is inside this rectangle.
     * All coordinate ranges are treated as closed.
     * 
     * @param    rectagle	The rectangle to test.
     * @return        		True if the point is contained.
     */
    public inline function containsRectangle(rectangle:Rectangle):Bool {
        return ShapeIntersection.rectangleVSRectangle(this, rectangle);
    }
	
	/**
     * Get a vertex by index. Vertices are ordered counter-clockwise with the origin as 0.
     * 
     * @param index     The index of the vertex.
     * @return          The vertex.
     */
    public inline function getVertex(index:Int):Vector2 {
        var v = new Vector2(x, y);
        
        switch (index) {
            case 0:
            case 1:
                v.x += width;
            case 2:
                v.x += width;
                v.y += height;
            case 3:
                v.y += height;
            default:
                throw "Invalid vertex index.";
        }
        
        return v;
    }
	
	private inline function get_center():Vector2 {
        return new Vector2(
            x + 0.5 * width,
            y + 0.5 * height);
    }
    
    private inline function get_area():Float {
        return width * height;
    }
	
	public function toString():String {
		return '{x: $x, y: $y, width: $width, height: $height}';
	}
}