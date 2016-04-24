package tests;

import bakeneko.core.Window;
import bakeneko.state.State;
import bakeneko.render.Shader;
import bakeneko.render.Pass;
import bakeneko.render.Renderer;
import bakeneko.render.VertexData;
import bakeneko.render.VertexStructure;
import bakeneko.render.VertexBuffer;
import bakeneko.render.Color;
import bakeneko.render.MeshData;

class RenderTest extends State {
	
	var vertexBuffer:VertexBuffer;
	
	override public function onInit():Void {
		app.renderSystem.onRenderEvent.add(render);
		
		var renderer:Renderer = cast app.windows[0].renderer;
		
		var structure = new VertexStructure();
		structure.add("pos", VertexData.Float3);
		
		vertexBuffer = renderer.createVertexBuffer(structure);
		
		var pass = renderer.createPass();
		pass.addShader(renderer.createShader());
		
		var data:MeshData = {
			positions: [[ -1.0, -1.0, 0.0], [1.0, -1.0, 0.0], [0.0, 1.0, 0.0]],
			indices: [0, 1, 2],
		};
	}
	
	function render(window:Window) {
		var g = window.renderer;
		
		g.begin();
		
		g.clear(Color.fromInt32(0x1c1d23));
		
		g.end();
	}
	
}