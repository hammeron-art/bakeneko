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
class HxslTest extends State {
	
	var globals:Globals;
	var cache:Cache;
	var output:Int;
	var shaderList:ShaderList;
	var testShader:TestShader;
	var compiledShader:RuntimeShader;
	
	var programBuffer:ProgramBuffer;
	
	var vertexData:Float32Array;
	var indexData:UInt16Array;
	
	var graphics:Graphics;
	var backColor:Color;
	
	var textures:Array<Texture>;
	
	override public function onInit():Void {
		
		cache = Cache.get();
		
		#if flash
		cache.constsToGlobal = true;
		#end
		
		var globals = new Globals();
		output = cache.allocOutputVars(["output.position", "output.color"]);
		
		testShader = new TestShader();
		//testShader.constTest = true;
		//testShader.factor = 1.0;
		
		shaderList = new ShaderList(testShader);
		compiledShader = compileShaders(shaderList);

		programBuffer = new ProgramBuffer(compiledShader);
		
		/*vertexData = new Float32Array([
			 0.0,  0.5,  0.0,  0.9,	 0.9,  0.83, 1.0, 0.0, 1.0,
			 0.5, -0.5,  0.0,  0.5,	 0.65, 0.75, 1.0, 0.0, 0.0,
			-0.5, -0.5,  0.0,  0.55, 0.87, 1.0,  1.0, 1.0, 0.0
		]);*/
		indexData = new UInt16Array([0, 1, 2]);
		
		backColor = new Color(0.12, 0.05, 0.16, 1.0);
		
		var format = new VertexStructure();
		format.push(new VertexElement(TFloat(3), SPosition));
		format.push(new VertexElement(TFloat(4), SColor));
		
		var data:MeshData = {
			vertexCount: 3,
			positions: [[0.0, 0.5, 0.0], [0.5, -0.5, 0.0], [ -0.5, -0.5, 0.0]],
			colors: [[0.9, 0.9, 0.83, 1.0], [0.5, 0.65, 0.75, 1.0], [0.55, 0.87, 1.0, 1.0]],
			uvs: [[1.0, 1.0], [0.0, 0.0], [1.0, 0.0]],
			indices: [0, 1, 2],
			structure: format,
		}
		
		vertexData = MeshTools.buildVertexData(data);
		
		trace(vertexData.length, format.totalNumValues * data.vertexCount);
		
		graphics = new Graphics(compiledShader, vertexData, indexData, backColor, textures);
		app.renderSystem.onRenderEvent.add(render);
		
		/*var tasks:Array<Task<Texture>> = [];
		
		tasks.push(app.assets.loadTexture({id: AssetManager.assets.textures.colorGrid_png}));
		tasks.push(app.assets.loadTexture({id: AssetManager.assets.textures.uvGrid_png}));
		
		Task.whenAllResult(tasks).onSuccess(function(results) {
			textures = results.result;

			testShader.texture1 = textures[1];
			testShader.texture2 = textures[0];
			
			graphics = new Graphics(compiledShader, vertexData, indexData, backColor, textures);
			app.renderSystem.onRenderEvent.add(render);
		});*/
		
	}
	
	override public function onDestroy():Void {
		app.renderSystem.onRenderEvent.remove(render);
	}
	
	override public function onUpdate(delta:Float):Void {
		//testShader.factor = 0.5 + (Math.cos(Timer.stamp()) * 0.5 + 0.5) * 0.5;
	}
	
	function render(window:Window) {
		setParams(programBuffer, compiledShader, shaderList);
		
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
		if (value == null)
			throw 'Missing param value ${si.s}.${param.name}';
		
		return value;
	}
	
	public function setParams(buffer:ProgramBuffer, shader:RuntimeShader, shaderList:ShaderList) {
		
		function set(buffer:ShaderBuffer, shaderData:RuntimeShaderData) {
			var param = shaderData.params;
			while (param != null) {
				buffer.params[param.pos] = getParamValue(param, shaderList);
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
	
	/*function setGlobals(buffer:ProgramBuffer, shaderList:ShaderList) {
		function set(buffer:ShaderBuffer, shaderData:RuntimeShaderData) {
			var global = shaderData.globals;
			
			while (global != null) {
				
				var value = globals.fastGet(global.gid);
				if (value == null) {
					
					if (global.path == '__consts__') {
						for (i in 0...shaderData.consts.length) {
							buffer.globals[global.pos + i] = shaderData.consts[i];
						}
						global = global.next;
						continue;
					}
					throw 'Missing global value ${global.path}';
					
				}
				//buffer.globals[global.pos
				
			}
		}
	}*/
	
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
		}
		
		var output: {
			var position:Vec4;
			var color:Vec4;
		}
		
		function vertex() {
			output.position = vec4(input.position, 1.0);
		}
		
		function fragment() {
			output.color = input.color;
		}
	}
	
}

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