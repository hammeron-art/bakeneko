package bakeneko.format.bitmapfont;

import bakeneko.core.Log;
import bakeneko.core.Pair;
import bakeneko.utils.Utils;
import bakeneko.format.bitmapfont.BitmapFontData.Character;
import bakeneko.format.bitmapfont.BitmapFontData.Common;
import bakeneko.format.bitmapfont.BitmapFontData.Info;
import bakeneko.format.bitmapfont.BitmapFontData.Page;
import bakeneko.format.bitmapfont.BitmapFontData.Number;
import bakeneko.math.MathUtil;

private enum Token {
	TTag(name:String);
	TString(name:String, value:String);
	TNumber(name:String, value:Float);
	TArray(name:String, valueList:Array<Float>);
}

class BitmapFontReader {

	public var fntData:String;
	public var info:Info;
	public var common:Common;
	public var pageList:Array<Page>;
	public var charList:Array<Character>;
	public var kerning:Map<Array<Int>, Float>;
	
	public function new(fntData:String) {
		Log.assert(fntData.length != 0, "Font data can't be empty");
		this.fntData = fntData;
		
		info = {
			face: '',
			size: 0,
			bold: false,
			italic: false,
			charset: '',
			unicode: false,
			stretchH: 0,
			smooth: false,
			aa: 1,
			padding: null,
			spacing: null,
			outline: 0,
		};
		
		common = {
			lineHeight:0,
			base:0,
			scaleW:0,
			scaleH:0,
			pages:0,
			packed:false,
		};
		
		pageList = [];
		charList = [];
		kerning = new Map();
		
		parse();
	}
	
	public function parse() {
		var tokenList = parseToTokens();
		
		for (tokenLine in tokenList) {
			switch (tokenLine[0]) {
				case TTag(name):
					tokenLine.splice(0, 1);
					parseTag(name, tokenLine);
				default:
			}
		}
	}
	
	function parseToTokens() {
		var tokenList:Array<Array<Token>> = [];
		
		var lineList = fntData.split('\n');
		
		for (line in lineList) {
			var propList = line.split(' ');
			
			var lineTokenList = new Array<Token>();
			
			lineTokenList.push(TTag(propList[0]));
			
			switch (lineTokenList[0]) {
				case TTag('info' | 'common' | 'page' | 'chars' | 'char' | 'kerning'):
				default:
					throw "Invalid Bitmap file format";
			}
			
			for (i in 1...propList.length) {
				var prop:Array<String> = propList[i].split('=');
				
				var valueList = prop[1].split(',');
				
				if (valueList.length == 1) {
					var value = Std.parseFloat(prop[1]);
				
					if (Math.isNaN(value))
						lineTokenList.push(TString(prop[0], prop[1]));
					else
						lineTokenList.push(TNumber(prop[0], value));
				} else {
					var values:Array<Float> = [];
					for (v in valueList)
						values.push(Std.parseFloat(v));
					
					lineTokenList.push(TArray(prop[0], values));
				}
			}
			
			tokenList.push(lineTokenList);
		}
		
		return tokenList;
	}
	
	function parseTag(name:String, tokenLine:Array<Token>) {
		switch (name) {		
			case 'info':
				
				for (i in 0...tokenLine.length) {
					switch (tokenLine[i]) {
						case TString(name, value):
							switch (name) {
								case 'unicode':
									info.unicode = false;
								default:
									Reflect.setField(info, name, value);
							}
							
						case TNumber(name, value):
							switch (name) {
								case 'bold' | 'italic' | 'smooth' | 'unicode':
									Reflect.setField(info, name, value == 1);
								case 'stretchH' | 'smooth' | 'aa' | 'outline':
									Reflect.setField(info, name, value);
							}
						
						case TArray(name, valueList):
							Reflect.setField(info, name, valueList);
						default:
					}
				}
			
			case 'common':
				for (i in 0...tokenLine.length) {
					switch (tokenLine[i]) {
						case TNumber(name, value):
							Reflect.setField(common, name,cast value);
						default:
							throw "BitmapFontReader: unknown property" + tokenLine[i];
					}
				}
			
			case 'page':
				var page:Page = {
					id: -1,
					file: '',
				};
				
				for (i in 0...tokenLine.length) {
					switch (tokenLine[i]) {
						case TNumber('id', value):
							page.id = Std.int(value);
						case TString('file', value):
							var r = ~/"/g;
							page.file = r.replace(value, '');
						default:
							throw "BitmapFontReader: unknown property";
					}
				}
				
				pageList.push(page);
			
			case 'char':
				var char:Character = {
					id: 0,
					x:0,
					y:0,
					width:0,
					height:0,
					xoffset:0,
					yoffset:0,
					xadvance:0,
					page:0,
					chnl:0,
				}
				
				for (i in 0...tokenLine.length) {
					switch (tokenLine[i]) {
						case TNumber(name, value):
							Reflect.setField(char, name, value);
						default:
							throw "BitmapFontReader: unknown property";
					}
				}
				
				charList.push(char);
			
			case 'kerning':

				var first = -1;
				var second = -1;
				var amount = 0;
				
				for (i in 0...tokenLine.length) {
					switch (tokenLine[i]) {
						case TNumber('first', value):
							first = cast value;
						case TNumber('second', value):
							second = cast value;
						case TNumber('amount', value):
							amount = cast value;
						default:
							throw "BitmapFontReader: unknown property";
					}
				}
				
				kerning.set([first, second], amount);
				
			default:
		}
	}
	
}