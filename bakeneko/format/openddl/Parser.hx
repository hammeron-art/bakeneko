package bakeneko.format.openddl;

import bakeneko.format.openddl.Data;

import haxe.Json;
import hxparse.Parser.parse as parse;

enum TokenDef {
	TkComment(s:String);
	
	TkIdent(s:String);
	TkName(s:String);
	TkKeyword(k:Keyword);
	
	TkArray(size:Int);
	TkInt(v:Int);
	TkFloat(v:Float);
	TkBool(v:Bool);
	TkString(s:String);
	
	TkEqual;
	TkComma;
	TkBraceOpen;
	TkBraceClose;
	TkBracketOpen;
	TkBracketClose;
	TkParentOpen;
	TkParentClose;
	
	TkEof;
}

enum Keyword {
	KBool;
	KInt;
	KFloat;
	KString;
	KRef;
	
	KInt8;
	KInt16;
	KInt32;
	KInt64;
	
	KUnsigned_int8;
	KUnsigned_int16;
	KUnsigned_int32;
	KUnsigned_int64;
	
	KNull;
}

typedef Position = {
	var lineMin:Int;
	var lineMax:Int;
	var posMin:Int;
	var posMax:Int;
}

class Token {
	public var tok: TokenDef;
	public var pos: Dynamic;

	public function new(tok, pos) {
		this.tok = tok;
		this.pos = pos;
	}
	
	public function toString() {
		return 'Unexpected token ${tok} at ${pos}';
	}
}

class DDLLexer extends hxparse.Lexer implements hxparse.RuleBuilder {
	
	static function mkPos(lexer:hxparse.Lexer, p:hxparse.Position) {
		return p.getLinePosition(lexer.input);
	}
	
	static function mk(lexer:hxparse.Lexer, td) {

		return new Token(td, mkPos(lexer, lexer.curPos()));
	}
	
	static var buf:StringBuf;
	
	static var keywords = @:mapping(1) Keyword;
	
	public static var tok = @:rule [
		"0x[0-9a-fA-F]+" => mk(lexer, TkInt(Std.parseInt(lexer.current))),
		"-*[0-9]+" => mk(lexer, TkInt(Std.parseInt(lexer.current))),
		"-*[0-9]+\\.[0-9]+" => mk(lexer, TkFloat(Std.parseFloat(lexer.current))),
		"-*\\.[0-9]+" => mk(lexer, TkFloat(Std.parseFloat(lexer.current))),
		"-*[0-9]+[eE][\\+\\-]?[0-9]+" => mk(lexer, TkFloat(Std.parseFloat(lexer.current))),
		"-*[0-9]+\\.[0-9]*[eE][\\+\\-]?[0-9]+" => mk(lexer, TkFloat(Std.parseFloat(lexer.current))),
		
		"//[^\n\r]*" => mk(lexer, TkComment(lexer.current.substr(2))),
		"/\\*" => {
			buf = new StringBuf();
				var pmin = lexer.curPos();
				var pmax = try lexer.token(comment) catch (e:haxe.io.Eof) throw 'Unclosed comment, $pmin';
				mk(lexer, TkComment(buf.toString()));
		},
		
		"($|%)_*[a-z][a-zA-Z0-9_]*|_+|_+[0-9][_a-zA-Z0-9]*" => mk(lexer, TkName(lexer.current.substr(1))),
		"_*[a-zA-Z][a-zA-Z0-9_]*|_+|_+[0-9][_a-zA-Z0-9]*" => {
			if (lexer.current == 'true') {
				mk(lexer, TkBool(true));
			} else if (lexer.current == 'false') {
				mk(lexer, TkBool(false));
			} else {
				var kwd = keywords.get(lexer.current);
				
				if (kwd != null)
					mk(lexer, TkKeyword(kwd));
				else 
					mk(lexer, TkIdent(lexer.current));
			}
		},
		
		"\\[[0-9]+\\]" => mk(lexer, TkArray(Std.parseInt(lexer.current.substr(1, lexer.current.length - 2)))),
		
		"=" => mk(lexer, TkEqual),
		"," => mk(lexer, TkComma),
		"{" => mk(lexer, TkBraceOpen),
		"}" => mk(lexer, TkBraceClose),
		"[" => mk(lexer, TkBracketOpen),
		"]" => mk(lexer, TkBracketClose),
		"\\(" => mk(lexer, TkParentOpen),
		"\\)" => mk(lexer, TkParentClose),
		
		'"' => {
			buf = new StringBuf();
			lexer.token(string);
			mk(lexer, TkString(buf.toString()));
		},
		"[\r\n\t ]" => lexer.token(tok),
		"" => mk(lexer, TkEof)
	];
	
	static var string = @:rule [
		"\\\\t" => {
			buf.addChar("\t".code);
			lexer.token(string);
		},
		"\\\\n" => {
			buf.addChar("\n".code);
			lexer.token(string);
		},
		"\\\\r" => {
			buf.addChar("\r".code);
			lexer.token(string);
		},
		'\\\\"' => {
			buf.addChar('"'.code);
			lexer.token(string);
		},
		"\\\\u[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]" => {
			buf.add(String.fromCharCode(Std.parseInt("0x" +lexer.current.substr(2))));
			lexer.token(string);
		},
		'"' => {
			lexer.curPos().pmax;
		},
		'[^"]' => {
			buf.add(lexer.current);
			lexer.token(string);
		},
	];
	
	public static var comment = @:rule [
		"*/" => lexer.curPos().pmax,
		"*" => {
			buf.add("*");
			lexer.token(comment);
		},
		"[^\\*]+" => {
			buf.add(lexer.current);
			lexer.token(comment);
		}
	];
}

class Parser extends hxparse.Parser<hxparse.LexerTokenSource<Token>, Token> implements hxparse.ParserBuilder {

	var lexer:DDLLexer;
	
	public function new(text:String) {
		lexer = new DDLLexer(byte.ByteData.ofString(text), '');
		var ts = new hxparse.LexerTokenSource(lexer, DDLLexer.tok);
		super(ts);
	}
	
	public function parseDDL():Data {
		
		var root:Struct = {
			name: '',
			type: '',
			values: parseStructs(),
			props: {}
		};
		
		return new Data(root);
	}
	
	function parseStructs():Array<Struct> {
		var array = [];

		while (true) {
			switch (peek(0)) {
				case {tok: TkIdent(s)}:
					var struct = parseStruct();
					array.push(struct);
					
				case {tok: TkKeyword(k)}:
					var struct = parseStruct();
					array.push(struct);
				
				case {tok: TkComment(s)}:
					junk();
				default:
					break;
			}
		}
		
		return array;
	}
	
	function parseStruct():Struct {

		var struct:Struct = {
			name: '',
			type: '',
			values: [],
			props: {}
		};
		
		while (true) {
			switch stream {
				case [{tok: TkBraceClose}]:
					break;
				case [{tok: TkEof}]:
					break;
				
				case [{tok: TkComment(s)}]:
				
				case [{tok: TkIdent(s)}]:
					struct.type = s;
				
				case [{tok: TkName(s)}]:
					struct.name = s;
					
				case [{tok: TkParentOpen}, props = parseProperties( { } )]:
					struct.props = props;
				
				case [{tok: TkBraceOpen}]:
					struct.values = parseStructs();
					
				case [{tok: TkKeyword(k)}]:
					struct.type = Type.enumConstructor(k).substr(1).toLowerCase();
				
					struct.values.push(parseValue());
					break;
			}
		}
		
		return struct;
	}
	
	function parseProperties(props: { } ):Dynamic {
		
		return switch stream {
			case [{tok: TkParentClose}]: props;
			case [{tok: TkIdent(s)}, {tok: TkEqual}, e = parseValue()]:
				Reflect.setField(props, s, e);
				switch stream {
					case [{tok: TkParentClose}]: props;
					case [{tok: TkComma}]: parseProperties(props);
				}
		}
	}
	
	function parseValue():Dynamic {
		return switch stream {
			case [{tok: TkInt(v)}]:
				v;
			case [{tok: TkFloat(v)}]:
				v;
			case [{tok: TkString(s)}]:
				s;
			case [{tok: TkBool(v)}]:
				v;
			case [{tok: TkName(s)}]:
				s;
			case [ { tok: TkArray(v) }]:
				while (true) {
					switch (peek(0)) {
						case {tok: TkComment(s)}:
							junk();
						default:
							break;
					}
				}
				var out = switch stream {
					case [ { tok: TkBraceOpen }, array = parseArray(v)]:
						array;
				}
				out;
			case [{tok: TkBraceOpen}, array = parseArray()]:
				array;
		}
	}
	
	function parseArray(enforceSize:Null<Int> = null) {
		var array = [];
		array.push(parseValue());
		
		while (true) {
			switch stream {
				case [{tok: TkComment(s)}]:
				case [{tok: TkBraceClose}]:
					break;
				case [{tok: TkComma}]:
					var subArray = parseValue();
					
					if (enforceSize != null)
						if (subArray.length != enforceSize)
							throw 'Subarray of size ${subArray.length} but expected size of $enforceSize. Subarray: ${subArray}';
						
					array.push(subArray);
			}
		}
		
		return array;
	}
}