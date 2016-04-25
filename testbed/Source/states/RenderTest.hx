package states;

import bakeneko.core.Window;
import bakeneko.state.State;
import bakeneko.render.Pass;
import bakeneko.render.Renderer;
import bakeneko.render.VertexData;
import bakeneko.render.VertexStructure;
import bakeneko.render.VertexBuffer;
import bakeneko.render.Color;
import bakeneko.render.MeshData;

class RenderTest extends State {
	
	var vertexBuffer:VertexBuffer;
	var color:Color;
	
	override public function onInit():Void {
		color = Color.fromInt32(0x4b151e);
		
		app.renderSystem.onRenderEvent.add(render);
		
		var renderer:Renderer = cast app.windows[0].renderer;
		
		var structure = new VertexStructure();
		structure.add("pos", VertexData.Float3);

		var pass = renderer.createPass();
		//pass.addShader(renderer.createShader());
		
		var data:MeshData = {
			positions: [[ -1.0, -1.0, 0.0], [1.0, -1.0, 0.0], [0.0, 1.0, 0.0]],
			indices: [0, 1, 2],
		};
		
		vertexBuffer = renderer.createVertexBuffer(data.indices.length, structure);
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