package states;

import bakeneko.core.Log;
import bakeneko.core.Window;
import bakeneko.hxsl.Cache;
import bakeneko.hxsl.Globals;
import bakeneko.hxsl.GlslOut;
import bakeneko.hxsl.ShaderList;
import bakeneko.render.IndexBuffer;
import bakeneko.render.MeshTools;
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
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLProgram;

class RenderTest extends State {
	
	var vertexBuffer:VertexBuffer;
	var indexBuffer:IndexBuffer;
	var color:Color;
	var renderState:RenderState;
	var program:GLProgram;
	
	override public function onInit():Void {
		color = Color.fromInt32(0x4b151e);
		
		app.renderSystem.onRenderEvent.add(render);
		
		var renderer:Renderer = cast app.windows[0].renderer;
		
		var structure = new VertexStructure();
		structure.push(new VertexElement(VertexData.TFloat(3), VertexSemantic.SPosition));

		var shader = new PixelColorShader();
		shader.additive = false;
		
		renderState = new RenderState();
		renderState.vertexStructures = [structure];
		
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
		
		var cache = Cache.get();
		var globals = new Globals();
		var output = cache.allocOutputVars(['pixelColor']);
		trace('pixel');
		function compileShaders(shaders:ShaderList) {
			for (shader in shaders)
				shader.updateConstants(globals);
			return cache.link(shaders, output);
		}
		
		var compiled = compileShaders(new ShaderList(shader));

		var vertexSource = GlslOut.toGlsl(compiled.vertex.data);
		var fragmentSource = GlslOut.toGlsl(compiled.fragment.data);
		
		var vertex = GL.createShader(GL.VERTEX_SHADER);
		var fragment = GL.createShader(GL.FRAGMENT_SHADER);
		GL.shaderSource(vertex, vertexSource);
		GL.shaderSource(fragment, fragmentSource);
		GL.compileShader(vertex);
		GL.compileShader(fragment);
		
		program = GL.createProgram();
		GL.attachShader(program, vertex);
		GL.attachShader(program, fragment);

		GL.linkProgram(program);

		if (GL.getProgramParameter(program, GL.LINK_STATUS) == 0)
		{
			Log.error(GL.getProgramInfoLog(program));
			GL.deleteProgram(program);
		}
		
		GL.useProgram(program);
	}
	
	override public function onDestroy():Void {
		app.renderSystem.onRenderEvent.remove(render);
	}
	
	function render(window:Window) {
		var g = window.renderer;
		g.setRenderState(renderState);
		
		g.begin();
		g.clear(color);
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);
		
		GL.drawElements(GL.TRIANGLES, 3, GL.UNSIGNED_SHORT, 0);
		
		g.end();
	}
	
}

class PixelColorShader extends bakeneko.hxsl.Shader {

	static var SRC = {
		@input var input: {
			var color:Vec3;
		};

		var pixelColor:Vec4;
		@const var additive:Bool;

		function fragment() {
			if (additive)
				pixelColor += vec4(input.color, 1.0);
			else
				pixelColor *= vec4(input.color, 1.0);
		}
	}

}