package states.hxsl;

import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.hxsl.AgalOptim;
import bakeneko.hxsl.AgalOut;
import bakeneko.hxsl.RuntimeShader;
import bakeneko.render.Color;
import bakeneko.render.MeshData;
import bakeneko.render.MeshTools;
import bakeneko.render.VertexStructure;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import haxe.io.UInt32Array;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;
import lime.utils.UInt8Array;


class FlashGraphics implements IGraphics {
	
	var compiledShader:RuntimeShader;
	
	var stage3D:Stage3D;
	var context3D:Context3D;
	
	var program:Program3D;
	var vertex:VertexBuffer3D;
	var index:IndexBuffer3D;
	var location:Int;
	
	//var globalVertexParams:Float32Array;
	//var globalFragmentParams:Float32Array;
	var backColor:Color;
	
	var fragmentParams:flash.Vector<Float>;
	var vertexParams:flash.Vector<Float>;
	
	var tex:flash.display3D.textures.Texture;
	
	public function new(compiledShader:RuntimeShader, data:MeshData, backColor:Color) {
		this.compiledShader = compiledShader;
		this.backColor = backColor;
		
		/*globalVertexParams = new Float32Array(compiledShader.vertex.consts.length << 2);
		for (i in 0...compiledShader.vertex.consts.length)
			globalVertexParams[i] = compiledShader.vertex.consts[i];
			
		globalFragmentParams = new Float32Array(compiledShader.fragment.consts.length << 2);
		for (i in 0...compiledShader.vertex.consts.length)
			globalFragmentParams[i] = compiledShader.fragment.consts[i];*/
			
		stage3D = flash.Lib.current.stage.stage3Ds[0];
		init(null, data);
		//stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, init.bind(_, data));
		//stage3D.requestContext3D(cast flash.display3D.Context3DRenderMode.AUTO, flash.display3D.Context3DProfile.STANDARD);
	}
	
	public function init(_, data:MeshData) {
		@:privateAccess
		context3D = Application.get().windows[0].renderer.context;
		//context3D = stage3D.context3D;
		//context3D.configureBackBuffer(System.app.windows[0].width, System.app.windows[0].height, 0, true);
		
		var vertexData = MeshTools.buildVertexData(data);
		var indexData = new UInt16Array(data.indices);
		
		vertex  = context3D.createVertexBuffer(data.vertexCount, data.structure.totalNumValues);
		index = context3D.createIndexBuffer(data.vertexCount);
	
		vertex.uploadFromByteArray(vertexData.buffer.getData(), 0, 0, 3);
		index.uploadFromByteArray(indexData.buffer.getData(), 0, 0, 3);
		
		var vertexSource = AgalOut.toAgal(compiledShader.vertex, 2);
		var fragmentSource = AgalOut.toAgal(compiledShader.fragment, 2);
		var opt = new AgalOptim();
		vertexSource = opt.optimize(vertexSource);
		fragmentSource = opt.optimize(fragmentSource);
		
		Log.info('${format.agal.Tools.toString(vertexSource)}\n\n${format.agal.Tools.toString(fragmentSource)}', 0);
		
		var vBytes = new haxe.io.BytesOutput();
		new format.agal.Writer(vBytes).write(vertexSource);
		var fBytes = new haxe.io.BytesOutput();
		new format.agal.Writer(fBytes).write(fragmentSource);
		
		var vb = vBytes.getBytes().getData();
		var fb = fBytes.getBytes().getData();
		
		program = context3D.createProgram();
		program.upload(vb, fb);
		context3D.setProgram(program);
		
		/*var flashSize = [
			flash.display3D.Context3DVertexBufferFormat.FLOAT_1,
			flash.display3D.Context3DVertexBufferFormat.FLOAT_2,
			flash.display3D.Context3DVertexBufferFormat.FLOAT_3,
			flash.display3D.Context3DVertexBufferFormat.FLOAT_4,
		];
		
		var i = 0;
		var offset = 0;
		for (element in data.structure.elements) {
			var size = element.numData();
			
			context3D.setVertexBufferAt(i, vertex, offset, flashSize[i]);
			//GL.vertexAttribPointer(i, size, GL.FLOAT, false, data.structure.totalSize, offset * 4);
			//GL.enableVertexAttribArray(i);
			
			offset += size;
			++i;
		}*/
		
		/*var width = 1024;
		var height = 1024;
		tex = context3D.createTexture(width, height, flash.display3D.Context3DTextureFormat.BGRA, false);
		var data = new UInt8Array(width * height * 4);
		for (i in 0...data.length)
			data[i] = Std.int(Math.random() * 255);
		tex.uploadFromByteArray(data.toBytes().getData(), 0, 0);*/
	}
	
	public function render(buffer:ProgramBuffer) {
		if (context3D == null)
			return;
			
		context3D.clear(backColor.r, backColor.g, backColor.b, backColor.a);
		
		//context3D.setProgram(program);
		context3D.setVertexBufferAt(0, vertex, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		context3D.setVertexBufferAt(1, vertex, 3, flash.display3D.Context3DVertexBufferFormat.FLOAT_4);
		context3D.setVertexBufferAt(2, vertex, 7, flash.display3D.Context3DVertexBufferFormat.FLOAT_2);
		//context3D.setProgram(program);
		
		
		if (compiledShader.vertex.paramsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.VERTEX, compiledShader.vertex.globalsSize, compiledShader.vertex.paramsSize, buffer.vertex.params.buffer.getData(), 0);
		if (compiledShader.fragment.paramsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.FRAGMENT, compiledShader.fragment.globalsSize, compiledShader.fragment.paramsSize, buffer.fragment.params.buffer.getData(), 0);

		//buffer.vertex.globals[0] = 1.0;
		if (compiledShader.vertex.globalsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.VERTEX, 0, compiledShader.vertex.globalsSize, buffer.vertex.globals.buffer.getData(), 0);
		if (compiledShader.fragment.globalsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.FRAGMENT, 0, compiledShader.fragment.globalsSize, buffer.fragment.globals.buffer.getData(), 0);

		for (i in 0...compiledShader.fragment.textures2DCount) {
			@:privateAccess
			context3D.setTextureAt(i, buffer.fragment.textures[i].nativeTexture.texture);
			context3D.setSamplerStateAt(i, flash.display3D.Context3DWrapMode.REPEAT, flash.display3D.Context3DTextureFilter.NEAREST, flash.display3D.Context3DMipFilter.MIPNONE);
		}
		/*if (tex == null) {
			var width = 1024;
			var height = 1024;
			
			tex = context3D.createTexture(width, height, flash.display3D.Context3DTextureFormat.BGRA, false);
			var data = new UInt8Array(width * height * 4);
			for (i in 0...data.length)
				data[i] = Std.int(Math.random() * 255);
			@:privateAccess
			tex.uploadFromByteArray(buffer.fragment.textures[0].image.data.toBytes().getData(), 0, 0);
		}*/
		//@:privateAccess
		//trace(buffer.fragment.textures[0].nativeTexture.texture.);
		//@:privateAccess
		//context3D.setTextureAt(0, tex);
		//context3D.setTextureAt(0, buffer.fragment.textures[0].nativeTexture.texture);
			
		context3D.drawTriangles(index);
		
		context3D.present();
	}
}