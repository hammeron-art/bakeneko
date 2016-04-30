package states.hxsl;

import bakeneko.hxsl.AgalOptim;
import bakeneko.hxsl.AgalOut;
import bakeneko.hxsl.RuntimeShader;
import bakeneko.render.Color;
import flash.display.Stage3D;
import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.Program3D;
import flash.display3D.VertexBuffer3D;
import lime.utils.Float32Array;
import lime.utils.UInt16Array;


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
	
	public function new(compiledShader:RuntimeShader, vertexData:Float32Array, indexData:UInt16Array, backColor:Color, textures) {
		this.compiledShader = compiledShader;
		this.backColor = backColor;
		
		/*globalVertexParams = new Float32Array(compiledShader.vertex.consts.length << 2);
		for (i in 0...compiledShader.vertex.consts.length)
			globalVertexParams[i] = compiledShader.vertex.consts[i];
			
		globalFragmentParams = new Float32Array(compiledShader.fragment.consts.length << 2);
		for (i in 0...compiledShader.vertex.consts.length)
			globalFragmentParams[i] = compiledShader.fragment.consts[i];*/
		
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
	
	public function render(buffer:ProgramBuffer) {
		if (context3D == null)
			return;
			
		context3D.clear(backColor.r, backColor.g, backColor.b, backColor.a);
		
		context3D.setVertexBufferAt(0, vertex, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		context3D.setVertexBufferAt(1, vertex, 3, flash.display3D.Context3DVertexBufferFormat.FLOAT_4);
		context3D.setProgram(program);
		
		if (compiledShader.vertex.paramsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.VERTEX, compiledShader.vertex.globalsSize, compiledShader.vertex.paramsSize, buffer.vertex.params.buffer.getData(), 0);
		if (compiledShader.fragment.paramsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.FRAGMENT, compiledShader.fragment.globalsSize, compiledShader.fragment.paramsSize, buffer.fragment.params.buffer.getData(), 0);

		buffer.vertex.globals[0] = 1.0;
		if (compiledShader.vertex.globalsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.VERTEX, 0, compiledShader.vertex.globalsSize, buffer.vertex.globals.buffer.getData(), 0);
		if (compiledShader.fragment.globalsSize > 0)
			context3D.setProgramConstantsFromByteArray(flash.display3D.Context3DProgramType.FRAGMENT, 0, compiledShader.fragment.globalsSize, buffer.fragment.globals.buffer.getData(), 0);
		
		context3D.drawTriangles(index);
		
		context3D.present();
	}
}