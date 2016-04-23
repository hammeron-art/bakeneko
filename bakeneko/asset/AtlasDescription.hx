package bakeneko.asset;

import bakeneko.core.Log;

class AtlasDescription {

	var packs:Map<String, Pack>;
	
	var line:Int;
	var reg = ~/[\w-+.:]+/gm;
	
	public function new(text:String) {
		read(text);
	}
	
	public function read(text:String) {
		packs = new Map();
		line = 0;
		
		var lines = text.split('\n');

		while (line < lines.length) {
			if (lines[line] == '') {
				++line;
				continue;
			}
			
			packs.set(lines[line], readPack(lines));
		}
	}
	
	function readPack(lines:Array<String>) {
		var pack:Pack = {
			name: lines[line++],
			width: 0,
			height: 0,
			format: '',
			filter: 0,
			repeat: false,
			regions: [],
		}
		
		inline function next() {
			reg.match(reg.matchedRight());
		}
		inline function get() {
			return reg.matched(0);
		}
		
		while (lines[line] != '') {
			reg.match(lines[line++]);

			//trace(reg.matched(0), reg.matched(1), reg.matched(2));
			var name = reg.matched(0);
			switch(name) {
				case 'size:':
					next();
					pack.width = Std.parseInt(get());
					next();
					pack.height = Std.parseInt(get());
				case 'format:':
					next();
					pack.format = get();
				case 'filter:':
					next();
				case 'repeat:':
					next();
				default:
					--line;
					var region = readRegion(lines);
					pack.regions.push(region);
			}
		}
		
		return pack;
	}
	
	function readRegion(lines:Array<String>) {
		var region:Region = {
			name:  lines[line++],
			rotate: false,
			x: 0,
			y: 0,
			width: 0,
			height: 0,
			originX: 0,
			originY: 0,
			offsetX: 0,
			offsetY: 0,
			index: -1,
		};
		
		inline function next() {
			reg.match(reg.matchedRight());
		}
		inline function get() {
			return reg.matched(0);
		}

		while (lines[line] != '') {
			reg.match(lines[line++]);
			
			switch(reg.matched(0)) {
				case 'rotate:':
					next();
					region.rotate = switch (get()) {
						case 'true':
							true;
						default:
							false;
					}
				case 'xy:':
					next();
					region.x = Std.parseInt(get());
					next();
					region.y = Std.parseInt(get());
				case 'size:':
					next();
					region.width = Std.parseInt(get());
					next();
					region.height = Std.parseInt(get());
				case 'orig:':
					next();
					region.originX = Std.parseInt(get());
					next();
					region.originY = Std.parseInt(get());
				case 'offset:':
					next();
					region.offsetX = Std.parseInt(get());
					next();
					region.offsetY = Std.parseInt(get());
				case 'index:':
					next();
					region.index = Std.parseInt(get());
				default:
					--line;
					return region;
			}
		}
		
		return region;
	}
	
}

typedef Pack = {
	var name:String;
	var width:Int;
	var height:Int;
	var format:String;
	var filter:Int;
	var repeat:Bool;
	var regions:Array<Region>;
}

typedef Region = {
	var name:String;
	var rotate:Bool;
	var x:Int;
	var y:Int;
	var width:Int;
	var height:Int;
	var originX:Int;
	var originY:Int;
	var offsetX:Int;
	var offsetY:Int;
	var index:Int;
}