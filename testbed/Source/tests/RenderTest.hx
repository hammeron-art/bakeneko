package tests;

import bakeneko.graphics4.Shader;
import bakeneko.core.Window;
import bakeneko.graphics4.Pass;
import bakeneko.graphics4.Renderer;
import bakeneko.graphics4.VertexData;
import bakeneko.graphics4.VertexStructure;
import bakeneko.graphics4.VertexBuffer;
import bakeneko.render.Color;
import bakeneko.render.MeshData;
import bakeneko.state.State;

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