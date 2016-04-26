package states;

import bakeneko.core.Log;
import bakeneko.core.Window;
import bakeneko.hxsl.AgalOptim;
import bakeneko.hxsl.AgalOut;
import bakeneko.hxsl.Cache;
import bakeneko.hxsl.Globals;
import bakeneko.hxsl.GlslOut;
import bakeneko.hxsl.RuntimeShader;
import bakeneko.hxsl.ShaderList;
import bakeneko.hxsl.SharedShader;
import bakeneko.render.Color;
import bakeneko.state.State;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.utils.Float32Array;

class HxslTest extends State {
	
	var globals:Globals;
	var cache:Cache;
	var output:Int;
	var compiledShader:RuntimeShader;
	var program:GLProgram;
	
	var positions:Array<Float>;
	
	var vertex:GLBuffer;
	var index:GLBuffer;
	
	override public function onInit():Void {
		
		cache = Cache.get();
		
		#if flash
		cache.constsToGlobal = true;
		#end
		
		var globals = new Globals();
		var output = cache.allocOutputVars(["output.position", "output.color"]);
		
		var shader = new TestShader();
		
		compiledShader = compileShaders(new ShaderList(shader));
		
		positions = [
			-1.0, -1.0, 0.0,  0.9, 	0.9,  0.83, 1.0,
			 1.0, -1.0, 0.0,  0.5, 	0.65, 0.75, 1.0,
			 0.0,  1.0, 0.0,  0.55, 0.87, 1.0,  1.0
		];
		
		tryOpengGl();
		tryFlash();
		
		app.renderSystem.onRenderEvent.add(render);
	}
	
	function tryOpengGl() {
		#if !flash
		
		var out = new GlslOut();
		var vertexSource = out.run(compiledShader.vertex.data);
		var fragmentSource = out.run(compiledShader.fragment.data);
		
		vertex = GL.createBuffer();
		index = GL.createBuffer();
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertex);
		GL.bufferData(GL.ARRAY_BUFFER, new Float32Array(positions), GL.STATIC_DRAW);
		
		GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 7 * 4, 0);
		GL.enableVertexAttribArray(0);
		GL.vertexAttribPointer(1, 4, GL.FLOAT, false, 7 * 4, 3 * 4);
		GL.enableVertexAttribArray(1);
		
		var vertex = GL.createShader(GL.VERTEX_SHADER);
		var fragment = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(vertex, vertexSource);
		GL.shaderSource(fragment, fragmentSource);
		GL.compileShader(vertex);
		GL.compileShader(fragment);
		
		program = GL.createProgram();
		GL.attachShader(program, vertex);
		GL.attachShader(program, fragment);

		GL.linkProgram(program);

		if (GL.getProgramParameter(program, GL.LINK_STATUS) == 0)
		{
			Log.error(GL.getProgramInfoLog(program));
			GL.deleteProgram(program);
		}
		
		GL.useProgram(program);
		
		Log.info('$vertexSource\n\n$fragmentSource', 0);
		
		#end
	}
	
	function tryFlash() {
		//cache.constsToGlobal = true;
		/*var out = new AgalOut();
		
		var vertexSource = out.compile(compiledShader.vertex, 2);
		var fragmentSource = out.compile(compiledShader.fragment, 2);
		var opt = new AgalOptim();
		vertexSource = opt.optimize(vertexSource);
		fragmentSource = opt.optimize(fragmentSource);*/
		
		//Log.info('${format.agal.Tools.toString(vertexSource)}\n\n${format.agal.Tools.toString(fragmentSource)}', 0);
	}
	
	function render(window:Window) {
		var g = window.renderer;
		
		GL.clearColor(0.12, 0.05, 0.16, 1.0);
		GL.clear(GL.COLOR_BUFFER_BIT);
		
		GL.drawArrays(GL.TRIANGLES, 0, 3);
	}
	
	function compileShaders(shaders:ShaderList) {
		for (shader in shaders)
			shader.updateConstants(globals);
		return cache.link(shaders, output);
	}
	
}

class TestShader extends bakeneko.hxsl.Shader {

	static var SRC = {
		@input var input: {
			var position: Vec3;
			var color: Vec4;
		};
		
		var output : {
			var position:Vec4;
			var color:Vec4;
		};

		function vertex() {
			output.position = vec4(input.position, 1.0);
		}
		
		function fragment() {
			output.color = input.color;
		}
	}

}