package states;

import bakeneko.asset.AssetManager;
import bakeneko.asset.Texture;
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
import bakeneko.hxsl.Types.Sampler2D;
import bakeneko.input.KeyCode;
import bakeneko.render.Color;
import bakeneko.state.State;
import format.agal.Tools;
import haxe.Timer;
import lime.utils.UInt16Array;
import lime.utils.Float32Array;
import lime.utils.UInt8Array;

#if !flash
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLUniformLocation;
import lime.graphics.opengl.GLTexture;

private class Graphics {
	
	var compiledShader:RuntimeShader;
	
	var program:GLProgram;
	var vertex:GLBuffer;
	var index:GLBuffer;
	var glTextures:Array<GLTexture>;
	var vertexLocation:GLUniformLocation;
	var fragmentLocation:GLUniformLocation;
	var vertTexLocations:Array<GLUniformLocation>;
	var fragTexLocations:Array<GLUniformLocation>;
	
	var backColor:Color;
	
	public function new(compiledShader:RuntimeShader, vertexData:Float32Array, indexData:UInt16Array, backColor: Color, textures:Array<Texture>) {
		this.compiledShader = compiledShader;
		this.backColor = backColor;
		
		var out = new GlslOut();
		var vertexSource = out.run(compiledShader.vertex.data);
		var fragmentSource = out.run(compiledShader.fragment.data);
		
		Log.info('$vertexSource\n\n$fragmentSource', 0);
		
		vertex = GL.createBuffer();
		index = GL.createBuffer();
		
		GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, index);
		GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indexData, GL.STATIC_DRAW);
		
		GL.bindBuffer(GL.ARRAY_BUFFER, vertex);
		GL.bufferData(GL.ARRAY_BUFFER, vertexData, GL.STATIC_DRAW);
		
		GL.vertexAttribPointer(0, 3, GL.FLOAT, false, 9 * 4, 0);
		GL.enableVertexAttribArray(0);
		GL.vertexAttribPointer(1, 4, GL.FLOAT, false, 9 * 4, 3 * 4);
		GL.enableVertexAttribArray(1);
		GL.vertexAttribPointer(2, 2, GL.FLOAT, false, 9 * 4, (3 + 4) * 4);
		GL.enableVertexAttribArray(2);
		
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

		if (GL.getProgramParameter(program, GL.LINK_STATUS) == 0) {
			Log.error(GL.getProgramInfoLog(program));
			GL.deleteProgram(program);
		}
		
		GL.useProgram(program);
		
		vertexLocation = GL.getUniformLocation(program, 'vertexParams');
		fragmentLocation = GL.getUniformLocation(program, 'fragmentParams');
		vertTexLocations = [
			for (i in 0...compiledShader.vertex.textures2DCount) {
				GL.getUniformLocation(program, 'vertexTextures[$i]');
			}
		];
		fragTexLocations = [
			for (i in 0...compiledShader.fragment.textures2DCount) {
				GL.getUniformLocation(program, 'fragmentTextures[$i]');
			}
		];
		
		/*glTextures = [];
		var param = compiledShader.fragment.textures2D;
		
		var i = 0;
		while (param != null) {
			var texture = shader.getParamValue(param.index);
			
			var tex = GL.createTexture();
			GL.activeTexture(i);
			GL.bindTexture(GL.TEXTURE_2D, tex);
			GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, texture.image.width, texture.image.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, texture.image.buffer.data);
			
			glTextures.push(tex);
			
			//vertexParams[param.index] = shader.getParamValue(param.index);
			param = compiledShader.fragment.params.next;
		}*/
		
		
		glTextures = [
			for (i in 0...compiledShader.fragment.textures2DCount) {
				var texture = textures[i];
				var tex = GL.createTexture();
				GL.activeTexture(0);
				GL.bindTexture(GL.TEXTURE_2D, tex);
				GL.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, texture.image.width, texture.image.height, 0, GL.RGBA, GL.UNSIGNED_BYTE, texture.image.buffer.data);
				
				tex;
			}
		];
	}
	
	public function render(vertexValues:Float32Array, fragmentValues:Float32Array) {
		
		if (compiledShader.vertex.paramsSize > 0)
			GL.uniform4fv(vertexLocation, vertexValues);
		if (compiledShader.fragment.paramsSize > 0)
			GL.uniform4fv(fragmentLocation, fragmentValues);
		for (i in 0...compiledShader.vertex.textures2DCount) {
			
		}
		for (i in 0...compiledShader.fragment.textures2DCount) {
			GL.activeTexture(GL.TEXTURE0 + i);
			GL.uniform1i(fragTexLocations[i], i);
			GL.bindTexture(GL.TEXTURE_2D, glTextures[i]);
			
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_S, GL.REPEAT);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_WRAP_T, GL.REPEAT);

			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
			GL.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
		}
		
		GL.clearColor(backColor.r, backColor.g, backColor.b, backColor.a);
		GL.clear(GL.COLOR_BUFFER_BIT);
		GL.drawElements(GL.TRIANGLES, 3, GL.UNSIGNED_SHORT, 0);
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
	
	var globalVertexParams:Float32Array;
	var globalFragmentParams:Float32Array;
	var backColor:Color;
	
	var fragmentParams:flash.Vector<Float>;
	var vertexParams:flash.Vector<Float>;
	
	public function new(compiledShader:RuntimeShader, vertexData:Float32Array, indexData:UInt16Array, backColor:Color) {
		this.compiledShader = compiledShader;
		this.backColor = backColor;
		
		globalVertexParams = new Float32Array(compiledShader.vertex.consts.length << 2);
		for (i in 0...compiledShader.vertex.consts.length)
			globalVertexParams[i] = compiledShader.vertex.consts[i];
			
		globalFragmentParams = new Float32Array(compiledShader.fragment.consts.length << 2);
		for (i in 0...compiledShader.vertex.consts.length)
			globalFragmentParams[i] = compiledShader.fragment.consts[i];
		
		stage3D = flash.Lib.current.stage.stage3Ds[0];
		stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, init.bind(_, vertexData, indexData));
		stage3D.requestContext3D(cast flash.display3D.Context3DRenderMode.AUTO, flash.display3D.Context3DProfile.STANDARD);
	}
	
	public function init(_, vertexData:Float32Array, indexData:UInt16Array) {
		context3D = stage3D.context3D;
		//context3D.configureBackBuffer(System.app.windows[0].width, System.app.windows[0].height, 0, true);
		
		vertex  = context3D.createVertexBuffer(3, 7);
		index = context3D.createIndexBuffer(3);
	
		vertex.uploadFromByteArray(vertexData.buffer.getData(), 0, 0, 3);
		index.uploadFromByteArray(indexData.buffer.getData(), 0, 0, 3);
		
		var vertexSource = AgalOut.toAgal(compiledShader.vertex, 2);
		var fragmentSource = AgalOut.toAgal(compiledShader.fragment, 2);
		var opt = new AgalOptim();
		vertexSource = opt.optimize(vertexSource);
		fragmentSource = opt.optimize(fragmentSource);
		
		//Log.info('${format.agal.Tools.toString(vertexSource)}\n\n${format.agal.Tools.toString(fragmentSource)}', 0);
		
		var vBytes = new haxe.io.BytesOutput();
		new format.agal.Writer(vBytes).write(vertexSource);
		var fBytes = new haxe.io.BytesOutput();
		new format.agal.Writer(fBytes).write(fragmentSource);
		
		var vb = vBytes.getBytes().getData();
		var fb = fBytes.getBytes().getData();
		
		program = context3D.createProgram();
		program.upload(vb, fb);
	}
	
	public function render(vertexValues:Float32Array, fragValues:Float32Array) {
		if (context3D == null)
			return;
			
		context3D.clear(backColor.r, backColor.g, backColor.b, backColor.a);
		
		context3D.setVertexBufferAt(0, vertex, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		context3D.setVertexBufferAt(1, vertex, 3, flash.display3D.Context3DVertexBufferFormat.FLOAT_4);
		context3D.setProgram(program);
		
		if (compiledShader.vertex.paramsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.VERTEX, compiledShader.vertex.globalsSize, compiledShader.vertex.paramsSize, vertexValues.buffer.getData(), 0);
		if (compiledShader.fragment.paramsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.FRAGMENT, compiledShader.fragment.globalsSize, compiledShader.fragment.paramsSize, fragValues.buffer.getData(), 0);

		if (compiledShader.vertex.globalsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.VERTEX, 0, compiledShader.vertex.globalsSize, globalVertexParams.buffer.getData(), 0);
		if (compiledShader.fragment.globalsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.FRAGMENT, 0, compiledShader.fragment.globalsSize, globalFragmentParams.buffer.getData(), 0);
		
		context3D.drawTriangles(index);
		
		context3D.present();
	}
}
#end

/**
 * Hxsl usage test without bakeneko render api and using native OpenGl or Stage3D
 */
class HxslTest extends State {
	
	var globals:Globals;
	var cache:Cache;
	var output:Int;
	var shader:TestShader;
	var compiledShader:RuntimeShader;
	
	var vertexParams:Float32Array;
	var fragmentParams:Float32Array;
	var vertTextParams:Array<Texture>;
	var fragTextParams:Array<Texture>;
	var vertexData:Float32Array;
	var indexData:UInt16Array;
	
	var graphics:Graphics;
	var backColor:Color;
	
	var texture:Texture;
	
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

		vertexParams = new Float32Array(compiledShader.vertex.paramsSize << 2);
		fragmentParams = new Float32Array(compiledShader.fragment.paramsSize << 2);

		vertTextParams = [ for (i in 0...compiledShader.vertex.textures2DCount) null ];
		fragTextParams = [ for (i in 0...compiledShader.fragment.textures2DCount) null ];
		
		vertexData = new Float32Array([
			 0.0,  0.5,  0.0,  0.9,	 0.9,  0.83, 1.0, 0.0, 1.0,
			 0.5, -0.5,  0.0,  0.5,	 0.65, 0.75, 1.0, 0.0, 0.0,
			-0.5, -0.5,  0.0,  0.55, 0.87, 1.0,  1.0, 1.0, 0.0
		]);
		indexData = new UInt16Array([0, 1, 2]);
		
		backColor = new Color(0.12, 0.05, 0.16, 1.0);
		
		app.assets.loadTexture({id: AssetManager.assets.textures.colorGrid_png}).onSuccess(function(task) {
			texture = task.result;
			shader.texture = texture;
			graphics = new Graphics(compiledShader, vertexData, indexData, backColor, [texture]);
			app.renderSystem.onRenderEvent.add(render);
		});
	}
	
	override public function onDestroy():Void {
		app.renderSystem.onRenderEvent.remove(render);
	}
	
	override public function onUpdate(delta:Float):Void {
		shader.factor = 0.5 + (Math.cos(Timer.stamp()) * 0.5 + 0.5) * 0.5;
	}
	
	function render(window:Window) {
		setParams();
		
		window.renderer.begin();
		graphics.render(vertexParams, fragmentParams);
		window.renderer.end();
	}
	
	public function setParams() {
		var param = compiledShader.fragment.params;
		var i = 0;
		while (param != null) {
			fragmentParams[param.index] = shader.getParamValue(param.index);
			param = compiledShader.fragment.params.next;
		}
		
		param = compiledShader.vertex.params;
		i = 0;
		while (param != null) {
			vertexParams[param.index] = shader.getParamValue(param.index);
			param = compiledShader.vertex.params.next;
		}
		
		param = compiledShader.fragment.textures2D;
		i = 0;
		while (param != null) {
			fragTextParams[i] = shader.getParamValue(param.index);
			param = compiledShader.fragment.textures2D.next;
		}
		
		param = compiledShader.vertex.textures2D;
		i = 0;
		while (param != null) {
			vertTextParams[i] = shader.getParamValue(param.index);
			param = compiledShader.vertex.textures2D.next;
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
			var uv:Vec2;
		};
		
		var output : {
			var position:Vec4;
			var color:Vec4;
		};
		
		@param var factor:Float;
		@param var texture:Sampler2D;
		@const var constTest:Bool;
		var localTest:Float;
		
		function __init__() {
			localTest = 0.20;
		}
		
		function vertex() {
			output.position = vec4(input.position.xyz * factor * (localTest + 0.75), 1.0);
		}
		
		function fragment() {
			var c = texture.get(input.uv);
			
			if (constTest)
				output.color = c * (input.color * (localTest + 0.8) * factor);
			else
				output.color = input.color;
		}
	}

}