package states;

import bakeneko.core.System;
import bakeneko.hxsl.Printer;
import bakeneko.hxsl.Shader;
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
import bakeneko.input.KeyCode;
import bakeneko.render.Color;
import bakeneko.state.State;
import format.agal.Tools;
import haxe.Timer;
import lime.utils.UInt32Array;

import lime.utils.Float32Array;

#if !flash
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;

private class Graphics {
	
	var compiledShader:RuntimeShader;
	
	var program:GLProgram;
	var vertex:GLBuffer;
	var index:GLBuffer;
	var vertexLocation:GLUniformLocation;
	var fragmentLocation:GLUniformLocation;
	
	var backColor:Color;
	
	public function new(compiledShader:RuntimeShader, vertexData:Float32Array, indexData:UInt32Array, backColor: Color) {
		this.compiledShader = compiledShader;
		this.backColor = backColor;
		
		var out = new GlslOut();
		var vertexSource = out.run(compiledShader.vertex.data);
		var fragmentSource = out.run(compiledShader.fragment.data);
		
		Log.info('$vertexSource\n\n$fragmentSource', 0);
		
		vertex = GL.createBuffer();
		index = GL.createBuffer();
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertex);
		GL.bufferData(GL.ARRAY_BUFFER, vertexData, GL.STATIC_DRAW);
		
		GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 7 * 4, 0);
		GL.enableVertexAttribArray(0);
		GL.vertexAttribPointer(1, 4, GL.FLOAT, false, 7 * 4, 3 * 4);
		GL.enableVertexAttribArray(1);
		
		var vertexShader = GL.createShader(GL.VERTEX_SHADER);
		var fragmentShader = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(vertexShader, vertexSource);
		GL.shaderSource(fragmentShader, fragmentSource);
		GL.compileShader(vertexShader);
		GL.compileShader(fragmentShader);
		
		program = GL.createProgram();
		GL.attachShader(program, vertexShader);
		GL.attachShader(program, fragmentShader);

		GL.linkProgram(program);

		if (GL.getProgramParameter(program, GL.LINK_STATUS) == 0)
		{
			Log.error(GL.getProgramInfoLog(program));
			GL.deleteProgram(program);
		}
		
		GL.useProgram(program);
		
		vertexLocation = GL.getUniformLocation(program, 'vertexParams');
		fragmentLocation = GL.getUniformLocation(program, 'fragmentParams');
	}
	
	public function render(paramValues:Float32Array) {
		GL.uniform4fv(vertexLocation, paramValues);
		GL.uniform4fv(fragmentLocation, paramValues);
		
		GL.clearColor(backColor.r, backColor.g, backColor.b, backColor.a);
		GL.clear(GL.COLOR_BUFFER_BIT);
		GL.drawArrays(GL.TRIANGLES, 0, 3);
	}

}
#else
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import flash.display3D.IndexBuffer3D;

private class Graphics {
	
	var compiledShader:RuntimeShader;
	
	var stage3D:Stage3D;
	var context3D:Context3D;
	
	var program:Program3D;
	var vertex:VertexBuffer3D;
	var index:IndexBuffer3D;
	var location:Int;
	
	var backColor:Color;
	
	var params:flash.Vector<Float>;
	
	public function new(compiledShader:RuntimeShader, vertexData:Float32Array, indexData:UInt32Array, backColor:Color) {
		this.compiledShader = compiledShader;
		this.backColor = backColor;
		
		stage3D = flash.Lib.current.stage.stage3Ds[0];
		stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, init.bind(_, vertexData, indexData));
		stage3D.requestContext3D(cast flash.display3D.Context3DRenderMode.AUTO, flash.display3D.Context3DProfile.STANDARD);
	}
	
	public function init(_, vertexData:Float32Array, indexData:UInt32Array) {
		context3D = stage3D.context3D;
		//context3D.configureBackBuffer(System.app.windows[0].width, System.app.windows[0].height, 0, true);
		
		vertex  = context3D.createVertexBuffer(3, 7);
		index = context3D.createIndexBuffer(3);
	
		//vertex.uploadFromByteArray(vertexData.buffer.getData(), 0, 0, 3);
		//index.uploadFromByteArray(indexData.buffer.getData(), 0, 0, 3);
		
		var a = new flash.Vector<Float>(vertexData.length);
		for (i in 0...vertexData.length)
			a[i] = vertexData[i];
		
		var v = new flash.Vector<UInt>(indexData.length);
		for (i in 0...indexData.length)
			v[i] = indexData[i];
		
		vertex.uploadFromVector(a, 0, 3);
		index.uploadFromVector(v, 0, 3);
		
		//var out = new AgalOut();
		var vertexSource = AgalOut.toAgal(compiledShader.vertex, 2);
		var fragmentSource = AgalOut.toAgal(compiledShader.fragment, 2);
		/*var opt = new AgalOptim();
		vertexSource = opt.optimize(vertexSource);
		fragmentSource = opt.optimize(fragmentSource);*/
		
		/*trace(Printer.shaderToString(compiledShader.fragment.data));
		trace(Printer.shaderToString(compiledShader.vertex.data));*/
		Log.info('${format.agal.Tools.toString(vertexSource)}\n\n${format.agal.Tools.toString(fragmentSource)}', 0);
		
		var vBytes = new haxe.io.BytesOutput();
		new format.agal.Writer(vBytes).write(vertexSource);
		var fBytes = new haxe.io.BytesOutput();
		new format.agal.Writer(fBytes).write(fragmentSource);
		
		var vb = vBytes.getBytes().getData();
		var fb = fBytes.getBytes().getData();
		vb.endian = flash.utils.Endian.LITTLE_ENDIAN;
		fb.endian = flash.utils.Endian.LITTLE_ENDIAN;
		
		program = context3D.createProgram();
		program.upload(vb, fb);
	}
	
	public function render(paramValues:Float32Array) {
		if (context3D == null)
			return;
		
		if (params == null || params.length != paramValues.length)
			params = new flash.Vector<Float>(paramValues.length);
		
		for (i in 0...paramValues.length)
			params[i] = paramValues[i];
			
		context3D.clear(backColor.r, backColor.g, backColor.b, backColor.a);
		
		context3D.setVertexBufferAt(0, vertex, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		context3D.setVertexBufferAt(1, vertex, 3, flash.display3D.Context3DVertexBufferFormat.FLOAT_4);
		context3D.setProgram(program);
		
		if (compiledShader.vertex.paramsSize > 0)
			context3D.setProgramConstantsFromVector(flash.display3D.Context3DProgramType.VERTEX, compiledShader.vertex.globalsSize, params, compiledShader.vertex.paramsSize);
		if (compiledShader.fragment.paramsSize > 0)
			context3D.setProgramConstantsFromVector(flash.display3D.Context3DProgramType.FRAGMENT, compiledShader.fragment.globalsSize, params, compiledShader.fragment.paramsSize);
		
		if (compiledShader.vertex.globalsSize > 0)
			context3D.setProgramConstantsFromVector(flash.display3D.Context3DProgramType.VERTEX, 0, params, compiledShader.vertex.globalsSize);
		if (compiledShader.fragment.globalsSize > 0)
			context3D.setProgramConstantsFromVector(flash.display3D.Context3DProgramType.FRAGMENT, 0, params, compiledShader.fragment.globalsSize);
		
		
		context3D.drawTriangles(index);
		
		context3D.present();
	}
}
#end

class HxslTest extends State {
	
	var globals:Globals;
	var cache:Cache;
	var output:Int;
	var shader:TestShader;
	var compiledShader:RuntimeShader;
	
	var paramValues:Float32Array;
	var vertexData:Float32Array;
	var indexData:UInt32Array;
	
	var graphics:Graphics;
	
	var backColor:Color;
	
	override public function onInit():Void {
		
		cache = Cache.get();
		
		#if flash
		cache.constsToGlobal = true;
		#end
		
		var globals = new Globals();
		output = cache.allocOutputVars(["output.position", "output.color"]);
		
		shader = new TestShader();
		shader.constTest = true;
		shader.factor = 1.0;
		
		compiledShader = compileShaders(new ShaderList(shader));
		paramValues = new Float32Array(compiledShader.fragment.paramsSize << 2);
		
		vertexData = new Float32Array([
			-0.3, -0.3, 0.0,  0.9, 	0.9,  0.83, 1.0,
			 0.3, -0.3, 0.0,  0.5, 	0.65, 0.75, 1.0,
			 0.3,  0.3, 0.0,  0.55, 0.87, 1.0,  1.0
		]);
		indexData = new UInt32Array([0, 1, 2]);
		
		
		backColor = new Color(0.12, 0.05, 0.16, 1.0);
		graphics = new Graphics(compiledShader, vertexData, indexData, backColor);
		
		app.renderSystem.onRenderEvent.add(render);
	}
	
	override public function onUpdate(delta:Float):Void {
		shader.factor = 0.5 + (Math.cos(Timer.stamp()) * 0.5 + 0.5) * 0.5;
	}
	
	function render(window:Window) {
		setParams();
		
		window.renderer.begin();
		graphics.render(paramValues);
		window.renderer.end();
	}
	
	public function setParams() {
		var param = compiledShader.fragment.params;
		var i = 0;
		while (param != null) {
			paramValues[param.index] = shader.getParamValue(param.index);
			param = compiledShader.fragment.params.next;
		}
	}
	
	function compileShaders(shaders:ShaderList) {
		for (shader in shaders)
			shader.updateConstants(globals);
		return cache.link(shaders, output);
	}
	
}

private class TestShader extends bakeneko.hxsl.Shader {

	static var SRC = {
		@input var input: {
			var position:Vec3;
			var color:Vec4;
		};
		
		var output : {
			var position:Vec4;
			var color:Vec4;
		};
		
		@param var factor:Float;
		@const var constTest:Bool;
		var initTest:Float;
		
		function __init__() {
			initTest = 1.0;
		}
		
		function vertex() {
			output.position = vec4(input.position.x, input.position.y, input.position.z, 1.0);
		}
		
		function fragment() {
			if (constTest)
				output.color = input.color * initTest * factor;
			else
				output.color = input.color;
		}
	}

}