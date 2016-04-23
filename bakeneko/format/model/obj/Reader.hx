package bakeneko.format.model.obj;
import bakeneko.core.Log;
import bakeneko.format.model.Data;
import bakeneko.render.VertexFormat;
import bakeneko.utils.SortedMap;

private enum Token {
	TComment(s:String);
	TNode(s:String);
	TSmooth(v:Bool);
	TFloat(v:Float);
	TInt(v:Int);
	TPosition;
	TNormal;
	TTextcoord;
	TFaceStart;
	TFaceEnd;
	// mark end of array
	TEnd;
	TEof;
}

/**
 * Parse Wavefront OBJ format
 */
class Reader {

	var buffer:String;
	var pos:Int;
	var line:Int;
	var token:Null<Token>;
	// if current line is a face definition
	var isFace = false;

	public static function parse(fileText:String):SceneData {
		return new Reader().parseText(fileText);
	}
	
	function new() {
	}
	
	function parseText(buffer:String) {
		this.buffer = buffer;
		this.pos = 0;
		this.line = 1;
		token = null;
		
		var scene:SceneData = {name: '', nodes: []};
		
		while (true) {
			switch (peek()) {
				case TNode(s):
					trace(s);
					var node = parseNode();
					if (node != null)
						scene.nodes.push(node);
				case TEof:
					return scene;
				default:
			}

			next();
		}
		
		Log.verbose(scene.nodes[0]);
		
		return scene;
	}
	
	function parseNode():NodeData {
		
		var vertexFormat = new VertexFormat();
		
		var t = next();
		
		var name = switch(t) {
			case TNode(n): n;
			default: error("Unexpected " + t);
		};
		
		var positions:Array<Vector> = [];
		var normals:Array<Vector> = [];
		var texcoords:Array<Vector> = [];
		var faces:Array<Array<Array<Int>>> = [];
		
		// read sequence of values and push to outArray
		// return number of values pushed
		function readArray(outArray):Int {
			var vec:Vector = [];
			
			var i = 0;
			while (true) {
				t = next();
				switch (t) {
				case TFloat(v), TInt(v):
					vec.push(v);
					++i;
				case TEnd:
					break;
				default:
					unexpected(t);
				}
			}
			
			outArray.push(vec);
			return i;
		}
		
		inline function addElemet(type:VertexType, semantic:VertexSemantic) {
			if (!vertexFormat.hasSemantic(semantic))
				vertexFormat.push(new VertexElement(type, semantic));
		}
		
		while (true) {
			t = next();
			switch(t) {
				case TPosition:
					var n = readArray(positions);
					addElemet(TFloat(n), SPosition);
				case TNormal:
					var n = readArray(normals);
					addElemet(TFloat(n), SNormal);
				case TTextcoord:
					var n = readArray(texcoords);
					addElemet(TFloat(n), STexcoord);
				case TFaceStart:
					var face:Array<Array<Int>> = [];
					
					while (true) {
						if (t == TFaceEnd)
							break;
						
						var indices:Array<Int> = [];
							
						while (true) {
							t = next();
							switch (t) {
							case TInt(v):
								indices.push(v);
							case TEnd, TFaceEnd:
								break;
							default:
								unexpected(t);
							}
						}
						
						face.push(indices);
					}
					faces.push(face);
				case TEof:
					break;
					
				default:
			}
		}

		trace('vertices: ${positions.length}');
		trace('texcoords: ${texcoords.length}');
		trace('normals: ${normals.length}');
		trace('faces: ${faces.length}\n');
		
		var data = remap(faces, positions, texcoords, normals);
		
		trace('vertices: ${data.positions.length}');
		trace('texcoords: ${data.texcoords.length}');
		trace('normals: ${data.normals.length}');
		trace('faces: ${data.faces.length}');
		
		var mesh:MeshData = {
			name: '',
			vertexFormat: vertexFormat,
			positions: data.positions,
			normals: data.normals,
			texcoords: data.texcoords,
			faces: data.faces
		}
		var node:NodeData = {
			name: name,
			meshes: [mesh],
			type: NodeType.model
		}
		
		return node;
	}
	
	/**
	 * OBJ format index textcoordinates and normals as well as vertices with the faces
	 * so we need to process parsed faces to output data in the unified format
	 */
	function remap(faces:Array<Array<Array<Int>>>, positions:Array<Vector>, texcoords:Array<Vector>, normals:Array<Vector>):
		{positions:Array<Vector>, texcoords:Array<Vector>, normals:Array<Vector>, faces:Array<Face> }
	{
		var outPositions:Array<Vector> = [];
		var outTexcoords:Array<Vector> = [];
		var outNormals:Array<Vector> = [];
		var outFaces:Array<Face> = [];
		
		for (face in faces) {
			switch (face.length) {
			case 3:
				for (index in face) {
					outPositions.push(positions[index[0] - 1]);
					var tex = texcoords[index[1] - 1];
					outTexcoords.push([tex[0], -tex[1]]);
					outNormals.push(normals[index[2] - 1]);
				}
			
			case 4:
				for (i in 0...3)
					outPositions.push(positions[face[i][0] - 1]);
				
				outPositions.push(positions[face[2][0] - 1]);
				outPositions.push(positions[face[3][0] - 1]);
				outPositions.push(positions[face[0][0] - 1]);
				
				inline function correct(uv:Vector):Vector {
					return [uv[0], -uv[1]];
				}
				
				for (i in 0...3)
					outTexcoords.push(correct(texcoords[face[i][1] - 1]));
				
				outTexcoords.push(correct(texcoords[face[2][1] - 1]));
				outTexcoords.push(correct(texcoords[face[3][1] - 1]));
				outTexcoords.push(correct(texcoords[face[0][1] - 1]));
				
				for (i in 0...3)
					outNormals.push(normals[face[i][2] - 1]);
				
				outNormals.push(normals[face[2][2] - 1]);
				outNormals.push(normals[face[3][2] - 1]);
				outNormals.push(normals[face[0][2] - 1]);
			}
		}
		
		return {
			positions: outPositions,
			texcoords: outTexcoords,
			normals: outNormals,
			faces: outFaces
		}
	}
	
	inline function peek() {
		if (token == null)
			token = nextToken();
		return token;
	}
	
	function next() {
		if (token == null)
			return nextToken();
		var temp = token;
		token = null;
		return temp;
	}
	
	function nextToken() {
		var start = pos;
		
		while (true) {
			var c = nextChar();
			
			switch(c) {
				case '\r'.code, '\t'.code:
					
				case ' '.code:
					if (isFace) {
						return TEnd;
					}
					
				case '\n'.code:
					if (isFace) {
						--pos;
						isFace = false;
						return TFaceEnd;
					}
					++line;
					return TEnd;
				
				case '#'.code:
					start = pos;
					seek('\n');
					--pos;
					
					return TComment(getSubString(start, pos - start));
				case 'o'.code:
					start = pos;
					seek('\n');
					--pos;
					
					return TNode(getSubString(start, pos - start));
					
				case 'v'.code:
					c = nextChar();
					return switch (c) {
						case 'n'.code: TNormal;
						case 't'.code: TTextcoord;
						default: TPosition;
					}
					
				case 's'.code:
					start = pos;
					seek('\n');
					--pos;
					
					var value = StringTools.trim(getSubString(start, pos - start - 1));
					
					if (value == 'off') {
						return TSmooth(false);
					}
					return TSmooth(true);
					
				case 'f'.code:
					c = nextChar();
					if (c != ' '.code)
						error('Unexpected face definition');

					isFace = true;
					return TFaceStart;
				
				case '/'.code:
					start = pos;
					if (isFace != true)
						error("Unexpected char");
					
				default:
					if ((c >= '0'.code && c <= '9'.code) || c == '-'.code) {
						do {
							c = nextChar();
						} while (c >= '0'.code && c <= '9'.code);
						
						if( c != '.'.code && c != 'E'.code && c != 'e'.code && pos - start < 10 ) {
							pos--;
							return TInt(Std.parseInt(getSubString(start, pos - start)));
						}
						
						if( c == '.'.code ) {
							do {
								c = nextChar();
							} while( c >= '0'.code && c <= '9'.code );
						}
						if( c == 'e'.code || c == 'E'.code ) {
							c = nextChar();
							if( c != '-'.code && c != '+'.code )
								--pos;
							do {
								c = nextChar();
							} while( c >= '0'.code && c <= '9'.code );
						}
						--pos;
						return TFloat(Std.parseFloat(getSubString(start, pos - start)));
					}
					
					if (StringTools.isEof(c)) {
						--pos;
						return TEof;
					}
			}
		}
	}
	
	function parseLine(text:String) {
		var start = 0;
		
		while (true) {
			var c = StringTools.fastCodeAt(text, 0);
			
			switch(c) {
				case ' '.code, '\r'.code, '\t'.code:
					++start;
				
				case '#'.code:
					start = pos;

					var comment = getSubString(start, text.length - 1 - start);
					return TComment(comment);
				/*case 'o'.code:
					start = pos;
					seek('\n');
					
					var name = getSubString(start, pos - start -1);
					trace(name);*/
		
					
				default:
					
					if (StringTools.isEof(c)) {
						--pos;
						return TEof;
					}
			}
		}
	}
	
	inline function isIdentChar(c) {
		return (c >= 'a'.code && c <= 'z'.code) || (c >= 'A'.code && c <= 'Z'.code) || (c >= '0'.code && c <= '9'.code) || c == '_'.code || c == '-'.code;
	}
	
	inline function nextChar() {
		return StringTools.fastCodeAt(buffer, pos++);
	}
	
	// Advance until first occurrence of subString
	function seek(subString:String) {
		while (true) {
			var c = nextChar();
			if( c == StringTools.fastCodeAt(subString, 0))
				break;
			if( StringTools.isEof(c) )
				error('Unclosed $c sequence');
		}
	}
	
	function getSubString(pos:Int, length:Int) {
		return buffer.substr(pos, length);
	}
	
	function unexpected(t:Token) {
		error('Unexpected token $t');
	}
	
	function error(message:String):Dynamic {
		throw message + '(line $line )';
		return null;
	}
	
}