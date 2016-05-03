package states;

import bakeneko.core.Log;
import bakeneko.core.Window;
import bakeneko.hxsl.Cache;
import bakeneko.hxsl.Globals;
import bakeneko.hxsl.GlslOut;
import bakeneko.hxsl.ShaderList;
import bakeneko.render.IndexBuffer;
import bakeneko.render.Material;
import bakeneko.render.Mesh;
import bakeneko.render.MeshTools;
import bakeneko.render.Pass;
import bakeneko.render.VertexElement;
import bakeneko.render.VertexSemantic;
import bakeneko.state.State;
import bakeneko.render.RenderState;
import bakeneko.render.Renderer;
import bakeneko.render.VertexData;
import bakeneko.render.VertexStructure;
import bakeneko.render.VertexBuffer;
import bakeneko.render.Color;
import bakeneko.render.MeshData;
import haxe.Timer;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;

class RenderTest extends State {
	
	var color:Color;
	var mesh:Mesh;
	var shader:PixelColorShader;
	
	override public function onInit():Void {
		color = Color.fromInt32(0xff4b151e);
		
		var structure = new VertexStructure();
		structure.push(new VertexElement(VertexData.TFloat(3), VertexSemantic.SPosition));
		structure.push(new VertexElement(VertexData.TFloat(4), VertexSemantic.SColor));
		
		var renderState = new RenderState();
		renderState.vertexStructures = [structure];
		
		shader = new PixelColorShader();
		shader.factor = 1.0;
		
		var pass = new Pass();
		pass.state = renderState;
		pass.addShader(shader);
		
		var material = new Material(pass);
		
		var data:MeshData = {
			vertexCount: 3,
			positions: [[ -1.0, -1.0, 0.0], [1.0, -1.0, 0.0], [0.0, 1.0, 0.0]],
			colors: [[1.0, 0.0, 0.0, 1.0], [0.0, 1.0, 0.0, 1.0], [0.0, 0.0, 1.0, 1.0]],
			indices: [0, 1, 2],
			structure: structure
		};
		
		mesh = new Mesh(data, material, structure);
		
		app.renderSystem.onRenderEvent.add(render);
	}
	
	override public function onDestroy():Void {
		app.renderSystem.onRenderEvent.remove(render);
	}
	
	override public function onUpdate(delta:Float):Void {
		shader.factor = 0.5 + (Math.cos(Timer.stamp()) * 0.5 + 0.5) * 0.5;
	}
	
	@:access(bakeneko.render.Renderer)
	function render(window:Window) {
		var g = window.renderer;
		  
		g.begin();
		g.clear(color);
		
		mesh.draw();
		
		g.end();
	}
	
}

class PixelColorShader extends bakeneko.hxsl.Shader {

	static var SRC = {
		@input var input: {
			var position:Vec3;
			var color:Vec4;
		};

		var output: {
			var position:Vec4;
			var color:Vec4;
		}

		@param var factor:Float;
		
		function vertex() {
			output.position = vec4(input.position * factor, 1.0);
		}
		
		function fragment() {
			output.color = input.color;
		}
	}

}