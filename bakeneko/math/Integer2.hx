package hxmath.math;

/**
 * The default underlying type.
 */
class Integer2Default
{
    public var x:Int;
    public var y:Int;
    
    public function new(x:Int, y:Int)
    {
        this.x = x;
        this.y = y;
    }
    
    public function toString():String
    {
        return '($x, $y)';
    }
}

/**
 * A 2D vector with integer values. Used primarily for indexing into 2D grids.
 */
@:forward(x, y)
abstract Integer2(Integer2Default) from Integer2Default to Integer2Default
{
    // Zero vector (v + 0 = v)
    public static var zero(get, never):Integer2;
        
    /**
     * Constructor.
     * 
     * @param x
     * @param y
     */
    public function new(x:Int, y:Int)
    {
        this = new Integer2Default(x, y);
    }
    
    /**
     * Convert to a Vector2.
     * 
     * @return  The equivalent Vector2.
     */
    @:to
    public inline function toVector2():Vector2 
    {
        var self:Integer2 = this;
        return new Vector2(self.x, self.y);
    }
    
    private static inline function get_zero():Integer2
    {
        return new Integer2(0, 0);
    }
}