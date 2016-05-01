package states.hxsl;

import bakeneko.asset.AssetManager;
import bakeneko.asset.Texture;
import bakeneko.core.Window;
import bakeneko.hxsl.Cache;
import bakeneko.hxsl.Globals;
import bakeneko.hxsl.RuntimeShader;
import bakeneko.hxsl.Shader;
import bakeneko.hxsl.ShaderList;
import bakeneko.hxsl.Types.Sampler2D;
import bakeneko.render.Color;
import bakeneko.render.MeshData;
import bakeneko.render.MeshTools;
import bakeneko.render.VertexData;
import bakeneko.render.VertexElement;
import bakeneko.render.VertexSemantic;
import bakeneko.render.VertexStructure;
import bakeneko.state.State;
import bakeneko.task.Task;
import haxe.Timer;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import states.hxsl.ProgramBuffer.ShaderBuffer;

#if !flash
typedef Graphics = GLGraphics;
#else
typedef Graphics = FlashGraphics;
#end

/**
 * Hxsl usage test with native OpenGl or Stage3D
 */
@:build(bakeneko.hxsl.Macros.buildGlobals())
class HxslTest extends State {
	
	var globals:Globals;
	var cache:Cache;
	var output:Int;
	var shaderList:ShaderList;
	var testShader:TestShader;
	var compiledShader:RuntimeShader;
	
	var programBuffer:ProgramBuffer;
	
	var graphics:Graphics;
	var backColor:Color;
	
	var textures:Array<Texture>;
	
	@global("time") var globalTime : Float = Math.sin(Timer.stamp());
	
	override public function onInit():Void {
		
		cache = Cache.get();
		
		#if flash
		cache.constsToGlobal = true;
		#end
		
		globals = new Globals();
		output = cache.allocOutputVars(["output.position", "output.color"]);

		initGlobals();
		
		testShader = new TestShader();
		testShader.changeColor = true;
		
		shaderList = new ShaderList(testShader);
		compiledShader = compileShaders(shaderList);
		
		programBuffer = new ProgramBuffer(compiledShader);
		
		backColor = new Color(0.12, 0.05, 0.16, 1.0);
		
		var format = new VertexStructure();
		format.push(new VertexElement(TFloat(3), SPosition));
		format.push(new VertexElement(TFloat(4), SColor));
		format.push(new VertexElement(TFloat(2), STexcoord));
		
		var data:MeshData = {
			vertexCount: 3,
			positions: [[0.0, 0.5, 0.0], [0.5, -0.5, 0.0], [ -0.5, -0.5, 0.0]],
			colors: [[0.9, 0.9, 0.83, 1.0], [0.5, 0.65, 0.75, 1.0], [0.55, 0.87, 1.0, 1.0]],
			uvs: [[0.5, 1.0], [0.0, 0.0], [1.0, 0.0]],
			indices: [0, 1, 2],
			structure: format,
		}
		
		//graphics = new Graphics(compiledShader, data, backColor);
		//app.renderSystem.onRenderEvent.add(render);
		
		var tasks:Array<Task<Texture>> = [];
		
		tasks.push(app.assets.loadTexture({id: AssetManager.assets.textures.colorGrid_png}));
		tasks.push(app.assets.loadTexture({id: AssetManager.assets.textures.uvGrid_png}));
		
		Task.whenAllResult(tasks).onSuccess(function(results) {
			textures = results.result;

			testShader.texture1 = textures[0];
			testShader.texture2 = textures[1];
			
			for (i in 0...4)
				trace(textures[0].image.data[i]);
			
			graphics = new Graphics(compiledShader, data, backColor);
			app.renderSystem.onRenderEvent.add(render);
		});
	}
	
	override public function onDestroy():Void {
		app.renderSystem.onRenderEvent.remove(render);
	}
	
	override public function onUpdate(delta:Float):Void {
		testShader.factor = 0.5 + (Math.cos(Timer.stamp()) * 0.5 + 0.5) * 0.5;
	}
	
	function render(window:Window) {
		setGlobals();
		setParams(programBuffer, compiledShader, shaderList);
		setGlobalParams(programBuffer, compiledShader);
		
		window.renderer.begin();
		graphics.render(programBuffer);
		window.renderer.end();
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
			
		var value = si.s.getParamValue(param.index);
		if (value == null) {
			throw 'Missing param value ${si.s}.${param.name}';
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
	
	function setGlobalParams(pBuffer:ProgramBuffer, shader:RuntimeShader) {
		
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
	
	function compileShaders(shaders:ShaderList) {
		for (shader in shaders)
			shader.updateConstants(globals);
		return cache.link(shaders, output);
	}
	
}

private class TestShader extends Shader {
	
	static var SRC = {
		@input var input: {
			var position:Vec3;
			var color:Vec4;
			var uv:Vec2;
		}
		
		var output: {
			var position:Vec4;
			var color:Vec4;
		}
		
		@param var factor:Float;
		@param var texture1:Sampler2D;
		@param var texture2:Sampler2D;
		@global var time:Float;
		@const var changeColor:Bool;
		var calculatedUV : Vec2;
		
		var minSize:Float;
		
		function __init__() {
			minSize = 0.8;
		}
		
		function vertex() {
			calculatedUV = input.uv;
			output.position = vec4(input.position * (minSize + (1.0 - minSize) * (cos(time * 0.34) * sin(time * 0.47))), 1.0);
		}
		
		function fragment() {
			if (changeColor) {
				var c1 = texture1.get(calculatedUV);
				var c2 = texture2.get(input.uv);
				
				output.color = input.color * 0.0 + c1 * vec4(1.0);//vec4(input.color.rgb /* factor*/, input.color.a);
				//output.color.r = c2.r;
				/*var c1 = texture1.get(calculatedUV);
				//var c2 = texture2.get(input.uv);
				
				//output.color = c1;
				output.color = vec4(input.color.rgb * factor * calculatedUV.x, input.color.a);
				output.color = c1;
				//output.color.a = c1.r;
				*/
			} else {
				output.color = input.color;
			}
		}
	}
	
	public function new() {
		super();
		factor = 1.0;
	}
	
}

/*
private class TestShader extends Shader {
	
	static var SRC = {
		@input var input: {
			var position:Vec3;
			var color:Vec4;
			var uv:Vec2;
		}
		
		var output: {
			var position:Vec4;
			var color:Vec4;
		}
		
		@param var factor:Float;
		@param var texture1:Sampler2D;
		@param var texture2:Sampler2D;
		@global var time:Float;
		@const var changeColor:Bool;
		
		var minSize:Float;
		
		function __init__() {
			minSize = 0.5;
		}
		
		function vertex() {
			output.position = vec4(input.position * (minSize + (1.0 - minSize) * (cos(time * 0.34) * sin(time * 0.47))), 1.0);
		}
		
		function fragment() {
			if (changeColor) {
				var c1 = texture1.get(input.uv);
				var c2 = texture2.get(input.uv);
				
				output.color = c1 * vec4(input.color.rgb * factor, input.color.a);
				output.color.r = c2.r;
			} else {
				output.color = input.color;
			}
		}
	}
	
	public function new() {
		super();
		factor = 1.0;
	}
	
}*/

/*private class TestShader extends bakeneko.hxsl.Shader {

	static var SRC = {
		@input var input: {
			var position:Vec3;
			var color:Vec4;
			var uv:Vec2;
		};
		
		var output : {
			var position:Vec4;
			var color:Vec4;
		};
		
		@param var factor:Float;
		@param var texture1:Sampler2D;
		@param var texture2:Sampler2D;
		@const var constTest:Bool;
		var localTest:Float;
		
		function __init__() {
			localTest = 0.20;
		}
		
		function vertex() {
			output.position = vec4(input.position.xyz * factor * (localTest + 0.75), 1.0);
		}
		
		function fragment() {
			var c1 = texture1.get(input.uv);
			var c2 = texture2.get(input.uv);
			
			if (constTest)
				output.color = (c2 * 0.2) + (c1 * (input.color * (localTest + 0.8) * factor));
			else
				output.color = input.color;
		}
	}

}*/