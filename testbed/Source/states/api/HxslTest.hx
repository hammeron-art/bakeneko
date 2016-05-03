package states.api;

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
import bakeneko.render.ShaderManager;
import bakeneko.render.VertexData;
import bakeneko.render.VertexElement;
import bakeneko.render.VertexSemantic;
import bakeneko.render.VertexStructure;
import bakeneko.state.State;
import bakeneko.task.Task;
import haxe.Timer;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import bakeneko.render.ProgramBuffer;
import bakeneko.render.ProgramBuffer.ShaderBuffer;

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
	
	var manager:ShaderManager;
	var globals(get, never):Globals;
	/*var cache:Cache;
	var output:Int;*/
	
	var shaderList:ShaderList;
	var testShader:TestShader;
	var compiledShader:RuntimeShader;
	
	var programBuffer:ProgramBuffer;
	
	var graphics:Graphics;
	var backColor:Color;
	
	var textures:Array<Texture>;
	
	@global("time") var globalTime : Float = Math.sin(Timer.stamp());
	
	inline function get_globals() return manager.globals;
	
	override public function onInit():Void {
		
		manager = new ShaderManager(["output.position", "output.color"]);

		initGlobals();
		
		testShader = new TestShader();
		testShader.changeColor = true;
		
		shaderList = new ShaderList(testShader);
		compiledShader = manager.compileShaders(shaderList);
		
		programBuffer = new ProgramBuffer(compiledShader);
		
		backColor = new Color(0.12, 0.05, 0.16, 1.0);
		
		var format = new VertexStructure();
		format.push(new VertexElement(TFloat(3), SPosition));
		//format.push(new VertexElement(TFloat(4), SColor));
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
			
			/*for (i in 0...4)
				trace(textures[0].image.data[i]);*/
			
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
		manager.setParams(programBuffer, compiledShader, shaderList);
		manager.setGlobalParams(programBuffer, compiledShader);
		
		window.renderer.begin();
		graphics.render(programBuffer);
		window.renderer.end();
	}
	
}

private class TestShader extends Shader {
	
	static var SRC = {
		@input var input: {
			var position:Vec3;
			//var color:Vec4;
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
			#if flash
			calculatedUV = vec2(input.uv.x, 1.0-input.uv.y);
			#else
			calculatedUV = input.uv;
			#end
			output.position = vec4(input.position * (minSize + (1.0 - minSize) * (cos(time * 0.34) * sin(time * 0.47))), 1.0);
		}
		
		function fragment() {
			if (changeColor) {
				var c1 = texture1.get(calculatedUV);
				var c2 = texture2.get(input.uv);
				
				output.color = c1;
				//output.color = input.color * 0.0 + c1 * vec4(1.0);//vec4(input.color.rgb /* factor*/, input.color.a);
				//output.color.r = c2.r;
				/*var c1 = texture1.get(calculatedUV);
				//var c2 = texture2.get(input.uv);
				
				//output.color = c1;
				output.color = vec4(input.color.rgb * factor * calculatedUV.x, input.color.a);
				output.color = c1;
				//output.color.a = c1.r;
				*/
			} else {
				//output.color = input.color;
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