package states.api;

import bakeneko.core.Application;
import bakeneko.core.Log;
import bakeneko.hxsl.AgalOptim;
import bakeneko.hxsl.AgalOut;
import bakeneko.hxsl.RuntimeShader;
import bakeneko.render.Color;
import bakeneko.render.Effect;
import bakeneko.render.Mesh;
import bakeneko.render.MeshData;
import bakeneko.render.MeshTools;
import bakeneko.render.Renderer;
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
import bakeneko.render.ProgramBuffer;


class FlashGraphics implements IGraphics {
	
	var compiledShader:RuntimeShader;
	
	var stage3D:Stage3D;
	var context3D:Context3D;
	
	var effect:Effect;
	//var vertex:VertexBuffer3D;
	//var index:IndexBuffer3D;
	var mesh:Mesh;
	var location:Int;
	
	//var globalVertexParams:Float32Array;
	//var globalFragmentParams:Float32Array;
	var backColor:Color;
	
	var fragmentParams:flash.Vector<Float>;
	var vertexParams:flash.Vector<Float>;
	
	var tex:flash.display3D.textures.Texture;
	
	public function new(compiledShader:RuntimeShader, mesh:Mesh, backColor:Color, effect:Effect) {
		this.compiledShader = compiledShader;
		this.backColor = backColor;
		this.effect = effect;
		
		stage3D = flash.Lib.current.stage.stage3Ds[0];
		init(null, mesh);
	}
	
	public function init(_, mesh:Mesh) {
		@:privateAccess
		context3D = Application.get().windows[0].renderer.context;
		
		this.mesh = mesh;
		
		var vertexSource = AgalOut.toAgal(compiledShader.vertex, 2);
		var fragmentSource = AgalOut.toAgal(compiledShader.fragment, 2);
		var opt = new AgalOptim();
		vertexSource = opt.optimize(vertexSource);
		fragmentSource = opt.optimize(fragmentSource);
		
		Log.info('${format.agal.Tools.toString(vertexSource)}\n\n${format.agal.Tools.toString(fragmentSource)}', 0);
		
		//@:privateAccess
		//context3D.setProgram(effect.program);
	}
	
	public function render(render:Renderer, buffer:ProgramBuffer) {
		if (context3D == null)
			return;
		
		//context3D.clear(backColor.r, backColor.g, backColor.b, backColor.a);
		//render.begin();
		render.clear(backColor);
		
		render.applyEffect(effect, buffer);
		
		@:privateAccess {
			render.drawBuffer(mesh.meshBuffer.vertexBuffer, mesh.meshBuffer.indexBuffer);
		}
		
		context3D.present();
	}
}