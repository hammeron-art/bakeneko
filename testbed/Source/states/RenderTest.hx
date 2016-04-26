package states;

import bakeneko.core.Window;
import bakeneko.render.IndexBuffer;
import bakeneko.render.MeshTools;
import bakeneko.render.VertexElement;
import bakeneko.render.VertexSemantic;
import bakeneko.state.State;
import bakeneko.render.Pipeline;
import bakeneko.render.Renderer;
import bakeneko.render.VertexData;
import bakeneko.render.VertexStructure;
import bakeneko.render.VertexBuffer;
import bakeneko.render.Color;
import bakeneko.render.MeshData;

class RenderTest extends State {
	
	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var color:Color;
	
	override public function onInit():Void {
		color = Color.fromInt32(0x4b151e);
		
		app.renderSystem.onRenderEvent.add(render);
		
		var renderer:Renderer = cast app.windows[0].renderer;
		
		var structure = new VertexStructure();
		structure.push(new VertexElement(VertexData.TFloat(3), VertexSemantic.SPosition));

		var shader = new PixelColorShader();
		shader.additive = false;
		
		var pipeline = renderer.createPipeline();
		pipeline.vertexStructures = [structure];
		pipeline.addShader(shader);
		
		var data:MeshData = {
			vertexCount: 3,
			positions: [[ -1.0, -1.0, 0.0], [1.0, -1.0, 0.0], [0.0, 1.0, 0.0]],
			indices: [0, 1, 2],
		};
		
		var vertexData = MeshTools.buildVertexData(data, structure);
		
		vertexBuffer = renderer.createVertexBuffer(data.positions.length, structure);
		indexBuffer = renderer.createIndexBuffer(data.indices.length, structure);
		
		var vb = vertexBuffer.lock();
		for (i in 0...vertexData.length)
			vb[i] = i;
		vertexBuffer.unlock();
		
		var ib = indexBuffer.lock();
		for (i in 0...data.indices.length)
			ib[i] = i;
		indexBuffer.unlock();
		
	}
	
	override public function onDestroy():Void {
		app.renderSystem.onRenderEvent.remove(render);
	}
	
	function render(window:Window) {
		var g = window.renderer;
		
		g.begin();
		g.clear(color);
		g.end();
	}
	
}

class PixelColorShader extends bakeneko.hxsl.Shader {

	static var SRC = {
		@input var input: {
			var color:Vec4;
		};

		var pixelColor:Vec4;
		@const var additive:Bool;

		function fragment() {
			if (additive)
				pixelColor += input.color;
			else
				pixelColor *= input.color;
		}
	}

}