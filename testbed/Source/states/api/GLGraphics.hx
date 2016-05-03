package states.api;

import bakeneko.asset.Texture;
import bakeneko.core.Log;
import bakeneko.hxsl.GlslOut;
import bakeneko.hxsl.RuntimeShader;
import bakeneko.render.Color;
import bakeneko.render.Effect;
import bakeneko.render.Mesh;
import bakeneko.render.MeshData;
import bakeneko.render.MeshTools;
import bakeneko.render.Renderer;
import bakeneko.render.VertexStructure;
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.graphics.opengl.GLProgram;
import lime.graphics.opengl.GLTexture;
import lime.graphics.opengl.GLUniformLocation;
import lime.utils.Float32Array;
import lime.utils.Int32Array;
import lime.utils.UInt16Array;
import lime.utils.UInt32Array;
import bakeneko.render.ProgramBuffer;


class GLGraphics implements IGraphics {
	
	var compiledShader:RuntimeShader;
	
	//var program:GLProgram;
	var mesh:Mesh;
	var effect:Effect;
	
	var backColor:Color;
	
	public function new(compiledShader:RuntimeShader, mesh:Mesh, backColor: Color, effect:Effect) {
		this.compiledShader = compiledShader;
		this.backColor = backColor;
		this.mesh = mesh;
		this.effect = effect;
		
		var out = new GlslOut();
		var vertexSource = out.run(compiledShader.vertex.data);
		var fragmentSource = out.run(compiledShader.fragment.data);
		
		Log.info('$vertexSource\n\n$fragmentSource', 0);
		
		@:privateAccess
		GL.useProgram(effect.program);
	}
	
	public function render(render:Renderer, buffer:ProgramBuffer) {
		
		render.applyEffect(effect, buffer);
		
		render.begin();
		render.clear(backColor);
		//GL.clearColor(backColor.r, backColor.g, backColor.b, backColor.a);
		//GL.clear(GL.COLOR_BUFFER_BIT);
		
		@:privateAccess {
			render.drawBuffer(mesh.meshBuffer.vertexBuffer, mesh.meshBuffer.indexBuffer);
		}
		
		render.end();
	}

}