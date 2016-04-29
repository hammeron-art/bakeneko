package bakeneko.utils;

using StringTools;

class Utils {

	// Generate unique string ID
	public static function uniqueID(?val:Null<Int>):String {
		// http://www.anotherchris.net/csharp/friendly-unique-id-generation-part-2/#base62

		if(val == null) {
            #if neko val = Std.random(0x3FFFFFFF);
            #else val = Std.random(0x7fffffff);
            #end
        }

        function to_char(value:Int) : String {
            if (value > 9) {
                var ascii = (65 + (value - 10));

                if (ascii > 90)
					ascii += 6;

                return String.fromCharCode(ascii);
            } else {
				return Std.string(value).charAt(0);
			}
        }

        var r = Std.int(val % 62);
        var q = Std.int(val / 62);

        if (q > 0)
			return uniqueID(q) + to_char(r);
        else
			return Std.string(to_char(r));
	}

	public static inline function int(bool:Bool):Int {
		if (bool)
			return 1;
		return 0;
	}
	
	@:generic
	public static inline function cycle<T:(Float, Int)>(value:T, max:T) {
		return ((value % max) + max) % max;
	}
	
	@:generic
	public static inline function angleDifference<T:(Float, Int)>(angle1:T, angle2:T) {
		return ((((angle1 - angle2) % 360) + 540) % 360) - 180;
	}
	
	public static function formatedCodeString(code:String) {
		var str = code.replace('{ ', '{\n').replace(' }', '\n}').replace('[', '[\n').replace(']', '\n]')
		.replace(', ', ',').replace(',', ',\n').replace('; ', ';').replace(';', ';\n')
		.replace(' : ', ':').replace('\n\n', '\n');
		
		var result = '';
		var c = '';
		var tabs = 0;
		
		var i = 0;
		while (i < str.length) {
			c = str.charAt(i);
			
			if (c == '{' || c == '[') {
				++tabs;
			}
			if (c == '}' || c == ']') {
				--tabs;
				result = result.substr(0, result.length - 1);
			}
			
			if (c == '\n') {
				result += c;
				for (ii in 0...tabs) {
					result += '\t';
				}
				++i;
				continue;
			}
			
			result += c;
			++i;
		}
		
		return result;
	}

}