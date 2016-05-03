package bakeneko.render;

import bakeneko.hxsl.Cache;
import bakeneko.hxsl.Globals;
import bakeneko.hxsl.RuntimeShader;
import bakeneko.hxsl.ShaderList;
import bakeneko.utils.Float32Array;
import bakeneko.render.ProgramBuffer.ShaderBuffer;

class ShaderManager {
	
	public var globals:Globals;
	var shaderCache:Cache;
	var output:Int;
	
	public function new(output:Array<String>) {
		shaderCache = Cache.get();
		#if flash
		shaderCache.constsToGlobal = true;
		#end
		globals = new Globals();
		this.output = shaderCache.allocOutputVars(output);
	}
	
	public function getParamValue(param:AllocParam, shaders:ShaderList):Dynamic {
		if (param.perObjectGlobal != null) {
			var value = globals.fastGet(param.perObjectGlobal.gid);
			if (value == null)
				throw 'Missing global value ${param.perObjectGlobal.path}';
			return value;
		}
		
		var si = shaders;
		var n = param.instance;
		while (n-- > 0)
			si = si.next;
			
		var value = si.shader.getParamValue(param.index);
		if (value == null) {
			throw 'Missing param value ${si.shader}.${param.name}';
		}
		
		return value;
	}
	
	public function setParams(buffer:ProgramBuffer, shader:RuntimeShader, shaderList:ShaderList) {
		
		function set(buffer:ShaderBuffer, shaderData:RuntimeShaderData) {
			/*if (shaderData.paramsSize <= 0)
				return;*/

			var param = shaderData.params;
			while (param != null) {
				fillRec(getParamValue(param, shaderList), param.type, buffer.params, param.pos);
				param = param.next;
			}
			
			var tid:Int = 0;
			var param = shaderData.textures2D;
			while (param != null) {
				var texture = getParamValue(param, shaderList);
				if (texture == null)
					throw 'Missing texture value ${param.name}';
					
				buffer.textures[tid++] = texture;
				param = param.next;
			}
			
			var param = shaderData.texturesCube;
			while (param != null) {
				var texture = getParamValue(param, shaderList);
				if (texture == null)
					throw 'Missing texture cube ${param.name}';
					
				buffer.textures[tid++] = texture;
				param = param.next;
			}
		}
		
		set(buffer.vertex, shader.vertex);
		set(buffer.fragment, shader.fragment);
		
	}
	
	public function setGlobalParams(pBuffer:ProgramBuffer, shader:RuntimeShader) {
		
		function set(buffer:ShaderBuffer, shaderData:RuntimeShaderData) {
			var global = shaderData.globals;
			
			while (global != null) {
				var value = globals.fastGet(global.gid);
				if (value == null) {
					
					if (global.path == '__consts__') {
						fillRec(shaderData.consts, global.type, buffer.globals, global.pos);
						global = global.next;
						continue;
					}
					throw 'Missing global value ${global.path}';
	
				}
				fillRec(value, global.type, buffer.globals, global.pos);
				global = global.next;
			}
		}
		
		set(pBuffer.vertex, shader.vertex);
		set(pBuffer.fragment, shader.fragment);
	}
	
	@:noDebug
	function fillRec( v : Dynamic, type : bakeneko.hxsl.Ast.Type, out : Float32Array, pos : Int ) {
		switch( type ) {
		case TFloat:
			out[pos] = v;
			return 1;
		case TVec(n, _):
			var v : bakeneko.math.Vector4 = v;
			out[pos++] = v.x;
			out[pos++] = v.y;
			switch( n ) {
			case 3:
				out[pos++] = v.z;
			case 4:
				out[pos++] = v.z;
				out[pos++] = v.w;
			}
			return n;
		case TMat4:
			var m : bakeneko.math.Matrix4x4 = v;
			for (i in 0...16) {
				out[pos++] = m.m[i];
			}
			/*out[pos++] = m._11;
			out[pos++] = m._21;
			out[pos++] = m._31;
			out[pos++] = m._41;
			out[pos++] = m._12;
			out[pos++] = m._22;
			out[pos++] = m._32;
			out[pos++] = m._42;
			out[pos++] = m._13;
			out[pos++] = m._23;
			out[pos++] = m._33;
			out[pos++] = m._43;
			out[pos++] = m._14;
			out[pos++] = m._24;
			out[pos++] = m._34;
			out[pos++] = m._44;*/
			return 16;
		case TMat3x4:
			var m : bakeneko.math.Matrix4x4 = v;
			for (i in 0...12) {
				out[pos++] = m.m[i];
			}
			/*var m : h3d.Matrix = v;
			out[pos++] = m._11;
			out[pos++] = m._21;
			out[pos++] = m._31;
			out[pos++] = m._41;
			out[pos++] = m._12;
			out[pos++] = m._22;
			out[pos++] = m._32;
			out[pos++] = m._42;
			out[pos++] = m._13;
			out[pos++] = m._23;
			out[pos++] = m._33;
			out[pos++] = m._43;*/
			return 12;
		case TMat3:
			var m : bakeneko.math.Matrix4x4 = v;
			out[pos++] = m.m[0];
			out[pos++] = m.m[1];
			out[pos++] = m.m[2];
			out[pos++] = 0;
			out[pos++] = m.m[4];
			out[pos++] = m.m[5];
			out[pos++] = m.m[6];
			out[pos++] = 0;
			out[pos++] = m.m[8];
			out[pos++] = m.m[9];
			out[pos++] = m.m[10];
			out[pos++] = 0;
			return 12;
		case TArray(TVec(4,VFloat), SConst(len)):
			var v : Array<bakeneko.math.Vector4> = v;
			for( i in 0...len ) {
				var n = v[i];
				if( n == null ) break;
				out[pos++] = n.x;
				out[pos++] = n.y;
				out[pos++] = n.z;
				out[pos++] = n.w;
			}
			return len * 4;
		case TArray(TMat3x4, SConst(len)):
			var v : Array<bakeneko.math.Matrix4x4> = v;
			for( i in 0...len ) {
				var m = v[i];
				if ( m == null ) break;
				for (i in 0...12) {
					out[pos++] = m.m[i];
				}
				/*out[pos++] = m._11;
				out[pos++] = m._21;
				out[pos++] = m._31;
				out[pos++] = m._41;
				out[pos++] = m._12;
				out[pos++] = m._22;
				out[pos++] = m._32;
				out[pos++] = m._42;
				out[pos++] = m._13;
				out[pos++] = m._23;
				out[pos++] = m._33;
				out[pos++] = m._43;*/
			}
			return len * 12;
		case TArray(t, SConst(len)):
			var v : Array<Dynamic> = v;
			var size = 0;
			for( i in 0...len ) {
				var n = v[i];
				if( n == null ) break;
				size = fillRec(n, t, out, pos);
				pos += size;
			}
			return len * size;
		case TStruct(vl):
			var tot = 0;
			for( vv in vl )
				tot += fillRec(Reflect.field(v, vv.name), vv.type, out, pos + tot);
			return tot;
		default:
			throw "assert " + type;
		}
		return 0;
	}
	
	public function compileShaders(shaders:ShaderList) {
		for( shader in shaders ) shader.updateConstants(globals);
		return shaderCache.link(shaders, output);
	}
	
}